"""
URL configuration for core project.

The `urlpatterns` list routes URLs to views. For more information please see:
    https://docs.djangoproject.com/en/6.0/topics/http/urls/
Examples:
Function views
    1. Add an import:  from my_app import views
    2. Add a URL to urlpatterns:  path('', views.home, name='home')
Class-based views
    1. Add an import:  from other_app.views import Home
    2. Add a URL to urlpatterns:  path('', Home.as_view(), name='home')
Including another URLconf
    1. Import the include() function: from django.urls import include, path
    2. Add a URL to urlpatterns:  path('blog/', include('blog.urls'))
"""
from django.contrib import admin
from django.urls import path
from ninja import NinjaAPI
from authentication.api import router as auth_router
from hospital.api import router as hospital_router  # Étape 1 : Importer

api = NinjaAPI(title="SGH Lits API", version="1.0.0")

# Ajout des différents modules de l'API
api.add_router("/auth", auth_router)
api.add_router("/hospital", hospital_router)  # Étape 2 : Connecter le routeur

urlpatterns = [
    path('admin/', admin.site.urls),
    path('api/', api.urls),
]