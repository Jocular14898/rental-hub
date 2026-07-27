import os
import uuid
from flask import Blueprint, request, jsonify
from flask_jwt_extended import jwt_required, get_jwt_identity
from werkzeug.utils import secure_filename
from models import db, User, Property, PropertyPhoto
from utils.auth import landlord_required

bp = Blueprint("properties", __name__, url_prefix="/api/properties")


def _to_bool(v):
    if isinstance(v, bool):
        return v
    if isinstance(v, str):
        return v.lower() in ("true", "yes", "1")
    return bool(v)

ALLOWED_EXTENSIONS = {"png", "jpg", "jpeg", "webp"}


def allowed_file(name):
    return "." in name and name.rsplit(".", 1)[1].lower() in ALLOWED_EXTENSIONS


@bp.route("", methods=["GET"])
def list_properties():
    page = request.args.get("page", 1, type=int)
    per_page = request.args.get("per_page", 20, type=int)

    query = Property.query.filter_by(is_active=True)

    if location := request.args.get("location"):
        query = query.filter(Property.location.ilike(f"%{location}%"))
    if min_price := request.args.get("min_price", type=float):
        query = query.filter(Property.price >= min_price)
    if max_price := request.args.get("max_price", type=float):
        query = query.filter(Property.price <= max_price)
    if bedrooms := request.args.get("bedrooms", type=int):
        query = query.filter(Property.bedrooms == bedrooms)
    if house_type := request.args.get("house_type"):
        query = query.filter(Property.house_type.ilike(f"%{house_type}%"))

    query = query.order_by(Property.created_at.desc())
    pagination = query.paginate(page=page, per_page=per_page, error_out=False)

    return jsonify({
        "properties": [p.to_dict() for p in pagination.items],
        "total": pagination.total,
        "page": page,
        "pages": pagination.pages,
    })


@bp.route("/<property_id>", methods=["GET"])
def get_property(property_id):
    prop = Property.query.get(property_id)
    if not prop or not prop.is_active:
        return jsonify({"error": "Property not found"}), 404
    return jsonify(prop.to_dict())


@bp.route("", methods=["POST"])
@jwt_required()
@landlord_required
def create_property():
    data = request.form.to_dict() if request.form else (request.get_json() or {})
    errors = {}
    for f in ("title", "price", "location", "bedrooms", "contact_phone"):
        if not data.get(f):
            errors[f] = f"{f} is required"
    if errors:
        return jsonify({"error": "Validation failed", "details": errors}), 400

    prop = Property(
        landlord_id=get_jwt_identity(),
        title=data["title"],
        price=float(data["price"]),
        location=data["location"],
        bedrooms=int(data["bedrooms"]),
        contact_phone=data["contact_phone"],
        house_type=data.get("house_type"),
        description=data.get("description"),
        security_details=data.get("security_details"),
        parking=_to_bool(data.get("parking")),
        water_available=_to_bool(data.get("water_available")),
        latitude=float(data["latitude"]) if data.get("latitude") else None,
        longitude=float(data["longitude"]) if data.get("longitude") else None,
    )
    db.session.add(prop)
    db.session.flush()

    # Handle photo uploads
    upload_dir = os.path.join(
        os.environ.get("UPLOAD_FOLDER", os.path.join(os.path.dirname(__file__), "..", "..", "uploads")),
        prop.id,
    )
    os.makedirs(upload_dir, exist_ok=True)

    files = request.files.getlist("photos") if request.files else []
    for i, f in enumerate(files):
        if f and allowed_file(f.filename):
            ext = f.filename.rsplit(".", 1)[1].lower()
            filename = f"{uuid.uuid4().hex}.{ext}"
            f.save(os.path.join(upload_dir, filename))
            photo = PropertyPhoto(
                property_id=prop.id,
                url=f"/uploads/{prop.id}/{filename}",
                is_primary=(i == 0),
            )
            db.session.add(photo)

    db.session.commit()
    return jsonify(prop.to_dict()), 201


@bp.route("/<property_id>", methods=["PUT"])
@jwt_required()
@landlord_required
def update_property(property_id):
    prop = Property.query.get(property_id)
    if not prop:
        return jsonify({"error": "Property not found"}), 404
    if prop.landlord_id != get_jwt_identity():
        return jsonify({"error": "Unauthorized"}), 403

    data = request.get_json() or {}
    for field in ("title", "price", "location", "bedrooms", "contact_phone",
                  "house_type", "description", "security_details",
                  "parking", "water_available", "latitude", "longitude", "is_active"):
        if field in data:
            setattr(prop, field, data[field])

    db.session.commit()
    return jsonify(prop.to_dict())


@bp.route("/<property_id>", methods=["DELETE"])
@jwt_required()
@landlord_required
def delete_property(property_id):
    prop = Property.query.get(property_id)
    if not prop:
        return jsonify({"error": "Property not found"}), 404
    if prop.landlord_id != get_jwt_identity():
        return jsonify({"error": "Unauthorized"}), 403

    db.session.delete(prop)
    db.session.commit()
    return jsonify({"message": "Property deleted"})
