from fastapi.testclient import TestClient
from app import models, schemas

def test_read_own_user_data(user_auth_client: TestClient, test_user: models.User):
    """Testa se um usuário logado pode ler seus próprios dados."""
    response = user_auth_client.get("/api/v1/users/me")
    assert response.status_code == 200
    data = response.json()
    assert data["email"] == test_user.email


def test_update_own_password(client: TestClient, test_user: models.User):
    """Testa se um usuário pode atualizar sua senha e logar com a nova."""
    
    login_response = client.post(
        "/api/v1/auth/login",
        data={"username": test_user.email, "password": "password123"}
    )
    assert login_response.status_code == 200
    token = login_response.json()["access_token"]
    headers = {"Authorization": f"Bearer {token}"}
    
    new_password = "newpassword123"
    response = client.put(
        "/api/v1/users/me",
        headers=headers,
        json={"password": new_password}
    )
    assert response.status_code == 200
    
    fail_response = client.post(
        "/api/v1/auth/login",
        data={"username": test_user.email, "password": "password123"}
    )
    assert fail_response.status_code == 401

    success_response = client.post(
        "/api/v1/auth/login",
        data={"username": test_user.email, "password": new_password}
    )
    assert success_response.status_code == 200
    assert "access_token" in success_response.json()


def test_unauthenticated_user_cannot_update(client: TestClient):
    """Garante que um usuário não logado não pode acessar as rotas /me."""
    response = client.put("/api/v1/users/me", json={"name": "hacker"})
    assert response.status_code == 401