import pytest
from fastapi.testclient import TestClient
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
import os

TEST_DATABASE_URL = "sqlite:///./test.db"
os.environ['DATABASE_URL'] = TEST_DATABASE_URL
os.environ['SECRET_KEY'] = "testsecretkey"
os.environ['API_KEY'] = "testapikeyforgateway"
os.environ['MAIL_FROM_EMAIL'] = "test@example.com"

from app.main import app
from app.database import Base, get_db
from app import crud, schemas

engine = create_engine(
    TEST_DATABASE_URL, connect_args={"check_same_thread": False}
)
TestingSessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)

def override_get_db():
    db = TestingSessionLocal()
    try:
        yield db
    finally:
        db.close()

app.dependency_overrides[get_db] = override_get_db


@pytest.fixture(scope="function")
def client():
    """Fixture que cria um banco de dados limpo para cada teste."""
    Base.metadata.create_all(bind=engine)
    yield TestClient(app)
    Base.metadata.drop_all(bind=engine)

@pytest.fixture(scope="function")
def db_session():
    """Fixture que fornece uma sessão de banco de dados para setup manual."""
    db = TestingSessionLocal()
    try:
        yield db
    finally:
        db.close()

@pytest.fixture(scope="function")
def test_user(client):
    """Cria um usuário comum e ativo via API."""
    user_data = {
        "name": "Test User",
        "email": "test@example.com",
        "password": "password123"
    }
    client.post("/api/v1/auth/register", json=user_data)
    
    db = TestingSessionLocal()
    user_in_db = crud.get_user_by_email(db, email=user_data["email"])
    crud.activate_user(db, user=user_in_db)
    db.close()
    
    user_data["id"] = user_in_db.id
    return user_data

@pytest.fixture(scope="function")
def admin_user(client):
    """Cria um usuário admin e ativo via API."""
    user_data = {
        "name": "Admin User",
        "email": "admin@example.com",
        "password": "adminpass123"
    }
    client.post("/api/v1/auth/register", json=user_data)
    
    db = TestingSessionLocal()
    user_in_db = crud.get_user_by_email(db, email=user_data["email"])
    crud.activate_user(db, user=user_in_db)
    crud.update_user_role(db, user=user_in_db, role="admin")
    db.close()

    user_data["id"] = user_in_db.id
    return user_data

@pytest.fixture(scope="function")
def user_auth_client(client, test_user):
    """Retorna um cliente de teste já autenticado como usuário comum."""
    response = client.post(
        "/api/v1/auth/login",
        data={"username": test_user["email"], "password": "password123"}
    )
    token = response.json()["access_token"]
    client.headers["Authorization"] = f"Bearer {token}"
    return client

@pytest.fixture(scope="function")
def admin_auth_client(client, admin_user):
    """Retorna um cliente de teste já autenticado como admin."""
    response = client.post(
        "/api/v1/auth/login",
        data={"username": admin_user["email"], "password": "adminpass123"}
    )
    token = response.json()["access_token"]
    client.headers["Authorization"] = f"Bearer {token}"
    return client