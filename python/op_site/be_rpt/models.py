from django.db import models
from django.contrib.postgres.fields import JSONField

# Create your models here.
class User(models.Model):
    """user models"""
    name = models.CharField(max_length=20, unique=True)
    data = JSONField(default=dict, blank=True)
    def __str__(self):
        return self.name

class Title(models.Model):
    """title models for table"""
    proj = JSONField(default=list, blank=True)
    block = JSONField(default=list, blank=True)
    version = JSONField(default=list, blank=True)

class Proj(models.Model):
    """project models"""
    name = models.CharField(max_length=20, unique=True)
    owner = models.ForeignKey(User, on_delete=models.CASCADE, blank=True, null=True)
    data = JSONField(default=dict, blank=True)
    def __str__(self):
        return self.name

class Block(models.Model):
    """block models"""
    name = models.CharField(max_length=20)
    proj = models.ForeignKey(Proj, on_delete=models.CASCADE)
    owner = models.ForeignKey(User, on_delete=models.CASCADE, blank=True, null=True)
    data = JSONField(default=dict, blank=True)
    def __str__(self):
        return f"{self.name}__{self.proj}"
    class Meta:
        unique_together = ("name", "proj")

class Version(models.Model):
    """version models"""
    name = models.CharField(max_length=50)
    block = models.ForeignKey(Block, on_delete=models.CASCADE)
    owner = models.ForeignKey(User, on_delete=models.CASCADE, blank=True, null=True)
    data = JSONField(default=dict, blank=True)
    def __str__(self):
        return f"{self.name}__{self.block}"
    class Meta:
        unique_together = ("name", "block")
