import uuid
from datetime import datetime, timezone
from . import db


SUBSCRIPTION_PRICES = {
    "landlord": 1000,
    "agent": 500,
}


class Subscription(db.Model):
    __tablename__ = "subscriptions"

    id = db.Column(db.String(36), primary_key=True, default=lambda: str(uuid.uuid4()))
    user_id = db.Column(
        db.String(36), db.ForeignKey("users.id"), nullable=False
    )
    plan_type = db.Column(db.String(20), nullable=False)  # landlord, agent
    status = db.Column(
        db.String(20), default="inactive"
    )  # active, inactive, expired
    mpesa_transaction_id = db.Column(db.String(100), nullable=True)
    amount = db.Column(db.Integer, nullable=False)
    start_date = db.Column(db.DateTime(timezone=True), nullable=True)
    end_date = db.Column(db.DateTime(timezone=True), nullable=True)
    created_at = db.Column(
        db.DateTime(timezone=True), default=lambda: datetime.now(timezone.utc)
    )

    def to_dict(self):
        return {
            "id": self.id,
            "user_id": self.user_id,
            "plan_type": self.plan_type,
            "status": self.status,
            "mpesa_transaction_id": self.mpesa_transaction_id,
            "amount": self.amount,
            "start_date": self.start_date.isoformat() if self.start_date else None,
            "end_date": self.end_date.isoformat() if self.end_date else None,
            "created_at": self.created_at.isoformat() if self.created_at else None,
        }

    def is_active(self) -> bool:
        if self.status != "active":
            return False
        if self.end_date and self.end_date < datetime.now(timezone.utc):
            self.status = "expired"
            return False
        return True
