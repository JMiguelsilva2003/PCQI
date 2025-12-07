import random
from app import crud, models
from app.security import create_access_token

def test_create_user_success(client, monkeypatch):
    """
    Testa se um novo usuário pode ser criado.
    ADAPTADO: Verifica se is_active é True (pois ativamos o auto-cadastro).
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
    assert data["is_active"] is True


def test_login_fails_for_unverified_user(client, db_session):
    """
    Garante que um usuário com email não verificado (is_active=False) não pode logar.
    ADAPTADO: Precisamos desativar o usuário manualmente no banco para testar isso,
    já que o registro agora ativa automaticamente.
    """
    email = f"unverified.{random.randint(1000, 9999)}@example.com"
    password = "password123"
    
    # 1. Cria o usuário
    resp = client.post("/api/v1/auth/register", json={"name": "Unverified User", "email": email, "password": password})
    user_id = resp.json()["id"]

    # 2. Forçar o estado 'Inativo' no banco para poder testar o bloqueio
    user_db = crud.get_user(db_session, user_id)
    user_db.is_active = False
    db_session.commit()

    # 3. Tenta fazer login com o usuário (agora inativo)
    response = client.post("/api/v1/auth/login", data={"username": email, "password": password})
    
    # Verifica se a API retornou o erro correto
    assert response.status_code == 400
    assert response.json()["detail"] == "Email has not been verified"


def test_password_recovery_flow(client, db_session):
    """
    Testa o fluxo completo de recuperação de senha.
    ADAPTADO: Gera o token manualmente, pois o envio de email está desligado.
    """
    
    # 1. Cria e ativa um usuário
    email = f"reset.{random.randint(1000, 9999)}@example.com"
    old_password = "oldpassword"
    client.post("/api/v1/auth/register", json={"name": "Reset Test", "email": email, "password": old_password})

    # 2. Solicita a redefinição (Apenas para verificar se a rota não quebra)
    response = client.post("/api/v1/auth/forgot-password", json={"email": email})
    assert response.status_code == 200

    # 3. Gerar Token Manualmente
    reset_token = create_access_token(data={"sub": email})

    # 4. Reseta a senha usando o token gerado
    new_password = "newpassword123"
    response = client.post("/api/v1/auth/reset-password", json={"token": reset_token, "new_password": new_password})
    
    assert response.status_code == 200
    assert response.json()["message"] == "Password has been reset successfully."

    # 5. Tenta logar com a senha ANTIGA (deve falhar)
    response = client.post("/api/v1/auth/login", data={"username": email, "password": old_password})
    assert response.status_code == 401
    
    # 6. Tenta logar com a senha NOVA (deve funcionar)
    response = client.post("/api/v1/auth/login", data={"username": email, "password": new_password})
    assert response.status_code == 200
    assert "access_token" in response.json()