from collections import Counter

FRAMES_PARA_INICIAR = 2   
FRAMES_PARA_TERMINAR = 15  
MIN_FRAMES_ANALISE = 5    

class AnalysisStateManager:
    def __init__(self):
        self.reset()

    def reset(self):
        """Reseta o estado para AGUARDANDO (pronto para a próxima manga)."""
        self.state = "Aguardando"
        self.current_frames = [] 
        self.background_frames_count = 0 
        self.object_frames_count = 0  
        print("State Manager: Resetado. AGUARDANDO.")

    def process_prediction(self, prediction: str) -> (str, str | None):
        final_decision = None
        
        pred_upper = prediction.upper() 

        if self.state == "Aguardando":
            if pred_upper != 'FUNDO':
                self.object_frames_count += 1
                self.background_frames_count = 0
                
                if self.object_frames_count >= FRAMES_PARA_INICIAR:
                    self.state = "Analisando"
                    self.current_frames = [prediction] * self.object_frames_count
                    print(f"State Manager: Manga detectada ({prediction}). Mudando para ANALISANDO.")
            else:
                self.object_frames_count = 0
        
        elif self.state == "Analisando":
            if pred_upper != 'FUNDO':
                self.current_frames.append(prediction)
                self.background_frames_count = 0
            else:
                self.background_frames_count += 1
                
                if self.background_frames_count >= FRAMES_PARA_TERMINAR:
                    final_decision = self._make_decision()
                    self.reset()
        
        return self.state, final_decision

    def _make_decision(self) -> str | None:
        
        print(f"State Manager: DECIDINDO com {len(self.current_frames)} frames.")
        
        if len(self.current_frames) < MIN_FRAMES_ANALISE:
            print("Decisão: Nenhuma (poucos frames).")
            return None

        counts = Counter(self.current_frames)
        
        final_decision = counts.most_common(1)[0][0] 
        
        print(f"Decisão: {final_decision} (Contagem: {counts})")
        return final_decision