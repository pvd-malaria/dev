# coding: utf-8

from django import forms
from crispy_forms.helper import FormHelper
from crispy_forms.layout import Layout, Submit, Row, Column

from .models import Modelos,  Categorias, Criterios

from django.utils.translation import ugettext_lazy as _


choices_missing = (
    (1, _(u"Option 1")),
)

choices_yes_no = (
    (0, ""),
    (1, _(u"Sim")),
    (2, _(u"Não")),
)

choices_n_tp_apresentacao = (
    (0, ""),
    (1, _(u"Cefálico")),
    (2, _(u"Pélvica ou podálica")),
    (3, _(u"Transversa")),
)

choices_n_tp_estado_civil = {
    (0, ""),
    (1, _(u"Solteira")),
    (2, _(u"Casada")),
    (3, _(u"Viuva")),
    (4, _(u"Separada")),
    (5, _(u"União estável")),
}

choices_n_tp_funcao_responsavel = {
    (0, ""),
    (1, _(u"Médico")),
    (2, _(u"Enfermeiro")),
    (3, _(u"Parteira")),
    (4, _(u"Funcionário do Cartório")),
    (5, _(u"Outros")),
}

choices_n_tp_gestacao = (
    (0, ""),
    (1, _(u"Menos de 22 semanas")),
    (2, _(u"22 a 27 semanas")),
    (3, _(u"28 a 31 semanas")),
    (4, _(u"32 a 36 semanas")),
    (5, _(u"37 a 41 semanas")),
    (6, _(u"42 semanas ou mais")),
)

choices_n_tp_gravidez = (
    (0, ""),
    (1, _(u"Única")),
    (2, _(u"Dupla")),
    (3, _(u"Tripla ou mais")),
)

choices_n_tp_grupo_robson = (
    (0, ""),
    (1, _(u"Grupo 1")),
    (2, _(u"Grupo 2")),
    (3, _(u"Grupo 3")),
    (4, _(u"Grupo 4")),
    (5, _(u"Grupo 5")),
    (6, _(u"Grupo 6")),
    (7, _(u"Grupo 7")),
    (8, _(u"Grupo 8")),
    (9, _(u"Grupo 9")),
    (10, _(u"Grupo 10")),
)

choices_n_tp_nascimento_assistido = (
    (0, ""),
    (1, _(u"Médico")),
    (2, _(u"Enfermeira/Obstetriz")),
    (3, _(u"Parteira")),
    (4, _(u"Outros")),
)

choices_n_tp_ocorrencia = {
    (0, ""),
    (1, _(u"Hospital")),
    (2, _(u"Outros estabelecimentos de saúde")),
    (3, _(u"Domicílio")),
    (4, _(u"Outros")),
}

choices_n_tp_parto = {
    (0, ""),
    (1, _(u"Vaginal")),
    (2, _(u"Cesáreo")),
}

choices_n_tp_raca_cor_mae = (
    (0, ""),
    (1, _(u"Branca")),
    (2, _(u"Preta")),
    (3, _(u"Amarela")),
    (4, _(u"Parda")),
    (5, _(u"Indígena")),
)

choices_n_ct_idade = (
    (0, ""),
    (1, _(u"8 a 14 anos")),
    (2, _(u"15 a 19 anos")),
    (3, _(u"20 a 24 anos")),
    (4, _(u"25 a 29 anos")),
    (5, _(u"30 a 34 anos")),
    (6, _(u"35 a 39 anos")),
    (7, _(u"40 a 44 anos")),
    (8, _(u"45 a 49 anos")),
    (9, "50+"),
)

choices_n_ct_nascidos_vivos = (
    (0, ""),
    (1, _(u"0 a 3")),
    (2, _(u"4 a 7")),
    (3, _(u"8 a 10")),
    (4, "11+"),
)

choices_n_ct_nascidos_mortos = (
    (0, ""),
    (1, _(u"0 a 3")),
    (2, _(u"4 a 7")),
    (3, _(u"8 a 10")),
    (4, "11+"),
)

choices_n_ct_gestacao_anterior = (
    (0, ""),
    (1, _(u"0 a 3")),
    (2, _(u"4 a 7")),
    (3, _(u"8 a 10")),
    (4, _(u"11 a 14")),
    (5, "15+"),
)

choices_n_ct_parto_normal = (
    (0, ""),
    (1, _(u"0 a 3")),
    (2, _(u"4 a 7")),
    (3, _(u"8 a 10")),
    (4, _(u"11 a 14")),
    (5, "15+"),
)

choices_n_ct_apgar5 = (
    (0, ""),
    (1, _(u"Grave")),
    (2, _(u"Moderado")),
    (3, _(u"Leve")),
    (4, _(u"Ótimo")),
)

choices_n_ct_apgar1 = (
    (0, ""),
    (1, _(u"Grave")),
    (2, _(u"Moderado")),
    (3, _(u"Leve")),
    (4, _(u"Ótimo")),
)

choices_n_ct_peso = (
    (0, ""),
    (1, _(u"Baixo")),
    (2, _(u"Insuficiente")),
    (3, _(u"Adequado")),
    (4, _(u"Excesso")),
)


