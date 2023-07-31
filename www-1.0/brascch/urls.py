"""brascch URL Configuration
"""
from django.contrib import admin
from django.urls import path, include

urlpatterns = [
    # url padrão 
    path('', include('website.urls')),

    # interface administrativa 
    path('admin/', admin.site.urls),

    # Translator
    path('i18n', include('django.conf.urls.i18n')),

]


