# Releasing Swift-BigInt

## Publishing a New Release

1. Go to [Releases → New Release](https://github.com/mkrd/Swift-BigInt/releases/new)
2. Create a new tag following the `v*.*.*` format (e.g. `v2.4.0`)
3. Write release notes and click **Publish release**

The [`deploy.yml`](.github/workflows/deploy.yml) workflow runs automatically on release creation. It:
- Extracts the version number from the git tag
- Patches `Swift-BigInt.podspec` (replacing the `999.99.9` placeholder)
- Runs `pod trunk push` to publish to CocoaPods

SPM users get the new version automatically from the git tag — no extra step needed.

## Renewing the CocoaPods Trunk Token

The `COCOAPODS_TRUNK_TOKEN` GitHub secret is required for CocoaPods publishing. Sessions expire after ~6 months. If the deploy workflow fails with:

```
[!] Authentication token is invalid or unverified.
```

Follow these steps to renew it:

1. **Register a new session:**
   ```bash
   pod trunk register your-email@example.com --description='Swift-BigInt releases'
   ```

2. **Verify:** Check your email and click the verification link.

3. **Confirm the session is active:**
   ```bash
   pod trunk me
   ```

4. **Copy the new token:**
   ```bash
   grep -A2 trunk ~/.netrc
   ```
   The value after `password` is your token.

5. **Update the GitHub secret:**
   Go to [Settings → Secrets → Actions](https://github.com/mkrd/Swift-BigInt/settings/secrets/actions), edit `COCOAPODS_TRUNK_TOKEN`, paste the new token, and save.

6. **Re-run the failed workflow** from the [Actions](https://github.com/mkrd/Swift-BigInt/actions) tab.

## CI

The [`build.yml`](.github/workflows/build.yml) workflow runs on every push and PR to `master`:
- **macOS:** Builds and tests via SPM (`swift test`) and CocoaPods (`pod lib lint`)
- **Linux:** Builds and tests via SPM (`swift test`)
