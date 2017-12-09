from rest_framework import generics
from rest_framework import permissions
from rest_framework.response import Response
from rest_framework import status
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

class ProjDetail(generics.RetrieveAPIView):
    """be report project detail"""
    queryset = Proj.objects.all()
    serializer_class = ProjRelatedSerializer

class BlockList(generics.ListAPIView):
    """be report block list"""
    queryset = Block.objects.all()
    serializer_class = BlockSerializer

class BlockDetail(generics.RetrieveAPIView):
    """be report block detail"""
    queryset = Block.objects.all()
    serializer_class = BlockRelatedSerializer

class VersionList(generics.ListAPIView):
    """be report version list"""
    queryset = Version.objects.all()
    serializer_class = VersionSerializer

class VersionDetail(generics.RetrieveAPIView):
    """be report version detail"""
    queryset = Version.objects.all()
    serializer_class = VersionRelatedSerializer

class FlowList(generics.ListAPIView):
    """be report flow list"""
    queryset = Flow.objects.all()
    serializer_class = FlowSerializer

class FlowDetail(generics.RetrieveAPIView):
    """be report flow detail"""
    queryset = Flow.objects.all()
    serializer_class = FlowRelatedSerializer

class StageList(generics.ListAPIView):
    """be report stage list"""
    queryset = Stage.objects.all()
    serializer_class = StageSerializer

class StageDetail(generics.RetrieveAPIView):
    """be report stage detail"""
    queryset = Stage.objects.all()
    serializer_class = StageDetailSerializer

class UserList(generics.ListAPIView):
    """be report user list"""
    queryset = User.objects.all()
    serializer_class = UserSerializer

class UserDetail(generics.RetrieveAPIView):
    """be report user detail"""
    queryset = User.objects.all()
    serializer_class = UserRelatedSerializer


# @method_decorator(csrf_exempt, name="dispatch")
# class UserPost(View):
#     """be report post user data"""
#     def post(self, request, *args, **kwargs):
#         user_dic = json.loads(request.body.decode())
#         if not user_dic:
#             return HttpResponseBadRequest("input user_dic is NA")
#         user_name = user_dic.get("name")
#         user_obj, create_flg = User.objects.update_or_create(
#             {"name": user_name, "data": user_dic.get("data")}, name=user_name)
#         return HttpResponse(
#             json.dumps({"user_name": user_obj.name, "create_flg": create_flg}),
#             content_type="application/json")

# @method_decorator(csrf_exempt, name="dispatch")
# class ProjPost(View):
#     """be report post project data"""
#     def post(self, request, *args, **kwargs):
#         proj_dic = json.loads(request.body.decode())
#         if not proj_dic:
#             return HttpResponseBadRequest("input proj_dic is NA")
#         proj_name = proj_dic.get("name")
#         proj_obj, create_flg = Proj.objects.update_or_create(
#             {"name": proj_name, "data": proj_dic.get("data")}, name=proj_name)
#         return HttpResponse(
#             json.dumps({"proj_name": proj_obj.name, "create_flg": create_flg}),
#             content_type="application/json")

# @method_decorator(csrf_exempt, name="dispatch")
# class BlockPost(View):
#     """be report post block data"""
#     def post(self, request, *args, **kwargs):
#         block_dic = json.loads(request.body.decode())
#         if not block_dic:
#             return HttpResponseBadRequest("input block_dic is NA")
#         proj_name = block_dic.get("proj")
#         proj_obj, _ = Proj.objects.get_or_create({"name": proj_name}, name=proj_name)
#         block_name = block_dic.get("name")
#         block_obj, create_flg = Block.objects.update_or_create(
#             {"name": block_name, "proj": proj_obj, "data": block_dic.get("data")},
#             name=block_name, proj=proj_obj)
#         return HttpResponse(
#             json.dumps({"block_name": block_obj.name, "create_flg": create_flg}),
#             content_type="application/json")

