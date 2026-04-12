import os
from dotenv import load_dotenv

load_dotenv()

class Config:
    SQLALCHEMY_DATABASE_URI = os.getenv("DATABASE_URL")
    SQLALCHEMY_TRACK_MODIFICATIONS = False
    API_TOKEN = os.getenv("API_TOKEN")
    DB_INIT_RETRIES = int(os.getenv("DB_INIT_RETRIES", "5"))
    DB_INIT_DELAY = float(os.getenv("DB_INIT_DELAY", "2"))
