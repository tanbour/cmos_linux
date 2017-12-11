from rest_framework import views
from rest_framework.response import Response
from rest_framework import status
from rest_framework import generics
from rest_framework import permissions
from .models import User, Title, Proj, Block, Version, Flow, Stage
from .serializers import UserSerializer, TitleSerializer, ProjSerializer, BlockSerializer, VersionSerializer, FlowSerializer, StageSerializer
from .serializers import UserRelatedSerializer, ProjRelatedSerializer, BlockRelatedSerializer, VersionRelatedSerializer, FlowRelatedSerializer, StageDetailSerializer
from django.utils import timezone as tz

class TitleList(generics.ListAPIView):
    """be report title list"""
    queryset = Title.objects.all()
    serializer_class = TitleSerializer

class TitleDetail(generics.RetrieveAPIView):
    """be report title detail"""
    queryset = Title.objects.all()
    serializer_class = TitleSerializer

class ProjList(generics.ListAPIView):
    """be report project list"""
    queryset = Proj.objects.all()
    serializer_class = ProjSerializer
    def get_queryset(self, *args, **kwargs):
        name = self.request.data.get("name")
        return self.queryset.filter(name=name) if name else self.queryset.all()

class ProjDetail(generics.RetrieveAPIView):
    """be report project detail"""
    queryset = Proj.objects.all()
    serializer_class = ProjRelatedSerializer

class BlockList(generics.ListAPIView):
    """be report block list"""
    queryset = Block.objects.all()
    serializer_class = BlockSerializer
    def get_queryset(self, *args, **kwargs):
        name = self.request.data.get("name")
        proj = self.request.data.get("proj")
        queryset = self.queryset.filter(name=name) if name else self.queryset.all()
        queryset = queryset.filter(proj__name=proj) if proj else queryset
        return queryset

class BlockDetail(generics.RetrieveAPIView):
    """be report block detail"""
    queryset = Block.objects.all()
    serializer_class = BlockRelatedSerializer

class VersionList(generics.ListAPIView):
    """be report version list"""
    queryset = Version.objects.all()
    serializer_class = VersionSerializer
    def get_queryset(self, *args, **kwargs):
        name = self.request.data.get("name")
        block = self.request.data.get("block")
        proj = self.request.data.get("proj")
        owner = self.request.data.get("owner")
        queryset = self.queryset.filter(name=name) if name else self.queryset.all()
        queryset = queryset.filter(block__name=block) if block else queryset
        queryset = queryset.filter(block__proj__name=proj) if proj else queryset
        queryset = queryset.filter(owner__name=owner) if owner else queryset
        return queryset

class VersionDetail(generics.RetrieveAPIView):
    """be report version detail"""
    queryset = Version.objects.all()
    serializer_class = VersionRelatedSerializer

class FlowList(generics.ListAPIView):
    """be report flow list"""
    queryset = Flow.objects.all()
    serializer_class = FlowSerializer
    def get_queryset(self, *args, **kwargs):
        name = self.request.data.get("name")
        version = self.request.data.get("version")
        block = self.request.data.get("block")
        proj = self.request.data.get("proj")
        owner = self.request.data.get("owner")
        queryset = self.queryset.filter(name=name) if name else self.queryset.all()
        queryset = queryset.filter(version__name=version) if version else queryset
        queryset = queryset.filter(version__block__name=block) if block else queryset
        queryset = queryset.filter(version__block__proj__name=proj) if proj else queryset
        queryset = queryset.filter(owner__name=owner) if owner else queryset
        return queryset

class FlowDetail(generics.RetrieveAPIView):
    """be report flow detail"""
    queryset = Flow.objects.all()
    serializer_class = FlowRelatedSerializer

class StageList(generics.ListAPIView):
    """be report stage list"""
    queryset = Stage.objects.all()
    serializer_class = StageSerializer
    def get_queryset(self, *args, **kwargs):
        name = self.request.data.get("name")
        flow = self.request.data.get("flow")
        version = self.request.data.get("version")
        block = self.request.data.get("block")
        proj = self.request.data.get("proj")
        owner = self.request.data.get("owner")
        queryset = self.queryset.filter(name=name) if name else self.queryset.all()
        queryset = queryset.filter(flow__name=flow) if flow else queryset
        queryset = queryset.filter(flow__version__name=version) if version else queryset
        queryset = queryset.filter(flow__version__block__name=block) if block else queryset
        queryset = queryset.filter(flow__version__block__proj__name=proj) if proj else queryset
        queryset = queryset.filter(owner__name=owner) if owner else queryset
        return queryset

class StageDetail(generics.RetrieveAPIView):
    """be report stage detail"""
    queryset = Stage.objects.all()
    serializer_class = StageDetailSerializer

class UserList(generics.ListCreateAPIView):
    """be report user list"""
    queryset = User.objects.all()
    serializer_class = UserSerializer
    def get_queryset(self, *args, **kwargs):
        name = self.request.data.get("name")
        return self.queryset.filter(name=name) if name else self.queryset.all()

class UserDetail(generics.RetrieveAPIView):
    """be report user detail"""
    queryset = User.objects.all()
    serializer_class = UserRelatedSerializer

class OpProj(views.APIView):
    """op platform post proj info"""
    def post(self, request, format=None):
        proj_name = request.data.get("name")
        if not proj_name:
            return Response({"message": "proj name is NA"}, status=status.HTTP_400_BAD_REQUEST)
        proj_obj, created_flg = Proj.objects.update_or_create(
            {"name": proj_name, "data": request.data.get("data", {})}, name=proj_name)
        return Response({"proj_name": proj_obj.name, "created_flg": created_flg})

