from rest_framework import serializers
from .models import Proj

class ProjSerializer(serializers.ModelSerializer):
    class Meta:
        model = Proj
        fields = ("id", "name", "updated_time", "data", "text")
