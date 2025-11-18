import pytest
import os
from selenium import webdriver
from selenium.webdriver.chrome.service import Service
from webdriver_manager.chrome import ChromeDriverManager

@pytest.fixture(scope="function")
def driver():
    
    options = webdriver.ChromeOptions()
    
    options.add_argument("--no-sandbox")
    options.add_argument("--disable-dev-shm-usage")
    options.add_argument("--start-maximized")
    options.add_argument("--disable-blink-features=AutomationControlled")
    
    prefs = {
        "credentials_enable_service": False,    
        "profile.password_manager_enabled": False,
        "profile.password_manager_leak_detection": False,
        "safebrowsing.enabled": False
    }
    options.add_experimental_option("prefs", prefs)
    
    options.add_argument("--disable-session-crashed-bubble")
    options.add_argument("--ignore-certificate-errors")

    service = Service(ChromeDriverManager().install())
    driver = webdriver.Chrome(service=service, options=options)
    
    driver.implicitly_wait(5)
    yield driver
    driver.quit()

@pytest.fixture
def site_url():
    return "https://pcqi.onrender.com/screens/index.html"