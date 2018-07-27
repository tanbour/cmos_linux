from django.db import models
from django.contrib.postgres.fields import JSONField

# Create your models here.
class User(models.Model):
    """user models"""
    name = models.CharField(max_length=20, unique=True)
    data = JSONField(default=dict, blank=True)
    def __str__(self):
        return self.name

class Host(models.Model):
    """host models"""
    name = models.CharField(max_length=50, unique=True)
    time = models.DateTimeField(auto_now=True)
    freq = models.CharField(max_length=50)
    ram = models.CharField(max_length=50)
    t_slot = models.CharField(max_length=50)
    group = models.CharField(max_length=50)
    status = models.CharField(max_length=50)
    def __str__(self):
        return self.name

class Queue(models.Model):
    """queue models"""
    name = models.CharField(max_length=50, unique=True)
    data = JSONField(default=dict, blank=True)
    host = models.ManyToManyField(Host, blank=True, related_name="queue_host")
    def __str__(self):
        return self.name

class Proj(models.Model):
    """proj models"""
    name = models.CharField(max_length=50, unique=True)
    data = JSONField(default=dict, blank=True)
    host = models.ManyToManyField(Host, blank=True, related_name="proj_host")
    def __str__(self):
        return self.name

class Cpu(models.Model):
    """cpu models"""
    value = models.CharField(max_length=50)
    time = models.DateTimeField(auto_now=True)
    host = models.ForeignKey(Host, on_delete=models.CASCADE, related_name="cpu_host")
    def __str__(self):
        return f"{str(self.time)}__{self.host}"

class Slot(models.Model):
    value = models.CharField(max_length=50)
    time = models.DateTimeField(auto_now=True)
    host = models.ForeignKey(Host, on_delete=models.CASCADE, related_name="slot_host")
    def __str__(self):
        return f"{str(self.time)}__{self.host}"

class Mem(models.Model):
    value = models.CharField(max_length=50)
    time = models.DateTimeField(auto_now=True)
    host = models.ForeignKey(Host, on_delete=models.CASCADE, related_name="mem_host")
    def __str__(self):
        return f"{str(self.time)}__{self.host}"

class Job(models.Model):
    """job models"""
    name = models.CharField(max_length=50, unique=True)
    owner = models.ForeignKey(User, on_delete=models.CASCADE, related_name="job_owner")
    queue = models.ForeignKey(Queue, on_delete=models.CASCADE, related_name="job_queue")
    status = models.CharField(max_length=20)
    data = JSONField(default=dict, blank=True)
    def __str__(self):
        return self.name
