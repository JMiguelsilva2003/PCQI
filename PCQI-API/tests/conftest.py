import pytest
from fastapi.testclient import TestClient
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
import os

os.environ['DATABASE_URL'] = "sqlite:///./test.db"
os.environ['SECRET_KEY'] = "testsecretkeyforjwt"
os.environ['API_KEY'] = "testapikeyforgateway"
os.environ['MAIL_FROM_EMAIL'] = "test@example.com"

from app.main import app
from app.database import Base, get_db
from app import crud, schemas

engine = create_engine(
    os.environ['DATABASE_URL'], connect_args={"check_same_thread": False}
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
def db_session():
    """
    Cria e limpa as tabelas para cada teste, fornecendo uma sessão de banco.
    Esta fixture garante que o banco de dados esteja sempre pronto.
    """
    Base.metadata.create_all(bind=engine)
    db = TestingSessionLocal()
    try:
        yield db
    finally:
        db.close()
    Base.metadata.drop_all(bind=engine)


@pytest.fixture(scope="function")
def test_user(db_session):
    """Cria, ativa e retorna um objeto de usuário comum."""
    user_in = schemas.UserCreate(
        name="Test User", email="test@example.com", password="password123"
    )
    user = crud.create_user(db=db_session, user=user_in)
    return crud.activate_user(db=db_session, user=user)


@pytest.fixture(scope="function")
def admin_user(db_session):
    """Cria, ativa, promove e retorna um objeto de usuário admin."""
    user_in = schemas.UserCreate(
        name="Admin User", email="admin@example.com", password="adminpass123"
    )
    user = crud.create_user(db=db_session, user=user_in)
    user = crud.activate_user(db=db_session, user=user)
    return crud.update_user_role(db=db_session, user=user, role="admin")


@pytest.fixture(scope="function")
def client():
    """
    Cliente de teste limpo para endpoints públicos.
    Agora garante que as tabelas existem antes de rodar.
    """
    Base.metadata.create_all(bind=engine)
    client = TestClient(app)
    try:
        yield client
    finally:
        client.close()
        Base.metadata.drop_all(bind=engine)


@pytest.fixture(scope="function")
def user_auth_client(test_user):
    """Cria um NOVO cliente e o autentica como usuário comum."""
    client = TestClient(app)
    response = client.post(
        "/api/v1/auth/login",
        data={"username": test_user.email, "password": "password123"},
    )
    assert response.status_code == 200
    token = response.json()["access_token"]
    client.headers["Authorization"] = f"Bearer {token}"
    return client


@pytest.fixture(scope="function")
def admin_auth_client(admin_user):
    """Cria um NOVO cliente e o autentica como admin."""
    client = TestClient(app)
    response = client.post(
        "/api/v1/auth/login",
        data={"username": admin_user.email, "password": "adminpass123"},
    )
    assert response.status_code == 200
    token = response.json()["access_token"]
    client.headers["Authorization"] = f"Bearer {token}"
    return client
