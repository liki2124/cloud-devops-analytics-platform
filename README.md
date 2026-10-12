# Cloud & DevOps Analytics Platform

A containerised monitoring platform for tracking API health, application performance, and container resource usage using Python, Docker, Prometheus, Grafana, cAdvisor, and GitHub Actions.

This project demonstrates practical skills in **Python development, containerisation, infrastructure monitoring, observability, automated testing, and CI/CD**.

## Overview

Reliable applications require more than successful deployment. They also need health checks, performance metrics, resource monitoring, and validation processes that help identify problems early.

The Cloud & DevOps Analytics Platform brings these elements together in a local, containerised environment. A Flask API exposes application metrics, Prometheus collects metrics and evaluates alerting rules, Grafana provides a monitoring interface, and cAdvisor exposes container resource metrics.

GitHub Actions automates testing, Prometheus configuration validation, and Docker image builds whenever changes are pushed or a pull request targets the `main` branch.

## Architecture

```text
                         +----------------------+
                         |     API Clients      |
                         +----------+-----------+
                                    |
                                    v
                         +----------------------+
                         |      Flask API       |
                         |       Port 8000       |
                         +----------+-----------+
                                    |
                                    v
                         +----------------------+
                         |   /metrics Endpoint  |
                         +----------+-----------+
                                    |
                                    v
+----------------------+  +----------------------+
|       cAdvisor       |->|      Prometheus      |
|      Port 8080       |  |       Port 9090       |
+----------------------+  |                      |
                          | Metrics and Alerting  |
                          +----------+-----------+
                                     |
                                     v
                          +----------------------+
                          |       Grafana        |
                          |       Port 3000       |
                          +----------------------+

+------------------------------------------------+
| GitHub Actions                                 |
| Automated tests, Prometheus validation,        |
| and Docker image build                         |
+------------------------------------------------+
```

## Technology Stack

| Area | Technologies |
|---|---|
| Application | Python, Flask |
| Containerisation | Docker, Docker Compose |
| Metrics collection | Prometheus, Prometheus client library |
| Infrastructure monitoring | cAdvisor |
| Visualisation | Grafana |
| Alerting | Prometheus alerting rules |
| Testing | pytest |
| CI/CD | GitHub Actions |
| Configuration | YAML, environment variables |
| Version control | Git, GitHub |

## Key Features

### 1. Application Health Monitoring

- Flask API with dedicated health and status endpoints.
- Docker health check that periodically verifies API availability.
- Container restart policies for improved service resilience.
- Health status visibility through Docker Compose.

### 2. Application Performance Metrics

The API exposes a Prometheus-compatible `/metrics` endpoint.

The implemented metrics include:

- HTTP request counter.
- Request duration histogram.
- Application metrics that can be queried and visualised in Prometheus and Grafana.

These metrics provide a foundation for analysing request activity and application response performance.

### 3. Infrastructure Monitoring

cAdvisor exposes container resource metrics that Prometheus can collect.

The monitoring configuration supports analysis of container resource consumption alongside application-level performance.

### 4. Prometheus Alert Rules

The project includes alerting rules for:

- **API availability:** identifies when the API cannot be scraped successfully by Prometheus.
- **Aggregate container CPU usage:** detects sustained CPU consumption above the configured threshold.

The CPU rule evaluates aggregate container CPU usage and triggers when it exceeds the configured threshold for the specified duration.

### 5. Grafana Visualisation

Grafana provides a web interface for exploring operational metrics.

Prometheus is available as the metrics collection and query service, allowing dashboards to visualise application and container behaviour.

### 6. Automated CI Validation

The GitHub Actions workflow runs the following checks:

1. Checks out the repository.
2. Sets up Python 3.12.
3. Installs project dependencies.
4. Runs automated tests using pytest.
5. Validates Prometheus configuration and alert rules with `promtool`.
6. Builds the Docker image.

This workflow helps catch application, configuration, and image-build problems before changes are accepted.

## Prerequisites

Install the following tools before running the project:

