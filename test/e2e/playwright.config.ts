import { defineConfig, devices } from '@playwright/test'

const domain = process.env.PLAYWRIGHT_DOMAIN ?? 'bookworm.com'

export default defineConfig({
  testDir: './specs',
  fullyParallel: false,
  workers: 1,
  retries: process.env.CI ? 1 : 0,
  reporter: 'list',
  timeout: 600_000,
  expect: { timeout: 60_000 },
  use: {
    baseURL: `https://kimai.${domain}`,
    ignoreHTTPSErrors: true,
    actionTimeout: 60_000,
    navigationTimeout: 120_000,
  },
  projects: [
    {
      name: 'desktop',
      use: { ...devices['Desktop Chrome'], viewport: { width: 1440, height: 960 } },
    },
  ],
})
