from flask_sqlalchemy import SQLAlchemy

db = SQLAlchemy()

from .user import User
from .property import Property, PropertyPhoto
from .reminder import Reminder
from .subscription import Subscription, SUBSCRIPTION_PRICES
from .favorite import Favorite
from .booking import Booking
