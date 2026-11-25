import { test, expect } from '../helpers/fixtures'
import { env } from '../helpers/env'
import { shoot } from '../helpers/screenshot'
import { completeWizard, create, customers, login, save } from '../helpers/kimai'

const customer = 'upgrade-customer'

test('customer is created on the released version before upgrade', async ({ page }) => {
  await test.step('login', async () => {
    await login(page, env('PLAYWRIGHT_DEVICE_USER'), env('PLAYWRIGHT_DEVICE_PASSWORD'), 'pre-upgrade-')
    await completeWizard(page, 'pre-upgrade-')
    await shoot(page, 'dashboard-before-upgrade')
  })

  await test.step('create customer', async () => {
    await customers(page)
    const existing = page.getByText(customer, { exact: true }).filter({ visible: true })
    if ((await existing.count()) === 0) {
      await create(page)
      await page.locator('#customer_edit_form_name').fill(customer)
      await save(page)
    }
    await expect(page.getByText(customer, { exact: true }).filter({ visible: true }).first()).toBeVisible()
    await shoot(page, 'customers-before-upgrade')
  })
})
