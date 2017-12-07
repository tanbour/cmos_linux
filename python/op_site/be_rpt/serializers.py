from rest_framework import serializers
from .models import User, Title, Proj, Block, Version, Flow, Stage

class UserSerializer(serializers.ModelSerializer):
    class Meta:
        model = User
        fields = ("id", "name", "data")

class TitleSerializer(serializers.ModelSerializer):
    class Meta:
        model = Title
        fields = ("id", "proj", "block", "version", "flow", "stage")

class ProjSerializer(serializers.ModelSerializer):
    class Meta:
        model = Proj
        fields = ("id", "name", "owner", "data")

class BlockSerializer(serializers.ModelSerializer):
    proj = ProjSerializer()
    class Meta:
        model = Block
        fields = ("id", "name", "proj", "owner", "milestone", "data")

class VersionSerializer(serializers.ModelSerializer):
    class Meta:
        model = Version
        fields = ("id", "name", "block", "owner", "created_time", "data")

class FlowSerializer(serializers.ModelSerializer):
    class Meta:
        model = Flow
        fields = ("id", "name", "version", "owner", "created_time", "data")

class StageSerializer(serializers.ModelSerializer):
    class Meta:
        model = Stage
        fields = ("id", "name", "flow", "owner", "created_time", "data")
