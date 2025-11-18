import time
from selenium.webdriver.common.by import By
from selenium.webdriver.common.keys import Keys
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from selenium.common.exceptions import TimeoutException

USER_EMAIL = "teste@teste.com"
USER_PASS = "123456789"

DELAY = 2 

def test_sprint2_full_flow(driver, site_url):
    print(f"\nINICIANDO TESTE VISUAL EM: {site_url}")
    driver.get(site_url)
    time.sleep(DELAY)

    print("\nETAPA 1: LOGIN")
    try:
        print("Procurando campos de login...")
        email_input = WebDriverWait(driver, 10).until(
            EC.visibility_of_element_located((By.ID, "emailLogin"))
        )
        pass_input = driver.find_element(By.ID, "senhaLogin")
        login_btn = driver.find_element(By.CSS_SELECTOR, "#formLogin .submit-btn")

        print(f"Digitando email: {USER_EMAIL}")
        email_input.clear()
        email_input.send_keys(USER_EMAIL)
        time.sleep(1)

        print("Digitando senha...")
        pass_input.clear()
        pass_input.send_keys(USER_PASS)
        time.sleep(DELAY)
        
        print("Clicando em 'Entrar'...")
        driver.execute_script("arguments[0].click();", login_btn)

        print("Aguardando redirecionamento...")
        WebDriverWait(driver, 60).until(EC.url_contains("dashboard.html"))
        
        print("Verificando se o menu carregou...")
        WebDriverWait(driver, 20).until(
            EC.element_to_be_clickable((By.ID, "btn-ver-maquinas"))
        )
        print("SUCESSO: Dashboard carregado!")
        time.sleep(DELAY)

    except Exception as e:
        raise Exception(f"Falha no Login: {e}")
    
        print("\nETAPA 2: VER ESTATÍSTICAS")
    
    print("Clicando no menu 'Estatísticas'...")
    btn_stats = driver.find_element(By.ID, "btn-ver-estatisticas")
    driver.execute_script("arguments[0].click();", btn_stats)
    time.sleep(DELAY)
    
    try:
        print("Verificando cards e gráficos...")
        total_el = WebDriverWait(driver, 10).until(
            EC.visibility_of_element_located((By.ID, "stats-total"))
        )
        
        WebDriverWait(driver, 10).until(
            lambda d: total_el.text != "..." and total_el.text != "Carregando" and total_el.text != ""
        )
        print(f"Total Analisado no Card: {total_el.text}")
        
        driver.find_element(By.ID, "historyChart")
        print("Gráfico de Histórico carregado (elemento <canvas> encontrado).")
        time.sleep(DELAY)
        
    except Exception as e:
        raise Exception(f"Falha nas Estatísticas: {e}")