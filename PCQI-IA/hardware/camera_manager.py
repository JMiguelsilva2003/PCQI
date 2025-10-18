import serial
import time
import requests
import os
from dotenv import load_dotenv

load_dotenv()

API_RENDER_URL = os.getenv("RENDER_API_URL")
MACHINE_ID = 1
API_KEY = os.getenv("HARDWARE_API_KEY") 

ARDUINO_PORT = 'COM3'
ARDUINO_BAUDRATE = 9600

try:
    arduino_serial = serial.Serial(ARDUINO_PORT, ARDUINO_BAUDRATE, timeout=1)
    time.sleep(2)
    print(f"Conexão com o Arduino na porta {ARDUINO_PORT} estabelecida.")
except serial.SerialException as e:
    print(f"ERRO: Não foi possível conectar ao Arduino. {e}")
    arduino_serial = None

def enviar_comando_arduino(comando: str):
    """Envia um comando serial para o Arduino."""
    if arduino_serial and arduino_serial.is_open:
        print(f"[ARDUINO] Enviando comando: {comando}")
        arduino_serial.write(f"{comando}\n".encode())
    else:
        print(f"[SIMULAÇÃO] Arduino não conectado. Comando seria: {comando}")

def buscar_proximo_comando():
    """Pergunta ao Render se há um novo comando na fila."""
    try:
        headers = {"X-API-Key": API_KEY}
        url = f"{API_RENDER_URL}/api/v1/machines/{MACHINE_ID}/commands/next"
        
        response = requests.get(url, headers=headers, timeout=5)
        
        if response.status_code == 200:
            data = response.json()
            if data and data.get("action"):
                return data["action"]
        
        elif response.status_code == 204:
            return None
        
        # Outros erros
        else:
            print(f"Erro ao buscar comando: {response.status_code}")
            return None
        
    except requests.RequestException as e:
        print(f"Erro de conexão ao buscar comando: {e}")
        return None

def run_gateway():
    """Loop principal do Gateway de Hardware."""
    print(f"Gateway de Hardware para Máquina {MACHINE_ID} iniciado.")
    print(f"Perguntando à API em: {API_RENDER_URL}")
    
    while True:
        comando = buscar_proximo_comando()
        
        if comando:
            if comando == "REJECT":
                enviar_comando_arduino("REJECT")
            elif comando == "ACCEPT":
                print("Peça 'preto' (ou b) aceita.")
            
            enviar_comando_arduino("MOVE")
        
        time.sleep(1)

if __name__ == "__main__":
    if not all([API_RENDER_URL, API_KEY]):
        print("ERRO: Variáveis de ambiente RENDER_API_URL ou HARDWARE_API_KEY não definidas.")
    else:
        run_gateway()