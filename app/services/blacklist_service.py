import uuid

from app import db
from app.models import Blacklist


def validate_app_uuid(app_uuid):
    try:
        uuid.UUID(app_uuid)
    except ValueError as exc:
        raise ValueError("app_uuid must be a valid UUID") from exc


def create_blacklist_entry(data, ip_address):
    email = data.get("email")
    app_uuid = data.get("app_uuid")
    blocked_reason = data.get("blocked_reason")

    if not email:
        raise ValueError("Email is required")

    if not app_uuid:
        raise ValueError("app_uuid is required")

    validate_app_uuid(app_uuid)

    if blocked_reason and len(blocked_reason) > 255:
        raise ValueError("blocked_reason must be at most 255 characters")

    existing_email = Blacklist.query.filter_by(email=email).first()
    if existing_email:
        return {"message": "Email is already in blacklist"}, 409

    blacklist_entry = Blacklist(
        email=email,
        app_uuid=app_uuid,
        blocked_reason=blocked_reason,
        ip_address=ip_address,
    )

    db.session.add(blacklist_entry)
    db.session.commit()

    return {"message": "Email added to blacklist successfully"}, 201


def get_blacklist_status(email):
    blacklist_entry = Blacklist.query.filter_by(email=email).first()

    if blacklist_entry:
        return {
            "is_blacklisted": True,
            "blocked_reason": blacklist_entry.blocked_reason,
        }, 200

    return {
        "is_blacklisted": False,
        "blocked_reason": None,
    }, 200
