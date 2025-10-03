from PIL import Image
import io

def test_root_health_check(client):
    response = client.get("/")
    assert response.status_code == 200
    assert response.json() == {"status": "PCQI Local AI API está online e pronta!"}

def test_predict_success_black_image(client):

    img = Image.new('RGB', (128, 128), color = 'black')
    
    img_byte_arr = io.BytesIO()
    img.save(img_byte_arr, format='JPEG')
    img_byte_arr.seek(0)

    response = client.post(
        "/predict",
        files={"file": ("test_black.jpg", img_byte_arr, "image/jpeg")}
    )

    assert response.status_code == 200
    data = response.json()
    assert "prediction" in data
    assert "confidence" in data
    assert data["prediction"] == "preto"

def test_predict_invalid_file_type(client):

    text_file_content = b"isso nao e uma imagem"
    
    response = client.post(
        "/predict",
        files={"file": ("test.txt", text_file_content, "text/plain")}
    )

    assert response.status_code == 400
    assert "Formato de arquivo inválido" in response.json()["detail"]