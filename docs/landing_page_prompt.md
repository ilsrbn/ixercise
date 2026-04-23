# Landing Page Generation Prompt

---

Build a single-page HTML/CSS landing website for **Ixercise** — a minimalist iOS workout tracker app. No frameworks, no build tools. One self-contained `index.html` file with embedded CSS and optional vanilla JS only.

---

## Design System (match exactly)

### Colors
```
--bg:       #FAFAFA   /* page background */
--surface:  #FFFFFF   /* card/panel background */
--ink:      #0A0A0A   /* primary text */
--mute:     #6B6B6B   /* secondary text */
--soft-mute:#9A9A9A   /* tertiary labels */
--line:     #E8E8E8   /* borders, dividers */
--accent:   #E11D2E   /* red — use sparingly: CTAs, highlights */
```

### Typography
- Font: system-ui, -apple-system, BlinkMacSystemFont, "Segoe UI", sans-serif
- Headlines: `font-weight: 700`, `letter-spacing: -0.03em to -0.04em`, `line-height: 1.0`
- Section labels: `font-size: 11px`, `letter-spacing: 0.1em`, `font-weight: 600`, uppercase, color `--soft-mute`
- Body: `font-size: 15–16px`, `line-height: 1.4`, color `--mute`
- No custom fonts, no Google Fonts

### Components
- Buttons: pill shape (`border-radius: 999px`), padding `12px 24px`
  - Primary: `background: #E11D2E`, white text, no border
  - Ghost: transparent background, `border: 1px solid #E8E8E8`, ink text
- Cards: `border-radius: 16px`, `border: 1px solid #E8E8E8`, white background
- No box shadows. No gradients. No decorative imagery.

---

## Content & Sections

### 1. Hero
- Eyebrow label (uppercase, spaced, muted): `YOUR WORKOUT. YOUR RULES.`
- Headline (large, 64–80px, tight): `Train on\nyour terms.`
- Subtext (muted, 16px): `Ixercise is a no-nonsense workout tracker for iPhone. Build plans, set schedules, and move — no account, no subscription, no noise.`
- CTA button (primary): `Download on the App Store`
- Ghost CTA link below: `Privacy Policy ↗` (links to privacy_policy page)

### 2. Features (3-column grid on desktop, stacked on mobile)
Each feature: icon (simple SVG or emoji), label (uppercase, spaced), title (bold, 22px), body text.

Feature 1 — **Build your plan**
> Pick from 80+ exercises. Set reps or time. Arrange your workout in any order you want.

Feature 2 — **Schedule it**
> Assign plans to specific days and times. Get a reminder when it's time to move.

Feature 3 — **Just train**
> Timer counts down, progress bar moves, sounds keep you in the zone. No distractions.

Feature 4 — **Live Activity**
> Your workout stays visible on the Lock Screen and Dynamic Island while you move.

Feature 5 — **100% offline**
> No account. No cloud. No tracking. All your data lives on your device.

Feature 6 — **Free**
> No subscription. No paywall. No "premium" tier. Just download and go.

### 3. How it works (3 steps, horizontal timeline or numbered list)
Use the same style as the app's onboarding step labels.

- `STEP 01` → **Pick your exercises** — Choose from push-ups to Romanian deadlifts. Build your personal library.
- `STEP 02` → **Create a training plan** — Arrange exercises, set reps or time per set, configure rest periods.
- `STEP 03` → **Train** — Hit play. Follow along. Ixercise keeps time so you don't have to.

### 4. Privacy callout (full-width band, dark background #0A0A0A, white text)
Headline: `Nothing leaves your phone.`
Body: `No servers. No analytics. No ads. Ixercise stores everything locally and requests only the permissions it needs — notifications for reminders, nothing else.`

### 5. Footer
- App name: `Ixercise`
- Tagline: `Workout tracker for iPhone.`
- Links: `Privacy Policy` · `Contact`
- Contact email: `serbini271@gmail.com`
- Copyright: `© 2026 Ixercise`

---

## Layout Rules

- Max content width: `640px`, centered, `padding: 0 20px`
- Sections separated by `border-top: 1px solid #E8E8E8` or generous vertical space (`80–120px`)
- Mobile-first. Responsive at 640px breakpoint.
- No hero image, no app screenshots, no illustrations — typography and whitespace carry the page.
- The accent red (`#E11D2E`) appears only on the primary CTA button and nowhere else.

---

## Tone

Match the app's copy voice: direct, confident, no filler words. Short sentences. Fragments OK.
Examples from the app: *"Pick exercises you actually do."* / *"Nothing scheduled."* / *"No trainings yet."*
Apply same voice throughout the landing page copy.

---

## Output

Single `index.html` file. No external dependencies except the App Store badge SVG inline or as a text link. Include a `<meta name="viewport">` tag and a basic `<meta description>` for SEO.
