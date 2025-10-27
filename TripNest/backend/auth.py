from fastapi import Depends, HTTPException, Security
from fastapi.security import HTTPAuthorizationCredentials, HTTPBearer
from .firebase import verify_token
from . import crud, models
from .database import SessionLocal

security = HTTPBearer()

def get_current_user(credentials: HTTPAuthorizationCredentials = Security(security)):
    token = credentials.credentials
    decoded_token = verify_token(token)
    if decoded_token is None:
        raise HTTPException(status_code=401, detail="Invalid authentication credentials")

    db = SessionLocal()
    user = crud.get_user_by_firebase_uid(db, firebase_uid=decoded_token["uid"])
    db.close()

    if user is None:
        raise HTTPException(status_code=404, detail="User not found")

    return user
