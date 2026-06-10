from django.contrib import admin
from .models import Service, Chambre, Lit, HistoriqueLit

@admin.register(Service)
class ServiceAdmin(admin.ModelAdmin):
    # Colonnes affichées dans la liste des services
    list_display = ('name', 'code', 'building', 'floor')
    # Barre de recherche pour trouver un service par son nom ou son code
    search_fields = ('name', 'code')


@admin.register(Chambre)
class ChambreAdmin(admin.ModelAdmin):
    # Colonnes affichées pour les chambres
    list_display = ('number', 'service', 'max_beds')
    # Filtre latéral pour trier les chambres par service
    list_filter = ('service',)
    # Barre de recherche pour trouver une chambre par son numéro
    search_fields = ('number',)


@admin.register(Lit)
class LitAdmin(admin.ModelAdmin):
    # On remplace 'service' par 'chambre' et on ajoute une méthode pour afficher le service de la chambre
    list_display = ('number', 'chambre', 'get_service', 'status', 'bed_type', 'last_updated')
    # On filtre désormais par le statut, le type de lit et le service à travers la relation de la chambre
    list_filter = ('status', 'bed_type', 'chambre__service')
    # Barre de recherche pour trouver un lit par son numéro
    search_fields = ('number',)
    # Permet de modifier le statut à la volée directement depuis la liste globale
    list_editable = ('status',)

    # Petite fonction pour afficher directement le code du service dans le tableau des lits
    def get_service(self, obj):
        return obj.chambre.service.code
    get_service.short_description = 'Service'  # Nom de la colonne dans l'admin


@admin.register(HistoriqueLit)
class HistoriqueLitAdmin(admin.ModelAdmin):
    # Colonnes affichées pour l'Audit Trail
    list_display = ('lit', 'user', 'old_status', 'new_status', 'date_action')
    # Filtres par statuts et par date pour l'analyse des administrateurs
    list_filter = ('old_status', 'new_status', 'date_action')
    # Sécurité médicale : on met tout en "lecture seule" pour empêcher la falsification
    readonly_fields = ('lit', 'user', 'old_status', 'new_status', 'date_action')

    # Empêche complètement d'ajouter un historique à la main depuis l'admin
    def has_add_permission(self, request):
        return False

    # Empêche complètement de supprimer une ligne d'historique (Traçabilité stricte)
    def has_delete_permission(self, request, obj=None):
        return False