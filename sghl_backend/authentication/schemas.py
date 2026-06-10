from ninja import Schema
from typing import Optional

# Ce que l'application envoie pour se connecter
class LoginSchema(Schema):
    username: str
    password: str

# Ce que le Backend renvoie si la connexion réussit
class TokenSchema(Schema):
    token: str
    username: str
    role: str
    email: Optional[str] = None