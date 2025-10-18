#include <Stepper.h>
#include <Servo.h>

// --- PINOS ---
// Motor de Passo
const int STEPPER_PIN_1 = 8;
const int STEPPER_PIN_2 = 9;
const int STEPPER_PIN_3 = 10;
const int STEPPER_PIN_4 = 11;

// Servo Motor (ejetor)
const int SERVO_PIN = 7;

// --- CONSTANTES ---
const int STEPS_PER_REVOLUTION = 2048; // Padrão do 28BYJ-48
const int MOTOR_SPEED = 12;            // Velocidade do motor (1-15)
const int SERVO_HOME_POS = 0;          // Posição de repouso (0 graus)
const int SERVO_REJECT_POS = 90;       // Posição para ejetar (90 graus)
const int STEPS_TO_MOVE = 512;         // Avança 1/4 de volta a cada comando

// --- OBJETOS GLOBAIS ---
Stepper stepper(STEPS_PER_REVOLUTION, STEPPER_PIN_1, STEPPER_PIN_3, STEPPER_PIN_2, STEPPER_PIN_4);
Servo rejectServo;

void setup() {
  Serial.begin(9600);
  stepper.setSpeed(MOTOR_SPEED);
  rejectServo.attach(SERVO_PIN);
  rejectServo.write(SERVO_HOME_POS);
  Serial.println("Controlador PCQI online.");
}

void loop() {
  // Se houver dados na porta serial
  if (Serial.available() > 0) {
    String comandoRecebido = Serial.readStringUntil('\n');
    comandoRecebido.trim();
    
    // Processa os comandos recebidos
    if (comandoRecebido == "MOVE") {
      moveConveyor();
    } else if (comandoRecebido == "REJECT") {
      rejectPiece();
    }
  }
}

// Função para avançar a esteira
void moveConveyor() {
  Serial.println("Comando 'MOVE' recebido. Avançando...");
  stepper.step(STEPS_TO_MOVE);
  Serial.println("Avanço concluído.");
}

// Função para acionar o ejetor
void rejectPiece() {
  Serial.println("Comando 'REJECT' recebido. Ejetando...");
  rejectServo.write(SERVO_REJECT_POS);
  delay(500); // Pausa para o braço atuar
  rejectServo.write(SERVO_HOME_POS);
  delay(500); // Pausa para o braço retornar
  Serial.println("Ejetor retornou.");
}