from django.views.generic import FormView
from django.views.generic import TemplateView
from django.views.generic import ListView
from django.views.generic import View
from django.views.generic import CreateView
from django.views.generic import UpdateView
from django.views.generic import DeleteView
from django.views.generic import DetailView
from django.urls import reverse_lazy
from django.shortcuts import render, redirect
from django.contrib.auth.forms import UserCreationForm
from django.contrib.auth.decorators import login_required
from django.core.files.storage import FileSystemStorage

from django.http.response import HttpResponse
from django.views.decorators.csrf import csrf_exempt
from formtools.wizard.views import SessionWizardView
from django.conf import settings
import sys
import json


def home(request):
    return render(request, 'website/index.html')

# --------------------- Menu ---------------------------


class About(TemplateView):
    template_name = "website/about.html"


class Dashboards(TemplateView):
    template_name = "website/dashboards.html"


class DataVisualization(TemplateView):
    template_name = "website/datavisualization.html"


class Discoveries(TemplateView):
    template_name = "website/discoveries.html"


class Contact(TemplateView):
    template_name = "website/contact.html"


# --------------------- Dashboards ---------------------------

class DashboardTaxasMalaria(TemplateView):
    template_name = "website/dashboards/TaxasMalaria.html"


class DashboardImportados(TemplateView):
    template_name = "website/dashboards/Importados.html"


# --------------------- Visualizations ---------------------------

class QualidadeInformacao(TemplateView):
    template_name = "website/visualization/QualidadeInformacao/Porcentagem.html"


class PlotlyCaseBubbleVisualization(TemplateView):
    template_name = "website/visualization/Casos/Cases_BubbleGraph.html"


class PlotlyCaseLineVisualization(TemplateView):
    template_name = "website/visualization/Casos/Cases_lineGraph.html"


class PlotlyEscolaridadeNivelVisualization(TemplateView):
    template_name = "website/visualization/Escolaridade/Escolaridade.html"


class PlotlyEscolaridadeAnosEstudoVisualization(TemplateView):
    template_name = "website/visualization/Escolaridade/anos_estudo.html"


class PlotlyGestanteVisualization(TemplateView):
    template_name = "website/visualization/Gestante/Gestante.html"


class PlotlyOcupacaoVisualization(TemplateView):
    template_name = "website/visualization/Ocupacao/Ocupacao.html"


class PlotlyMortesVisualization(TemplateView):
    template_name = "website/visualization/Mortes/MortesAmazoniaLegalArea.html"


class PlotlyCruzesVisualization(TemplateView):
    template_name = "website/visualization/Parasitemia-em-Cruzes/Cruzes.html"


class PlotlyPopulacaoVisualization(TemplateView):
    template_name = "website/visualization/Populacao/piramides-etarias.html"


class PlotlyMapDeckLocalidadesVisualization(TemplateView):
    template_name = "website/visualization/Localidade/mapdeck_localidades.html"


class PlotlyTaxaIncidenciaVisualization(TemplateView):
    template_name = "website/visualization/Taxa-Incidencia/TXINC.html"


class PlotlyGgridgesVisualization(TemplateView):
    template_name = "website/visualization/ggridges/index.html"


class PlotlyRedimentoVisualization(TemplateView):
    template_name = "website/visualization/Rendimento/renda.html"


class PlotlyRedimentoGiniVisualization(TemplateView):
    template_name = "website/visualization/Rendimento/gini.html"


class PlotlyMobilidadeVisualization(TemplateView):
    template_name = "website/visualization/Mobilidade/index.html"


# --------------------- NewsLetters ---------------------------


class NewsletterAtlasGeo(TemplateView):
    template_name = "website/newsletters/00_atlas_geo.html"


class NewsletterAtlasPop(TemplateView):
    template_name = "website/newsletters/01_atlas_pop.html"


class NewsletterAtlasComp(TemplateView):
    template_name = "website/newsletters/02_atlas_comp.html"


class NewsletterAtlasMig(TemplateView):
    template_name = "website/newsletters/03_atlas_mig.html"


class NewsletterAtlasMetodoLogia(TemplateView):
    template_name = "website/newsletters/04_atlas_metodologia.html"