class ModelsForm(forms.ModelForm):
    class Meta:
        model = Modelos
        fields = ('title', 'name', 'description',
                  'instructions', 'predictor', 'dataset')


class CategoryForm(forms.ModelForm):
    class Meta:
        model = Categorias
        fields = ['nome']


class CriterioForm(forms.ModelForm):
    class Meta:
        model = Criterios
        fields = ['titulo', 'descricao', 'categoria1',
                  'categoria2', 'categoria3', 'thumbnail', 'arquivo_zip']


class PredictionMortalityForm(forms.Form):
    n_ct_parto_cesarea = forms.ChoiceField(
        initial=0, required=True, choices=choices_missing, label=_(u"Missing from dict"))
    n_tp_escolaridade_agregado1 = forms.ChoiceField(
        initial=0, required=True, choices=choices_missing, label=_(u"Missing from dict"))
    n_tp_escolaridade_agregado2 = forms.ChoiceField(
        initial=0, required=True, choices=choices_missing, label=_(u"Missing from dict"))
    n_tp_prenatal = forms.ChoiceField(
        initial=0, required=True, choices=choices_missing, label=_(u"Missing from dict"))
    n_tp_escolaridade_2010 = forms.ChoiceField(
        initial=0, required=True, choices=choices_missing, label=_(u"Missing from dict"))

    """ Bebê """
    n_ct_peso = forms.ChoiceField(
        initial=0, required=True, choices=choices_n_ct_peso, label=_(u"Peso"))
    n_ct_apgar1 = forms.ChoiceField(
        initial=0, required=True, choices=choices_n_ct_apgar1, label=_(u"Apgar 1"))
    n_ct_apgar5 = forms.ChoiceField(
        initial=0, required=True, choices=choices_n_ct_apgar5, label=_(u"Apgar 5"))
    n_tp_apresentacao = forms.ChoiceField(
        initial=0, required=True, choices=choices_n_tp_apresentacao, label=_(u"Tipo de apresentacao do RN"))
    n_tp_grupo_robson = forms.ChoiceField(
        initial=0, required=True, choices=choices_n_tp_grupo_robson, label=_(u"10 grupos de Robson"))
    n_st_malformacao = forms.ChoiceField(
        initial=0, required=True, choices=choices_yes_no, label=_(u"Anomalia identificada"))

    """ Mãe """
    n_ct_idade = forms.ChoiceField(
        initial=0, required=True, choices=choices_n_ct_idade, label=_(u"Idade"))
    n_tp_estado_civil = forms.ChoiceField(
        initial=0, required=True, choices=choices_n_tp_estado_civil, label=_(u"Situação conjugal"))
    n_tp_raca_cor_mae = forms.ChoiceField(
        initial=0, required=True, choices=choices_n_tp_raca_cor_mae, label=_(u"Tipo de raça e cor"))
    n_tp_gravidez = forms.ChoiceField(
        initial=0, required=True, choices=choices_n_tp_gravidez, label=_(u"Tipo de gravidez"))
    n_tp_gestacao = forms.ChoiceField(
        initial=0, required=True, choices=choices_n_tp_gestacao, label=_(u"Semanas de gestação"))

    """ Quantidade prévia de: """
    n_ct_gestacao_anterior = forms.ChoiceField(
        initial=0, required=True, choices=choices_n_ct_gestacao_anterior, label=_(u"Gestações"))
    n_ct_parto_normal = forms.ChoiceField(
        initial=0, required=True, choices=choices_n_ct_parto_normal, label=_(u"Partos normais"))
    n_ct_nascidos_vivos = forms.ChoiceField(
        initial=0, required=True, choices=choices_n_ct_nascidos_vivos, label=_(u"Nascidos vivos"))
    n_ct_nascidos_mortos = forms.ChoiceField(
        initial=0, required=True, choices=choices_n_ct_nascidos_mortos, label=_(u"Nascidos mortos"))

    """ Outros """
    n_tp_ocorrencia = forms.ChoiceField(
        initial=0, required=True, choices=choices_n_tp_ocorrencia, label=_(u"Local de nascimento"))
    n_tp_nascimento_assistido = forms.ChoiceField(
        initial=0, required=True, choices=choices_n_tp_nascimento_assistido, label=_(u"Função do assistente no parto"))
    n_tp_parto = forms.ChoiceField(
        initial=0, required=True, choices=choices_n_tp_parto, label=_(u"Tipo de parto"))
    n_tp_funcao_responsavel = forms.ChoiceField(
        initial=0, required=True, choices=choices_n_tp_funcao_responsavel, label=_(u"Função do responsável pelo preenchimento"))

    def __get_label(self, field):
        return text_type(self._meta.get_field(field).label)

    def clean(self):
        cleaned_data = self.cleaned_data

        for field_name in cleaned_data:
            field_value = cleaned_data.get(field_name)
            if field_value == "0":
                self.add_error(str(field_name), _(u'Campo obrigatório!'))
                break

        return cleaned_data
