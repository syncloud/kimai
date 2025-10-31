import pytest
from os.path import dirname, join

from selenium.webdriver.common.by import By
from subprocess import check_output
from syncloudlib.integration.hosts import add_host_alias

DIR = dirname(__file__)


TMP_DIR = '/tmp/syncloud/ui'
MODE = 'install'

@pytest.fixture(scope="session")
def module_setup(request, device, artifact_dir, ui_mode, data_dir, app, domain, device_host, local, selenium):
    if not local:
        add_host_alias(app, device_host, domain)
        device.activated()
        device.run_ssh('mkdir -p {0}'.format(TMP_DIR), throw=False)     

        def module_teardown():
            device.run_ssh('journalctl > {0}/journalctl.log'.format(TMP_DIR), throw=False)
            device.run_ssh("snap run kimai.sql kimai -e 'select * from kimai2_users;' > {0}/users.log".format(TMP_DIR), throw=False)
            device.scp_from_device('{0}/*'.format(TMP_DIR), join(artifact_dir, ui_mode))
            check_output('cp /videos/* {0}'.format(artifact_dir), shell=True)
            check_output('chmod -R a+r {0}'.format(artifact_dir), shell=True)
            #selenium.log()
        request.addfinalizer(module_teardown)


def test_start(module_setup, app, domain, device_host):
    add_host_alias(app, device_host, domain)


def test_login(selenium, device_user, device_password):
    selenium.open_app()
    selenium.find_by(By.ID, "username").send_keys(device_user)
    password = selenium.find_by(By.ID, "password")
    password.send_keys(device_password)
    selenium.find_by(By.XPATH, "//button[contains(.,'Log in')]").click()
    selenium.screenshot('login')


def test_welcome(selenium):
    selenium.find_by(By.XPATH, "//a[.='Next']").click()
    selenium.screenshot('welcome')
    selenium.find_by(By.XPATH, "//h1[.='Your profile']")
    selenium.find_by(By.XPATH, "//button[.='Next']").click()
    selenium.find_by(By.XPATH, "//h1[.='Congratulations']")
    selenium.find_by(By.XPATH, "//a[.='Next']").click()


def test_system_teams(selenium, device_user):
    selenium.find_by(By.CLASS_NAME, "navbar-menu-system").click()
    selenium.find_by(By.CLASS_NAME, "navbar-menu-teams").click()
    selenium.find_by(By.XPATH, "//a[.='Create']").click()
    selenium.find_by(By.ID, "team_edit_form_name").send_keys("team")
    selenium.find_by(By.XPATH, '//label[.="Add user"]/..//div[contains(@class, "selectpicker")]').click()
    selenium.find_by(By.XPATH, f'//div[contains(@class, "list-group-item") and contains(., "{device_user}")]').click()
    selenium.find_by(By.CLASS_NAME, 'form-selectgroup-check').click()
    selenium.find_by(By.XPATH, "//button[.='Save']").click()
    selenium.invisible_by(By.XPATH, "//h3[.='Create']")
    selenium.invisible_by(By.XPATH, "//button[.='Save']")
    selenium.screenshot('teams')


def menu_administration(selenium, item):
    selenium.clickable_by(By.XPATH, "//li[@id='admin']")
    menu = selenium.find_by(By.XPATH, "//li[@id='admin']/div")
    if "show" not in menu.get_attribute("class"):
        selenium.click_by(By.XPATH, "//li[@id='admin']")
    selenium.click_by(By.XPATH, f"//a[contains(.,'{item}')]")
    selenium.screenshot('administration')


def test_administration_customers(selenium):
    menu_administration(selenium, "Customers")
    selenium.click_by(By.XPATH, "//a[.='Create']")
    selenium.find_by(By.ID, "customer_edit_form_name").send_keys("customer")
    selenium.click_by(By.XPATH, "//button[.='Save']")
    selenium.invisible_by(By.XPATH, "//h3[.='Create']")
    selenium.invisible_by(By.XPATH, "//button[.='Save']")
    selenium.find_by(By.XPATH, "//span[contains(.,'customer')]")
    selenium.screenshot('customers')


