from sqlalchemy.orm import Session

from . import models, schemas


def get_user(db: Session, user_id: int):
    return db.query(models.User).filter(models.User.id == user_id).first()


def get_user_by_email(db: Session, email: str):
    return db.query(models.User).filter(models.User.email == email).first()


def get_user_by_firebase_uid(db: Session, firebase_uid: str):
    return db.query(models.User).filter(models.User.firebase_uid == firebase_uid).first()


def get_users(db: Session, skip: int = 0, limit: int = 100):
    return db.query(models.User).offset(skip).limit(limit).all()


def create_user(db: Session, user: schemas.UserCreate):
    db_user = models.User(
        email=user.email, full_name=user.full_name, firebase_uid=user.firebase_uid
    )
    db.add(db_user)
    db.commit()
    db.refresh(db_user)
    return db_user


def update_user_fcm_token(db: Session, user_id: int, fcm_token: str):
    db_user = get_user(db, user_id)
    if db_user:
        db_user.fcm_token = fcm_token
        db.commit()
        db.refresh(db_user)
    return db_user


def get_group(db: Session, group_id: int):
    return db.query(models.Group).filter(models.Group.id == group_id).first()


def get_groups_for_user(db: Session, user_id: int, skip: int = 0, limit: int = 100):
    return (
        db.query(models.Group)
        .filter((models.Group.owner_id == user_id) | (models.Group.members.any(id=user_id)))
        .offset(skip)
        .limit(limit)
        .all()
    )


def create_group(db: Session, group: schemas.GroupCreate, owner_id: int):
    db_group = models.Group(**group.dict(), owner_id=owner_id)
    db.add(db_group)
    db.commit()
    db.refresh(db_group)
    return db_group


def add_member_to_group(db: Session, group_id: int, user_id: int):
    db_group = get_group(db, group_id)
    db_user = get_user(db, user_id)
    if db_group and db_user:
        db_group.members.append(db_user)
        db.commit()
        db.refresh(db_group)
    return db_group


def get_goal(db: Session, goal_id: int):
    return db.query(models.Goal).filter(models.Goal.id == goal_id).first()


def create_goal(db: Session, goal: schemas.GoalCreate, group_id: int):
    db_goal = models.Goal(**goal.dict(), group_id=group_id)
    db.add(db_goal)
    db.commit()
    db.refresh(db_goal)
    return db_goal


def create_contribution(
    db: Session, contribution: schemas.ContributionCreate, user_id: int, goal_id: int
):
    db_contribution = models.Contribution(
        **contribution.dict(), user_id=user_id, goal_id=goal_id
    )
    db.add(db_contribution)
    db.commit()
    db.refresh(db_contribution)
    return db_contribution


def get_messages(db: Session, group_id: int, skip: int = 0, limit: int = 100):
    return (
        db.query(models.Message)
        .filter(models.Message.group_id == group_id)
        .offset(skip)
        .limit(limit)
        .all()
    )


def create_message(db: Session, message: schemas.MessageCreate, user_id: int, group_id: int):
    db_message = models.Message(
        **message.dict(), user_id=user_id, group_id=group_id
    )
    db.add(db_message)
    db.commit()
    db.refresh(db_message)
    return db_message
