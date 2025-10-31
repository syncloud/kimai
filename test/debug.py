import os
import shutil
from os import environ
from os.path import dirname, join

from syncloudlib.integration.conftest import new_firefox_driver
from syncloudlib.integration.selenium_wrapper import SeleniumWrapper

from test.ui import test_login, test_system_teams, \
    test_administration_customers, test_administration_projects, test_administration_activities, \
    test_time_tracking_times, test_invoices, test_invoices_create, test_welcome, test_invoices_template

DIR = dirname(__file__)

def test_chrome():
    # sudo docker network create --ipv6 --subnet 2001:0DB8::/112 ip6net
    # sudo docker run -it --network ip6net -p 4444:4444 -p 5900:5900 -p 7900:7900 --shm-size="2g" selenium/standalone-firefox:4.35.0-20250828
    # firefox http://localhost:7900
    # password: secret

    driver = new_firefox_driver("http://localhost:4444/wd/hub", "desktop")
    driver.set_window_rect(0, 0, 2000, 3000)
    driver.maximize_window()

    artifacts_dir = join(DIR, "artifact")
    if os.path.exists(artifacts_dir):
        shutil.rmtree(artifacts_dir)
        os.makedirs(artifacts_dir)

    selenium = SeleniumWrapper(
        driver,
        "desktop",
        artifacts_dir,
        environ["DOMAIN"],
        5,
        "firefox"
    )

    try:
        device_user = "test"
        test_login(selenium, device_user, "test1234")
        # test_welcome(selenium)
        # test_system_teams(selenium, device_user)
        # test_administration_customers(selenium)
        # test_administration_projects(selenium)
        # test_administration_activities(selenium)
        # test_time_tracking_times(selenium)
        test_invoices(selenium)
        test_invoices_template(selenium)
        test_invoices_create(selenium)
    finally:
        print()
        driver.quit()