class OpBlock(views.APIView):
    """op platform post block info"""
    def post(self, request, format=None):
        block_name = request.data.get("name")
        proj_name = request.data.get("proj")
        if not block_name:
            return Response({"message": "block name is NA"}, status=status.HTTP_400_BAD_REQUEST)
        if not proj_name:
            return Response({"message": "proj name is NA"}, status=status.HTTP_400_BAD_REQUEST)
        proj_obj, _ = Proj.objects.get_or_create({"name": proj_name}, name=proj_name)
        block_obj, created_flg = Block.objects.update_or_create(
            {"name": block_name, "proj": proj_obj, "data": request.data.get("data", {})},
            name=block_name, proj=proj_obj)
        return Response({"block_name": block_obj.name, "created_flg": created_flg})

class OpVersion(views.APIView):
    """op platform post version info"""
    def post(self, request, format=None):
        version_name = request.data.get("name")
        block_name = request.data.get("block")
        proj_name = request.data.get("proj")
        owner_name = request.data.get("owner")
        if not version_name:
            return Response({"message": "version name is NA"}, status=status.HTTP_400_BAD_REQUEST)
        if not block_name:
            return Response({"message": "block name is NA"}, status=status.HTTP_400_BAD_REQUEST)
        if not proj_name:
            return Response({"message": "proj name is NA"}, status=status.HTTP_400_BAD_REQUEST)
        if not owner_name:
            return Response({"message": "owner name is NA"}, status=status.HTTP_400_BAD_REQUEST)
        owner_obj, _ = User.objects.get_or_create({"name": owner_name}, name=owner_name)
        proj_obj, _ = Proj.objects.get_or_create({"name": proj_name}, name=proj_name)
        block_obj, _ = Block.objects.get_or_create(
            {"name": block_name, "proj": proj_obj}, name=block_name, proj=proj_obj)
        version_obj, created_flg = Version.objects.update_or_create(
            {"name": version_name, "block": block_obj, "owner": owner_obj,
             "data": request.data.get("data", {})},
            name=version_name, block=block_obj, owner=owner_obj)
        return Response({"version_name": version_obj.name, "created_flg": created_flg})

class OpFlow(views.APIView):
    """op platform post flow info"""
    def post(self, request, format=None):
        flow_name = request.data.get("name")
        version_name = request.data.get("version")
        block_name = request.data.get("block")
        proj_name = request.data.get("proj")
        owner_name = request.data.get("owner")
        if not flow_name:
            return Response({"message": "flow name is NA"}, status=status.HTTP_400_BAD_REQUEST)
        if not version_name:
            return Response({"message": "version name is NA"}, status=status.HTTP_400_BAD_REQUEST)
        if not block_name:
            return Response({"message": "block name is NA"}, status=status.HTTP_400_BAD_REQUEST)
        if not proj_name:
            return Response({"message": "proj name is NA"}, status=status.HTTP_400_BAD_REQUEST)
        if not owner_name:
            return Response({"message": "owner name is NA"}, status=status.HTTP_400_BAD_REQUEST)
        owner_obj, _ = User.objects.get_or_create({"name": owner_name}, name=owner_name)
        proj_obj, _ = Proj.objects.get_or_create({"name": proj_name}, name=proj_name)
        block_obj, _ = Block.objects.get_or_create(
            {"name": block_name, "proj": proj_obj}, name=block_name, proj=proj_obj)
        version_obj, _ = Version.objects.get_or_create(
            {"name": version_name, "block": block_obj, "owner": owner_obj},
            name=version_name, block=block_obj, owner=owner_obj)
        flow_obj, created_flg = Flow.objects.update_or_create(
            {"name": flow_name, "version": version_obj, "owner": owner_obj,
             "data": request.data.get("data", {})},
            name=flow_name, version=version_obj, owner=owner_obj)
        return Response({"flow_name": flow_obj.name, "created_flg": created_flg})

class OpStage(views.APIView):
    """op platform post stage info"""
    def post(self, request, format=None):
        stage_name = request.data.get("name")
        flow_name = request.data.get("flow")
        version_name = request.data.get("version")
        block_name = request.data.get("block")
        proj_name = request.data.get("proj")
        owner_name = request.data.get("owner")
        if not stage_name:
            return Response({"message": "stage name is NA"}, status=status.HTTP_400_BAD_REQUEST)
        if not flow_name:
            return Response({"message": "flow name is NA"}, status=status.HTTP_400_BAD_REQUEST)
        if not version_name:
            return Response({"message": "version name is NA"}, status=status.HTTP_400_BAD_REQUEST)
        if not block_name:
            return Response({"message": "block name is NA"}, status=status.HTTP_400_BAD_REQUEST)
        if not proj_name:
            return Response({"message": "proj name is NA"}, status=status.HTTP_400_BAD_REQUEST)
        if not owner_name:
            return Response({"message": "owner name is NA"}, status=status.HTTP_400_BAD_REQUEST)
        owner_obj, _ = User.objects.get_or_create({"name": owner_name}, name=owner_name)
        proj_obj, _ = Proj.objects.get_or_create({"name": proj_name}, name=proj_name)
        block_obj, _ = Block.objects.get_or_create(
            {"name": block_name, "proj": proj_obj}, name=block_name, proj=proj_obj)
        version_obj, _ = Version.objects.get_or_create(
            {"name": version_name, "block": block_obj, "owner": owner_obj},
            name=version_name, block=block_obj, owner=owner_obj)
        flow_obj, _ = Flow.objects.get_or_create(
            {"name": flow_name, "version": version_obj, "owner": owner_obj},
            name=flow_name, version=version_obj, owner=owner_obj)
        stage_obj = Stage.objects.create(
            name=stage_name, flow=flow_obj, owner=owner_obj, data=request.data.get("data", {}))
        return Response({"stage_name": stage_obj.name})
