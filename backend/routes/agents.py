from datetime import date
from flask import Blueprint, request, jsonify
from flask_jwt_extended import jwt_required, get_jwt_identity
from models import db, Reminder, Property
from utils.auth import agent_required

bp = Blueprint("agents", __name__, url_prefix="/api/agents")


@bp.route("/reminders", methods=["GET"])
@jwt_required()
@agent_required
def list_reminders():
    agent_id = get_jwt_identity()
    status = request.args.get("status")
    query = Reminder.query.filter_by(agent_id=agent_id)
    if status:
        query = query.filter_by(status=status)
    query = query.order_by(Reminder.due_date.asc())
    return jsonify([r.to_dict() for r in query.all()])


@bp.route("/reminders", methods=["POST"])
@jwt_required()
@agent_required
def create_reminder():
    data = request.get_json() or {}
    errors = {}
    for f in ("tenant_name", "due_date"):
        if not data.get(f):
            errors[f] = f"{f} is required"
    if errors:
        return jsonify({"error": "Validation failed", "details": errors}), 400

    reminder = Reminder(
        agent_id=get_jwt_identity(),
        tenant_name=data["tenant_name"],
        tenant_phone=data.get("tenant_phone"),
        property_id=data.get("property_id"),
        unit_number=data.get("unit_number"),
        rent_amount=float(data["rent_amount"]) if data.get("rent_amount") else None,
        due_date=date.fromisoformat(data["due_date"]),
        status=data.get("status", "unpaid"),
        notes=data.get("notes"),
    )
    db.session.add(reminder)
    db.session.commit()
    return jsonify(reminder.to_dict()), 201


@bp.route("/reminders/<reminder_id>", methods=["PUT"])
@jwt_required()
@agent_required
def update_reminder(reminder_id):
    reminder = Reminder.query.get(reminder_id)
    if not reminder:
        return jsonify({"error": "Reminder not found"}), 404
    if reminder.agent_id != get_jwt_identity():
        return jsonify({"error": "Unauthorized"}), 403

    data = request.get_json() or {}
    for field in ("tenant_name", "tenant_phone", "unit_number",
                  "rent_amount", "status", "notes"):
        if field in data:
            setattr(reminder, field, data[field])
    if "due_date" in data:
        reminder.due_date = date.fromisoformat(data["due_date"])

    db.session.commit()
    return jsonify(reminder.to_dict())


@bp.route("/reminders/<reminder_id>", methods=["DELETE"])
@jwt_required()
@agent_required
def delete_reminder(reminder_id):
    reminder = Reminder.query.get(reminder_id)
    if not reminder:
        return jsonify({"error": "Reminder not found"}), 404
    if reminder.agent_id != get_jwt_identity():
        return jsonify({"error": "Unauthorized"}), 403

    db.session.delete(reminder)
    db.session.commit()
    return jsonify({"message": "Reminder deleted"})


@bp.route("/reminders/overdue", methods=["GET"])
@jwt_required()
@agent_required
def overdue_reminders():
    agent_id = get_jwt_identity()
    today = date.today()
    reminders = Reminder.query.filter(
        Reminder.agent_id == agent_id,
        Reminder.status.in_(["unpaid", "overdue"]),
        Reminder.due_date < today,
    ).all()
    for r in reminders:
        r.status = "overdue"
    db.session.commit()
    return jsonify([r.to_dict() for r in reminders])
