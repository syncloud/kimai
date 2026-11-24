import { test, expect } from '../helpers/fixtures'
import { env } from '../helpers/env'
import { shoot } from '../helpers/screenshot'
import { choose, completeWizard, create, customers, login, save, administration } from '../helpers/kimai'

const customer = 'upgrade-customer'

test('customer survives the upgrade and accepts new projects', async ({ page }) => {
  const project = `upgrade-project-${Date.now().toString(36)}`

  await test.step('login', async () => {
    await login(page, env('PLAYWRIGHT_DEVICE_USER'), env('PLAYWRIGHT_DEVICE_PASSWORD'), 'post-upgrade-')
    await completeWizard(page, 'post-upgrade-')
    await shoot(page, 'dashboard-after-upgrade')
  })

  await test.step('customer survived', async () => {
    await customers(page)
    await expect(page.getByText(customer, { exact: true }).filter({ visible: true }).first()).toBeVisible()
    await shoot(page, 'customers-after-upgrade')
  })

  await test.step('create project', async () => {
    await administration(page, 'Projects')
    await create(page)
    await page.locator('#project_edit_form_name').fill(project)
    await choose(page, 'project_edit_form_customer', customer)
    await save(page)
    await expect(page.getByText(project).first()).toBeVisible()
    await shoot(page, 'projects-after-upgrade')
  })
})
