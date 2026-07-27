from flask import Blueprint, request, jsonify
from flask_jwt_extended import jwt_required, get_jwt_identity
from models import db, Favorite, Property

bp = Blueprint("favorites", __name__, url_prefix="/api/favorites")


@bp.route("", methods=["GET"])
@jwt_required()
def list_favorites():
    user_id = get_jwt_identity()
    favorites = Favorite.query.filter_by(user_id=user_id).order_by(
        Favorite.created_at.desc()
    ).all()
    results = []
    for f in favorites:
        prop = Property.query.get(f.property_id)
        if prop and prop.is_active:
            d = f.to_dict()
            d["property"] = prop.to_dict()
            results.append(d)
    return jsonify(results)


@bp.route("", methods=["POST"])
@jwt_required()
def add_favorite():
    user_id = get_jwt_identity()
    data = request.get_json() or {}
    property_id = data.get("property_id")
    if not property_id:
        return jsonify({"error": "property_id is required"}), 400

    prop = Property.query.get(property_id)
    if not prop:
        return jsonify({"error": "Property not found"}), 404

    existing = Favorite.query.filter_by(
        user_id=user_id, property_id=property_id
    ).first()
    if existing:
        return jsonify(existing.to_dict())

    fav = Favorite(user_id=user_id, property_id=property_id)
    db.session.add(fav)
    db.session.commit()
    return jsonify(fav.to_dict()), 201


@bp.route("/<property_id>", methods=["DELETE"])
@jwt_required()
def remove_favorite(property_id):
    user_id = get_jwt_identity()
    fav = Favorite.query.filter_by(
        user_id=user_id, property_id=property_id
    ).first()
    if not fav:
        return jsonify({"error": "Favorite not found"}), 404
    db.session.delete(fav)
    db.session.commit()
    return jsonify({"message": "Favorite removed"})
