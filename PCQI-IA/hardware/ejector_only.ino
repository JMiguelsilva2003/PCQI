#include <Stepper.h>

const int PASSOS_POR_VOLTA = 2048;
const int IN1 = 8;
const int IN2 = 9;
const int IN3 = 10;
const int IN4 = 11;

Stepper myStepper(PASSOS_POR_VOLTA, IN1, IN3, IN2, IN4);

// --- CONSTANTES DE MOVIMENTO ---
const int PASSOS_PARA_EJETAR = 512; // 512 passos = 90 graus
const int VELOCIDADE_EJECAO = 15; 

String comandoRecebido = "";

// --- FUNÇÃO SETUP ---
void setup() {
  Serial.begin(9600);
  myStepper.setSpeed(VELOCIDADE_EJECAO); 
  Serial.println("Controlador de Ejeção (Motor de Passo) online.");
}

// --- FUNÇÃO LOOP ---
void loop() {
  if (Serial.available() > 0) {
    comandoRecebido = Serial.readStringUntil('\n');
    comandoRecebido.trim();
    
    if (comandoRecebido == "REJECT") {
      ejetarPeca();
    }
  }
}

// --- FUNÇÃO DE AÇÃO ---
void ejetarPeca() {
  Serial.println("Comando 'REJECT' recebido. Ejetando...");
  
  // 1. Gira para "empurrar" a peça
  myStepper.step(PASSOS_PARA_EJETAR);
  
  delay(300); // Pausa
  
  // 2. Gira de volta para a posição inicial
  myStepper.step(-PASSOS_PARA_EJETAR);
  
  Serial.println("Ejetor retornou à posição inicial.");
  
  // Desliga os pinos do motor para economizar energia
  digitalWrite(IN1, LOW);
  digitalWrite(IN2, LOW);
  digitalWrite(IN3, LOW);
  digitalWrite(IN4, LOW);
}