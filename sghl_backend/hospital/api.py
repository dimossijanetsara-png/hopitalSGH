from ninja import Router
from typing import List
from ninja.errors import HttpError
from .models import Lit, HistoriqueLit  # Ajout de l'import HistoriqueLit
from .schemas import LitSchema, UpdateLitStatusSchema
from authentication.api import JWTAuthBearer

router = Router(auth=JWTAuthBearer())

@router.get("/lits", response=List[LitSchema])
def list_lits(request):
    user = request.auth 
    lits = Lit.objects.select_related('service').all()
    results = []
    for lit in lits:
        results.append({
            "id": lit.id,
            "number": lit.number,
            "service_id": lit.service.id,
            "service_code": lit.service.code,
            "status": lit.status,
            "status_display": lit.get_status_display(),
            "bed_type": lit.bed_type,
            "bed_type_display": lit.get_bed_type_display(),
            "last_updated": lit.last_updated
        })
    return results


@router.patch("/lits/{lit_id}/status", response=LitSchema)
def update_lit_status(request, lit_id: int, data: UpdateLitStatusSchema):
    user = request.auth

    try:
        lit = Lit.objects.select_related('service').get(id=lit_id)
    except Lit.DoesNotExist:
        raise HttpError(404, f"Le lit avec l'ID {lit_id} n'existe pas.")

    # Logique RBAC
    if user and user.role == 'SOIGNANT':
        if hasattr(user, 'service') and user.service != lit.service:
            raise HttpError(403, "Action interdite : Vous ne pouvez modifier que les lits de votre service.")

    valides_status = [choice[0] for choice in Lit.STATUT_CHOICES]
    if data.status not in valides_status:
        raise HttpError(400, f"Statut invalide.")

    # --- CRÉATION DE L'AUDIT TRAIL (Nouveau bloc) ---
    old_status_value = lit.status
    new_status_value = data.status

    # On n'enregistre un historique que si le statut a réellement changé
    if old_status_value != new_status_value:
        HistoriqueLit.objects.create(
            lit=lit,
            user=user,  # L'utilisateur connecté extrait du Token
            old_status=old_status_value,
            new_status=new_status_value
        )
    # ------------------------------------------------

    # Mise à jour finale du lit
    lit.status = new_status_value
    lit.save()

    return {
        "id": lit.id,
        "number": lit.number,
        "service_id": lit.service.id,
        "service_code": lit.service.code,
        "status": lit.status,
        "status_display": lit.get_status_display(),
        "bed_type": lit.bed_type,
        "bed_type_display": lit.get_bed_type_display(),
        "last_updated": lit.last_updated
    }