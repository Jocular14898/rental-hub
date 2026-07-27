import uuid
from datetime import datetime, timezone
from . import db


class Favorite(db.Model):
    __tablename__ = "favorites"

    id = db.Column(db.String(36), primary_key=True, default=lambda: str(uuid.uuid4()))
    user_id = db.Column(db.String(36), db.ForeignKey("users.id"), nullable=False)
    property_id = db.Column(db.String(36), db.ForeignKey("properties.id"), nullable=False)
    created_at = db.Column(
        db.DateTime(timezone=True), default=lambda: datetime.now(timezone.utc)
    )

    __table_args__ = (db.UniqueConstraint("user_id", "property_id"),)

    def to_dict(self):
        return {
            "id": self.id,
            "user_id": self.user_id,
            "property_id": self.property_id,
            "created_at": self.created_at.isoformat() if self.created_at else None,
        }
