# App Store Release Checklist — v1.0.0

Work through this list top to bottom before submitting to App Store Review.

---

## Apple Developer Account

- [ ] Apple Developer account active ($99/year)
- [ ] App ID / Bundle ID registered in App Store Connect (`com.ilsrbn.ixercise` or chosen ID)
- [ ] App record created in App Store Connect

---

## App Icon

- [ ] App icon 1024×1024 PNG (no alpha, no rounded corners — Apple adds the mask)
- [ ] All required icon sizes generated and included in Xcode asset catalog

---

## Screenshots

- [ ] Screenshots for iPhone 6.9" (1320×2868) — required
- [ ] Screenshots for iPhone 6.7" (1290×2796) — required
- [ ] Screenshots for iPhone 5.5" (1242×2208) — required if supporting older devices
- [ ] At least 3 screenshots per device size
- [ ] Screenshots reviewed for overlay copy accuracy (see `docs/SCREENSHOTS_COPY.md`)
- [ ] Both light and dark mode represented

---

## App Store Metadata (English)

- [ ] App name: `Ixercise`
- [ ] Subtitle: `Offline workout planner` (≤30 chars)
- [ ] Promotional text written (see `docs/APP_STORE_METADATA.md`)
- [ ] Full description written and reviewed
- [ ] Keywords entered (≤100 chars, comma-separated)
- [ ] What's New text for v1.0 written

---

## App Store Metadata (Ukrainian)

- [ ] App name localized
- [ ] Subtitle localized: `Планер тренувань офлайн`
- [ ] Promotional text (UA)
- [ ] Full description (UA)
- [ ] Keywords (UA)
- [ ] What's New (UA)

---

## URLs

- [ ] Support URL set (e.g. `https://github.com/ilsrbn/ixercise/issues`)
- [ ] Privacy Policy URL set (`https://github.com/ilsrbn/ixercise/blob/main/PRIVACY_POLICY.md`)
- [ ] Marketing URL set (GitHub repo or landing page)

---

## App Privacy (App Store Connect)

- [ ] Privacy practices answered in App Store Connect
- [ ] Confirmed: no data collected
- [ ] Confirmed: no tracking
- [ ] Confirmed: no third-party analytics or advertising
- [ ] "Does this app use third-party advertising networks?" → No
- [ ] "Does this app use analytics tools?" → No

---

## Build & Testing

- [ ] `flutter build ipa --release` runs without errors
- [ ] Release build tested on a physical device (not just simulator)
- [ ] TestFlight build uploaded and installed
- [ ] Smoke test: create workout → run workout → complete workout
- [ ] Offline test: airplane mode on → full workout flow works
- [ ] Local reminders test: set reminder → fires correctly on device
- [ ] Live Activities test: workout in progress → Lock Screen shows activity
- [ ] Dynamic Island test: workout in progress → Dynamic Island updates
- [ ] Light mode tested on device
- [ ] Dark mode tested on device
- [ ] Ukrainian localization reviewed on device

---

## App Review Notes

- [ ] App Review Notes filled in (see `docs/APP_STORE_METADATA.md` → App Review Notes section)
- [ ] Notes explain: offline app, no login required, no paid content, no external services

---

## Repository

- [ ] `LICENSE` file present (MIT)
- [ ] `README.md` updated
- [ ] `PRIVACY_POLICY.md` present at repo root
- [ ] GitHub repo public (if open sourcing before launch)
- [ ] `v1.0.0` git tag created: `git tag v1.0.0`
- [ ] GitHub release created with release notes

---

## Post-Submit

- [ ] App submitted for review in App Store Connect
- [ ] GitHub release published
- [ ] Product Hunt draft prepared (see `docs/LAUNCH_POSTS.md`)
- [ ] Reddit posts drafted and scheduled
- [ ] Social posts ready
