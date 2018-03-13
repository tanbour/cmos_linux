from django.contrib import admin
from .models import User, Title, Proj, Block, Flow, Stage

# Register your models here.
class UserAdmin(admin.ModelAdmin):
    """user admin"""
    list_display = ("id", "name")
    list_filter = ["name"]
    search_field = ["name", "data"]

class TitleAdmin(admin.ModelAdmin):
    """title admin"""
    list_display = ("id", "proj", "block", "flow", "stage")
    list_filter = ["proj", "block", "flow", "stage"]
    search_field = ["proj", "block", "flow", "stage"]

class ProjAdmin(admin.ModelAdmin):
    """project admin"""
    list_display = ("id", "name", "owner")
    list_filter = ["name"]
    search_field = ["name", "owner", "data"]

class BlockAdmin(admin.ModelAdmin):
    """block admin"""
    list_display = ("id", "name", "proj", "owner")
    list_filter = ["name"]
    search_field = ["name", "proj", "owner", "data"]

class FlowAdmin(admin.ModelAdmin):
    """flow admin"""
    list_display = ("id", "name", "block", "owner", "created_time", "status")
    list_filter = ["created_time"]
    search_field = ["name", "block", "owner", "created_time", "status", "data"]

class StageAdmin(admin.ModelAdmin):
    """stage admin"""
    list_display = ("id", "name", "flow", "owner", "created_time", "status", "version")
    list_filter = ["created_time"]
    search_field = ["name", "flow", "owner", "created_time", "status", "version", "data"]

admin.site.register(User, UserAdmin)
admin.site.register(Title, TitleAdmin)
admin.site.register(Proj, ProjAdmin)
admin.site.register(Block, BlockAdmin)
admin.site.register(Flow, FlowAdmin)
admin.site.register(Stage, StageAdmin)
