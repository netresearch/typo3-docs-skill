#!/usr/bin/env bash
# The perl programs are single-quoted on purpose; their $ belong to perl.
# shellcheck disable=SC2016
# TD-46: a page must not use a substitution that only an included file defines.
#
# render-guides (0.40.2, the image typo3-ci-workflows' docs.yml pins, and the
# :latest of 2026-09-23) does not carry `.. |name| replace::` definitions from an
# `.. include::`d file into the including page. The page renders the literal
# text `|name|` and the log says
#   app.WARNING: No replacement was found for variable |name|
# for every include form tried (`/Includes.rst.txt`, `../Includes.rst.txt`, an
# included `.rst`). A definition on the page itself renders; so do the
# guides.xml built-ins (|release|, |version|, |project|, |today|), which are not
# defined in any include file and therefore never reported here.
#
# Only names defined in an included file are checked: any
# Documentation/**/*.rst.txt, and any file an `.. include::` names (an included
# `.rst` fails the same way). Literal blocks, code-ish directives, comments, ``inline literals``
# and `interpreted text` are stripped first, because a substitution is not
# expanded there. Each page is judged on its own.
set -euo pipefail

[ -d Documentation ] || exit 0

# One perl process over the whole tree (xargs could split the list, and an
# include in one batch would then not be seen in another). Definitions count
# as "included" when they sit in a *.rst.txt file or in any file that an
# `.. include::` names, resolved like render-guides does: `/x` from
# Documentation/, anything else relative to the including file.
rc=0
find Documentation \( -name '*.rst' -o -name '*.rst.txt' \) -not -path '*GENERATED*' -print0 \
  | perl -0 -MCwd=abs_path -MFile::Basename=dirname -e '
    my @files = <STDIN>;
    chomp @files;
    my $root = abs_path("Documentation");
    my (%src, %text);
    for my $file (@files) {
        open my $fh, "<", $file or next;
        local $/ = "\n";
        my @lines = <$fh>;
        close $fh;
        $text{$file} = \@lines;
        $src{abs_path($file)} = 1 if $file =~ /\.rst\.txt$/;
        for (@lines) {
            next unless /^\s*\.\.\s+include::\s+(\S+)/;
            my $t = $1;
            my $a = abs_path($t =~ m{^/} ? "$root$t" : dirname($file) . "/$t");
            $src{$a} = 1 if defined $a && -f $a;
        }
    }
    my %inc;
    for my $file (keys %text) {
        next unless $src{abs_path($file)};
        for (@{ $text{$file} }) { $inc{$1} = 1 if /^\.\.\s+\|([^|]+)\|\s+\S+::/; }
    }
    exit 0 unless %inc;
    my $found = 0;
    for my $file (sort grep { /\.rst$/ } keys %text) {
        my (%local, @keep);
        my $block = -1;    # indent of the line opening a literal block, -1 = none
        for my $l (@{ $text{$file} }) {
            if ($l =~ /^\.\.\s+\|([^|]+)\|\s+\S+::/) { $local{$1} = 1; next; }
            (my $ind = $l) =~ s/^(\s*).*/length($1)/se;
            if ($block >= 0) {
                if ($l =~ /^\s*$/ || $ind > $block) { next; }
                $block = -1;
            }
            if ($l =~ /^(\s*)\.\.\s+(code-block|code|sourcecode|literalinclude|uml|raw)::/
                || ($l =~ /::\s*$/ && $l !~ /^\s*\.\.\s/)) {
                $block = length(($l =~ /^(\s*)/)[0]);
                $l =~ s/::\s*$/\n/;
                push @keep, $l if $l !~ /^\s*\.\./;
                next;
            }
            if ($l =~ /^(\s*)\.\.(\s|$)/) {
                # A comment, i.e. not a directive, target, substitution definition,
                # footnote or citation: render-guides drops its indented body.
                $block = length($1)
                    if $l !~ /^\s*\.\.\s+(?:\S+::(?:\s|$)|_|\||\[)/;
                next;
            }
            push @keep, $l;
        }
        my $text = join "", @keep;
        $text =~ s/``.*?``//gs;
        $text =~ s/`[^`]*`_{0,2}//gs;
        my %seen;
        while ($text =~ /(?<![\w|])\|([^|\s](?:[^|]*[^|\s])?)\|(?=_{0,2}(?![\w|]))/g) {
            my $n = $1;
            next unless $inc{$n} && !$local{$n} && !$seen{$n}++;
            print "$file: |$n| is defined only in an included file and renders as literal text; define it on this page or write the value\n";
            $found = 1;
        }
    }
    exit $found;
  ' || rc=$?
# 1 is a finding. Anything else non-zero is the checker failing; it exits 2
# with the reason on stderr. automated-assessment's run-checkpoints.sh reports
# every non-zero exit of a script as `fail` and discards its output, so there
# a failed scan looks like a finding; only a direct run tells them apart.
case "$rc" in
  0) exit 0 ;;
  1) exit 1 ;;
  *) echo "check-rst-substitutions-resolve: scan failed (perl exit $rc)" >&2; exit 2 ;;
esac
