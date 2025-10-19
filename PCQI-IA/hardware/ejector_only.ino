#include <Stepper.h>

const int PASSOS_POR_VOLTA = 2048; [cite: 3234]

const int IN1 = 8;
const int IN2 = 9;
const int IN3 = 10;
const int IN4 = 11;
Stepper myStepper(PASSOS_POR_VOLTA, IN1, IN3, IN2, IN4); [cite: 3236]

// --- CONSTANTES DE MOVIMENTO ---
// Quantidade de passos para o ejetor "empurrar" (512 = 90 graus)
const int PASSOS_PARA_EJETAR = 512;
const int VELOCIDADE_EJECAO = 15; // Velocidade do motor

String comandoRecebido = "";

void setup() {
  Serial.begin(9600);
  myStepper.setSpeed(VELOCIDADE_EJECAO); 
  Serial.println("Controlador de Ejeção (Motor de Passo) online.");
}

void loop() {
  if (Serial.available() > 0) {
    comandoRecebido = Serial.readStringUntil('\n');
    comandoRecebido.trim();
    
    if (comandoRecebido == "REJECT") {
      ejetarPeca();
    }
  }
}

void ejetarPeca() {
  Serial.println("Comando 'REJECT' recebido. Ejetando...");
  
  myStepper.step(PASSOS_PARA_EJETAR);
  
  delay(300); 
  
  myStepper.step(-PASSOS_PARA_EJETAR);
  
  Serial.println("Ejetor retornou à posição inicial.");
  
  digitalWrite(IN1, LOW);
  digitalWrite(IN2, LOW);
  digitalWrite(IN3, LOW);
  digitalWrite(IN4, LOW);
}