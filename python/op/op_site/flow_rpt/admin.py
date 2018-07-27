from django.contrib import admin
from .models import User, Title, Proj, Block, Flow, Stage, Signoff

# Register your models here.
class UserAdmin(admin.ModelAdmin):
    """user admin"""
    list_display = ("id", "name")
    filter_horizontal = ("proj_admin",)
    list_filter = ["name"]
    search_fields = ["name", "data"]

class TitleAdmin(admin.ModelAdmin):
    """title admin"""
    list_display = ("id", "proj", "block", "flow", "stage")
    list_filter = ["proj", "block", "flow", "stage"]
    search_fields = ["proj", "block", "flow", "stage"]

class ProjAdmin(admin.ModelAdmin):
    """project admin"""
    list_display = ("id", "name", "owner")
    list_filter = ["name"]
    search_fields = ["name", "data"]

class BlockAdmin(admin.ModelAdmin):
    """block admin"""
    list_display = ("id", "name", "proj", "owner")
    list_filter = ["name"]
    search_fields = ["name", "data"]

class FlowAdmin(admin.ModelAdmin):
    """flow admin"""
    list_display = ("id", "name", "block", "owner", "created_time", "status", "comment")
    list_filter = ["created_time"]
    search_fields = ["name", "created_time", "status", "comment", "data"]

class StageAdmin(admin.ModelAdmin):
    """stage admin"""
    list_display = ("id", "name", "owner", "created_time", "status", "version")
    filter_horizontal = ("flow",)
    list_filter = ["created_time"]
    search_fields = ["name", "created_time", "status", "version", "data"]

class SignoffAdmin(admin.ModelAdmin):
    """signoff admin"""
    list_display = ("id", "name", "block", "l_flow", "l_stage", "l_user", "updated_time")
    list_filter = ["updated_time"]
    search_fields = ["name", "updated_time", "data"]

admin.site.register(User, UserAdmin)
admin.site.register(Title, TitleAdmin)
admin.site.register(Proj, ProjAdmin)
admin.site.register(Block, BlockAdmin)
admin.site.register(Flow, FlowAdmin)
admin.site.register(Stage, StageAdmin)
admin.site.register(Signoff, SignoffAdmin)
