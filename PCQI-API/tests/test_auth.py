def test_create_user_success(client):
    """Testa se um novo usuário pode ser criado com sucesso."""
    import random
    random_email = f"testuser{random.randint(1000, 9999)}@example.com"
    
    response = client.post(
        "/api/v1/auth/register",
        json={"email": random_email, "password": "testpassword123"},
    )
    assert response.status_code == 200
    data = response.json()
    assert data["email"] == random_email
    assert "id" in data

def test_create_user_duplicate_email(client):
    """Testa se a API impede o cadastro de um email que já existe."""
    email = "duplicate@example.com"
    client.post("/api/v1/auth/register", json={"email": email, "password": "password"})
    
    response = client.post(
        "/api/v1/auth/register",
        json={"email": email, "password": "anotherpassword"},
    )
    assert response.status_code == 400
    assert response.json() == {"detail": "Email already registered"}

def test_login_success(client):
    """Testa o login com credenciais válidas."""
    email = "logintest@example.com"
    password = "password123"
    client.post("/api/v1/auth/register", json={"email": email, "password": password})

    response = client.post(
        "/api/v1/auth/login",
        data={"username": email, "password": password}
    )
    assert response.status_code == 200
    data = response.json()
    assert "access_token" in data