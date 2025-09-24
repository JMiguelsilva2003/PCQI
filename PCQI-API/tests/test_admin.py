def test_admin_can_list_users(admin_auth_client, test_user, admin_user):
    """Testa se um admin pode listar todos os usuários."""
    response = admin_auth_client.get("/api/v1/admin/users")
    assert response.status_code == 200
    user_list = response.json()
    assert len(user_list) >= 2
    assert "admin@example.com" in [user["email"] for user in user_list]

def test_user_cannot_list_users(user_auth_client):
    """Testa se um usuário comum NÃO PODE listar todos os usuários."""
    response = user_auth_client.get("/api/v1/admin/users")
    assert response.status_code == 403

def test_admin_can_promote_user(admin_auth_client, test_user):
    """Testa se um admin pode promover um usuário comum."""
    response = admin_auth_client.put(f"/api/v1/admin/users/{test_user['id']}/promote")
    assert response.status_code == 200
    promoted_user = response.json()
    assert promoted_user["role"] == "admin"

def test_user_cannot_promote_user(user_auth_client, admin_user):
    """Testa se um usuário comum NÃO PODE promover outro usuário."""
    response = user_auth_client.put(f"/api/v1/admin/users/{admin_user['id']}/promote")
    assert response.status_code == 403