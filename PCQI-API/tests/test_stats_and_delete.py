import pytest
from fastapi.testclient import TestClient
from sqlalchemy.orm import Session
from app import crud, models, schemas

@pytest.fixture(scope="function")
def populate_stats_data(
    db_session: Session, 
    admin_auth_client: TestClient, 
    user_auth_client: TestClient, 
    test_user: models.User
):
    """
    Cenário para testar estatísticas.
    - Admin cria Setor A e Setor B
    - Admin adiciona 'test_user' ao Setor A
    - 'test_user' cria a Maquina A1 no Setor A
    - Admin cria a Maquina B1 no Setor B
    - Comandos são adicionados via CRUD
    
    TOTAIS ESPERADOS:
    - Maquina A1 (Setor A): 2 MATURA, 1 VERDE     -> Total: 3
    - Maquina B1 (Setor B): 1 MATURA, 3 VERDE, 1 OUTRA -> Total: 5
    
    - Visão do User (Setor A): Total 3 (2 Matura, 1 Verde)
    - Visão do Admin (Geral): Total 8 (3 Matura, 4 Verde, 1 Outra)
    """
    
    resp_A = admin_auth_client.post("/api/v1/sectors/", json={"name": "Setor A de Stats"})
    assert resp_A.status_code == 201
    sector_A = resp_A.json()

    resp_B = admin_auth_client.post("/api/v1/sectors/", json={"name": "Setor B de Stats"})
    assert resp_B.status_code == 201
    sector_B = resp_B.json()

    resp_add = admin_auth_client.post(f"/api/v1/sectors/{sector_A['id']}/members", json={"user_id": test_user.id})
    assert resp_add.status_code == 200

    resp_A1 = user_auth_client.post("/api/v1/machines/", json={"name": "Maquina A1", "sector_id": sector_A['id']})
    assert resp_A1.status_code == 201
    machine_A1 = resp_A1.json()

    resp_B1 = admin_auth_client.post("/api/v1/machines/", json={"name": "Maquina B1", "sector_id": sector_B['id']})
    assert resp_B1.status_code == 201
    machine_B1 = resp_B1.json()

    crud.create_machine_command(db_session, machine_id=machine_A1['id'], action="MATURA")
    crud.create_machine_command(db_session, machine_id=machine_A1['id'], action="MATURA")
    crud.create_machine_command(db_session, machine_id=machine_A1['id'], action="VERDE")

    crud.create_machine_command(db_session, machine_id=machine_B1['id'], action="MATURA")
    crud.create_machine_command(db_session, machine_id=machine_B1['id'], action="VERDE")
    crud.create_machine_command(db_session, machine_id=machine_B1['id'], action="VERDE")
    crud.create_machine_command(db_session, machine_id=machine_B1['id'], action="VERDE")
    crud.create_machine_command(db_session, machine_id=machine_B1['id'], action="OUTRA")

    return {
        "sector_A_id": sector_A['id'],
        "sector_B_id": sector_B['id'],
        "machine_A1_id": machine_A1['id'],
        "machine_B1_id": machine_B1['id']
    }

def test_stats_empty(user_auth_client: TestClient):
    """Testa se as estatísticas vêm vazias quando não há dados."""
    response = user_auth_client.get("/api/v1/stats")
    assert response.status_code == 200
    data = response.json()
    assert data["total"] == 0
    assert data["maduras"] == 0
    assert data["verdes"] == 0
    assert data["outras"] == 0

def test_stats_admin_sees_all(admin_auth_client: TestClient, populate_stats_data):
    """Testa se o admin vê o total de todos os setores."""
    response = admin_auth_client.get("/api/v1/stats")
    assert response.status_code == 200
    data = response.json()
    assert data["total"] == 8
    assert data["maduras"] == 3
    assert data["verdes"] == 4
    assert data["outras"] == 1

