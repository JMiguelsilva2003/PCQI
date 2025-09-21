import cv2
import numpy as np

class CameraManager:
    @staticmethod
    def list_available_cameras():
        available_cameras = []
        print("Buscando câmeras disponíveis...")
        for i in range(10):
            cap = cv2.VideoCapture(i)
            if cap.isOpened():
                print(f"  - Câmera encontrada no índice: {i}")
                available_cameras.append(i)
                cap.release()
        if not available_cameras:
            print("Nenhuma câmera encontrada.")
        return available_cameras

    def __init__(self, camera_index=0):
        print(f"\nTentando iniciar a câmera no índice {camera_index}...")
        self.cap = cv2.VideoCapture(camera_index)
        if not self.cap.isOpened():
            raise IOError(f"Não foi possível abrir a câmera no índice {camera_index}")
        
        self.roi_x = 200
        self.roi_y = 120
        self.roi_width = 240
        self.roi_height = 240
        
        print(f"Câmera {camera_index} iniciada com sucesso!")

    def get_frame(self):
        ret, frame = self.cap.read()
        return ret, frame

    def get_roi_frame(self, frame: np.ndarray):
        roi_frame = frame[self.roi_y : self.roi_y + self.roi_height, self.roi_x : self.roi_x + self.roi_width]
        return roi_frame

    def release(self):
        self.cap.release()
        print("Câmera liberada.")

if __name__ == '__main__':
    cameras = CameraManager.list_available_cameras()
    
    if cameras:
        choice = input(f"\nDigite o número da câmera que deseja usar {cameras}: ")
        
        try:
            camera_index = int(choice)
            if camera_index not in cameras:
                raise ValueError("Índice de câmera inválido.")

            cam = CameraManager(camera_index)

            while True:
                ret, frame = cam.get_frame()
                if not ret:
                    break
                
                cv2.rectangle(
                    frame, 
                    (cam.roi_x, cam.roi_y), 
                    (cam.roi_x + cam.roi_width, cam.roi_y + cam.roi_height), 
                    (0, 255, 0), 2
                )
                
                cv2.putText(frame, "Pressione ESPACO para capturar ROI", (10, 30), cv2.FONT_HERSHEY_SIMPLEX, 0.7, (255, 255, 255), 2)
                cv2.putText(frame, "Pressione Q para sair", (10, 60), cv2.FONT_HERSHEY_SIMPLEX, 0.7, (255, 255, 255), 2)

                cv2.imshow('Câmera - Viseira da IA', frame)
                
                key = cv2.waitKey(1) & 0xFF
                if key == ord('q'):
                    break
                if key == 32:
                    roi = cam.get_roi_frame(frame)
                    cv2.imshow('ROI Capturada', roi)

            cam.release()
            cv2.destroyAllWindows()
            
        except (ValueError, IOError) as e:
            print(f"Erro: {e}")