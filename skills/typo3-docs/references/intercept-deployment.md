# TYPO3 Intercept Deployment & Webhook Setup

Automatic documentation deployment to docs.typo3.org via TYPO3 Intercept.
**Canonical source (wins on conflict — see `canonical-sources.md`):**

- [Webhook setup](https://docs.typo3.org/m/typo3/docs-how-to-document/main/en-us/Howto/WritingDocForExtension/Webhook.html) `[upstream]` — prerequisites (TER registration, repo referenced in TER, `Documentation/` structure), the exact GitHub/GitLab webhook settings for `https://docs-hook.typo3.org`, and additionally **Bitbucket Cloud** setup
- [Documentation for extensions](https://docs.typo3.org/m/typo3/docs-how-to-document/main/en-us/Howto/WritingDocForExtension/Index.html) `[upstream]` — Documentation-Team approval requirement, the published URL pattern, and the **`documentation-draft`** branch (renders to `/p/<vendor>/<package>/draft/en-us/`)

Follow the upstream pages for registration and setup — they are more complete
than any copy here. This file keeps only what upstream does not cover: the
`gh` CLI automation, delivery-verification semantics, and observed failure
modes (`[regression]`).

## GitHub CLI Automation `[skill-procedure]`

For faster setup using `gh` CLI:

```bash
# Create webhook
gh api repos/{owner}/{repo}/hooks \
  --method POST \
  --field name=web \
  --field "config[url]=https://docs-hook.typo3.org" \
  --field "config[content_type]=json" \
  --field "config[insecure_ssl]=0" \
  --raw-field "events[]=push" \
  --field active=true

# Trigger test delivery
gh api repos/{owner}/{repo}/hooks/{hook_id}/tests --method POST

# Check delivery status
gh api repos/{owner}/{repo}/hooks/{hook_id}/deliveries \
  --jq '.[] | {id: .id, status: .status, status_code: .status_code, event: .event}'

# List webhooks to find hook_id
gh api repos/{owner}/{repo}/hooks --jq '.[] | {id: .id, url: .config.url}'
```

## First-Time Approval `[upstream]`

The first webhook trigger is held until the TYPO3 Documentation Team approves
the repository — see
[Documentation for extensions](https://docs.typo3.org/m/typo3/docs-how-to-document/main/en-us/Howto/WritingDocForExtension/Index.html).
Observed approval time: 1-3 business days. Check the Intercept dashboard for
status.

## Verification

### Check Webhook Delivery

**GitHub:**
1. Go to **Settings** → **Webhooks**
2. Click on the webhook
3. Scroll to **Recent Deliveries**
4. Verify delivery shows `200` or `204` response code

**Expected Status Codes** `[regression]` — upstream documents no
response-code semantics; these are verified against real deliveries:

| Code | Meaning |
|------|---------|
| `200` | Success (ping events) |
| `204` | Success (push events accepted) |
| `412` | Precondition Failed - expected on first-time test pushes before approval |

> **Note**: A `412` error on test push delivery is normal for repositories not yet approved. The actual push after commits will trigger the approval workflow.

**GitLab:**
1. Go to **Settings** → **Webhooks**
2. Click **Edit** on the webhook
3. Scroll to **Recent events**
4. Verify event shows success status

### Check Intercept Dashboard

1. **Visit**: https://intercept.typo3.com/
2. **Check Recent Actions**: View recent webhook triggers
3. **Documentation Deployments**: https://intercept.typo3.com/admin/docs/deployments
4. **Search for Your Extension**: Filter by package name

### Verify Published Documentation

URL pattern `[upstream]`: `https://docs.typo3.org/p/{vendor}/{extension}/{branch-or-version}/en-us/`
(e.g. `https://docs.typo3.org/p/netresearch/rte-ckeditor-image/main/en-us/`);
a `documentation-draft` branch renders to `/draft/en-us/`.

## Triggering Documentation Builds

### Automatic Triggers

Documentation builds are triggered automatically by:

1. **Git Push to Main/Master**
   ```bash
   git push origin main
   ```

2. **Version Tags**
   ```bash
   git tag 2.1.0
   git push origin 2.1.0
   ```

3. **Branch Push** (for multi-version documentation)
   ```bash
   git push origin docs-v12
   ```

### Manual Trigger

If automatic builds fail or you need to rebuild:

1. Visit: https://intercept.typo3.com/admin/docs/deployments
2. Find your extension
3. Click **Redeploy** button
4. Monitor build progress in Recent actions

## Build Process

Understanding the rendering pipeline:

1. **Webhook Received**: Intercept receives push notification
2. **Queue Job**: Build job added to rendering queue
3. **Clone Repository**: Code checked out at specific commit/tag
4. **Render Documentation**: Using `ghcr.io/typo3-documentation/render-guides:latest`
5. **Publish**: Rendered HTML published to docs.typo3.org
6. **Index**: Documentation indexed for search

**Typical Build Time**: 2-5 minutes

## Troubleshooting

### Webhook Not Triggering

**Check**:
- Webhook URL is exactly `https://docs-hook.typo3.org`
- SSL verification is enabled
- Webhook is marked as "Active"
- Recent deliveries show `200` response

**Fix**:
1. Edit webhook settings
2. Verify URL and SSL settings
3. Click **Redeliver** on failed delivery
4. Check Intercept Recent actions

### Build Failing

**Common Issues**:

1. **RST Syntax Errors**
   ```bash
   # Validate locally before pushing
   scripts/validate_docs.sh
   ```

2. **Missing Configuration File**
   ```bash
   # Check for guides.xml (modern) or Settings.cfg (legacy)
   ls -la Documentation/guides.xml Documentation/Settings.cfg
   ```

3. **Invalid Cross-References**
   - Render locally to check for broken `:ref:` links
   - Fix undefined labels

4. **Encoding Issues**
   - Ensure all files are UTF-8 encoded
   - Check for BOM (Byte Order Mark) issues

### First Build Stuck "On Hold"

**Expected Behavior**: First build requires manual approval

**Action**:
- Wait for Documentation Team review (1-3 business days)
- Ensure TER registration is complete
- Verify Git repository URL in TER matches webhook source

**Speed Up Approval**:
- Post in TYPO3 Slack [#typo3-documentation](https://typo3.slack.com/archives/C028JEPJL)
- Reference your extension key and repository URL

### Documentation Not Updating

**Check**:
1. **Build Status**: Visit Intercept dashboard, verify build succeeded
2. **Cache**: Browser cache might show old version
   - Hard refresh: `Ctrl+F5` / `Cmd+Shift+R`
   - Try incognito/private mode
3. **Correct URL**: Verify you're visiting the right branch/version URL

**Fix**:
1. Trigger manual rebuild from Intercept dashboard
2. Check build logs for errors
3. Verify `guides.xml` or `Settings.cfg` has correct project configuration

### Version-Tag Webhook Returns HTTP 500 (typo3.org-side outage) `[regression]`

A release can be blocked by an Intercept **server-side** failure that affects only
the **version-tag** webhook while `main` pushes keep rendering fine. The
`refs/tags/vX.Y.Z` delivery to `https://docs-hook.typo3.org` returns **HTTP 500**
(GitHub delivered it fine — the 500 comes back *from* Intercept), so **no render
run is ever created** for the tag. If your release pipeline has a "verify docs
rendered" step (e.g. `release.yml`'s `verify-docs` job), it then fails with a
**misleading message** such as *"Failed to list render workflow runs"* / *"every
jobs API query failed"* — the real cause is not an API problem, it is that **no
render run exists to find**. Don't chase the API error; check the webhook delivery.

**Diagnose** — read the tag delivery's response status directly:

```bash
REPO=owner/repo
# 1. Find the docs-hook.typo3.org webhook id
HOOK=$(gh api "repos/$REPO/hooks" \
  --jq '.[] | select(.config.url | contains("docs-hook.typo3.org")) | .id')

# 2. List recent deliveries and their status codes.
#    IMPORTANT: parse delivery ids with Python, NOT jq — the ids are 19-digit
#    integers and jq silently loses precision, so a jq-extracted id 404s.
#    --slurp wraps each --paginate page into one outer array (each page is a
#    separate JSON document otherwise, which breaks a single json.load()).
gh api "repos/$REPO/hooks/$HOOK/deliveries" --paginate --slurp \
  | python3 -c 'import json,sys
for page in json.load(sys.stdin):
    for d in page:
        print(d["id"], d["status_code"], d.get("event"), d.get("action") or "")'
# A tag push showing status_code 500 (while main pushes show 200) confirms the
# typo3.org-side outage.
```

**Recover** (once typo3.org's Intercept is healthy again — this is *their* fix,
not yours; retrying while it is down just reproduces the 500):

```bash
# Redeliver the failed tag webhook (DID = the 19-digit delivery id from above)
DID=<deliveryId>
gh api -X POST "repos/$REPO/hooks/$HOOK/deliveries/$DID/attempts"
# Then re-run the release pipeline's failed jobs so verify-docs finds the run
gh run rerun <releaseRunId> --failed
```

Main-branch pushes rendering fine while only the version tag 500s is the signature
of this outage — it is not a fault in your `guides.xml`, tag, or release workflow.

## Best Practices

### Pre-Push Checklist

Before pushing documentation changes:

✅ **Validate RST Syntax**
```bash
scripts/validate_docs.sh /path/to/project
```

✅ **Render Locally**
```bash
scripts/render_docs.sh /path/to/project
open Documentation-GENERATED-temp/Index.html
```

✅ **Check for Warnings**
- No rendering warnings
- No broken cross-references
- All code blocks have language specified
- UTF-8 emoji icons render correctly

✅ **Commit Message**
```bash
git commit -m "docs: update configuration guide with new settings"
```

### Version Management

**Branching Strategy**:
- `main` / `master`: Latest development documentation
- Version tags: Specific release documentation (e.g., `2.1.0`, `3.0.0`)
- Version branches: Long-term support versions (e.g., `docs-v12`, `docs-v11`)

**Tag Documentation Builds**:
```bash
# Create release tag
git tag -a 2.1.0 -m "Release 2.1.0"
git push origin 2.1.0

# Documentation auto-builds for version 2.1.0
# Published at: /p/{vendor}/{ext}/2.1.0/en-us/
```

### Multi-Version Documentation `[upstream]`

Branch-based multi-version rendering (each pushed branch/tag publishes its own
version) is covered by the upstream pages linked in the header; rendering is
triggered only for the pushed version. Keep `guides.xml` `version`/`release`
in sync per branch (checkpoint TD-30).

## Security Considerations

### Webhook Secret (Optional)

While TYPO3 Intercept doesn't require webhook secrets, you can add them for extra security:

**GitHub**:
1. Generate random secret: `openssl rand -hex 20`
2. Add to webhook **Secret** field
3. Intercept validates using X-Hub-Signature header

**GitLab**:
1. Generate random secret
2. Add to webhook **Secret token** field
3. Intercept validates using X-Gitlab-Token header

### Access Control

**Documentation Repositories Should**:
- Be publicly readable (required for Intercept access)
- Limit push access to trusted contributors
- Use branch protection for `main`/`master`
- Require pull request reviews for documentation changes

**Avoid in Documentation**:
- API keys, passwords, secrets
- Internal URLs, server hostnames
- Sensitive configuration details
- Personal information

## Resources

**Official Documentation**:
- [How to Document - Webhook Setup](https://docs.typo3.org/m/typo3/docs-how-to-document/main/en-us/Howto/WritingDocForExtension/Webhook.html)
- [TYPO3 Intercept Dashboard](https://intercept.typo3.com/)
- [Documentation Deployments](https://intercept.typo3.com/admin/docs/deployments)

**Community Support**:
- TYPO3 Slack: [#typo3-documentation](https://typo3.slack.com/archives/C028JEPJL)
- TYPO3 Slack: [#typo3-cms](https://typo3.slack.com/archives/C025HCWGM)

**Related Guides**:
- [TYPO3 Documentation Standards](https://docs.typo3.org/m/typo3/docs-how-to-document/main/en-us/)
- [RST Syntax Reference](rst-syntax.md)
- [TYPO3 Directives Reference](typo3-directives.md)
