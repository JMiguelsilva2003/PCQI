import pytest
import os
from fastapi.testclient import TestClient
from sqlalchemy.orm import Session
from app import crud, models
from app.security import create_access_token 

def test_read_root(client: TestClient):
    """ Testa a rota raiz (GET /). """
    response = client.get("/")
    assert response.status_code == 200
    assert response.json() == {"message": "Bem-vindo à API do PCQI v2!"}

def test_verify_email(client: TestClient, db_session: Session):
    """
    Testa o fluxo de verificação de email (GET /api/v1/auth/verify-email).
    """
    user_in = models.User(
        email="verify@example.com",
        name="Verify User",
        hashed_password=crud.hash_password("password123"),
        is_active=False
    )
    db_session.add(user_in)
    db_session.commit()
    db_session.refresh(user_in)
    
    assert user_in.is_active is False

    token = create_access_token(data={"sub": user_in.email})

    response = client.get(f"/api/v1/auth/verify-email?token={token}")
    
    assert response.status_code == 200
    assert response.json()["message"] == "Email verified successfully!"
    
    db_session.refresh(user_in)
    assert user_in.is_active is True

def test_refresh_token(user_auth_client: TestClient):
    """
    Testa se um token de acesso válido pode ser usado para 
    obter um novo par de tokens.
    (POST /api/v1/auth/refresh)
    """
    response = user_auth_client.post("/api/v1/auth/refresh")
    
    assert response.status_code == 200
    data = response.json()
    assert "access_token" in data
    assert "refresh_token" in data
    assert data["token_type"] == "bearer"


def test_list_sectors_permissions(
    admin_auth_client: TestClient, 
    user_auth_client: TestClient, 
    populate_stats_data 
):
    """
    Testa a lógica de listagem de setores:
    - Admin deve ver todos os setores.
    - User deve ver APENAS o Setor A.
    """
    resp_admin = admin_auth_client.get("/api/v1/sectors/")
    assert resp_admin.status_code == 200
    admin_data = resp_admin.json()
    assert len(admin_data) >= 2 
    nomes_admin = [s["name"] for s in admin_data]
    assert "Setor A de Stats" in nomes_admin
    assert "Setor B de Stats" in nomes_admin

    resp_user = user_auth_client.get("/api/v1/sectors/")
    assert resp_user.status_code == 200
    user_data = resp_user.json()
    assert len(user_data) == 1
    assert user_data[0]["name"] == "Setor A de Stats"

def test_list_machines_permissions(
    admin_auth_client: TestClient, 
    user_auth_client: TestClient, 
    populate_stats_data
):
    """
    Testa a lógica de listagem de máquinas:
    - Admin deve ver todas as máquinas.
    - User deve ver APENAS a Máquina A1.
    """
    resp_admin = admin_auth_client.get("/api/v1/machines/")
    assert resp_admin.status_code == 200
    admin_data = resp_admin.json()
    assert len(admin_data) >= 2
    nomes_admin = [m["name"] for m in admin_data]
    assert "Maquina A1" in nomes_admin
    assert "Maquina B1" in nomes_admin
    
    resp_user = user_auth_client.get("/api/v1/machines/")
    assert resp_user.status_code == 200
    user_data = resp_user.json()
    assert len(user_data) == 1
    assert user_data[0]["name"] == "Maquina A1"

def test_hardware_api_key_protection(
    client: TestClient, 
    setup_machine_data, 
    db_session: Session
):
    """
    Testa a segurança da X-API-Key nas rotas de hardware e a lógica de fila vazia.
    """
    _, machine_a, _, _ = setup_machine_data
    
    machine_id = machine_a['id']
    api_key = os.getenv("API_KEY") 
    
    headers_good = {"X-API-Key": api_key}
    headers_bad = {"X-API-Key": "CHAVE_ERRADA"}
    headers_none = {}
    
    resp_post_none = client.post(
        f"/api/v1/machines/{machine_id}/commands", 
        headers=headers_none, 
        json={"prediction": "MATURA"}
    )
    assert resp_post_none.status_code == 422 

    resp_post_bad = client.post(
        f"/api/v1/machines/{machine_id}/commands", 
        headers=headers_bad, 
        json={"prediction": "MATURA"}
    )
    assert resp_post_bad.status_code == 401
    
    resp_get_none = client.get(f"/api/v1/machines/{machine_id}/commands/next", headers=headers_none)
    assert resp_get_none.status_code == 422

    resp_get_bad = client.get(f"/api/v1/machines/{machine_id}/commands/next", headers=headers_bad)
    assert resp_get_bad.status_code == 401

    resp_get_empty = client.get(f"/api/v1/machines/{machine_id}/commands/next", headers=headers_good)
    assert resp_get_empty.status_code == 204

    resp_post_good = client.post(
        f"/api/v1/machines/{machine_id}/commands", 
        headers=headers_good, 
        json={"prediction": "TEST_COMMAND"}
    )
    assert resp_post_good.status_code == 201
    
    resp_get_filled = client.get(f"/api/v1/machines/{machine_id}/commands/next", headers=headers_good)
    assert resp_get_filled.status_code == 200
    assert resp_get_filled.json()["action"] == "TEST_COMMAND"
    
    resp_get_empty_again = client.get(f"/api/v1/machines/{machine_id}/commands/next", headers=headers_good)
    assert resp_get_empty_again.status_code == 204