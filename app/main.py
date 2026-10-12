
from time import perf_counter

from flask import Flask, Response, g, jsonify, request
from prometheus_client import (
    Counter,
    Histogram,
    CONTENT_TYPE_LATEST,
    generate_latest,
)

app = Flask(__name__)

REQUEST_COUNT = Counter(
    "http_requests_total",
    "Total HTTP requests",
    ["method", "endpoint", "status_code"],
)

REQUEST_LATENCY = Histogram(
    "http_request_duration_seconds",
    "Request processing time in seconds",
    ["method", "endpoint"],
)


@app.before_request
def start_timer():
    g.start_time = perf_counter()


@app.after_request
def record_metrics(response):
    if request.path != "/metrics":
        endpoint = request.endpoint or "unknown"

        REQUEST_COUNT.labels(
            request.method,
            endpoint,
            str(response.status_code),
        ).inc()

        REQUEST_LATENCY.labels(
            request.method,
            endpoint,
        ).observe(perf_counter() - g.start_time)

    return response


@app.route("/")
def home():
    return jsonify(
        application="Cloud & DevOps Analytics Platform",
        status="running",
    )


@app.route("/health")
def health():
    return jsonify(status="healthy"), 200


@app.route("/api/status")
def api_status():
    return jsonify(
        service="demo-api",
        status="operational",
    )


@app.route("/metrics")
def metrics():
    return Response(
        generate_latest(),
        mimetype=CONTENT_TYPE_LATEST,
    )


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=8000)
