import firebase_admin
from firebase_admin import credentials, auth, messaging
import os
from dotenv import load_dotenv

load_dotenv()

cred = credentials.Certificate(os.getenv("FIREBASE_SERVICE_ACCOUNT_KEY_PATH"))
firebase_admin.initialize_app(cred)


def verify_token(token: str):
    try:
        decoded_token = auth.verify_id_token(token)
        return decoded_token
    except Exception as e:
        return None


def send_notification(token: str, title: str, body: str):
    message = messaging.Message(
        notification=messaging.Notification(title=title, body=body),
        token=token,
    )
    try:
        response = messaging.send(message)
        return response
    except Exception as e:
        return None
