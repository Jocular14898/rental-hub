from flask import Blueprint, request, jsonify
from flask_jwt_extended import create_access_token, jwt_required, get_jwt_identity
from models import db, User

bp = Blueprint("auth", __name__, url_prefix="/api/auth")


@bp.route("/register", methods=["POST"])
def register():
    data = request.get_json() or {}
    errors = {}
    for f in ("name", "phone", "email", "password", "user_type"):
        if not data.get(f):
            errors[f] = f"{f} is required"
    if data.get("user_type") not in ("tenant", "landlord", "agent"):
        errors["user_type"] = "Must be tenant, landlord, or agent"
    if errors:
        return jsonify({"error": "Validation failed", "details": errors}), 400

    if User.query.filter_by(phone=data["phone"]).first():
        return jsonify({"error": "Phone already registered"}), 409
    if User.query.filter_by(email=data["email"]).first():
        return jsonify({"error": "Email already registered"}), 409

    user = User(
        name=data["name"],
        phone=data["phone"],
        email=data["email"],
        user_type=data["user_type"],
    )
    user.set_password(data["password"])
    db.session.add(user)
    db.session.commit()

    token = create_access_token(identity=user.id)
    return jsonify({"token": token, "user": user.to_dict()}), 201


@bp.route("/login", methods=["POST"])
def login():
    data = request.get_json() or {}
    if not data.get("password"):
        return jsonify({"error": "Password is required"}), 400

    user = None
    if data.get("email"):
        user = User.query.filter_by(email=data["email"]).first()
    elif data.get("phone"):
        user = User.query.filter_by(phone=data["phone"]).first()
    else:
        return jsonify({"error": "Email or phone is required"}), 400

    if not user or not user.check_password(data["password"]):
        return jsonify({"error": "Invalid credentials"}), 401

    token = create_access_token(identity=user.id)
    return jsonify({"token": token, "user": user.to_dict()})


@bp.route("/me", methods=["GET"])
@jwt_required()
def me():
    user = User.query.get(get_jwt_identity())
    if not user:
        return jsonify({"error": "User not found"}), 404
    return jsonify(user.to_dict())
