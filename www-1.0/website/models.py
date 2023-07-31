# coding: utf-8
from django.db import models
import zipfile
from django.conf import settings
import shutil
from django.utils.translation import ugettext_lazy as _

class Modelos(models.Model):
    title = models.CharField(max_length=50, verbose_name=('Title'))
    name = models.CharField(max_length=30,  verbose_name=('Name'))
    description = models.TextField(verbose_name=('Description'))
    instructions = models.TextField(verbose_name=('Instructions'))
    predictor = models.FileField(upload_to='predictor',  verbose_name=('Predictor'))
    dataset = models.FileField(upload_to='dataset',  verbose_name=('Dataset'))

    def __str__(self):
        return self.title

class Categorias(models.Model):
    nome = models.CharField(max_length=200, verbose_name=('Name'))
    dt_criacao = models.DateTimeField(auto_now_add=True, verbose_name=('Creation Date'))

    def __str__(self):
        return self.nome


class Criterios(models.Model):
    upload_to_aux = '%d/%m/%Y/%H/%M/%S'

    titulo = models.CharField(max_length=200, verbose_name=('Title'))
    descricao = models.TextField(null=True, blank=True,verbose_name=('Description'))
    categoria1 = models.ForeignKey(Categorias, related_name='categoria1_set', null=True, blank=True, on_delete=models.CASCADE, verbose_name=('Category 1'))
    categoria2 = models.ForeignKey(Categorias, related_name='categoria2_set', null=True, blank=True, on_delete=models.CASCADE, verbose_name=('Category 2'))
    categoria3 = models.ForeignKey(Categorias, related_name='categoria3_set', null=True, blank=True, on_delete=models.CASCADE, verbose_name=('Category 3'))
    thumbnail = models.ImageField(upload_to='documents/'+upload_to_aux+'/thumbnails/', default='documents/'+upload_to_aux+'/thumbnails/imagedefault.jpg')
    arquivo_zip = models.FileField(upload_to='documents/'+upload_to_aux+'/', verbose_name=('ZIP File'), default='documents/'+upload_to_aux+'/mapa.zip')
    data_upload = models.DateTimeField(auto_now_add=True,  verbose_name='Upload Date')

    def save(self, *args, **kwargs):
        if zipfile.is_zipfile(self.arquivo_zip):
            super().save(*args, **kwargs)
            zpObj = zipfile.ZipFile(self.arquivo_zip, 'r')
            objCriterios = Criterios.objects.get(pk=self.id)
            zpObj.extractall(settings.MEDIA_ROOT+'/documents'+objCriterios.arquivo_zip.url[15:36])
            zpObj.close()

    def delete(self,*args, **kwargs):
        objCriterios = Criterios.objects.get(pk=self.id)
        folder_name = settings.MEDIA_ROOT+'/documents'+objCriterios.arquivo_zip.url[15:36]
        super().delete(*args, **kwargs)
        shutil.rmtree(folder_name, ignore_errors=True)


