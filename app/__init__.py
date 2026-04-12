import time

from flask import Flask, jsonify
from flask_sqlalchemy import SQLAlchemy
from sqlalchemy import text
from sqlalchemy.exc import SQLAlchemyError

db = SQLAlchemy()


def initialize_database(app, retries=None):
    max_retries = retries if retries is not None else app.config["DB_INIT_RETRIES"]
    delay = app.config["DB_INIT_DELAY"]

    with app.app_context():
        from app.models import Blacklist

        for attempt in range(1, max_retries + 1):
            try:
                db.session.execute(text("SELECT 1"))
                db.create_all()
                app.config["DB_READY"] = True
                return True
            except SQLAlchemyError as exc:
                db.session.remove()
                app.config["DB_READY"] = False
                app.logger.warning(
                    "Database initialization attempt %s/%s failed: %s",
                    attempt,
                    max_retries,
                    exc,
                )
                if attempt < max_retries:
                    time.sleep(delay)

    return False


def create_app():
    app = Flask(__name__)
    app.config.from_object("app.config.Config")

    db.init_app(app)

    from app.routes import bp
    app.register_blueprint(bp)

    @app.errorhandler(SQLAlchemyError)
    def handle_database_error(error):
        db.session.rollback()
        app.logger.warning("Database request failed: %s", error)
        return jsonify({"message": "Database is not available right now"}), 503

    initialize_database(app)

    return app
