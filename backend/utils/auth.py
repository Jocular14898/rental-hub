from functools import wraps
from flask import jsonify
from flask_jwt_extended import get_jwt_identity
from models import User


def landlord_required(fn):
    @wraps(fn)
    def wrapper(*args, **kwargs):
        user_id = get_jwt_identity()
        user = User.query.get(user_id)
        if not user or user.user_type != "landlord":
            return jsonify({"error": "Landlord access required"}), 403
        return fn(*args, **kwargs)
    return wrapper


def agent_required(fn):
    @wraps(fn)
    def wrapper(*args, **kwargs):
        user_id = get_jwt_identity()
        user = User.query.get(user_id)
        if not user or user.user_type != "agent":
            return jsonify({"error": "Agent access required"}), 403
        return fn(*args, **kwargs)
    return wrapper
