import random
from app import crud

def test_create_user_success(client, monkeypatch):
    """
    Testa se um novo usuário pode ser criado.
    """
    def mock_send_email(email: str):
        print(f"MOCK: Email de verificação seria enviado para {email}")

    monkeypatch.setattr("app.routers.auth.send_verification_email", mock_send_email)

    random_email = f"testuser{random.randint(1000, 9999)}@example.com"
    response = client.post(
        "/api/v1/auth/register",
        json={"name": "Test Name", "email": random_email, "password": "testpassword123"},
    )
    
    assert response.status_code == 200
    data = response.json()
    assert data["email"] == random_email
    assert data["name"] == "Test Name"
    assert data["is_active"] is False


def test_login_fails_for_unverified_user(client):
    """
    Garante que um usuário com email não verificado (is_active=False) não pode logar.
    Isso testa uma importante feature de segurança.
    """
    email = f"unverified.{random.randint(1000, 9999)}@example.com"
    password = "password123"
    
    # Cria o usuário
    client.post("/api/v1/auth/register", json={"name": "Unverified User", "email": email, "password": password})

    # Tenta fazer login com o usuário criado
    response = client.post("/api/v1/auth/login", data={"username": email, "password": password})
    
    # Verifica se a API retornou o erro correto
    assert response.status_code == 400
    assert response.json()["detail"] == "Email has not been verified"


def test_password_recovery_flow(client, monkeypatch, db_session):
    """
    Testa o fluxo completo de recuperação de senha
    """
    
    captured_token = None
    
    def mock_send_password_reset(email: str):
        nonlocal captured_token
        from app.security import create_access_token
        captured_token = create_access_token(data={"sub": email})
        print("MOCK: Email de reset de senha seria enviado.")

    monkeypatch.setattr("app.routers.auth.send_password_reset_email", mock_send_password_reset)

    # 1. Cria e ativa um usuário para o teste
    email = f"reset.{random.randint(1000, 9999)}@example.com"
    old_password = "oldpassword"
    register_response = client.post("/api/v1/auth/register", json={"name": "Reset Test", "email": email, "password": old_password})
    user_id = register_response.json()["id"]
    
    user_in_db = crud.get_user(db_session, user_id=user_id)
    crud.activate_user(db_session, user=user_in_db)

    # 2. Solicita a redefinição de senha
    response = client.post("/api/v1/auth/forgot-password", json={"email": email})
    assert response.status_code == 200
    assert captured_token is not None

    # 3. Reseta a senha com o token capturado
    new_password = "newpassword123"
    response = client.post("/api/v1/auth/reset-password", json={"token": captured_token, "new_password": new_password})
    assert response.status_code == 200
    assert response.json()["message"] == "Password has been reset successfully."

    # 4. Tenta logar com a senha ANTIGA (deve falhar)
    response = client.post("/api/v1/auth/login", data={"username": email, "password": old_password})
    assert response.status_code == 401
    
    # 5. Tenta logar com a senha NOVA (deve funcionar)
    response = client.post("/api/v1/auth/login", data={"username": email, "password": new_password})
    assert response.status_code == 200
    assert "access_token" in response.json()