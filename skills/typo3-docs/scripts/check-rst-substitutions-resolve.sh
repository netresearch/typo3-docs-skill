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
# Only names defined in an include file (Documentation/**/*.rst.txt) are
# checked. Literal blocks, code-ish directives, comments, ``inline literals``
# and `interpreted text` are stripped first, because a substitution is not
# expanded there. Each page is judged on its own.
set -euo pipefail

[ -d Documentation ] || exit 0

defs=$(find Documentation -name '*.rst.txt' -not -path '*GENERATED*' -print0 \
  | xargs -0 -r perl -ne 'print "$1\n" if /^\.\.\s+\|([^|]+)\|\s+\S+::/' | sort -u)
[ -n "$defs" ] || exit 0

rc=0
find Documentation -name '*.rst' -not -path '*GENERATED*' -print0 \
  | INCLUDE_DEFS="$defs" xargs -0 -r perl -e '
    my %inc = map { $_ => 1 } grep { length } split /\n/, $ENV{INCLUDE_DEFS};
    my $found = 0;
    for my $file (@ARGV) {
        open my $fh, "<", $file or next;
        my @lines = <$fh>;
        close $fh;
        my (%local, @keep);
        my $block = -1;    # indent of the line opening a literal block, -1 = none
        for my $l (@lines) {
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
            next if $l =~ /^\s*\.\.(\s|$)/;    # comment or other directive line
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
# xargs reports a child exit of 1 as 123. Anything else non-zero is the
# checker failing, not a finding, and must not read as one.
case "$rc" in
  0) exit 0 ;;
  123) exit 1 ;;
  *) echo "check-rst-substitutions-resolve: scan failed (xargs exit $rc)" >&2; exit 2 ;;
esac
