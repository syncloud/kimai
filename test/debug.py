import os
from os import environ
from os.path import dirname, join

from syncloudlib.integration.conftest import new_firefox_driver
from syncloudlib.integration.selenium_wrapper import SeleniumWrapper

from test.ui import test_login_new, test_customers, test_projects, test_activities

DIR = dirname(__file__)


def test_chrome():
    # sudo docker network create --ipv6 --subnet 2001:0DB8::/112 ip6net
    # sudo docker run -it --network ip6net -p 4444:4444 -p 5900:5900 -p 7900:7900 --shm-size="2g" selenium/standalone-firefox:4.35.0-20250828
    # firefox http://localhost:7900
    # password: secret

    driver = new_firefox_driver("http://localhost:4444/wd/hub", "desktop")

    # options = webdriver.ChromeOptions()
    # options.add_argument('--no-sandbox')
    # options.add_argument('--disable-dev-shm-usage')
    # options.set_capability('goog:loggingPrefs', {'performance': 'ALL'})
    # options.set_capability('acceptInsecureCerts', True)
    # driver = webdriver.Remote(options=options)
    # driver.maximize_window()

    artifacts_dir = join(DIR, "artifact")
    os.makedirs(artifacts_dir, exist_ok=True )

    selenium = SeleniumWrapper(
        driver,
        "desktop",
        artifacts_dir,
        environ["DOMAIN"],
        10,
        "firefox"
    )

    try:
        device_user = "test"
        test_login_new(selenium, device_user, "test1234")
        # test_welcome(selenium)
        # test_teams(selenium, device_user)
        # test_customers(selenium)
        # test_projects(selenium)
        test_activities(selenium)
        # test_new_product(selenium)
        # test_payments(selenium)
        # test_new_invoice(selenium)
    finally:
        print()
        selenium.log()
        driver.quit()
