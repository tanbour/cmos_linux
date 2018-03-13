from rest_framework import serializers
from .models import User, Title, Proj, Block, Flow, Stage

class TitleSerializer(serializers.ModelSerializer):
    class Meta:
        model = Title
        fields = ("id", "proj", "block", "flow", "stage")

class StageFullSerializer(serializers.ModelSerializer):
    class Meta:
        model = Stage
        fields = ("id", "name", "flow", "owner", "created_time", "status", "version")
        depth = 4

class StageSerializer(serializers.ModelSerializer):
    class Meta:
        model = Stage
        fields = ("id", "name", "flow", "owner", "created_time", "status", "version", "data")
        depth = 1

class StageDetailSerializer(serializers.ModelSerializer):
    class Meta:
        model = Stage
        fields = ("id", "name", "flow", "data")
        depth = 4

class FlowSerializer(serializers.ModelSerializer):
    class Meta:
        model = Flow
        fields = ("id", "name", "block", "owner", "created_time", "status", "data")
        depth = 1

class FlowRelatedSerializer(serializers.ModelSerializer):
    stage_flow = StageSerializer(many=True, read_only=True)
    class Meta:
        model = Flow
        fields = ("id", "name", "block", "stage_flow")
        depth = 3

class BlockSerializer(serializers.ModelSerializer):
    class Meta:
        model = Block
        fields = ("id", "name", "proj", "owner", "milestone", "data")
        depth = 1

class BlockRelatedSerializer(serializers.ModelSerializer):
    flow_block = FlowSerializer(many=True, read_only=True)
    class Meta:
        model = Block
        fields = ("id", "name", "proj", "flow_block")
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
    flow_owner = FlowSerializer(many=True, read_only=True)
    stage_owner = StageSerializer(many=True, read_only=True)
    class Meta:
        model = User
        fields = ("id", "name", "proj_owner", "block_owner", "flow_owner", "stage_owner")
        depth = 1
