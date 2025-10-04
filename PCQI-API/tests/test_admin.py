from app import crud, schemas

def test_admin_can_list_users(admin_auth_client, test_user):
    """Testa se um admin pode listar todos os usuários."""
    response = admin_auth_client.get("/api/v1/admin/users")
    assert response.status_code == 200
    user_list = response.json()
    assert len(user_list) >= 2

def test_user_cannot_list_users(user_auth_client):
    """Testa se um usuário comum NÃO PODE listar todos os usuários."""
    response = user_auth_client.get("/api/v1/admin/users")
    assert response.status_code == 403

def test_admin_can_promote_user(admin_auth_client, test_user):
    """Testa se um admin pode promover um usuário comum."""
    response = admin_auth_client.put(f"/api/v1/admin/users/{test_user.id}/promote")
    assert response.status_code == 200
    assert response.json()["role"] == "admin"

def test_user_cannot_promote_user(user_auth_client, admin_user):
    """Testa se um usuário comum NÃO PODE promover outro usuário."""
    response = user_auth_client.put(f"/api/v1/admin/users/{admin_user.id}/promote")
    assert response.status_code == 403

def test_user_in_sector_can_create_machine(admin_auth_client, user_auth_client, test_user):
    """Garante que um usuário membro de um setor pode criar uma máquina nele."""
    sector_response = admin_auth_client.post("/api/v1/sectors/", json={"name": "Setor de Producao"})
    assert sector_response.status_code == 201
    sector = sector_response.json()

    add_member_response = admin_auth_client.post(f"/api/v1/sectors/{sector['id']}/members", json={"user_id": test_user.id})
    assert add_member_response.status_code == 200

    create_machine_response = user_auth_client.post(
        "/api/v1/machines/",
        json={"name": "Minha Maquina de Teste", "sector_id": sector['id']}
    )
    assert create_machine_response.status_code == 201
    machine_data = create_machine_response.json()
    assert machine_data["name"] == "Minha Maquina de Teste"
    assert machine_data["creator_id"] == test_user.id

def test_user_not_in_sector_cannot_create_machine(admin_auth_client, user_auth_client, test_user):
    """Garante que um usuário que NÃO é membro de um setor NÃO PODE criar uma máquina nele."""
    sector_response = admin_auth_client.post("/api/v1/sectors/", json={"name": "Setor Restrito"})
    assert sector_response.status_code == 201
    sector = sector_response.json()

    create_machine_response = user_auth_client.post(
        "/api/v1/machines/",
        json={"name": "Maquina Invasora", "sector_id": sector['id']}
    )
    assert create_machine_response.status_code == 403

def test_user_can_read_own_sector_machine(admin_auth_client, user_auth_client, test_user):
    """Garante que um usuário pode ver os detalhes de uma máquina em seu setor."""
    sector_resp = admin_auth_client.post("/api/v1/sectors/", json={"name": "Setor do User"})
    assert sector_resp.status_code == 201
    sector = sector_resp.json()
    admin_auth_client.post(f"/api/v1/sectors/{sector['id']}/members", json={"user_id": test_user.id})
    machine_resp = user_auth_client.post("/api/v1/machines/", json={"name": "Maquina do User", "sector_id": sector['id']})
    assert machine_resp.status_code == 201
    machine = machine_resp.json()

    response = user_auth_client.get(f"/api/v1/machines/{machine['id']}")
    assert response.status_code == 200
    assert response.json()["id"] == machine['id']

def test_user_cannot_read_other_sector_machine(user_auth_client, admin_auth_client):
    """Garante que um usuário não pode ver os detalhes de uma máquina de outro setor."""
    sector_resp = admin_auth_client.post("/api/v1/sectors/", json={"name": "Setor Secreto do Admin"})
    assert sector_resp.status_code == 201
    sector = sector_resp.json()
    machine_resp = admin_auth_client.post(
        "/api/v1/machines/",
        json={"name": "Maquina Secreta", "sector_id": sector['id']}
    )
    assert machine_resp.status_code == 201
    machine = machine_resp.json()
    
    response = user_auth_client.get(f"/api/v1/machines/{machine['id']}")

    assert response.status_code == 403