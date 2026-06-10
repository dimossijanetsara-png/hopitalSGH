from django.contrib import admin
from django.contrib.auth.admin import UserAdmin
from .models import User

class CustomUserAdmin(UserAdmin):
    # Ajoute le champ 'role' et 'phone_number' dans les formulaires d'édition de l'admin
    fieldsets = UserAdmin.fieldsets + (
        ('Informations RH / SGH Lits', {'fields': ('role', 'phone_number')}),
    )
    # Affiche le rôle directement dans la liste des utilisateurs
    list_display = ['username', 'email', 'role', 'is_staff', 'is_superuser']
    list_filter = ['role', 'is_staff', 'is_superuser']

# Enregistrement du modèle personnalisé
admin.site.register(User, CustomUserAdmin)