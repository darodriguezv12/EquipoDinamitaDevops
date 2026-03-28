import os
from flask import request, current_app
from flask_restful import Resource
from marshmallow import ValidationError
from sqlalchemy.exc import IntegrityError
from app import db
from app.models.blacklist import Blacklist
from app.schemas.blacklist import BlacklistRequestSchema

request_schema = BlacklistRequestSchema()


def _verify_token():
    auth_header = request.headers.get("Authorization", "")
    if not auth_header.startswith("Bearer "):
        return False
    token = auth_header[len("Bearer "):]
    return token == current_app.config.get("STATIC_TOKEN", "")


class BlacklistResource(Resource):

    def post(self):
        if not _verify_token():
            return {"mensaje": "Token de autenticación inválido o ausente"}, 401

        json_data = request.get_json(silent=True)
        if not json_data:
            return {"mensaje": "El cuerpo de la solicitud debe ser JSON válido"}, 400

        try:
            data = request_schema.load(json_data)
        except ValidationError as err:
            return {"mensaje": "Datos de entrada inválidos", "errores": err.messages}, 400

        if Blacklist.query.filter_by(email=data["email"]).first():
            return {"mensaje": "El correo electrónico ya se encuentra en la lista negra"}, 409

        ip_address = request.headers.get("X-Forwarded-For", request.remote_addr)
        if ip_address and "," in ip_address:
            ip_address = ip_address.split(",")[0].strip()

        entry = Blacklist(
            email=data["email"],
            app_uuid=str(data["app_uuid"]),
            blocked_reason=data.get("blocked_reason"),
            ip_address=ip_address,
        )

        try:
            db.session.add(entry)
            db.session.commit()
        except IntegrityError:
            db.session.rollback()
            return {"mensaje": "El correo electrónico ya se encuentra en la lista negra"}, 409

        return {"mensaje": "Correo electrónico agregado exitosamente a la lista negra"}, 201
