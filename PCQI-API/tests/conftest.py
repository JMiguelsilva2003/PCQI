import pytest
from fastapi.testclient import TestClient
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker, Session
import os

os.environ['DATABASE_URL'] = "sqlite:///./test.db"
os.environ['SECRET_KEY'] = "testsecretkeyforjwt"
os.environ['API_KEY'] = "testapikeyforgateway"
os.environ['MAIL_FROM_EMAIL'] = "test@example.com"

from app.main import app
from app.database import Base, get_db
from app import crud, schemas, models

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

@pytest.fixture(scope="function")
def populate_stats_data(
    db_session: Session, 
    admin_auth_client: TestClient, 
    user_auth_client: TestClient, 
    test_user: models.User
):
    """
    Uma fixture que cria um cenário complexo para testar estatísticas.
    Agora está em conftest.py e pode ser usada por qualquer teste.
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
    
    db_session.commit()

    return {
        "sector_A_id": sector_A['id'],
        "sector_B_id": sector_B['id'],
        "machine_A1_id": machine_A1['id'],
        "machine_B1_id": machine_B1['id']
    }