import pytest
import numpy as np
import cv2
from collections import Counter

from local_api.utils.quality import check_image_quality, LIMITE_DESFOQUE
from local_api.state_manager import AnalysisStateManager, FRAMES_PARA_INICIAR, FRAMES_PARA_TERMINAR

@pytest.fixture
def clean_image_bytes():
    img = np.zeros((50, 50, 3), dtype=np.uint8)
    img[10:40, 10:40] = 255
    _, buffer = cv2.imencode('.jpg', img)
    return buffer.tobytes()

@pytest.fixture
def blurry_image_bytes():
    img = np.full((50, 50, 3), 120, dtype=np.uint8)
    _, buffer = cv2.imencode('.jpg', img)
    return buffer.tobytes()

def test_quality_check_passes_on_sharp_image(clean_image_bytes):
    result = check_image_quality(clean_image_bytes)
    assert result['valid'] is True

def test_quality_check_fails_on_blurry_image(blurry_image_bytes):
    result = check_image_quality(blurry_image_bytes)
    assert result['valid'] is False
    assert "Imagem desfocada" in result['error']

def test_quality_threshold_is_respected(clean_image_bytes):
    result = check_image_quality(clean_image_bytes)
    assert 'Score:' in result['error'] 
    assert result['valid'] is True

def test_state_manager_starts_awaiting():
    manager = AnalysisStateManager()
    state, decision = manager.process_prediction("FUNDO")
    assert state == "Aguardando"
    assert decision is None

def test_state_manager_transitions_to_analyzing():
    manager = AnalysisStateManager()
    N = FRAMES_PARA_INICIAR
    
    for _ in range(N - 1):
        state, _ = manager.process_prediction("MATURA")
        assert state == "Aguardando"
    state, _ = manager.process_prediction("MATURA")
    assert state == "Analisando"

def test_state_manager_aggregates_and_decides_correctly():
    manager = AnalysisStateManager()
    
    for _ in range(FRAMES_PARA_INICIAR):
        manager.process_prediction("VERDE")

    for i in range(10):
        pred = "MATURA" if i < 7 else "VERDE"
        manager.process_prediction(pred)

    for _ in range(FRAMES_PARA_TERMINAR - 1):
        state, decision = manager.process_prediction("FUNDO")
        assert state == "Analisando"
        assert decision is None

    state, decision = manager.process_prediction("FUNDO")
    
    assert decision == "MATURA"
    assert state == "Aguardando"
    assert len(manager.current_frames) == 0

def test_state_manager_resets_on_decision():
    manager = AnalysisStateManager()
    
    for _ in range(FRAMES_PARA_INICIAR + 5):
        manager.process_prediction("MATURA")

    for _ in range(FRAMES_PARA_TERMINAR):
        manager.process_prediction("FUNDO")
        
    state, _ = manager.process_prediction("MATURA")
    assert state == "Aguardando" 
    assert manager.object_frames_count == 1