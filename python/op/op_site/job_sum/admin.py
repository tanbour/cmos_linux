from django.contrib import admin
from .models import User, Queue, Job, Host, Proj, Cpu, Slot, Mem

# Register your models here.
class UserAdmin(admin.ModelAdmin):
    """user admin"""
    list_display = ("id", "name")
    list_filter = ["name"]
    search_fields = ["name", "data"]

class QueueAdmin(admin.ModelAdmin):
    """queue admin"""
    list_display = ("id", "name")
    filter_horizontal = ("host",)
    list_filter = ["name"]
    search_fields = ["name", "data"]

class JobAdmin(admin.ModelAdmin):
    """job admin"""
    list_display = ("id", "name", "owner", "queue", "status")
    list_filter = ["name"]
    search_fields = ["name", "status", "data"]

class ProjAdmin(admin.ModelAdmin):
    """proj admin"""
    list_display = ("id", "name")
    filter_horizontal = ("host",)
    list_filter = ["name"]
    search_fields = ["name", "data"]

class CpuAdmin(admin.ModelAdmin):
    """cpu admin"""
    list_display = ("id", "value", "time", "host")
    list_filter = ["time"]
    search_fields = ["value"]

class SlotAdmin(admin.ModelAdmin):
    """slot admin"""
    list_display = ("id", "value", "time", "host")
    list_filter = ["time"]
    search_fields = ["value"]

class MemAdmin(admin.ModelAdmin):
    """mem admin"""
    list_display = ("id", "value", "time", "host")
    list_filter = ["time"]
    search_fields = ["value"]

class HostAdmin(admin.ModelAdmin):
    """host admin"""
    list_display = ("id", "name", "freq", "ram", "t_slot", "group", "status")
    list_filter = ["name"]
    search_fields = ["name", "freq", "ram", "t_slot", "group", "status"]

admin.site.register(User, UserAdmin)
admin.site.register(Queue, QueueAdmin)
admin.site.register(Job, JobAdmin)
admin.site.register(Proj, ProjAdmin)
admin.site.register(Cpu, CpuAdmin)
admin.site.register(Slot, SlotAdmin)
admin.site.register(Mem, MemAdmin)
admin.site.register(Host, HostAdmin)
