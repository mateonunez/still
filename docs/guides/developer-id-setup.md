# Prepare Developer ID and notarization credentials

This setup prepares the local signing Mac. It does not sign Still, submit an archive to Apple or distribute a beta. Follow the [beta handoff](beta-handoff.md) before the final signing session. Keep the development candidate separate from the release artifact.

## 1. Use the personal developer account

Sign in to [Apple Developer](https://developer.apple.com/account/) with the account intended to own Still. Developer ID and notarization require an eligible paid Apple Developer Program membership; a free development account is insufficient. If enrollment is needed, use the Individual membership for personally owned distribution. Apple documents [membership benefits](https://developer.apple.com/support/compare-memberships/) and [individual enrollment](https://developer.apple.com/help/account/membership/enrolling-in-the-app).

Check Membership Details for the intended **Team ID** and active membership. Select that same team when creating the certificate. Installing a certificate does not confirm Still's release bundle ID; record that decision separately.

### Multiple teams on the same Mac

The Apple Account email, Xcode's selected account and a label such as “personal” do not uniquely identify the signing team. One account can have access to multiple teams. Pin the intended membership's **Team ID**, the exact Developer ID Application certificate **SHA-1 fingerprint**, and a dedicated notarization profile before signing. The certificate's subject Organizational Unit contains its Team ID. [Apple certificate identity](https://developer.apple.com/documentation/technotes/tn3161-inside-code-signing-certificates)

Xcode's free **Personal Team** is different from an Individual paid Developer Program membership; it cannot provide Developer ID distribution or notarization. Confirm membership on the developer portal rather than inferring it from that label. The certificate will normally use the verified legal name, not a GitHub username. [Apple membership comparison](https://developer.apple.com/support/compare-memberships/)

Keep team selection project-local. Do not change Xcode defaults, remove other identities or revoke certificates to separate projects. Use the confirmed certificate fingerprint as the eventual `codesign --sign` selector; never select the first identity or use a partial certificate name. Missing or mismatched configuration must stop release preparation, without a fallback to another team.

## 2. Create or reuse a local Developer ID Application identity

If a valid Developer ID Application identity for the intended personal team already exists on this Mac, reuse it. Otherwise, create one as the Account Holder. Apple supports certificate creation through Xcode or the developer portal. The following portal route creates the key locally through Keychain Access. [Apple certificate instructions](https://developer.apple.com/help/account/certificates/create-developer-id-certificates/)

1. Open **Keychain Access → Certificate Assistant → Request a Certificate from a Certificate Authority**.
2. Enter the account email and a recognizable Common Name; leave CA Email Address empty. Choose **Saved to disk** and keep the CSR outside the repository. [Apple CSR instructions](https://developer.apple.com/help/account/certificates/create-a-certificate-signing-request)
3. In Apple Developer → **Certificates, Identifiers & Profiles → Certificates → +**, choose **Developer ID Application**. Upload the CSR, download the `.cer` and open it on the same Mac.
4. In Keychain Access → **My Certificates**, confirm the Developer ID Application certificate belongs to the intended team and has its associated private key. A downloaded certificate alone is not a signing identity. [Apple's certificate and private-key model](https://developer.apple.com/documentation/technotes/tn3161-inside-code-signing-certificates)

Developer ID Installer is for installer packages; the initial app archive needs Developer ID Application. Do not create an Installer certificate solely for a ZIP or DMG. [Apple certificate types](https://developer.apple.com/help/account/certificates/create-developer-id-certificates/)

Check the local identity list yourself:

```sh
security find-identity -v -p codesigning
```

Look for a valid `Developer ID Application: … (TEAMID)` entry for the selected team. This read-only command lists identity metadata; it does not export private keys or sign anything. It searches file-based keychains, so absence needs diagnosis rather than automatic certificate deletion or revocation. [Apple signing guidance](https://developer.apple.com/documentation/xcode/creating-distribution-signed-code-for-the-mac/), [keychain search limitations](https://developer.apple.com/documentation/technotes/tn3161-inside-code-signing-certificates)

Record only the selected identity's 40-character SHA-1 fingerprint, its name and matching Team ID in ignored project-local release configuration. Do not paste the entire identity inventory. Fingerprint selection removes ambiguity between certificates with similar display names; it does not replace the final signature/team verification.

## 3. Save notarization credentials in Keychain

At [Apple Account](https://account.apple.com/), open **Sign-In and Security → App-Specific Passwords** and generate a password named `Still notarization`. Two-factor authentication is required. Use this app-specific password, not the main account password. [Apple password instructions](https://support.apple.com/en-us/102654)

Run this in your own terminal after replacing the two placeholders. The profile name `still-personal-notary` is a suggested local name; choose another if it already belongs to a different setup.

```sh
xcrun notarytool store-credentials "still-personal-notary" \
  --apple-id "YOUR_PERSONAL_APPLE_ACCOUNT_EMAIL" \
  --team-id "YOUR_PERSONAL_TEAM_ID"
```

Enter the app-specific password at the secure prompt. Omitting `--password` keeps it out of the command and shell history. By default, the tool validates the credentials with Apple before storing them in Keychain; this sends an authentication request, not an app upload. Do not use `--no-validate` to manufacture a successful setup. [Apple Keychain workflow](https://developer.apple.com/documentation/technotes/tn3147-migrating-to-the-latest-notarization-tool)

Always provide the same confirmed Team ID explicitly, even when the Apple Account has access to only one team today. A profile name alone is not proof of team ownership. Create or validate the dedicated profile with that explicit team; do not reuse another project's profile based on a similar name. [Apple team selection guidance](https://developer.apple.com/documentation/technotes/tn3147-migrating-to-the-latest-notarization-tool)

Confirm access with a read-only history request:

```sh
xcrun notarytool history --keychain-profile "still-personal-notary"
```

A successful response, including an empty history, confirms credential access. It does not confirm an app is notarized. If credentials fail after changing the main account password, generate a replacement app-specific password and repeat storage; Apple automatically revokes those passwords on account-password changes. [Apple credential testing](https://developer.apple.com/documentation/technotes/tn3147-migrating-to-the-latest-notarization-tool), [password revocation](https://support.apple.com/en-us/102654)

## 4. Report readiness without sharing secrets

Provide only: active membership confirmed, intended Team ID, the selected Developer ID Application identity name and SHA-1 fingerprint, local Keychain profile name, and whether the history request succeeded. Keep passwords, private keys, `.p12` exports and certificate/key files out of chat, logs and Git. No full identity inventory or notarization history is needed.

Before notarization upload, verify the signed outer app and every executable helper separately. Each must have the expected Developer ID Application signature and the exact configured `TeamIdentifier`. A valid signature belonging to a different team is a failure. Inspect metadata with `codesign -dv --verbose=4 <signed-path>` and verify integrity with `codesign --verify --strict <signed-path>`; these commands alone are not an automated team gate. The final release workflow must compare the metadata against the pinned Team ID and refuse upload on any mismatch.

When the candidate acceptance and release inputs are complete, these identifiers let the final signing workflow select the right local identity and Keychain profile. The release app will still need separate hardened-runtime signing, notarization, ticket validation and a clean-Mac download trial.

Research checked against Apple sources and local `notarytool store-credentials --help` on October 6, 2026. No account, certificate, Keychain credential or notarization submission was inspected or changed during preparation of this guide.
