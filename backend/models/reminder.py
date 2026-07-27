import uuid
from datetime import datetime, timezone
from . import db


class Reminder(db.Model):
    __tablename__ = "reminders"

    id = db.Column(db.String(36), primary_key=True, default=lambda: str(uuid.uuid4()))
    agent_id = db.Column(
        db.String(36), db.ForeignKey("users.id"), nullable=False
    )
    tenant_name = db.Column(db.String(100), nullable=False)
    tenant_phone = db.Column(db.String(20), nullable=True)
    property_id = db.Column(
        db.String(36), db.ForeignKey("properties.id"), nullable=True
    )
    unit_number = db.Column(db.String(50), nullable=True)
    rent_amount = db.Column(db.Float, nullable=True)
    due_date = db.Column(db.Date, nullable=False)
    status = db.Column(
        db.String(20), default="unpaid"
    )  # unpaid, paid, overdue
    notes = db.Column(db.Text, nullable=True)
    created_at = db.Column(
        db.DateTime(timezone=True), default=lambda: datetime.now(timezone.utc)
    )

    def to_dict(self):
        return {
            "id": self.id,
            "agent_id": self.agent_id,
            "tenant_name": self.tenant_name,
            "tenant_phone": self.tenant_phone,
            "property_id": self.property_id,
            "unit_number": self.unit_number,
            "rent_amount": self.rent_amount,
            "due_date": self.due_date.isoformat() if self.due_date else None,
            "status": self.status,
            "notes": self.notes,
            "created_at": self.created_at.isoformat() if self.created_at else None,
        }
