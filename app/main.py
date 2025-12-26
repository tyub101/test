from flask import Flask, jsonify

app = Flask(__name__)


@app.get("/")
def index():
    return jsonify(
        message="Flask API running on Cloud Run",
        endpoints={"health": "/health", "echo": "/echo/<value>"},
    )


@app.get("/health")
def health():
    return jsonify(status="ok")


@app.get("/echo/<value>")
def echo(value: str):
    return jsonify(echo=value)


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=8080)
