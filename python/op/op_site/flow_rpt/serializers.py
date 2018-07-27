from rest_framework import serializers
from .models import User, Title, Proj, Block, Flow, Stage, Signoff
from django.db.models import Q

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

class StageDetailSerializer(serializers.ModelSerializer):
    class Meta:
        model = Stage
        fields = ("id", "name", "data")

class FlowSerializer(serializers.ModelSerializer):
    class Meta:
        model = Flow
        fields = ("id", "name", "block", "owner", "created_time", "status", "comment", "data")
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
    # mmm = BlockSerializer(many=True, read_only=True)
    class Meta:
        model = User
        fields = ("id", "name", "proj_owner", "block_owner", "flow_owner", "stage_owner")

# class ProjRelatedSerializer(serializers.ModelSerializer):
#     block_proj = BlockSerializer(many=True, read_only=True)
#     class Meta:
#         model = Proj
#         fields = ("id", "name", "block_proj")

class ProjRelatedSerializer(serializers.ModelSerializer):
    block_proj = serializers.SerializerMethodField()
    class Meta:
        model = Proj
        fields = ("id", "name", "block_proj")
    def get_block_proj(self, proj_obj):
        queryset = Block.objects.filter(proj=proj_obj)
        user = self.context["request"].GET.get("user")
        if user:
            user_obj = User.objects.filter(name=user).first()
            if proj_obj not in user_obj.proj_admin.all():
                q_filter = Q()
                block_set = set()
                for query_obj in Flow.objects.filter(block__proj=proj_obj, owner__name=user):
                    block_name = query_obj.block.name
                    if block_name in block_set:
                        continue
                    block_set.add(query_obj.block.name)
                    q_filter = q_filter|Q(name=block_name)
                queryset = queryset.filter(q_filter) if q_filter else queryset.none()
        serializer = BlockSerializer(instance=queryset, many=True, read_only=True)
        return serializer.data

class BlockRelatedSerializer(serializers.ModelSerializer):
    flow_block = serializers.SerializerMethodField()
    class Meta:
        model = Block
        fields = ("id", "name", "flow_block")
    def get_flow_block(self, block_obj):
        queryset = Flow.objects.filter(block=block_obj)
        user = self.context["request"].GET.get("user")
        user_obj = User.objects.filter(name=user).first()
        if block_obj.proj not in user_obj.proj_admin.all():
            queryset = queryset.filter(owner__name=user)
        serializer = FlowSerializer(instance=queryset, many=True, read_only=True)
        return serializer.data

class FlowRelatedSerializer(serializers.ModelSerializer):
    stage_flow = StageSerializer(many=True, read_only=True)
    class Meta:
        model = Flow
        fields = ("id", "name", "stage_flow")

class FlowStatusSerializer(serializers.ModelSerializer):
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

class FlowStatusRelatedSerializer(serializers.ModelSerializer):
    stage_flow = StageSerializer(many=True, read_only=True)
    class Meta:
        model = Flow
        fields = ("id", "name", "block", "stage_flow")
        depth = 2

class SignoffStageSerializer(serializers.ModelSerializer):
    class Meta:
        model = Stage
        fields = ("id", "name", "created_time", "status", "version")

class SignoffSerializer(serializers.ModelSerializer):
    block = BlockSerializer()
    l_stage = SignoffStageSerializer()
    class Meta:
        model = Signoff
        fields = ("id", "name", "block", "l_flow", "l_stage", "l_user", "updated_time", "data")
        depth = 1