def test_administration_projects(selenium):
    menu_administration(selenium, "Projects")
    selenium.click_by(By.XPATH, "//a[.='Create']")
    selenium.find_by(By.ID, "project_edit_form_name").send_keys("project")
    selenium.click_by(By.XPATH, '//label[.="Customer"]/..//div[contains(@class, "selectpicker")]')
    selenium.click_by(By.XPATH, "//div[@id= 'project_edit_form_customer-ts-dropdown']/div[contains(.,'customer')]")
    selenium.click_by(By.XPATH, "//button[.='Save']")
    selenium.invisible_by(By.XPATH, "//h3[.='Create']")
    selenium.invisible_by(By.XPATH, "//button[.='Save']")
    selenium.find_by(By.XPATH, "//span[contains(.,'project')]")
    selenium.screenshot('projects')

def test_administration_activities(selenium):
    menu_administration(selenium, "Activities")
    selenium.click_by(By.XPATH, "//a[.='Create']")
    selenium.find_by(By.ID, "activity_edit_form_name").send_keys("activity")
    selenium.click_by(By.XPATH, '//label[.="Project"]/..//div[contains(@class, "selectpicker")]')
    selenium.click_by(By.XPATH, "//div[@id='activity_edit_form_project-ts-dropdown']//div[.='project']")
    selenium.click_by(By.XPATH, "//button[.='Save']")
    selenium.invisible_by(By.XPATH, "//h3[.='Create']")
    selenium.invisible_by(By.XPATH, "//button[.='Save']")
    selenium.find_by(By.XPATH, "//span[contains(.,'activity')]")
    selenium.screenshot('activities')

def test_time_tracking_times(selenium):
    selenium.click_by(By.XPATH, "//a[contains(.,'My times')]")
    selenium.click_by(By.XPATH, "//a[.='Create']")
    selenium.click_by(By.XPATH, "//label[contains(.,'Duration')]/..//div[contains(@class, 'duration-widget')]//button")
    selenium.click_by(By.XPATH, '//a[.="1:00"]')
    selenium.click_by(By.XPATH, "//label[.='Project']/..//div[contains(@class, 'selectpicker')]")
    selenium.click_by(By.XPATH, "//div[@id='timesheet_edit_form_project-ts-dropdown']//div[.='project']")
    selenium.click_by(By.XPATH, "//label[.='Activity']/..//div[contains(@class, 'selectpicker')]")
    selenium.click_by(By.XPATH, "//div[@id='timesheet_edit_form_activity-ts-dropdown']//div[.='activity']")
    selenium.click_by(By.XPATH, "//button[.='Save']")
    selenium.invisible_by(By.XPATH, "//h5[.=Create]")
    selenium.find_by(By.XPATH, "//p[contains(.,'Show entries 1')]")
    selenium.screenshot('times')

def test_invoices(selenium):
    xpath = "//a[contains(.,'Invoices')]"
    menu = selenium.find_by(By.XPATH, xpath)
    if "show" not in menu.get_attribute("class"):
        selenium.click_by(By.XPATH, xpath)
    selenium.screenshot('invoices')

def test_invoices_template(selenium):
    selenium.click_by(By.XPATH, "//a[contains(.,'Invoice template')]")
    selenium.click_by(By.XPATH, "//a[.='Create']")
    selenium.find_by(By.XPATH, "//button[.='Save']")
    selenium.find_by(By.ID, "invoice_template_form_name").send_keys("invoice-name")
    selenium.find_by(By.ID, "invoice_template_form_title").send_keys("invoice-title")
    selenium.find_by(By.ID, "invoice_template_form_company").send_keys("invoice-company")
    selenium.click_by(By.XPATH, "//button[.='Save']")
    selenium.find_by(By.XPATH, "//td[.='invoice-name']")

def test_invoices_create(selenium):
    selenium.click_by(By.XPATH, "//a[contains(.,'Create invoice')]")
    selenium.click_by(By.XPATH, "//button[.='Search']")
    selenium.find_by(By.XPATH, "//span[contains(.,'customer')]")
    selenium.screenshot('invoice')

