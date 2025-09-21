import cv2
import numpy as np
from pygrabber.dshow_graph import FilterGraph

class CameraManager:
    @staticmethod
    def list_available_cameras():

        devices = FilterGraph()
        cameras = devices.get_input_devices()
        
        available_cameras = {}
        print("Buscando câmeras disponíveis...")
        if cameras:
            for i, name in enumerate(cameras):
                available_cameras[i] = name
                print(f"  - Câmera encontrada: {i} -> {name}")
        else:
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
        try:
            choice_str = input(f"\nDigite o NÚMERO da câmera que deseja usar: ")
            camera_index = int(choice_str)
            
            if camera_index not in cameras:
                raise ValueError(f"Índice de câmera '{camera_index}' inválido.")

            print(f"Iniciando a câmera: {cameras[camera_index]}")
            cam = CameraManager(camera_index)

            while True:
                ret, frame = cam.get_frame()
                if not ret: break
                
                cv2.rectangle(frame, (cam.roi_x, cam.roi_y), (cam.roi_x + cam.roi_width, cam.roi_y + cam.roi_height), (0, 255, 0), 2)
                cv2.putText(frame, "Pressione ESPACO para capturar ROI", (10, 30), cv2.FONT_HERSHEY_SIMPLEX, 0.7, (255, 255, 255), 2)
                cv2.putText(frame, "Pressione Q para sair", (10, 60), cv2.FONT_HERSHEY_SIMPLEX, 0.7, (255, 255, 255), 2)
                cv2.imshow('Câmera - Viseira da IA', frame)
                
                key = cv2.waitKey(1) & 0xFF
                if key == ord('q'): break
                if key == 32:
                    roi = cam.get_roi_frame(frame)
                    cv2.imshow('ROI Capturada', roi)

            cam.release()
            cv2.destroyAllWindows()
            
        except (ValueError, IOError, KeyError) as e:
            print(f"Erro: {e}. Certifique-se de digitar um número válido da lista.")