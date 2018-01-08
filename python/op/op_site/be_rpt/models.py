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
    flow = JSONField(default=list, blank=True)
    stage = JSONField(default=list, blank=True)

class Proj(models.Model):
    """project models"""
    name = models.CharField(max_length=20, unique=True)
    owner = models.ForeignKey(User, on_delete=models.CASCADE, related_name="proj_owner", blank=True, null=True)
    data = JSONField(default=dict, blank=True)
    def __str__(self):
        return self.name

class Block(models.Model):
    """block models"""
    name = models.CharField(max_length=20)
    proj = models.ForeignKey(Proj, on_delete=models.CASCADE, related_name="block_proj")
    owner = models.ForeignKey(User, on_delete=models.CASCADE, related_name="block_owner", blank=True, null=True)
    milestone = models.ForeignKey("Stage", on_delete=models.SET_NULL, related_name="block_milestone", blank=True, null=True)
    data = JSONField(default=dict, blank=True)
    def __str__(self):
        return f"{self.name}__{self.proj}"
    class Meta:
        unique_together = ("name", "proj")

class Version(models.Model):
    """version models"""
    name = models.CharField(max_length=50)
    block = models.ForeignKey(Block, on_delete=models.CASCADE, related_name="version_block")
    owner = models.ForeignKey(User, on_delete=models.CASCADE, related_name="version_owner")
    created_time = models.DateTimeField(auto_now_add=True)
    data = JSONField(default=dict, blank=True)
    def __str__(self):
        return f"{self.name}__{self.block}"
    class Meta:
        unique_together = ("name", "block", "owner")

class Flow(models.Model):
    """flow models"""
    name = models.CharField(max_length=50)
    version = models.ForeignKey(Version, on_delete=models.CASCADE, related_name="flow_version")
    owner = models.ForeignKey(User, on_delete=models.CASCADE, related_name="flow_owner")
    created_time = models.DateTimeField(auto_now_add=True)
    data = JSONField(default=dict, blank=True)
    def __str__(self):
        return f"{self.name}__{self.version}"
    class Meta:
        unique_together = ("name", "version", "owner")

class Stage(models.Model):
    """stage models"""
    name = models.CharField(max_length=50)
    flow = models.ForeignKey(Flow, on_delete=models.CASCADE, related_name="stage_flow")
    owner = models.ForeignKey(User, on_delete=models.CASCADE, related_name="stage_owner")
    created_time = models.DateTimeField(auto_now_add=True)
    data = JSONField(default=dict, blank=True)
    def __str__(self):
        return f"{self.name}__{self.flow}"
