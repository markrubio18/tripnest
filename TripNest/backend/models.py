from sqlalchemy import Boolean, Column, ForeignKey, Integer, String, Float, DateTime, Table
from sqlalchemy.orm import relationship
import datetime

from .database import Base


class User(Base):
    __tablename__ = "users"

    id = Column(Integer, primary_key=True, index=True)
    firebase_uid = Column(String, unique=True, index=True)
    email = Column(String, unique=True, index=True)
    full_name = Column(String, index=True)
    is_active = Column(Boolean, default=True)
    fcm_token = Column(String, nullable=True)

    groups = relationship("Group", back_populates="owner")
    contributions = relationship("Contribution", back_populates="user")


class Group(Base):
    __tablename__ = "groups"

    id = Column(Integer, primary_key=True, index=True)
    name = Column(String, index=True)
    description = Column(String)
    owner_id = Column(Integer, ForeignKey("users.id"))

    owner = relationship("User", back_populates="groups")
    members = relationship("User", secondary="group_members")
    goal = relationship("Goal", uselist=False, back_populates="group")


class Goal(Base):
    __tablename__ = "goals"

    id = Column(Integer, primary_key=True, index=True)
    name = Column(String, index=True)
    target_amount = Column(Float)
    target_date = Column(DateTime)
    group_id = Column(Integer, ForeignKey("groups.id"), unique=True)

    group = relationship("Group", back_populates="goal")
    contributions = relationship("Contribution", back_populates="goal")


class Contribution(Base):
    __tablename__ = "contributions"

    id = Column(Integer, primary_key=True, index=True)
    amount = Column(Float)
    timestamp = Column(DateTime, default=datetime.datetime.utcnow)
    user_id = Column(Integer, ForeignKey("users.id"))
    goal_id = Column(Integer, ForeignKey("goals.id"))

    user = relationship("User", back_populates="contributions")
    goal = relationship("Goal", back_populates="contributions")


group_members = Table(
    "group_members",
    Base.metadata,
    Column("group_id", Integer, ForeignKey("groups.id"), primary_key=True),
    Column("user_id", Integer, ForeignKey("users.id"), primary_key=True),
)


class Message(Base):
    __tablename__ = "messages"

    id = Column(Integer, primary_key=True, index=True)
    text = Column(String)
    timestamp = Column(DateTime, default=datetime.datetime.utcnow)
    user_id = Column(Integer, ForeignKey("users.id"))
    group_id = Column(Integer, ForeignKey("groups.id"))

    user = relationship("User")
    group = relationship("Group")
