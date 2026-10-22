import { test, expect } from '../helpers/fixtures'
import { env } from '../helpers/env'
import { shoot } from '../helpers/screenshot'
import {
  administration,
  choose,
  completeWizard,
  create,
  expandMenu,
  login,
  save,
  selectpicker,
  systemMenu,
  label,
} from '../helpers/kimai'

test('device user tracks time and invoices a customer', async ({ page }) => {
  const user = env('PLAYWRIGHT_DEVICE_USER', 'user')
  const password = env('PLAYWRIGHT_DEVICE_PASSWORD', 'Password1')
  const run = Date.now().toString(36)
  const team = `team-${run}`
  const customer = `customer-${run}`
  const project = `project-${run}`
  const activity = `activity-${run}`
  const template = `invoice-${run}`

  await test.step('login with the device user', async () => {
    await login(page, user, password)
    await completeWizard(page)
    await shoot(page, 'dashboard')
  })

  await test.step('system teams', async () => {
    await systemMenu(page).click()
    await page.locator('.navbar-menu-teams').click()
    await create(page)
    await page.locator('#team_edit_form_name').fill(team)
    await selectpicker(page, 'Add user').click()
    await page.locator('div.list-group-item').filter({ hasText: user }).first().click()
    await page.locator('.form-selectgroup-check').first().click()
    await save(page)
    await expect(page.getByText(team).first()).toBeVisible()
    await shoot(page, 'teams')
  })

  await test.step('administration customers', async () => {
    await administration(page, 'Customers')
    await shoot(page, 'administration')
    await create(page)
    await page.locator('#customer_edit_form_name').fill(customer)
    await save(page)
    await expect(page.getByText(customer).first()).toBeVisible()
    await shoot(page, 'customers')
  })

  await test.step('administration projects', async () => {
    await administration(page, 'Projects')
    await create(page)
    await page.locator('#project_edit_form_name').fill(project)
    await choose(page, 'project_edit_form_customer', customer)
    await save(page)
    await expect(page.getByText(project).first()).toBeVisible()
    await shoot(page, 'projects')
  })

  await test.step('administration activities', async () => {
    await administration(page, 'Activities')
    await create(page)
    await page.locator('#activity_edit_form_name').fill(activity)
    await choose(page, 'activity_edit_form_project', project)
    await save(page)
    await expect(page.getByText(activity).first()).toBeVisible()
    await shoot(page, 'activities')
  })

  await test.step('time tracking', async () => {
    await page.getByRole('link', { name: 'My times' }).click()
    await create(page)
    await page
      .locator('label')
      .filter({ hasText: 'Duration' })
      .locator('xpath=..')
      .locator('div.duration-widget button')
      .click()
    await page.getByRole('link', { name: '1:00', exact: true }).click()
    await choose(page, 'timesheet_edit_form_project', project)
    await choose(page, 'timesheet_edit_form_activity', activity)
    await save(page)
    await expect(page.getByText(/Show entries 1/)).toBeVisible()
    await expect(page.getByText(activity).first()).toBeVisible()
    await shoot(page, 'times')
  })

  await test.step('invoice template', async () => {
    await expandMenu(page, 'Invoices')
    await shoot(page, 'invoices')
    await page.getByRole('link', { name: 'Invoice template' }).click()
    await create(page)
    await page.locator('#invoice_template_form_name').fill(template)
    await page.locator('#invoice_template_form_title').fill('invoice-title')
    await page.locator('#invoice_template_form_company').fill('invoice-company')
    await save(page)
    await expect(page.getByText(template, { exact: true })).toBeVisible()
    await shoot(page, 'invoice-template')
  })

  await test.step('create invoice', async () => {
    await page.getByRole('link', { name: 'Create invoice' }).click()
    await page.getByRole('button', { name: label('Search') }).click()
    await expect(page.getByText(customer).first()).toBeVisible()
    await shoot(page, 'invoice')
  })
})