def test_stats_user_sees_own_sector_only(user_auth_client: TestClient, populate_stats_data):
    """Testa se o usuário comum vê apenas estatísticas do seu próprio setor."""
    response = user_auth_client.get("/api/v1/stats")
    assert response.status_code == 200
    data = response.json()
    assert data["total"] == 3
    assert data["maduras"] == 2
    assert data["verdes"] == 1
    assert data["outras"] == 0

def test_stats_admin_filter_by_sector(admin_auth_client: TestClient, populate_stats_data):
    """Testa se o admin pode filtrar por um setor específico (Setor B)."""
    sector_B_id = populate_stats_data["sector_B_id"]
    response = admin_auth_client.get(f"/api/v1/stats?sector_id={sector_B_id}")
    assert response.status_code == 200
    data = response.json()
    assert data["total"] == 5
    assert data["maduras"] == 1
    assert data["verdes"] == 3
    assert data["outras"] == 1

def test_stats_user_filter_by_own_machine(user_auth_client: TestClient, populate_stats_data):
    """Testa se o usuário pode filtrar por uma máquina que lhe pertence."""
    machine_A1_id = populate_stats_data["machine_A1_id"]
    response = user_auth_client.get(f"/api/v1/stats?machine_id={machine_A1_id}")
    assert response.status_code == 200
    data = response.json()
    assert data["total"] == 3
    assert data["maduras"] == 2
    assert data["verdes"] == 1

def test_stats_user_cannot_filter_other_sector_machine(user_auth_client: TestClient, populate_stats_data):
    """Testa se o usuário recebe 0 ao tentar filtrar por uma máquina de outro setor."""
    machine_B1_id = populate_stats_data["machine_B1_id"]
    response = user_auth_client.get(f"/api/v1/stats?machine_id={machine_B1_id}")
    assert response.status_code == 200
    data = response.json()
    assert data["total"] == 0
    assert data["maduras"] == 0
    assert data["verdes"] == 0

# Testes das Rotas DELETE

def test_user_can_delete_own_machine(
    user_auth_client: TestClient, 
    admin_auth_client: TestClient, 
    test_user: models.User
):
    """Testa se um usuário comum pode deletar uma máquina que ele mesmo criou."""

    resp_sector = admin_auth_client.post("/api/v1/sectors/", json={"name": "Setor para Deleção"})
    sector = resp_sector.json()
    admin_auth_client.post(f"/api/v1/sectors/{sector['id']}/members", json={"user_id": test_user.id})
    
    resp_machine = user_auth_client.post("/api/v1/machines/", json={"name": "Minha Maquina", "sector_id": sector['id']})
    assert resp_machine.status_code == 201
    machine = resp_machine.json()

    resp_delete = user_auth_client.delete(f"/api/v1/machines/{machine['id']}")
    assert resp_delete.status_code == 200
    
    resp_get = user_auth_client.get(f"/api/v1/machines/{machine['id']}")
    assert resp_get.status_code == 404

def test_user_cannot_delete_other_machine(
    user_auth_client: TestClient, 
    admin_auth_client: TestClient
):
    """Testa se um usuário comum NÃO PODE deletar a máquina de outro usuário (admin)."""
    resp_sector = admin_auth_client.post("/api/v1/sectors/", json={"name": "Setor do Admin"})
    sector = resp_sector.json()
    resp_machine = admin_auth_client.post("/api/v1/machines/", json={"name": "Maquina do Admin", "sector_id": sector['id']})
    assert resp_machine.status_code == 201
    machine = resp_machine.json()

    resp_delete = user_auth_client.delete(f"/api/v1/machines/{machine['id']}")
    assert resp_delete.status_code == 403 

