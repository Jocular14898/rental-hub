from flask import Blueprint, request, jsonify
from flask_jwt_extended import jwt_required, get_jwt_identity
from models import db, Booking, Property

bp = Blueprint("bookings", __name__, url_prefix="/api/bookings")


@bp.route("", methods=["GET"])
@jwt_required()
def list_bookings():
    user_id = get_jwt_identity()
    bookings = Booking.query.filter_by(tenant_id=user_id).order_by(
        Booking.created_at.desc()
    ).all()
    results = []
    for b in bookings:
        prop = Property.query.get(b.property_id)
        d = b.to_dict()
        d["property"] = prop.to_dict() if prop else None
        results.append(d)
    return jsonify(results)


@bp.route("/landlord", methods=["GET"])
@jwt_required()
def landlord_bookings():
    """Get bookings for the landlord's properties."""
    user_id = get_jwt_identity()
    property_ids = [
        p.id for p in Property.query.filter_by(landlord_id=user_id).all()
    ]
    if not property_ids:
        return jsonify([])
    bookings = Booking.query.filter(
        Booking.property_id.in_(property_ids)
    ).order_by(Booking.created_at.desc()).all()
    results = []
    for b in bookings:
        prop = Property.query.get(b.property_id)
        d = b.to_dict()
        d["property"] = prop.to_dict() if prop else None
        results.append(d)
    return jsonify(results)


@bp.route("", methods=["POST"])
@jwt_required()
def create_booking():
    data = request.get_json() or {}
    property_id = data.get("property_id")
    if not property_id:
        return jsonify({"error": "property_id is required"}), 400

    prop = Property.query.get(property_id)
    if not prop or not prop.is_active:
        return jsonify({"error": "Property not found"}), 404

    booking = Booking(
        tenant_id=get_jwt_identity(),
        property_id=property_id,
        message=data.get("message"),
    )
    db.session.add(booking)
    db.session.commit()
    return jsonify(booking.to_dict()), 201


@bp.route("/<booking_id>", methods=["PUT"])
@jwt_required()
def update_booking(booking_id):
    booking = Booking.query.get(booking_id)
    if not booking:
        return jsonify({"error": "Booking not found"}), 404

    data = request.get_json() or {}
    if "status" in data:
        booking.status = data["status"]
    if "message" in data:
        booking.message = data["message"]

    db.session.commit()
    return jsonify(booking.to_dict())
