from ninja import Schema
from datetime import datetime

class ServiceSchema(Schema):
    id: int
    name: str
    code: str
    building: str
    floor: int

class LitSchema(Schema):
    id: int
    number: str
    service_id: int
    service_code: str  # Pratique pour l'affichage rapide sur mobile
    status: str
    status_display: str  # Version lisible (ex: "En cours de nettoyage")
    bed_type: str
    bed_type_display: str
    last_updated: datetime

# Schéma utilisé pour mettre à jour le statut d'un lit depuis le Frontend
class UpdateLitStatusSchema(Schema):
    status: str