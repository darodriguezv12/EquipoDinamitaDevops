from flask import Blueprint, current_app, jsonify, request

from app.services.blacklist_service import create_blacklist_entry, get_blacklist_status

bp = Blueprint("blacklists", __name__)


def validate_token():
    auth_header = request.headers.get("Authorization")
    print("terst")
    if not auth_header or not auth_header.startswith("Bearer "):
        return False

    token = auth_header.split(" ")[1]
    return token == current_app.config["API_TOKEN"]


@bp.route("/ping", methods=["GET"])
def ping():
    return jsonify({"message": "pong"}), 200


@bp.route("/blacklists", methods=["POST"])
def add_to_blacklist():
    if not validate_token():
        return jsonify({"message": "Unauthorized"}), 401

    data = request.get_json()

    if not data:
        return jsonify({"message": "Request body is required"}), 400

    try:
        response, status_code = create_blacklist_entry(
            data,
            request.remote_addr or "unknown",
        )
        return jsonify(response), status_code
    except ValueError as error:
        return jsonify({"message": str(error)}), 400


@bp.route("/blacklists/<string:email>", methods=["GET"])
def check_blacklist(email):
    if not validate_token():
        return jsonify({"message": "Unauthorized"}), 401

    response, status_code = get_blacklist_status(email)
    return jsonify(response), status_code
