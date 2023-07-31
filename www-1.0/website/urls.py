from django.views.generic import TemplateView

from website.views import PlotlyCaseBubbleVisualization, PlotlyCaseLineVisualization
from website.views import PlotlyEscolaridadeNivelVisualization, PlotlyEscolaridadeAnosEstudoVisualization
from website.views import PlotlyGestanteVisualization, PlotlyOcupacaoVisualization
from website.views import PlotlyMortesVisualization, PlotlyCruzesVisualization
from website.views import PlotlyPopulacaoVisualization, PlotlyMapDeckLocalidadesVisualization
from website.views import PlotlyTaxaIncidenciaVisualization, PlotlyGgridgesVisualization
from website.views import PlotlyRedimentoVisualization, PlotlyRedimentoGiniVisualization, PlotlyMobilidadeVisualization
from website.views import QualidadeInformacao
from website.views import NewsletterAtlasGeo, NewsletterAtlasPop, NewsletterAtlasMig, NewsletterAtlasComp, NewsletterAtlasMetodoLogia
from website.views import About, Dashboards, DataVisualization, Discoveries, Contact
from website.views import DashboardTaxasMalaria, DashboardImportados
from django.contrib import admin
from django.urls import path, include
from django.conf.urls import url
from django.conf import settings
from django.conf.urls.static import static


from.import views

app_name = 'website'

# lista de roteamentos de URLs para funções/Views
urlpatterns = [

    # --------------------- Menu ----------------------------------

    path('', views.home, name="home"),
    path('about', About.as_view(), name="about"),
    path('dashboards', Dashboards.as_view(), name="dashboards"),
    path('datavisualization', DataVisualization.as_view(),
         name="datavisualization"),
    path('discoveries', Discoveries.as_view(), name="discoveries"),
    path('contact', Contact.as_view(), name="contact"),

    path('myAdmin/', admin.site.urls),

    # --------------------- Dashboards ---------------------------

    path('dashboardTaxasMalaria', DashboardTaxasMalaria.as_view(),
         name="dashboardTaxasMalaria"),

    path('dashboardImportados', DashboardImportados.as_view(),
         name="dashboardImportados"),

    # --------------------- Visualizations------------------------

    path('qualidade_informacao', QualidadeInformacao.as_view(),
         name="qualidade_informacao"),

    path('plotly_case_bubble', PlotlyCaseBubbleVisualization.as_view(),
         name="plotly_case_bubble"),

    path('plotly_case_line', PlotlyCaseLineVisualization.as_view(),
         name="plotly_case_line"),

    path('plotly_escolaridade_nivel', PlotlyEscolaridadeNivelVisualization.as_view(),
         name="plotly_escolaridade_nivel"),

    path('plotly_escolaridade_anos_estudo', PlotlyEscolaridadeAnosEstudoVisualization.as_view(),
         name="plotly_escolaridade_anos_estudo"),

    path('plotly_gestante', PlotlyGestanteVisualization.as_view(),
         name="plotly_gestante"),

    path('plotly_ocupacao', PlotlyOcupacaoVisualization.as_view(),
         name="plotly_ocupacao"),

    path('plotly_mortes', PlotlyMortesVisualization.as_view(),
         name="plotly_mortes"),

    path('plotly_cruzes', PlotlyCruzesVisualization.as_view(),
         name="plotly_cruzes"),

    path('plotly_populacao', PlotlyPopulacaoVisualization.as_view(),
         name="plotly_populacao"),

    path('plotly_mapdeck_localidades', PlotlyMapDeckLocalidadesVisualization.as_view(),
         name="plotly_mapdeck_localidades"),

    path('plotly_taxa_incidencia', PlotlyTaxaIncidenciaVisualization.as_view(),
         name="plotly_taxa_incidencia"),

    path('plotly_ggridges', PlotlyGgridgesVisualization.as_view(),
         name="plotly_ggridges"),

    path('plotly_redimento', PlotlyRedimentoVisualization.as_view(),
         name="plotly_rendimento"),

    path('plotly_redimento_gini', PlotlyRedimentoGiniVisualization.as_view(),
         name="plotly_rendimento_gini"),

    path('plotly_mobilidade', PlotlyMobilidadeVisualization.as_view(),
         name="plotly_mobilidade"),





    # --------------------- NewsLetters ------------------------

    path('newsletter_atlas_geo', NewsletterAtlasGeo.as_view(),
         name="newsletter_atlas_geo"),

    path('newsletter_atlas_pop', NewsletterAtlasPop.as_view(),
         name="newsletter_atlas_pop"),

    path('newsletter_atlas_comp', NewsletterAtlasComp.as_view(),
         name="newsletter_atlas_comp"),

    path('newsletter_atlas_mig', NewsletterAtlasMig.as_view(),
         name="newsletter_atlas_mig"),

    path('newsletter_atlas_metodologia', NewsletterAtlasMetodoLogia.as_view(),
         name="newsletter_atlas_metodologia"),


]

if settings.DEBUG:
    urlpatterns += static(settings.MEDIA_URL,
                          document_root=settings.MEDIA_ROOT)
