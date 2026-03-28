from flask import Flask
from flask_sqlalchemy import SQLAlchemy
from flask_marshmallow import Marshmallow
from flask_migrate import Migrate
from config import config

db = SQLAlchemy()
ma = Marshmallow()
migrate = Migrate()


def create_app(config_name="default"):
    app = Flask(__name__)
    app.config.from_object(config[config_name])

    db.init_app(app)
    ma.init_app(app)
    migrate.init_app(app, db)

    from flask_restful import Api
    from app.routes.blacklist import BlacklistResource

    api = Api(app)
    api.add_resource(BlacklistResource, "/blacklists")

    return app