def test_admin_can_delete_any_machine(
    user_auth_client: TestClient, 
    admin_auth_client: TestClient,
    test_user: models.User
):
    """Testa se um admin PODE deletar a máquina de qualquer usuário."""
    resp_sector = admin_auth_client.post("/api/v1/sectors/", json={"name": "Setor do User"})
    sector = resp_sector.json()
    admin_auth_client.post(f"/api/v1/sectors/{sector['id']}/members", json={"user_id": test_user.id})
    
    resp_machine = user_auth_client.post("/api/v1/machines/", json={"name": "Maquina do User", "sector_id": sector['id']})
    assert resp_machine.status_code == 201
    machine = resp_machine.json()

    resp_delete = admin_auth_client.delete(f"/api/v1/machines/{machine['id']}")
    assert resp_delete.status_code == 200


# --- Testes de DELETE /sectors ---

def test_admin_can_delete_empty_sector(admin_auth_client: TestClient):
    """Testa se o admin pode deletar um setor vazio."""
    resp_sector = admin_auth_client.post("/api/v1/sectors/", json={"name": "Setor Vazio"})
    assert resp_sector.status_code == 201
    sector = resp_sector.json()

    resp_delete = admin_auth_client.delete(f"/api/v1/sectors/{sector['id']}")
    assert resp_delete.status_code == 200

def test_admin_cannot_delete_non_empty_sector(admin_auth_client: TestClient):
    """Testa a salvaguarda que impede o admin de deletar um setor com máquinas."""
    resp_sector = admin_auth_client.post("/api/v1/sectors/", json={"name": "Setor Ocupado"})
    sector = resp_sector.json()
    admin_auth_client.post("/api/v1/machines/", json={"name": "Maquina", "sector_id": sector['id']})

    resp_delete = admin_auth_client.delete(f"/api/v1/sectors/{sector['id']}")
    assert resp_delete.status_code == 400
    assert "Não é possível apagar o setor" in resp_delete.json()["detail"]

def test_user_cannot_delete_sector(user_auth_client: TestClient, admin_auth_client: TestClient):
    """Testa se um usuário comum NÃO PODE deletar um setor."""
    resp_sector = admin_auth_client.post("/api/v1/sectors/", json={"name": "Setor para User Tentar"})
    sector = resp_sector.json()

    resp_delete = user_auth_client.delete(f"/api/v1/sectors/{sector['id']}")
    assert resp_delete.status_code == 403


# --- Testes de DELETE ---

def test_admin_can_delete_user(
    client: TestClient, 
    admin_auth_client: TestClient, 
    db_session: Session
):
    """Testa se o admin pode deletar um usuário comum."""
    user_to_delete_data = {
        "name": "Usuario Deletavel",
        "email": "delete@me.com",
        "password": "password123"
    }
    resp_create = client.post("/api/v1/auth/register", json=user_to_delete_data)
    assert resp_create.status_code == 200
    user_to_delete = resp_create.json()

    resp_delete = admin_auth_client.delete(f"/api/v1/admin/users/{user_to_delete['id']}")
    assert resp_delete.status_code == 200
    assert resp_delete.json()["email"] == user_to_delete_data["email"]

    resp_login = client.post(
        "/api/v1/auth/login",
        data={"username": user_to_delete_data["email"], "password": user_to_delete_data["password"]}
    )
    assert resp_login.status_code == 401

def test_admin_cannot_delete_self(admin_auth_client: TestClient, admin_user: models.User):
    """Testa a salvaguarda que impede um admin de se auto-deletar."""
    admin_id = admin_user.id
    resp_delete = admin_auth_client.delete(f"/api/v1/admin/users/{admin_id}")
    assert resp_delete.status_code == 400
    assert "Administradores não podem deletar a si próprios" in resp_delete.json()["detail"]

def test_user_cannot_delete_user(user_auth_client: TestClient, admin_user: models.User):
    """Testa se um usuário comum NÃO PODE deletar outro usuário."""
    admin_id = admin_user.id
    resp_delete = user_auth_client.delete(f"/api/v1/admin/users/{admin_id}")
    assert resp_delete.status_code == 403