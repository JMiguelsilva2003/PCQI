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

    print("\nETAPA 2: CRIAR MÁQUINA")
    
    print("Clicando na aba 'Ver Máquinas'...")
    btn_nav = driver.find_element(By.ID, "btn-ver-maquinas")
    driver.execute_script("arguments[0].click();", btn_nav)
    time.sleep(DELAY)
    
    print("Clicando em '+ Criar Nova Máquina'...")
    try:
        btn_criar = WebDriverWait(driver, 10).until(
            EC.presence_of_element_located((By.ID, "btn-criar-maquina"))
        )
        driver.execute_script("arguments[0].click();", btn_criar)
        time.sleep(DELAY)
    except Exception as e:
        raise Exception(f"Erro ao abrir formulário: {e}")

    nome_original = f"Maq Teste {int(time.time())}"
    print(f"Preenchendo nome: '{nome_original}'")
    
    try:
        nome_input = WebDriverWait(driver, 10).until(
            EC.visibility_of_element_located((By.ID, "machine-name"))
        )
        nome_input.clear()
        nome_input.send_keys(nome_original)
        time.sleep(1)
        
        print("Selecionando setor (Seta Baixo + Enter)...")
        sel = driver.find_element(By.ID, "machine-sector")
        sel.click()
        time.sleep(1)
        sel.send_keys(Keys.ARROW_DOWN)
        sel.send_keys(Keys.ENTER)
        time.sleep(DELAY)

        print("Salvando...")
        save_btn = driver.find_element(By.CSS_SELECTOR, "#form-create-machine button[type='submit']")
        driver.execute_script("arguments[0].click();", save_btn)
        
        WebDriverWait(driver, 10).until(EC.alert_is_present())
        alert_text = driver.switch_to.alert.text
        print(f"Alerta do site: '{alert_text}'")
        driver.switch_to.alert.accept()
        print("Máquina criada.")
        
    except Exception as e:
        raise Exception(f"Erro na criação: {e}")
    
    print("Aguardando lista atualizar...")
    time.sleep(3) 

    print("\nETAPA 3: EDITAR MÁQUINA")
    
    try:
        print(f"Procurando botão 'Editar' para '{nome_original}'...")
        edit_btn = WebDriverWait(driver, 10).until(
            EC.presence_of_element_located((By.CSS_SELECTOR, f"button.edit-machine[data-machine-name='{nome_original}']"))
        )
        driver.execute_script("arguments[0].scrollIntoView({block: 'center'});", edit_btn)
        time.sleep(DELAY)
        
        print("Clicando em 'Editar'...")
        driver.execute_script("arguments[0].click();", edit_btn)
        
        alert_prompt = WebDriverWait(driver, 5).until(EC.alert_is_present())
        print(f"Prompt aberto com texto: '{alert_prompt.text}'")
        
        novo_nome = f"{nome_original} EDITADA"
        print(f"Digitando novo nome: '{novo_nome}'")
        alert_prompt.send_keys(novo_nome)
        time.sleep(DELAY)
        alert_prompt.accept()
        
        WebDriverWait(driver, 5).until(EC.alert_is_present())
        driver.switch_to.alert.accept()
        print("Edição confirmada.")
        
        time.sleep(2)
        if novo_nome in driver.page_source:
            print("Visual: Nome atualizado na lista com sucesso!")
        else:
            raise Exception("Nome não mudou visualmente.")

    except Exception as e:
        raise Exception(f"Falha na Edição: {e}")

    print("\nETAPA 4: VER ESTATÍSTICAS")
    
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

    print("\nETAPA 5: DELETAR MÁQUINA")
    
    print("Voltando para lista de máquinas...")
    btn_nav = driver.find_element(By.ID, "btn-ver-maquinas")
    driver.execute_script("arguments[0].click();", btn_nav)
    time.sleep(DELAY)
    
    try:
        print(f"Procurando botão 'Excluir' para '{novo_nome}'...")
        delete_btn = WebDriverWait(driver, 10).until(
            EC.presence_of_element_located((By.CSS_SELECTOR, f"button.delete-machine[data-machine-name='{novo_nome}']"))
        )
        driver.execute_script("arguments[0].scrollIntoView({block: 'center'});", delete_btn)
        time.sleep(DELAY)
        
        print("Clicando em 'Excluir'...")
        driver.execute_script("arguments[0].click();", delete_btn)
        
        confirm_alert = WebDriverWait(driver, 5).until(EC.alert_is_present())
        print(f"Confirmação: '{confirm_alert.text}'")
        time.sleep(1)
        confirm_alert.accept()
        print("Confirmado.")
        
        WebDriverWait(driver, 5).until(EC.alert_is_present())
        driver.switch_to.alert.accept()
        print("Exclusão concluída.")
        
        time.sleep(2)
        if novo_nome not in driver.page_source:
            print("Visual: Máquina desapareceu da lista!")
        else:
            raise Exception("Máquina ainda visível.")
            
    except Exception as e:
        raise Exception(f"Falha na Exclusão: {e}")

    print("\nTODOS OS TESTES DE UI DA SPRINT 2")
    time.sleep(3)