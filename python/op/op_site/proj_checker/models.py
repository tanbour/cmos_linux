from django.db import models
from django.contrib.postgres.fields import JSONField

# Create your models here.
class Proj(models.Model):
    """project models"""
    name = models.CharField(max_length=20, unique=True)
    updated_time = models.DateTimeField(auto_now=True)
    lock = models.BooleanField(default=False)
    data = JSONField(default=dict, blank=True)
    text = models.TextField(blank=True)
    def __str__(self):
        return self.name
