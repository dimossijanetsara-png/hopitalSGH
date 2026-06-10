from django.contrib.auth.models import AbstractUser
from django.db import models

class User(AbstractUser):
    # Définition des rôles requis par le système
    ADMIN = 'ADMIN'
    REGULATEUR = 'REGULATEUR'
    SOIGNANT = 'SOIGNANT'
    
    ROLE_CHOICES = [
        (ADMIN, 'Administrateur'),
        (REGULATEUR, 'Régulateur de lits'),
        (SOIGNANT, 'Personnel Soignant'),
    ]
    
    role = models.CharField(
        max_length=20, 
        choices=ROLE_CHOICES, 
        default=SOIGNANT
    )
    
    # Ajout d'un numéro de téléphone pour les notifications urgentes
    phone_number = models.CharField(max_length=15, blank=True, null=True)

    def __str__(self):
        return f"{self.username} ({self.get_role_display()})"