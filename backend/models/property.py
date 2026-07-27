import uuid
from datetime import datetime, timezone
from . import db


class Property(db.Model):
    __tablename__ = "properties"

    id = db.Column(db.String(36), primary_key=True, default=lambda: str(uuid.uuid4()))
    landlord_id = db.Column(
        db.String(36), db.ForeignKey("users.id"), nullable=False
    )
    title = db.Column(db.String(200), nullable=False)
    price = db.Column(db.Float, nullable=False)
    location = db.Column(db.String(200), nullable=False)
    latitude = db.Column(db.Float, nullable=True)
    longitude = db.Column(db.Float, nullable=True)
    bedrooms = db.Column(db.Integer, nullable=False)
    house_type = db.Column(db.String(50), nullable=True)  # apartment, maisonette, bungalow, etc.
    description = db.Column(db.Text, nullable=True)
    security_details = db.Column(db.Text, nullable=True)
    parking = db.Column(db.Boolean, default=False)
    water_available = db.Column(db.Boolean, default=False)
    contact_phone = db.Column(db.String(20), nullable=False)
    is_active = db.Column(db.Boolean, default=True)
    created_at = db.Column(
        db.DateTime(timezone=True), default=lambda: datetime.now(timezone.utc)
    )

    photos = db.relationship(
        "PropertyPhoto", backref="property", lazy="dynamic",
        cascade="all, delete-orphan", order_by="PropertyPhoto.is_primary.desc()"
    )

    def to_dict(self):
        return {
            "id": self.id,
            "landlord_id": self.landlord_id,
            "title": self.title,
            "price": self.price,
            "location": self.location,
            "latitude": self.latitude,
            "longitude": self.longitude,
            "bedrooms": self.bedrooms,
            "house_type": self.house_type,
            "description": self.description,
            "security_details": self.security_details,
            "parking": self.parking,
            "water_available": self.water_available,
            "contact_phone": self.contact_phone,
            "is_active": self.is_active,
            "photos": [p.to_dict() for p in self.photos],
            "created_at": self.created_at.isoformat() if self.created_at else None,
        }


class PropertyPhoto(db.Model):
    __tablename__ = "property_photos"

    id = db.Column(db.String(36), primary_key=True, default=lambda: str(uuid.uuid4()))
    property_id = db.Column(
        db.String(36), db.ForeignKey("properties.id"), nullable=False
    )
    url = db.Column(db.String(500), nullable=False)
    is_primary = db.Column(db.Boolean, default=False)

    def to_dict(self):
        return {
            "id": self.id,
            "url": self.url,
            "is_primary": self.is_primary,
        }
