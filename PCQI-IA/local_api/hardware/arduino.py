import serial
import time
from local_api.config import ARDUINO_PORT, ARDUINO_BAUDRATE

arduino_serial = None

def connect_to_arduino():
    global arduino_serial
    try:
        arduino_serial = serial.Serial(port=ARDUINO_PORT, baudrate=ARDUINO_BAUDRATE, timeout=.1)
        time.sleep(2)
        print(f"Conexão com o Arduino na porta {ARDUINO_PORT} estabelecida com sucesso!")
    except serial.SerialException as e:
        print(f"AVISO: Não foi possível conectar ao Arduino. A API rodará em modo de simulação. Erro: {e}")
        arduino_serial = None

def send_command(comando: str):
    if arduino_serial and arduino_serial.is_open:
        print(f"Enviando comando para o Arduino: '{comando}'")
        arduino_serial.write(f"{comando}\n".encode())
        time.sleep(1)
    else:
        print(f"SIMULAÇÃO (Arduino não conectado): Comando '{comando}' seria enviado.")

def close_connection():
    if arduino_serial and arduino_serial.is_open:
        arduino_serial.close()
        print("Conexão com o Arduino encerrada.")