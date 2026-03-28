from marshmallow import fields, validate
from app import ma
from app.models.blacklist import Blacklist


class BlacklistRequestSchema(ma.Schema):
    # Schema de validación para el cuerpo de la solicitud POST
    email = fields.Email(required=True)
    app_uuid = fields.UUID(required=True)
    blocked_reason = fields.String(
        required=False,
        allow_none=True,
        validate=validate.Length(max=255)
    )


class BlacklistResponseSchema(ma.SQLAlchemyAutoSchema):
    # Schema de serialización para la respuesta
    class Meta:
        model = Blacklist
        load_instance = False
