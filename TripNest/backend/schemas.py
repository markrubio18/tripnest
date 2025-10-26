from pydantic import BaseModel
from typing import List, Optional
import datetime


class ContributionBase(BaseModel):
    amount: float


class ContributionCreate(ContributionBase):
    pass


class Contribution(ContributionBase):
    id: int
    user_id: int
    goal_id: int
    timestamp: datetime.datetime

    class Config:
        orm_mode = True


class GoalBase(BaseModel):
    name: str
    target_amount: float
    target_date: datetime.datetime


class GoalCreate(GoalBase):
    pass


class Goal(GoalBase):
    id: int
    group_id: int
    contributions: List[Contribution] = []

    class Config:
        orm_mode = True


class GroupBase(BaseModel):
    name: str
    description: Optional[str] = None


class GroupCreate(GroupBase):
    pass


class Group(GroupBase):
    id: int
    owner_id: int
    goal: Optional[Goal] = None
    members: List["User"] = []
    current_balance: Optional[float] = None
    projected_yield: Optional[float] = None
    estimated_final_balance: Optional[float] = None

    class Config:
        orm_mode = True


class UserBase(BaseModel):
    email: str
    full_name: Optional[str] = None


class UserCreate(UserBase):
    firebase_uid: str


class User(UserBase):
    id: int
    firebase_uid: str
    is_active: bool
    fcm_token: Optional[str] = None
    groups: List[Group] = []
    contributions: List[Contribution] = []

    class Config:
        orm_mode = True


Group.update_forward_refs()
