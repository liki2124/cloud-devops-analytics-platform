import pytest

from app.main import app


@pytest.fixture
def client():
    app.config["TESTING"] = True

    with app.test_client() as test_client:
        yield test_client


def test_home_returns_running_status(client):
    response = client.get("/")

    assert response.status_code == 200
    assert response.get_json() == {
        "application": "Cloud & DevOps Analytics Platform",
        "status": "running",
    }


def test_health_returns_healthy(client):
    response = client.get("/health")

    assert response.status_code == 200
    assert response.get_json() == {"status": "healthy"}


def test_api_status_returns_operational(client):
    response = client.get("/api/status")

    assert response.status_code == 200
    assert response.get_json() == {
        "service": "demo-api",
        "status": "operational",
    }


def test_metrics_endpoint_exposes_prometheus_metrics(client):
    response = client.get("/metrics")

    assert response.status_code == 200
    assert b"http_requests_total" in response.data
    assert b"http_request_duration_seconds" in response.data


def test_unknown_endpoint_returns_404(client):
    response = client.get("/not-a-real-endpoint")

    assert response.status_code == 404