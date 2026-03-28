import uuid
from datetime import datetime, timezone
from app import db


class Blacklist(db.Model):
    __tablename__ = "blacklists"

    id = db.Column(
        db.String(36),
        primary_key=True,
        default=lambda: str(uuid.uuid4())
    )
    email = db.Column(db.String(255), nullable=False, unique=True)
    app_uuid = db.Column(db.String(36), nullable=False)
    blocked_reason = db.Column(db.String(255), nullable=True)
    # Longitud 45 para soportar IPv6
    ip_address = db.Column(db.String(45), nullable=False)
    created_at = db.Column(
        db.DateTime(timezone=True),
        nullable=False,
        default=lambda: datetime.now(timezone.utc)
    )
