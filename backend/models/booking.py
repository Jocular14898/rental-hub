import uuid
from datetime import datetime, timezone
from . import db


class Booking(db.Model):
    __tablename__ = "bookings"

    id = db.Column(db.String(36), primary_key=True, default=lambda: str(uuid.uuid4()))
    tenant_id = db.Column(db.String(36), db.ForeignKey("users.id"), nullable=False)
    property_id = db.Column(db.String(36), db.ForeignKey("properties.id"), nullable=False)
    status = db.Column(
        db.String(20), default="pending"
    )  # pending, confirmed, cancelled
    message = db.Column(db.Text, nullable=True)
    created_at = db.Column(
        db.DateTime(timezone=True), default=lambda: datetime.now(timezone.utc)
    )

    def to_dict(self):
        return {
            "id": self.id,
            "tenant_id": self.tenant_id,
            "property_id": self.property_id,
            "status": self.status,
            "message": self.message,
            "created_at": self.created_at.isoformat() if self.created_at else None,
        }
