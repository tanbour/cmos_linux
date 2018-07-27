from django.contrib import admin
from .models import Proj

# Register your models here.
class ProjAdmin(admin.ModelAdmin):
    """proj admin"""
    list_display = ("id", "name", "updated_time", "lock")
    list_filter = ["updated_time"]
    search_fields = ["name", "data", "text"]

admin.site.register(Proj, ProjAdmin)
