from app import db
from app.models import Blacklist


def test_ping_returns_pong(client):
    response = client.get("/ping")
    print("test")
    assert response.status_code == 200
    assert response.get_json() == {"message": "pong"}


def test_create_blacklist_entry_returns_201(client, auth_headers):
    payload = {
        "email": "person@example.com",
        "app_uuid": "123e4567-e89b-12d3-a456-426614174000",
        "blocked_reason": "fraude",
    }

    response = client.post("/blacklists", json=payload, headers=auth_headers)

    assert response.status_code == 201
    assert response.get_json() == {"message": "Email added to blacklist successfully"}


def test_create_blacklist_entry_without_token_returns_401(client):
    payload = {
        "email": "person@example.com",
        "app_uuid": "123e4567-e89b-12d3-a456-426614174000",
    }

    response = client.post("/blacklists", json=payload)

    assert response.status_code == 401
    assert response.get_json() == {"message": "Unauthorized"}


def test_create_blacklist_entry_with_invalid_uuid_returns_400(client, auth_headers):
    payload = {
        "email": "person@example.com",
        "app_uuid": "not-a-uuid",
        "blocked_reason": "fraude",
    }

    response = client.post("/blacklists", json=payload, headers=auth_headers)

    assert response.status_code == 400
    assert response.get_json() == {"message": "app_uuid must be a valid UUID"}


def test_get_existing_blacklist_entry_returns_200(client, app, auth_headers):
    with app.app_context():
        db.session.add(
            Blacklist(
                email="listed@example.com",
                app_uuid="123e4567-e89b-12d3-a456-426614174000",
                blocked_reason="fraude",
                ip_address="127.0.0.1",
            )
        )
        db.session.commit()

    response = client.get("/blacklists/listed@example.com", headers=auth_headers)

    assert response.status_code == 200
    assert response.get_json() == {
        "is_blacklisted": True,
        "blocked_reason": "fraude",
    }


def test_get_missing_blacklist_entry_returns_200(client, auth_headers):
    response = client.get("/blacklists/missing@example.com", headers=auth_headers)

    assert response.status_code == 200
    assert response.get_json() == {
        "is_blacklisted": False,
        "blocked_reason": None,
    }


def test_get_blacklist_entry_without_token_returns_401(client):
    response = client.get("/blacklists/listed@example.com")

    assert response.status_code == 401
    assert response.get_json() == {"message": "Unauthorized"}