- [Docker Desktop](https://www.docker.com/products/docker-desktop/) with Docker Compose.
- [Git](https://git-scm.com/).
- A GitHub account to inspect the source code and CI workflow.

Docker Desktop must be running before you start the containers.

## Getting Started

### 1. Clone the repository

```bash
git clone https://github.com/liki2124/cloud-devops-analytics-platform.git
cd cloud-devops-analytics-platform
```

### 2. Configure Grafana credentials

The Compose configuration requires `GRAFANA_ADMIN_PASSWORD` to be set in a local `.env` file.

Create the file:

```powershell
notepad .env
```

Add a new, unique password:

```dotenv
GRAFANA_ADMIN_PASSWORD=replace_with_a_strong_unique_password
```

Replace the example value with your own strong password. Do not commit `.env` or share the password publicly.

### 3. Validate the Compose configuration

```bash
docker compose config --quiet
```

If the command completes without errors, the Compose configuration is valid.

### 4. Build and start the services

```bash
docker compose up -d --build
```

Check the container status:

```bash
docker compose ps
```

View the logs if you need to troubleshoot a service:

```bash
docker compose logs --tail=100
```

Follow the API logs:

```bash
docker compose logs -f api
```

Press `Ctrl+C` to stop following the logs. This does not stop the containers.

## Access the Services

Once the containers are running, open the following addresses in your browser.

| Service | URL | Purpose |
|---|---|---|
| Flask API | http://localhost:8000 | Application entry point |
| API health | http://localhost:8000/health | Health check |
| API status | http://localhost:8000/api/status | Application status |
| API metrics | http://localhost:8000/metrics | Prometheus metrics |
| Prometheus | http://localhost:9090 | Metrics queries and targets |
| Grafana | http://localhost:3000 | Monitoring visualisation |
| cAdvisor | http://localhost:8080 | Container resource metrics |

Grafana credentials are the username `admin` and the password configured in `.env`.

## Monitoring and Alerting

### Prometheus

Prometheus uses the configuration in `prometheus/prometheus.yml`.

The configured scrape targets include:

- `api:8000` for application metrics.
- `cadvisor:8080` for container resource metrics.

The project uses a five-second scrape interval.

To inspect metric collection:

1. Open Prometheus at `http://localhost:9090`.
2. Navigate to **Status → Targets**.
3. Verify that the configured targets are being scraped successfully.
4. Use the query interface to explore available metrics.

### Alert Rules

Alert definitions are stored in:

```text
prometheus/rules/alerts.yml
```

Prometheus loads these rules through the `rule_files` setting in its configuration.

The rules cover API scrape availability and sustained aggregate container CPU usage.

### Grafana

Open `http://localhost:3000` to access Grafana.

Prometheus can be used as the data source for dashboards that explore request activity, application latency, and container resource usage.

A configured dashboard should be treated as a separate deliverable unless its dashboard definition is committed to the repository.

## Testing

Run the automated tests locally:

```bash
python -m pip install -r requirements.txt
python -m pytest -v tests
```

Alternatively, run the tests inside the API container environment after building the image:

```bash
docker compose run --rm --no-deps api python -m pytest -v tests
```

The project also validates its Prometheus configuration and alert rules as part of the CI workflow.

## Continuous Integration

The workflow is defined in:

```text
.github/workflows/ci.yml
```

It runs on pushes and pull requests targeting `main`.

The pipeline checks Python tests, validates Prometheus configuration and alert rules, and builds the application Docker image.

View workflow results in the **Actions** tab of the GitHub repository.

## Repository Structure

```text
cloud-devops-analytics-platform/
|-- .github/
|   `-- workflows/
|       `-- ci.yml
|-- app/
|   `-- main.py
|-- prometheus/
|   |-- prometheus.yml
|   `-- rules/
|       `-- alerts.yml
|-- tests/
|   `-- test_main.py
|-- .gitignore
|-- Dockerfile
|-- docker-compose.yml
|-- requirements.txt
|-- README.md
`-- LICENSE
```

## Engineering Focus

This project demonstrates hands-on experience with:

- Building and exposing a Python API.
- Containerising applications and managing multi-service environments.
- Implementing health checks and service restart policies.
- Instrumenting applications with Prometheus metrics.
- Collecting infrastructure metrics with cAdvisor.
- Defining and validating monitoring alert rules.
- Automating tests and configuration checks in GitHub Actions.
- Managing application configuration and secrets outside source control.
- Documenting deployment and troubleshooting workflows.

## Future Improvements

Potential next steps include:

- Add a version-controlled Grafana dashboard provisioning configuration.
- Expand API metrics with request status codes and endpoint-level breakdowns.
- Add more comprehensive integration tests.
- Introduce automated container image security scanning.
- Publish versioned Docker images through a container registry.
- Add alert notification integrations.
- Deploy the platform to a cloud environment.

These are proposed enhancements rather than claims about existing functionality.

## License

See the [LICENSE](LICENSE) file for licensing information.

## Author

**Likitha Shivananjegowda**

GitHub: [@liki2124](https://github.com/liki2124)

Portfolio:https://likitha-portfolio-tau.vercel.app/
