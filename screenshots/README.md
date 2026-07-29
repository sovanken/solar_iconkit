# Screenshots for pub.dev

pub.dev displays up to 10 screenshots on the package landing page. Packages
with screenshots see roughly 2–3× higher click-through from search results.

## Files to capture

Drop the PNGs into this folder with these exact names:

### 1. `browser-grid.png` — Icon browser landing view

**What to capture:**
- Full page of <https://solar-icons-web.vercel.app> in dark mode
- Sidebar visible with categories
- Icon grid visible with a good mix of icon styles
- Header showing "Solar Iconkit" brand and the style chips

**How:**
1. Open <https://solar-icons-web.vercel.app> in Chrome
2. Set viewport to **1440 × 900** (Chrome DevTools → Device toolbar → Responsive → 1440 × 900)
3. Use a full-page screenshot tool (browser extension, `Ctrl+Shift+P → "Capture full-size screenshot"` in Chrome DevTools)
4. Crop to 1440 × 900 if needed

### 2. `style-comparison.png` — Six styles side-by-side

**What to capture:**
- Any icon (recommend `solar:home-2`) shown in all 6 styles: linear, outline, broken, bold, line-duotone, bold-duotone
- Labels under each style
- Consistent size and color across all 6

**How:**
- Open the icon detail dialog on <https://solar-icons-web.vercel.app>
- Click any icon to open the dialog — it shows the style column on the left/right
- Crop to just the style column + main preview

### 3. `widget-in-app.png` — SolarIcon in real Flutter UI

**What to capture:**
- The "Preview in context" strip from the icon dialog, OR
- A real Flutter app screenshot showing SolarIcon in an AppBar, Button, and ListTile

**How:**
- Open the icon dialog on the web browser
- Scroll to the "Preview in context" section
- Screenshot the 4-card grid (Menu / Sidebar / Button / Toolbar)

## Guidelines

- **Format:** PNG (JPG also accepted, but PNG is preferred for UI shots)
- **Resolution:** Aim for 1440 × 900 or higher. Avoid extreme aspect ratios.
- **File size:** Under 500 KB each ideally (compress with squoosh.app or tinypng.com)
- **Dark mode:** Use dark mode consistently — matches your Solar Iconkit brand
- **No watermarks:** No browser chrome, no personal info visible

## After capturing

1. Save the 3 PNGs in this folder with the exact filenames above
2. Uncomment the `screenshots:` block in `pubspec.yaml`
3. Verify locally: `flutter pub publish --dry-run` (should show the screenshots in the package tree)
4. Re-publish: bump patch version and `flutter pub publish`

## Optional extras (up to 7 more slots)

If you want to fill more of the 10 available screenshot slots:

- Dark vs. light mode side-by-side
- Category filter in action
- Copy dialog with Flutter code snippet
- Search palette (Cmd+K)
- Mobile responsive layout
- IconTheme integration example
- Docs page overview

Pick the ones that best sell the package to a first-time visitor.
