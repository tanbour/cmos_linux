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
    owner = UserSerializer()
    class Meta:
        model = Proj
        fields = ("id", "name", "owner", "data", "block_proj")

class BlockSerializer(serializers.ModelSerializer):
    proj = ProjSerializer()
    owner = UserSerializer()
    milestone_id = serializers.ReadOnlyField(source="milestone.id")
    milestone_name = serializers.ReadOnlyField(source="milestone.name")
    class Meta:
        model = Block
        fields = ("id", "name", "proj", "owner", "milestone_id", "milestone_name", "data")

class VersionSerializer(serializers.ModelSerializer):
    block = BlockSerializer()
    owner = UserSerializer()
    class Meta:
        model = Version
        fields = ("id", "name", "block", "owner", "created_time", "data")

class FlowSerializer(serializers.ModelSerializer):
    version = VersionSerializer()
    owner = UserSerializer()
    class Meta:
        model = Flow
        fields = ("id", "name", "version", "owner", "created_time", "data")

class StageSerializer(serializers.ModelSerializer):
    flow = FlowSerializer()
    owner = UserSerializer()
    class Meta:
        model = Stage
        fields = ("id", "name", "flow", "owner", "created_time", "data")
