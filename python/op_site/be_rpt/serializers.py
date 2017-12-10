from rest_framework import serializers
from .models import User, Title, Proj, Block, Version, Flow, Stage

class TitleSerializer(serializers.ModelSerializer):
    class Meta:
        model = Title
        fields = ("id", "proj", "block", "version", "flow", "stage")

class StageSerializer(serializers.ModelSerializer):
    class Meta:
        model = Stage
        fields = ("id", "name", "flow", "owner", "created_time")
        depth = 1

class StageDetailSerializer(serializers.ModelSerializer):
    class Meta:
        model = Stage
        fields = ("id", "name", "flow", "data")
        depth = 5

class FlowSerializer(serializers.ModelSerializer):
    class Meta:
        model = Flow
        fields = ("id", "name", "version", "owner", "created_time", "data")
        depth = 1

class FlowRelatedSerializer(serializers.ModelSerializer):
    stage_flow = StageSerializer(many=True, read_only=True)
    class Meta:
        model = Flow
        fields = ("id", "name", "version", "stage_flow")
        depth = 4

class VersionSerializer(serializers.ModelSerializer):
    class Meta:
        model = Version
        fields = ("id", "name", "block", "owner", "created_time", "data")
        depth = 1

class VersionRelatedSerializer(serializers.ModelSerializer):
    flow_version = FlowSerializer(many=True, read_only=True)
    class Meta:
        model = Version
        fields = ("id", "name", "block", "flow_version")
        depth = 3

class BlockSerializer(serializers.ModelSerializer):
    class Meta:
        model = Block
        fields = ("id", "name", "proj", "owner", "milestone", "data")
        depth = 1

class BlockRelatedSerializer(serializers.ModelSerializer):
    version_block = VersionSerializer(many=True, read_only=True)
    class Meta:
        model = Block
        fields = ("id", "name", "proj", "version_block")
        depth = 2

class ProjSerializer(serializers.ModelSerializer):
    class Meta:
        model = Proj
        fields = ("id", "name", "owner", "data")
        depth = 1

class ProjRelatedSerializer(serializers.ModelSerializer):
    block_proj = BlockSerializer(many=True, read_only=True)
    class Meta:
        model = Proj
        fields = ("id", "name", "block_proj")
        depth = 1

class UserSerializer(serializers.ModelSerializer):
    class Meta:
        model = User
        fields = ("id", "name", "data")

class UserRelatedSerializer(serializers.ModelSerializer):
    proj_owner = ProjSerializer(many=True, read_only=True)
    block_owner = BlockSerializer(many=True, read_only=True)
    version_owner = VersionSerializer(many=True, read_only=True)
    flow_owner = FlowSerializer(many=True, read_only=True)
    stage_owner = StageSerializer(many=True, read_only=True)
    class Meta:
        model = User
        fields = ("id", "name", "proj_owner", "block_owner", "version_owner", "flow_owner", "stage_owner")
        depth = 1
