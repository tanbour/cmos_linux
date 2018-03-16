from rest_framework import serializers
from .models import User, Title, Proj, Block, Flow, Stage

class UserSerializer(serializers.ModelSerializer):
    class Meta:
        model = User
        fields = ("id", "name", "data")

class TitleSerializer(serializers.ModelSerializer):
    class Meta:
        model = Title
        fields = ("id", "proj", "block", "flow", "stage")

class ProjSerializer(serializers.ModelSerializer):
    class Meta:
        model = Proj
        fields = ("id", "name", "owner", "data")
        depth = 1

class BlockSerializer(serializers.ModelSerializer):
    class Meta:
        model = Block
        fields = ("id", "name", "proj", "owner", "milestone", "data")
        depth = 1

class FlowSerializer(serializers.ModelSerializer):
    class Meta:
        model = Flow
        fields = ("id", "name", "block", "owner", "created_time", "status", "data")
        depth = 1

class StageSerializer(serializers.ModelSerializer):
    flow = FlowSerializer(many=True, read_only=True)
    class Meta:
        model = Stage
        fields = ("id", "name", "flow", "owner", "created_time", "status", "version", "data")
        depth = 1

class UserRelatedSerializer(serializers.ModelSerializer):
    proj_owner = ProjSerializer(many=True, read_only=True)
    block_owner = BlockSerializer(many=True, read_only=True)
    flow_owner = FlowSerializer(many=True, read_only=True)
    stage_owner = StageSerializer(many=True, read_only=True)
    class Meta:
        model = User
        fields = ("id", "name", "proj_owner", "block_owner", "flow_owner", "stage_owner")

class ProjRelatedSerializer(serializers.ModelSerializer):
    block_proj = BlockSerializer(many=True, read_only=True)
    class Meta:
        model = Proj
        fields = ("id", "name", "block_proj")

class BlockRelatedSerializer(serializers.ModelSerializer):
    flow_block = FlowSerializer(many=True, read_only=True)
    class Meta:
        model = Block
        fields = ("id", "name", "flow_block")

class FlowRelatedSerializer(serializers.ModelSerializer):
    stage_flow = StageSerializer(many=True, read_only=True)
    class Meta:
        model = Flow
        fields = ("id", "name", "stage_flow")

class StageDetailSerializer(serializers.ModelSerializer):
    class Meta:
        model = Stage
        fields = ("id", "name", "data")

class FlowStatusSerializer(serializers.ModelSerializer):
    class Meta:
        model = Flow
        fields = ("id", "name", "block", "owner", "created_time", "status", "data")
        depth = 2

class FlowStatusRelatedSerializer(serializers.ModelSerializer):
    stage_flow = StageSerializer(many=True, read_only=True)
    class Meta:
        model = Flow
        fields = ("id", "name", "block", "stage_flow")
        depth = 2
