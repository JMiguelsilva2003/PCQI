import pytest
import os
from fastapi.testclient import TestClient
from sqlalchemy.orm import Session
from app import crud, models
from datetime import datetime, timedelta, timezone

def test_user_can_edit_own_machine_name(setup_machine_data):
    """
    Testa se um usuário comum (não admin) pode editar
    o nome de uma máquina que ele mesmo criou.
    (PUT /api/v1/machines/{machine_id})
    """
    test_user, machine_a, user_auth_client, _ = setup_machine_data
    machine_id = machine_a['id']
    
    response = user_auth_client.put(
        f"/api/v1/machines/{machine_id}",
        json={"name": "Máquina A (Editada)"}
    )
    
    assert response.status_code == 200
    assert response.json()["name"] == "Máquina A (Editada)"
    assert response.json()["id"] == machine_id

def test_user_cannot_edit_other_machine(setup_machine_data, admin_auth_client):
    """
    Testa se um usuário comum não pode editar uma máquina
    que ele não criou (neste caso, uma criada pelo admin).
    """
    _, _, user_auth_client, sector = setup_machine_data
    
    resp_admin_machine = admin_auth_client.post(
        "/api/v1/machines/",
        json={"name": "Máquina do Admin", "sector_id": sector['id']}
    )
    assert resp_admin_machine.status_code == 201
    admin_machine = resp_admin_machine.json()
    
    response = user_auth_client.put(
        f"/api/v1/machines/{admin_machine['id']}",
        json={"name": "Máquina Hackeada"}
    )
    
    assert response.status_code == 403 
def test_gateway_can_send_heartbeat(client: TestClient, setup_machine_data, db_session: Session):
    """
    Testa se um gateway (com a API Key correta) pode
    enviar um heartbeat.
    (PUT /api/v1/machines/{machine_id}/heartbeat)
    """
    _, machine_a, _, _ = setup_machine_data
    machine_id = machine_a['id']
    
    api_key = os.getenv("API_KEY") 
    assert api_key, "API_KEY não definida no .env de teste"
    
    headers = {"X-API-Key": api_key}
    
    db_machine = crud.get_machine(db_session, machine_id)
    assert db_machine.last_heartbeat is None
    
    response = client.put(f"/api/v1/machines/{machine_id}/heartbeat", headers=headers)
    
    assert response.status_code == 200
    assert "last_heartbeat" in response.json()
    
    assert response.json()["last_heartbeat"] is not None
    
    heartbeat_time = datetime.fromisoformat(response.json()["last_heartbeat"])
    
    time_diff = datetime.now(timezone.utc) - heartbeat_time.replace(tzinfo=timezone.utc)
    assert time_diff < timedelta(seconds=5)

def test_gateway_heartbeat_fails_bad_key(client: TestClient, setup_machine_data):
    """ Testa se o heartbeat falha com uma API key inválida. """
    _, machine_a, _, _ = setup_machine_data
    machine_id = machine_a['id']
    
    headers = {"X-API-Key": "CHAVE_ERRADA"}
    response = client.put(f"/api/v1/machines/{machine_id}/heartbeat", headers=headers)
    
    assert response.status_code == 401 

def test_get_stats_history(admin_auth_client, populate_stats_data):
    """
    Testa o endpoint de histórico de estatísticas.
    (GET /api/v1/stats/history)
    """
    response = admin_auth_client.get("/api/v1/stats/history?range=1")
    assert response.status_code == 200
    data = response.json()
    assert isinstance(data, list)
    
    if len(data) > 0:
        assert data[0]["maduras"] == 3
        assert data[0]["verdes"] == 4 

def test_get_stats_performance_by_machine(admin_auth_client, user_auth_client, populate_stats_data):
    """
    Testa o endpoint de ranking de máquinas (visão admin e user).
    (GET /api/v1/stats/performance_by_machine)
    """
    machine_a1_id = populate_stats_data["machine_A1_id"]
    machine_b1_id = populate_stats_data["machine_B1_id"]
    
    resp_admin = admin_auth_client.get("/api/v1/stats/performance_by_machine")
    assert resp_admin.status_code == 200
    data_admin = resp_admin.json()
    assert len(data_admin) >= 2 
    
    machine_a1_data = next((item for item in data_admin if item["machine_id"] == machine_a1_id), None)
    assert machine_a1_data is not None
    assert machine_a1_data["machine_name"] == "Maquina A1"
    assert machine_a1_data["maduras"] == 2
    assert machine_a1_data["verdes"] == 1
    
    machine_b1_data = next((item for item in data_admin if item["machine_id"] == machine_b1_id), None)
    assert machine_b1_data is not None
    assert machine_b1_data["machine_name"] == "Maquina B1"
    assert machine_b1_data["maduras"] == 1
    assert machine_b1_data["verdes"] == 3
    
    resp_user = user_auth_client.get("/api/v1/stats/performance_by_machine")
    assert resp_user.status_code == 200
    data_user = resp_user.json()
    
    assert len(data_user) > 0
    user_machine_a1_data = next((item for item in data_user if item["machine_id"] == machine_a1_id), None)
    assert user_machine_a1_data is not None
    assert user_machine_a1_data["machine_name"] == "Maquina A1"
    user_machine_b1_data = next((item for item in data_user if item["machine_id"] == machine_b1_id), None)
    assert user_machine_b1_data is None