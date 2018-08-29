from django.db import models
from django.contrib.postgres.fields import JSONField

# Create your models here.
class User(models.Model):
    """user models"""
    name = models.CharField(max_length=20, unique=True)
    proj_admin = models.ManyToManyField("Proj", related_name="user_proj", blank=True)
    data = JSONField(default=dict, blank=True)
    def __str__(self):
        return self.name

class Title(models.Model):
    """title models for table"""
    proj = JSONField(default=list, blank=True)
    block = JSONField(default=list, blank=True)
    flow = JSONField(default=list, blank=True)
    stage = JSONField(default=list, blank=True)

class Proj(models.Model):
    """project models"""
    name = models.CharField(max_length=50, unique=True)
    owner = models.ForeignKey(User, on_delete=models.CASCADE, related_name="proj_owner", blank=True, null=True)
    data = JSONField(default=dict, blank=True)
    def __str__(self):
        return self.name

class Block(models.Model):
    """block models"""
    name = models.CharField(max_length=50)
    proj = models.ForeignKey(Proj, on_delete=models.CASCADE, related_name="block_proj")
    owner = models.ForeignKey(User, on_delete=models.CASCADE, related_name="block_owner", blank=True, null=True)
    milestone = models.ForeignKey("Stage", on_delete=models.SET_NULL, related_name="block_milestone", blank=True, null=True)
    data = JSONField(default=dict, blank=True)
    def __str__(self):
        return f"{self.name}__{self.proj}"
    class Meta:
        unique_together = ("name", "proj")

class Flow(models.Model):
    """flow models"""
    name = models.CharField(max_length=100)
    block = models.ForeignKey(Block, on_delete=models.CASCADE, related_name="flow_block")
    owner = models.ForeignKey(User, on_delete=models.CASCADE, related_name="flow_owner")
    created_time = models.DateTimeField()
    status = models.CharField(max_length=20)
    comment = models.CharField(max_length=200, blank=True)
    data = JSONField(default=dict, blank=True)
    def __str__(self):
        return f"{self.name}__{self.block}"
    class Meta:
        unique_together = ("name", "block", "owner", "created_time")
        ordering = ["-created_time"]

class Stage(models.Model):
    """stage models"""
    name = models.CharField(max_length=200)
    flow = models.ManyToManyField(Flow, related_name="stage_flow")
    owner = models.ForeignKey(User, on_delete=models.CASCADE, related_name="stage_owner")
    created_time = models.DateTimeField()
    status = models.CharField(max_length=20)
    version = models.CharField(max_length=200)
    data = JSONField(default=dict, blank=True)
    def __str__(self):
        return f"{self.name}"
    class Meta:
        ordering = ["-created_time"]

class Signoff(models.Model):
    """signoff static info models"""
    name = models.CharField(max_length=200)
    block = models.ForeignKey(Block, on_delete=models.CASCADE, related_name="signoff_block")
    l_flow = models.ForeignKey(Flow, on_delete=models.CASCADE, related_name="signoff_l_flow", blank=True, null=True)
    l_stage = models.ForeignKey(Stage, on_delete=models.CASCADE, related_name="signoff_l_stage", blank=True, null=True)
    l_user = models.ForeignKey(User, on_delete=models.CASCADE, related_name="signoff_l_user")
    updated_time = models.DateTimeField(auto_now=True)
    data = JSONField(default=dict, blank=True)
    def __str__(self):
        return f"{self.name}__{self.block}"
    class Meta:
        unique_together = ("name", "block")
