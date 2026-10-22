import { Locator, Page, expect } from '@playwright/test'
import { shoot } from './screenshot'

export function label(text: string): RegExp {
  return new RegExp(`(^|\\W)${text}$`)
}

export function systemMenu(page: Page): Locator {
  return page.locator('.navbar-menu-system')
}

export async function login(page: Page, user: string, password: string) {
  await page.goto('/')
  await page.locator('#username').fill(user)
  await page.locator('#password').fill(password)
  await shoot(page, 'login')
  await page.getByRole('button', { name: 'Log in' }).click()
}

export async function completeWizard(page: Page) {
  const next = page.getByRole('link', { name: 'Next', exact: true })
  await expect(next.or(systemMenu(page)).first()).toBeVisible()
  if (!(await next.isVisible())) {
    return
  }
  await next.click()
  await expect(page.getByRole('heading', { name: 'Your profile' })).toBeVisible()
  await shoot(page, 'welcome')
  await page.getByRole('button', { name: 'Next', exact: true }).click()
  await expect(page.getByRole('heading', { name: 'Congratulations' })).toBeVisible()
  await shoot(page, 'congratulations')
  await page.getByRole('link', { name: 'Next', exact: true }).click()
  await expect(systemMenu(page)).toBeVisible()
}

export function selectpicker(page: Page, label: string): Locator {
  return page
    .locator('label')
    .filter({ hasText: new RegExp(`^\\s*${label}\\s*$`) })
    .locator('xpath=..')
    .locator('div.selectpicker')
}

export async function choose(page: Page, label: string, dropdown: string, option: string) {
  await selectpicker(page, label).click()
  await page.locator(`#${dropdown}-ts-dropdown`).getByRole('option', { name: option }).click()
}

export async function create(page: Page) {
  await page.getByRole('link', { name: label('Create') }).click()
  await expect(page.getByRole('button', { name: label('Save') })).toBeVisible()
}

export async function save(page: Page) {
  const button = page.getByRole('button', { name: label('Save') })
  await button.click()
  await expect(button).toBeHidden()
}

export async function administration(page: Page, item: string) {
  const admin = page.locator('li#admin')
  await expect(admin).toBeVisible()
  const menu = admin.locator('> div')
  if (!((await menu.getAttribute('class')) ?? '').includes('show')) {
    await admin.click()
  }
  await admin.getByRole('link', { name: item }).click()
}

export async function expandMenu(page: Page, name: string) {
  const link = page.getByRole('link', { name }).first()
  await expect(link).toBeVisible()
  if (!((await link.getAttribute('class')) ?? '').includes('show')) {
    await link.click()
  }
}
