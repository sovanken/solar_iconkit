// Capture pub.dev screenshots for solar_iconkit.
//
// Runs against the live web browser at https://solar-icons-web.vercel.app
// and writes three PNG files into this directory.
//
// Usage: npx playwright@latest install chromium && node capture.mjs

import { chromium } from 'playwright';
import { fileURLToPath } from 'url';
import { dirname, resolve } from 'path';

const __dirname = dirname(fileURLToPath(import.meta.url));
const SITE = 'https://solar-icons-web.vercel.app';
const OUT = (name) => resolve(__dirname, name);

const browser = await chromium.launch();
const context = await browser.newContext({
  viewport: { width: 1440, height: 900 },
  deviceScaleFactor: 2, // 2× DPR for crisp screenshots
  colorScheme: 'dark',
});
const page = await context.newPage();

console.log('Navigating to', SITE);
await page.goto(SITE, { waitUntil: 'networkidle' });

// Wait for the icon grid to render (Iconify icons load asynchronously).
// Icon cards are buttons with the .icon-card-anim class.
await page.waitForSelector('button.icon-card-anim', { state: 'visible', timeout: 20000 });
// Give Iconify a few extra seconds to batch-fetch all icon SVGs.
await page.waitForTimeout(4000);

// ===== 1) browser-grid.png — landing view =====
console.log('Capturing browser-grid.png');
await page.screenshot({
  path: OUT('browser-grid.png'),
  fullPage: false,
});

// ===== 2) style-comparison.png — six styles side-by-side inside the dialog =====
// Click any icon card to open the detail dialog.
console.log('Opening icon detail dialog');

// Click the first icon card to open the detail dialog.
await page.locator('button.icon-card-anim').first().click({ timeout: 5000 });

// Wait for dialog to appear
await page.waitForSelector('[role="dialog"]', { timeout: 5000 });
await page.waitForTimeout(1500);

// Screenshot the whole dialog (it shows all 6 styles side-by-side + hero preview)
const dialog = page.locator('[role="dialog"]').first();
await dialog.screenshot({ path: OUT('style-comparison.png') });

// ===== 3) widget-in-app.png — "Preview in context" strip =====
console.log('Scrolling to Preview in context');

// Scroll the dialog to bring the "Preview in context" strip into view
await page.evaluate(() => {
  const el = [...document.querySelectorAll('*')].find((n) =>
    n.textContent?.trim().startsWith('Preview in context'),
  );
  el?.scrollIntoView({ behavior: 'instant', block: 'center' });
});
await page.waitForTimeout(800);

// Screenshot the "Preview in context" section
const preview = page.locator('text=Preview in context').locator('..').first();
try {
  await preview.screenshot({ path: OUT('widget-in-app.png') });
} catch (e) {
  // Fallback: screenshot the current dialog viewport
  await dialog.screenshot({ path: OUT('widget-in-app.png') });
}

await browser.close();
console.log('\nDone. 3 files written to', __dirname);
