from rest_framework import serializers
from .models import User, Title, Proj, Block, Flow, Stage, Signoff
from django.db.models import Q

class UserListSerializer(serializers.ModelSerializer):
    class Meta:
        model = User
        fields = ("id", "name", "proj_admin", "data")

class TitleSerializer(serializers.ModelSerializer):
    class Meta:
        model = Title
        fields = ("id", "proj", "block", "flow", "stage")

class ProjSerializer(serializers.ModelSerializer):
    class Meta:
        model = Proj
        fields = ("id", "name", "owner", "data")
        depth = 1

class BlockListSerializer(serializers.ModelSerializer):
    class Meta:
        model = Block
        fields = ("id", "name", "owner", "milestone", "data")
        depth = 1

class BlockDetailSerializer(serializers.ModelSerializer):
    class Meta:
        model = Block
        fields = ("id", "name", "proj", "owner", "milestone", "data")
        depth = 2

class FlowListSerializer(serializers.ModelSerializer):
    class Meta:
        model = Flow
        fields = ("id", "name", "owner", "created_time", "status", "comment", "data")
        depth = 1

class FlowDetailSerializer(serializers.ModelSerializer):
    class Meta:
        model = Flow
        fields = ("id", "name", "block", "owner", "created_time", "status", "comment", "data")
        depth = 3

class StageListSerializer(serializers.ModelSerializer):
    class Meta:
        model = Stage
        fields = ("id", "name", "owner", "created_time", "status", "version", "data")
        depth = 1

class StageDetailSerializer(serializers.ModelSerializer):
    class Meta:
        model = Stage
        fields = ("id", "name", "flow", "data")
        depth = 4

class UserDetailSerializer(serializers.ModelSerializer):
    proj_owner = ProjSerializer(many=True, read_only=True)
    block_owner = BlockListSerializer(many=True, read_only=True)
    flow_owner = FlowListSerializer(many=True, read_only=True)
    stage_owner = StageListSerializer(many=True, read_only=True)
    class Meta:
        model = User
        fields = ("id", "name", "proj_owner", "block_owner", "flow_owner", "stage_owner")

class FlowCmpListSerializer(serializers.ModelSerializer):
    stage_flow = StageListSerializer(many=True, read_only=True)
    class Meta:
        model = Flow
        fields = ("id", "name", "block", "owner", "created_time", "status", "comment", "data", "stage_flow")
        depth = 1

class FlowStatusListSerializer(serializers.ModelSerializer):
    cur_stage = serializers.SerializerMethodField()
    class Meta:
        model = Flow
        fields = (
            "id", "name", "block", "owner", "created_time",
            "status", "comment", "data", "cur_stage")
        depth = 2
    def get_cur_stage(self, obj):
        cur_stage = obj.stage_flow.order_by("-created_time").first()
        return cur_stage.name if cur_stage else None

class FlowStatusDetailSerializer(serializers.ModelSerializer):
    stage_flow = StageListSerializer(many=True, read_only=True)
    class Meta:
        model = Flow
        fields = ("id", "name", "block", "stage_flow")
        depth = 2

class SignoffSerializer(serializers.ModelSerializer):
    block = BlockDetailSerializer()
    l_user_name = serializers.SerializerMethodField()
    class Meta:
        model = Signoff
        fields = ("id", "name", "block", "l_flow", "l_stage", "l_user", "updated_time", "data", "l_user_name")
    def get_l_user_name(self, obj):
        return obj.l_user.name