# @method_decorator(csrf_exempt, name="dispatch")
# class VersionPost(View):
#     """be report post version data"""
#     def post(self, request, *args, **kwargs):
#         version_dic = json.loads(request.body.decode())
#         if not version_dic:
#             return HttpResponseBadRequest("input version_dic is NA")
#         owner_name = version_dic.get("owner")
#         owner_obj, _ = User.objects.get_or_create({"name": owner_name}, name=owner_name)
#         proj_name = version_dic.get("proj")
#         block_name = version_dic.get("block")
#         proj_obj, _ = Proj.objects.get_or_create({"name": proj_name}, name=proj_name)
#         block_obj, _ = Block.objects.get_or_create(
#             {"name": block_name, "proj": proj_obj}, name=block_name, proj=proj_obj)
#         version_obj = Version.objects.create(name=version_dic.get("name"), block=block_obj, owner=owner_obj, data=version_dic.get("data"))
#         return HttpResponse(
#             json.dumps({"version_created": version_obj.name}),
#             content_type="application/json")

# @method_decorator(csrf_exempt, name="dispatch")
# class FlowPost(View):
#     """be report post flow data"""
#     def post(self, request, *args, **kwargs):
#         flow_dic = json.loads(request.body.decode())
#         if not flow_dic:
#             return HttpResponseBadRequest("input flow_dic is NA")
#         owner_name = flow_dic.get("owner")
#         owner_obj, _ = User.objects.get_or_create({"name": owner_name}, name=owner_name)
#         proj_name = flow_dic.get("proj")
#         block_name = flow_dic.get("block")
#         version_name = flow_dic.get("version")
#         proj_obj, _ = Proj.objects.get_or_create({"name": proj_name}, name=proj_name)
#         block_obj, _ = Block.objects.get_or_create(
#             {"name": block_name, "proj": proj_obj}, name=block_name, proj=proj_obj)
#         version_obj, _ = Version.objects.get_or_create(
#             {"name": version_name, "block": block_obj, "owner": owner_obj},
#             name=version_name, block=block_obj, owner=owner_obj)
#         flow_obj = Flow.objects.create(
#             name=flow_dic.get("name"), version=version_obj, owner=owner_obj, data=flow_dic.get("data"))
#         return HttpResponse(
#             json.dumps({"flow_created": flow_obj.name}),
#             content_type="application/json")

# @method_decorator(csrf_exempt, name="dispatch")
# class StagePost(View):
#     """be report post stage data"""
#     def post(self, request, *args, **kwargs):
#         stage_dic = json.loads(request.body.decode())
#         if not stage_dic:
#             return HttpResponseBadRequest("input stage_dic is NA")
#         owner_name = stage_dic.get("owner")
#         owner_obj, _ = User.objects.get_or_create({"name": owner_name}, name=owner_name)
#         proj_name = stage_dic.get("proj")
#         block_name = stage_dic.get("block")
#         version_name = stage_dic.get("version")
#         flow_name = stage_dic.get("flow")
#         proj_obj, _ = Proj.objects.get_or_create({"name": proj_name}, name=proj_name)
#         block_obj, _ = Block.objects.get_or_create(
#             {"name": block_name, "proj": proj_obj}, name=block_name, proj=proj_obj)
#         version_obj, _ = Version.objects.get_or_create(
#             {"name": version_name, "block": block_obj, "owner": owner_obj},
#             name=version_name, block=block_obj, owner=owner_obj)
#         flow_obj, _ = Flow.objects.get_or_create(
#             {"name": flow_name, "version": version_obj, "owner": owner_obj},
#             name=flow_name, version=version_obj, owner=owner_obj)
#         stage_obj = Stage.objects.create(
#             name=stage_dic.get("name"), flow=flow_obj, owner=owner_obj, data=stage_dic.get("data"))
#         return HttpResponse(
#             json.dumps({"stage_created": stage_obj.name}),
#             content_type="application/json")
