import { defineConfig, devices } from '@playwright/test'
import { env } from './helpers/env'

const domain = env('PLAYWRIGHT_DOMAIN')
const app = env('PLAYWRIGHT_APP')
const output = env('PLAYWRIGHT_OUTPUT_DIR')

export default defineConfig({
  testDir: './specs',
  fullyParallel: false,
  workers: 1,
  retries: process.env.CI ? 1 : 0,
  reporter: 'list',
  outputDir: output,
  timeout: 3_600_000,
  expect: { timeout: 60_000 },
  use: {
    actionTimeout: 60_000,
    navigationTimeout: 120_000,
    baseURL: `https://${app}.${domain}`,
    ignoreHTTPSErrors: true,
    trace: 'retain-on-failure',
    video: 'off',
    screenshot: 'only-on-failure',
  },
  projects: [
    {
      name: 'desktop',
      use: { ...devices['Desktop Chrome'], viewport: { width: 1440, height: 960 } },
    },
  ],
})
