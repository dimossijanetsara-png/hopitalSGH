from django.db import models
from django.conf import settings

class Service(models.Model):
    """
    Représente un service hospitalier (ex: Réanimation, Urgences).
    """
    name = models.CharField(max_length=100, unique=True, verbose_name="Nom du service")
    code = models.CharField(max_length=10, unique=True, verbose_name="Code court (ex: REA, URG)")
    building = models.CharField(max_length=50, verbose_name="Bâtiment / Aile")
    floor = models.IntegerField(default=0, verbose_name="Étage")

    class Meta:
        verbose_name = "Service"
        verbose_name_plural = "Services"

    def __str__(self):
        return f"{self.name} (Bâtiment {self.building})"


class Chambre(models.Model):
    """
    Niveau intermédiaire obligatoire requis par le cahier des charges.
    Une chambre appartient à un service.
    """
    number = models.CharField(max_length=20, verbose_name="Numéro de chambre (ex: CH-102)")
    service = models.ForeignKey(Service, on_delete=models.CASCADE, related_name="chambres", verbose_name="Service associé")
    max_beds = models.IntegerField(default=2, verbose_name="Nombre maximum de lits")

    class Meta:
        verbose_name = "Chambre"
        verbose_name_plural = "Chambres"
        unique_together = ('number', 'service')

    def __str__(self):
        return f"Chambre {self.number} ({self.service.code})"


class Lit(models.Model):
    """
    Représente un lit au sein d'une chambre spécifique (Hiérarchie : Bâtiment > Service > Chambre > Lit).
    """
    DISPONIBLE = 'DISPO'
    OCCUPE = 'OCCUPE'
    NETTOYAGE = 'NETTOYAGE'
    RESERVE = 'RESERVE'

    STATUT_CHOICES = [
        (DISPONIBLE, 'Disponible'),
        (OCCUPE, 'Occupé'),
        (NETTOYAGE, 'En cours de nettoyage'),
        (RESERVE, 'Réservé / Bloqué'),
    ]

    STANDARD = 'STANDARD'
    REANIMATION = 'REA'
    SOINS_INTENSIFS = 'SI'

    TYPE_CHOICES = [
        (STANDARD, 'Lit Standard'),
        (REANIMATION, 'Lit de Réanimation'),
        (SOINS_INTENSIFS, 'Soins Intensifs'),
    ]

    number = models.CharField(max_length=20, verbose_name="Code du lit (ex: Lit A)")
    # Modification de la relation : le lit pointe vers la chambre
    chambre = models.ForeignKey(Chambre, on_delete=models.CASCADE, related_name="lits", verbose_name="Chambre associée")
    status = models.CharField(max_length=20, choices=STATUT_CHOICES, default=DISPONIBLE, verbose_name="Statut actuel")
    bed_type = models.CharField(max_length=20, choices=TYPE_CHOICES, default=STANDARD, verbose_name="Type de lit")
    last_updated = models.DateTimeField(auto_now=True, verbose_name="Dernière mise à jour")

    class Meta:
        verbose_name = "Lit"
        verbose_name_plural = "Lits"
        unique_together = ('number', 'chambre')

    def __str__(self):
        return f"{self.number} - Chambre {self.chambre.number} ({self.get_status_display()})"


class HistoriqueLit(models.Model):
    """
    Audit Trail immuable pour la traçabilité.
    """
    lit = models.ForeignKey(Lit, on_delete=models.CASCADE, related_name="historiques", verbose_name="Lit concerné")
    user = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.SET_NULL, null=True, verbose_name="Opérateur")
    old_status = models.CharField(max_length=20, verbose_name="Ancien statut")
    new_status = models.CharField(max_length=20, verbose_name="Nouveau statut")
    date_action = models.DateTimeField(auto_now_add=True, verbose_name="Date du changement")

    class Meta:
        verbose_name = "Historique de lit"
        verbose_name_plural = "Historique des lits"
        ordering = ['-date_action']

    def __str__(self):
        return f"Lit {self.lit.number}: {self.old_status} -> {self.new_status} par {self.user}"