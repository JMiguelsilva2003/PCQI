import pytest
from fastapi.testclient import TestClient
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
import os

TEST_DATABASE_URL = "sqlite:///./test.db"
os.environ['DATABASE_URL'] = TEST_DATABASE_URL
os.environ['SECRET_KEY'] = "testsecretkey" 

from app.main import app
from app.database import Base, get_db

engine = create_engine(
    TEST_DATABASE_URL, connect_args={"check_same_thread": False}
)
TestingSessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)

def override_get_db():
    try:
        db = TestingSessionLocal()
        yield db
    finally:
        db.close()

app.dependency_overrides[get_db] = override_get_db

@pytest.fixture(scope="module")
def client():
    Base.metadata.create_all(bind=engine)
    yield TestClient(app)
    Base.metadata.drop_all(bind=engine)
    # if os.path.exists("./test.db"):
        # os.remove("./test.db")