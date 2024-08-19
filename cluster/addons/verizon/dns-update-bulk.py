from time import sleep
from selenium import webdriver
from selenium.webdriver.firefox.service import Service as FirefoxService
from selenium.webdriver.firefox.options import Options as FirefoxOptions
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from selenium.common.exceptions import TimeoutException, NoSuchElementException
from secrets.password import verizon_password

def login(driver):
    try:
        password_input = WebDriverWait(driver, 10).until(
            EC.presence_of_element_located((By.CLASS_NAME, "vz-input"))
        )
        password_input.send_keys(verizon_password)
        
        # keep_signed_in = driver.find_element(By.XPATH, "//input[@type='checkbox']")
        # keep_signed_in.click()
        
        login_button = driver.find_element(By.CLASS_NAME, "btn-primary")
        login_button.click()
        sleep(1)
    except TimeoutException:
        print("Already logged in or login page not found. Continuing...")

def update_dns_entries(driver):
    # Navigate to DNS server page
    driver.get("https://192.168.1.1/#/adv/network/dnsserver")
    
    # Wait for the table to load
    WebDriverWait(driver, 10).until(
        EC.presence_of_element_located((By.CLASS_NAME, "underline-box"))
    )
    
    # Find all rows in the table
    rows = driver.find_elements(By.XPATH, "//div[@role='row']")
    links = []
    for row in rows:
        try:
            source = row.find_element(By.XPATH, ".//div[@role='cell'][3]").text
            hostname = row.find_element(By.XPATH, ".//div[@role='cell'][1]").text
            if source == "Manually" and hostname is not "home-assistant.internal":
                edit_link = row.find_element(By.LINK_TEXT, "Edit")
                href = edit_link.get_attribute("href")
                links.append(href)   
        except NoSuchElementException:
            continue 
    for link in links:
        try:
            # open each in new tab to avoid dumb loading issues
            driver.execute_script("window.open();")
            driver.switch_to.window(driver.window_handles[-1])
            driver.get(link)
            
            # Wait for the edit page to load
            WebDriverWait(driver, 10).until(
                EC.presence_of_element_located((By.CLASS_NAME, "ip-input"))
            )
            sleep(2)
            # Update IP address
            ip_inputs = driver.find_elements(By.CLASS_NAME, "ip-input")
            for i, octet in enumerate(["192", "168", "1", "23"]):
                ip_inputs[i].clear()
                ip_inputs[i].send_keys(octet)
            
            # Click Apply
            apply_button = driver.find_element(By.XPATH, "//button[contains(text(), 'Apply')]")
            apply_button.click()
            
            # Wait for the changes to be applied and return to the main DNS page
            WebDriverWait(driver, 10).until(
                # EC.presence_of_element_located((By.CLASS_NAME, "popup-modal-outter"))
                EC.invisibility_of_element_located((By.CLASS_NAME, "popup-modal-bg popup-modal-bg-leave-active popup-modal-bg-leave-to"))
            )
        except NoSuchElementException:
            continue

def main():
    firefox_options = FirefoxOptions()
    firefox_service = FirefoxService(executable_path='/opt/homebrew/bin/geckodriver')
    driver = webdriver.Firefox(service=firefox_service, options=firefox_options)
    driver.get("https://192.168.1.1/#/login/")
    
    login(driver)
    update_dns_entries(driver)
    
    driver.quit()

if __name__ == "__main__":
    main()