from django.contrib import admin
from .models import User, Title, Proj, Block, Version, Flow, Stage

# Register your models here.
class UserAdmin(admin.ModelAdmin):
    """user admin"""
    list_display = ("name",)
    list_filter = ["name"]
    search_field = ["name", "data"]

class TitleAdmin(admin.ModelAdmin):
    """title admin"""
    list_display = ("proj", "block", "version", "flow", "stage")
    list_filter = ["proj", "block", "version", "flow", "stage"]
    search_field = ["proj", "block", "version", "flow", "stage"]

class ProjAdmin(admin.ModelAdmin):
    """project admin"""
    list_display = ("name", "owner")
    list_filter = ["name"]
    search_field = ["name", "data"]

class BlockAdmin(admin.ModelAdmin):
    """block admin"""
    list_display = ("name", "proj", "owner")
    list_filter = ["name"]
    search_field = ["name", "data"]

class VersionAdmin(admin.ModelAdmin):
    """version admin"""
    list_display = ("name", "block", "owner", "created_time")
    list_filter = ["created_time"]
    search_field = ["name", "data"]

class FlowAdmin(admin.ModelAdmin):
    """flow admin"""
    list_display = ("name", "version", "owner", "created_time")
    list_filter = ["created_time"]
    search_field = ["name", "data"]

class StageAdmin(admin.ModelAdmin):
    """stage admin"""
    list_display = ("name", "flow", "owner", "created_time")
    list_filter = ["created_time"]
    search_field = ["name", "data"]

admin.site.register(User, UserAdmin)
admin.site.register(Title, TitleAdmin)
admin.site.register(Proj, ProjAdmin)
admin.site.register(Block, BlockAdmin)
admin.site.register(Version, VersionAdmin)
admin.site.register(Flow, FlowAdmin)
admin.site.register(Stage, StageAdmin)
