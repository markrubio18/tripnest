from fastapi import FastAPI, Depends, HTTPException
from sqlalchemy.orm import Session
from typing import List

from . import crud, models, schemas, auth
from .database import SessionLocal, engine

models.Base.metadata.create_all(bind=engine)

app = FastAPI()


# Dependency
def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()


@app.post("/users/", response_model=schemas.User)
def create_user(user: schemas.UserCreate, db: Session = Depends(get_db)):
    db_user = crud.get_user_by_email(db, email=user.email)
    if db_user:
        raise HTTPException(status_code=400, detail="Email already registered")
    return crud.create_user(db=db, user=user)


@app.put("/users/me/fcm-token", response_model=schemas.User)
def update_fcm_token(
    fcm_token: str,
    db: Session = Depends(get_db),
    current_user: models.User = Depends(auth.get_current_user),
):
    return crud.update_user_fcm_token(db=db, user_id=current_user.id, fcm_token=fcm_token)


@app.get("/users/{user_id}", response_model=schemas.User)
def read_user(
    user_id: int,
    db: Session = Depends(get_db),
    current_user: models.User = Depends(auth.get_current_user),
):
    db_user = crud.get_user(db, user_id=user_id)
    if db_user is None:
        raise HTTPException(status_code=404, detail="User not found")
    return db_user


@app.post("/groups/", response_model=schemas.Group)
def create_group(
    group: schemas.GroupCreate,
    db: Session = Depends(get_db),
    current_user: models.User = Depends(auth.get_current_user),
):
    return crud.create_group(db=db, group=group, owner_id=current_user.id)


@app.post("/groups/{group_id}/members", response_model=schemas.Group)
def add_member_to_group_by_email(
    group_id: int,
    email: str,
    db: Session = Depends(get_db),
    current_user: models.User = Depends(auth.get_current_user),
):
    group = crud.get_group(db, group_id=group_id)
    if group.owner_id != current_user.id:
        raise HTTPException(status_code=403, detail="Only the group owner can add members")

    user_to_add = crud.get_user_by_email(db, email=email)
    if not user_to_add:
        raise HTTPException(status_code=404, detail="User not found")

    return crud.add_member_to_group(db=db, group_id=group_id, user_id=user_to_add.id)


from .investment import calculate_projected_yield

def _add_investment_details_to_group(group: models.Group):
    if group.goal:
        current_balance = sum(c.amount for c in group.goal.contributions)
        final_balance, estimated_yield = calculate_projected_yield(
            current_balance, group.goal.target_date
        )
        group.current_balance = current_balance
        group.projected_yield = estimated_yield
        group.estimated_final_balance = final_balance
    return group

@app.get("/groups/", response_model=List[schemas.Group])
def read_groups(
    skip: int = 0,
    limit: int = 100,
    db: Session = Depends(get_db),
    current_user: models.User = Depends(auth.get_current_user),
):
    groups = crud.get_groups_for_user(db, user_id=current_user.id, skip=skip, limit=limit)
    return [_add_investment_details_to_group(group) for group in groups]


@app.get("/groups/{group_id}", response_model=schemas.Group)
def read_group(
    group_id: int,
    db: Session = Depends(get_db),
    current_user: models.User = Depends(auth.get_current_user),
):
    group = crud.get_group(db, group_id=group_id)
    if group is None:
        raise HTTPException(status_code=404, detail="Group not found")
    if current_user not in group.members and current_user.id != group.owner_id:
        raise HTTPException(status_code=403, detail="Not authorized to access this group")

    return _add_investment_details_to_group(group)


@app.post("/goals/", response_model=schemas.Goal)
def create_goal(goal: schemas.GoalCreate, group_id: int, db: Session = Depends(get_db)):
    return crud.create_goal(db=db, goal=goal, group_id=group_id)


@app.get("/goals/{goal_id}", response_model=schemas.Goal)
def read_goal(goal_id: int, db: Session = Depends(get_db)):
    db_goal = crud.get_goal(db, goal_id=goal_id)
    if db_goal is None:
        raise HTTPException(status_code=404, detail="Goal not found")
    return db_goal


from .firebase import send_notification

@app.post("/contributions/", response_model=schemas.Contribution)
def create_contribution(
    contribution: schemas.ContributionCreate,
    goal_id: int,
    db: Session = Depends(get_db),
    current_user: models.User = Depends(auth.get_current_user),
):
    new_contribution = crud.create_contribution(
        db=db, contribution=contribution, user_id=current_user.id, goal_id=goal_id
    )
    goal = crud.get_goal(db, goal_id=goal_id)
    if goal and goal.group.owner.fcm_token:
        send_notification(
            token=goal.group.owner.fcm_token,
            title="New Contribution!",
            body=f"{current_user.full_name} just contributed ${contribution.amount} to {goal.name}.",
        )
    return new_contribution


@app.get("/groups/{group_id}/messages/", response_model=List[schemas.Message])
def read_messages(
    group_id: int,
    skip: int = 0,
    limit: int = 100,
    db: Session = Depends(get_db),
    current_user: models.User = Depends(auth.get_current_user),
):
    return crud.get_messages(db, group_id=group_id, skip=skip, limit=limit)


@app.post("/groups/{group_id}/messages/", response_model=schemas.Message)
def create_message(
    group_id: int,
    message: schemas.MessageCreate,
    db: Session = Depends(get_db),
    current_user: models.User = Depends(auth.get_current_user),
):
    return crud.create_message(
        db=db, message=message, user_id=current_user.id, group_id=group_id
    )
