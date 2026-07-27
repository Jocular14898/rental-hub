import os
from flask import Flask, send_from_directory
from flask_migrate import Migrate
from flask_jwt_extended import JWTManager
from flask_cors import CORS
from config import Config
from models import db

jwt = JWTManager()


def create_app(config_class=Config):
    app = Flask(__name__)
    app.config.from_object(config_class)
    CORS(app)

    db.init_app(app)
    Migrate(app, db)
    jwt.init_app(app)

    from routes.auth import bp as auth_bp
    from routes.properties import bp as properties_bp
    from routes.agents import bp as agents_bp
    from routes.subscriptions import bp as subscriptions_bp
    from routes.favorites import bp as favorites_bp
    from routes.bookings import bp as bookings_bp

    app.register_blueprint(auth_bp)
    app.register_blueprint(properties_bp)
    app.register_blueprint(agents_bp)
    app.register_blueprint(subscriptions_bp)
    app.register_blueprint(favorites_bp)
    app.register_blueprint(bookings_bp)

    # Serve uploaded files
    upload_dir = app.config.get("UPLOAD_FOLDER",
                                 os.path.join(os.path.dirname(__file__), "..", "uploads"))

    @app.route("/uploads/<path:filename>")
    def uploaded_file(filename):
        return send_from_directory(upload_dir, filename)

    @app.route("/api/health")
    def health():
        return {"status": "ok"}

    # Create tables on first request in development
    with app.app_context():
        db.create_all()

    return app


def main():
    app = create_app()
    port = int(os.environ.get("PORT", 8200))
    print(f"RentalHub API → http://localhost:{port}")
    app.run(host="0.0.0.0", port=port, debug=True)


if __name__ == "__main__":
    main()
