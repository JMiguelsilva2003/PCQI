import time
from selenium.webdriver.common.by import By
from selenium.webdriver.common.keys import Keys
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from selenium.common.exceptions import TimeoutException

USER_EMAIL = "teste@teste.com"
USER_PASS = "123456789"

def test_login_and_create_machine(driver, site_url):
    print(f"Acessando: {site_url}")
    driver.get(site_url)

    print("Aguardando formulário de login...")
    
    try:
        email_input = WebDriverWait(driver, 10).until(
            EC.visibility_of_element_located((By.ID, "emailLogin"))
        )
        pass_input = driver.find_element(By.ID, "senhaLogin")
        
        login_btn = driver.find_element(By.CSS_SELECTOR, "#formLogin .submit-btn")

        print(f"Preenchendo login ({USER_EMAIL})...")
        email_input.clear()
        email_input.send_keys(USER_EMAIL)
        pass_input.clear()
        pass_input.send_keys(USER_PASS)
        
        time.sleep(0.5)
        
        print("Clicando em Entrar...")
        driver.execute_script("arguments[0].click();", login_btn)

    except Exception as e:
        raise Exception(f"Erro no formulário de login: {e}")

    print("Aguardando Dashboard (pode demorar no Render)...")
    try:
        btn_ver_maquinas = WebDriverWait(driver, 60).until(
            EC.element_to_be_clickable((By.ID, "btn-ver-maquinas"))
        )
        print("Dashboard carregado (Login Sucesso).")
    except TimeoutException:
        try:
            alert = driver.switch_to.alert
            print(f"⚠️ Alerta do site: '{alert.text}'")
            alert.accept()
        except:
            pass
        raise Exception("Timeout: Não entrou no Dashboard após login.")

    btn_ver_maquinas.click() 
    time.sleep(1)

    print("Clicando em 'Criar Nova Máquina'...")
    try:
        btn_criar = WebDriverWait(driver, 10).until(
            EC.presence_of_element_located((By.ID, "btn-criar-maquina"))
        )
        driver.execute_script("arguments[0].click();", btn_criar)
    except Exception as e:
        raise Exception(f"Não conseguiu clicar no botão criar: {e}")

    print("Preenchendo formulário...")
    try:
        nome_maq_input = WebDriverWait(driver, 10).until(
            EC.visibility_of_element_located((By.ID, "machine-name"))
        )
        
        nome_maquina = f"Selenium Test {int(time.time())}"
        nome_maq_input.clear()
        nome_maq_input.send_keys(nome_maquina)
        
        select_sector = driver.find_element(By.ID, "machine-sector")
        select_sector.click()
        time.sleep(1) 
        select_sector.send_keys(Keys.ARROW_DOWN)
        select_sector.send_keys(Keys.ENTER)

        print("Salvando...")
        save_btn = driver.find_element(By.CSS_SELECTOR, "#form-create-machine button[type='submit']")
        driver.execute_script("arguments[0].click();", save_btn)

    except Exception as e:
        raise Exception(f"Erro ao preencher/salvar formulário: {e}")

    print("Aguardando confirmação...")
    try:
        WebDriverWait(driver, 10).until(EC.alert_is_present())
        alert = driver.switch_to.alert
        print(f"Alerta Recebido: {alert.text}")
        alert.accept()
    except:
        print("Nenhum alerta apareceu. Verificando lista...")

    time.sleep(3)
    if nome_maquina in driver.page_source:
        print(f"SUCESSO: Máquina '{nome_maquina}' criada!")
    else:
        raise Exception("Erro: Máquina criada não apareceu na lista.")