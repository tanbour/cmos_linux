from django.http import HttpResponse, HttpResponseBadRequest, JsonResponse
from django.shortcuts import render
from django.views.decorators.csrf import csrf_exempt
from django.views import View
from django.views.generic.list import ListView
from django.views.generic.detail import DetailView
from django.utils.decorators import method_decorator
from django.core.exceptions import ObjectDoesNotExist, MultipleObjectsReturned
from .models import User, Title, Proj, Block, Version, Flow, Stage
from .serializers import UserSerializer, TitleSerializer, ProjSerializer, BlockSerializer, VersionSerializer, FlowSerializer, StageSerializer
from rest_framework import generics
from rest_framework.response import Response
from rest_framework import status
from django.utils import timezone as tz
import json

# Create your views here.
class ProjList(ListView):
    """be report project list"""
    model = Proj
    template_name = "be_rpt/list_page.html"
    def get_context_data(self, **kwargs):
        context = super(ProjList, self).get_context_data(**kwargs)
        context["head_lst"] = Title.objects.first().proj
        context["owner_distinct_lst"] = Proj.objects.distinct("owner")
        context["name_distinct_lst"] = Proj.objects.distinct("name")
        context["level"] = "proj"
        return context

class AProjList(generics.ListAPIView):
    """be report project list"""
    queryset = Proj.objects.all()
    serializer_class = ProjSerializer
    def list(self, request, *args, **kwargs):
        q_s = self.get_queryset()
        qs_slz = ProjSerializer(q_s, many=True)
        rsp_dic = {"head_lst": Title.objects.first().proj, "qs_dic_lst": qs_slz.data, "level": "proj"}
        return Response(rsp_dic)

class ABlockList(generics.ListAPIView):
    """be report project list"""
    queryset = Block.objects.all()
    serializer_class = ProjSerializer
    def list(self, request, *args, **kwargs):
        q_s = self.get_queryset()
        qs_slz = ProjSerializer(q_s, many=True)
        rsp_dic = {"head_lst": Title.objects.first().block, "qs_dic_lst": qs_slz.data, "level": "block"}
        return Response(rsp_dic)

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

class BlockList(ListView):
    """be report block list"""
    model = Block
    template_name = "be_rpt/list_page.html"
    def get_queryset(self):
        proj_pk = self.kwargs.get("proj_pk")
        self.proj_obj = Proj.objects.get(pk=proj_pk)
        self.block_qs = block_qs = Block.objects.filter(proj_id=proj_pk)
        return block_qs
    def get_context_data(self, **kwargs):
        context = super(BlockList, self).get_context_data(**kwargs)
        context["head_lst"] = Title.objects.first().block
        context["owner_distinct_lst"] = self.block_qs.distinct("owner")
        context["name_distinct_lst"] = self.block_qs.distinct("name")
        context["level"] = "block"
        context["proj_obj"] = self.proj_obj
        return context

class VersionList(ListView):
    """be report version list"""
    model = Version
    template_name = "be_rpt/list_page.html"
    def get_queryset(self):
        block_pk = self.kwargs.get("block_pk")
        self.block_obj = block_obj = Block.objects.get(pk=block_pk)
        self.proj_obj = block_obj.proj
        self.version_qs = version_qs = Version.objects.filter(block_id=block_pk)
        return version_qs
    def get_context_data(self, **kwargs):
        context = super(VersionList, self).get_context_data(**kwargs)
        context["head_lst"] = Title.objects.first().version
        context["owner_distinct_lst"] = self.version_qs.distinct("owner")
        context["name_distinct_lst"] = self.version_qs.distinct("name")
        context["level"] = "version"
        context["block_obj"] = self.block_obj
        context["proj_obj"] = self.proj_obj
        return context

class FlowList(ListView):
    """be report flow list"""
    model = Flow
    template_name = "be_rpt/list_page.html"
    def get_queryset(self):
        version_pk = self.kwargs.get("version_pk")
        self.version_obj = version_obj = Version.objects.get(pk=version_pk)
        self.block_obj = block_obj = version_obj.block
        self.proj_obj = block_obj.proj
        self.flow_qs = flow_qs = Flow.objects.filter(version_id=version_pk)
        return flow_qs
    def get_context_data(self, **kwargs):
        context = super(FlowList, self).get_context_data(**kwargs)
        context["head_lst"] = Title.objects.first().flow
        context["owner_distinct_lst"] = self.flow_qs.distinct("owner")
        context["name_distinct_lst"] = self.flow_qs.distinct("name")
        context["level"] = "flow"
        context["version_obj"] = self.version_obj
        context["block_obj"] = self.block_obj
        context["proj_obj"] = self.proj_obj
        return context

class StageList(ListView):
    """be report stage list"""
    model = Stage
    template_name = "be_rpt/list_page.html"
    def get_queryset(self):
        flow_pk = self.kwargs.get("flow_pk")
        self.flow_obj = flow_obj = Flow.objects.get(pk=flow_pk)
        self.version_obj = version_obj = flow_obj.version
        self.block_obj = block_obj = version_obj.block
        self.proj_obj = block_obj.proj
        self.stage_qs = stage_qs = Stage.objects.filter(flow_id=flow_pk)
        return stage_qs
    def get_context_data(self, **kwargs):
        context = super(StageList, self).get_context_data(**kwargs)
        context["head_lst"] = Title.objects.first().stage
        context["owner_distinct_lst"] = self.stage_qs.distinct("owner")
        context["name_distinct_lst"] = self.stage_qs.distinct("name")
        context["level"] = "stage"
        context["flow_obj"] = self.flow_obj
        context["version_obj"] = self.version_obj
        context["block_obj"] = self.block_obj
        context["proj_obj"] = self.proj_obj
        return context

class StageDetail(DetailView):
    """be report stage details"""
    model = Stage
    template_name = "be_rpt/detail_page.html"
    def get_object(self):
        stage_pk = self.kwargs.get("stage_pk")
        stage_obj = Stage.objects.get(pk=stage_pk)
        self.flow_obj = flow_obj = stage_obj.flow
        self.version_obj = version_obj = flow_obj.version
        self.block_obj = block_obj = version_obj.block
        self.proj_obj = block_obj.proj
        return stage_obj
    def get_context_data(self, **kwargs):
        context = super(StageDetail, self).get_context_data(**kwargs)
        context["flow_obj"] = self.flow_obj
        context["version_obj"] = self.version_obj
        context["block_obj"] = self.block_obj
        context["proj_obj"] = self.proj_obj
        return context

@method_decorator(csrf_exempt, name="dispatch")
class UserPost(View):
    """be report post user data"""
    def post(self, request, *args, **kwargs):
        user_dic = json.loads(request.body.decode())
        if not user_dic:
            return HttpResponseBadRequest("input user_dic is NA")
        user_name = user_dic.get("name")
        user_obj, create_flg = User.objects.update_or_create(
            {"name": user_name, "data": user_dic.get("data")}, name=user_name)
        return HttpResponse(
            json.dumps({"user_name": user_obj.name, "create_flg": create_flg}),
            content_type="application/json")

@method_decorator(csrf_exempt, name="dispatch")
class ProjPost(View):
    """be report post project data"""
    def post(self, request, *args, **kwargs):
        proj_dic = json.loads(request.body.decode())
        if not proj_dic:
            return HttpResponseBadRequest("input proj_dic is NA")
        proj_name = proj_dic.get("name")
        proj_obj, create_flg = Proj.objects.update_or_create(
            {"name": proj_name, "data": proj_dic.get("data")}, name=proj_name)
        return HttpResponse(
            json.dumps({"proj_name": proj_obj.name, "create_flg": create_flg}),
            content_type="application/json")

@method_decorator(csrf_exempt, name="dispatch")
class BlockPost(View):
    """be report post block data"""
    def post(self, request, *args, **kwargs):
        block_dic = json.loads(request.body.decode())
        if not block_dic:
            return HttpResponseBadRequest("input block_dic is NA")
        proj_name = block_dic.get("proj")
        proj_obj, _ = Proj.objects.get_or_create({"name": proj_name}, name=proj_name)
        block_name = block_dic.get("name")
        block_obj, create_flg = Block.objects.update_or_create(
            {"name": block_name, "proj": proj_obj, "data": block_dic.get("data")},
            name=block_name, proj=proj_obj)
        return HttpResponse(
            json.dumps({"block_name": block_obj.name, "create_flg": create_flg}),
            content_type="application/json")

@method_decorator(csrf_exempt, name="dispatch")
class VersionPost(View):
    """be report post version data"""
    def post(self, request, *args, **kwargs):
        version_dic = json.loads(request.body.decode())
        if not version_dic:
            return HttpResponseBadRequest("input version_dic is NA")
        owner_name = version_dic.get("owner")
        owner_obj, _ = User.objects.get_or_create({"name": owner_name}, name=owner_name)
        proj_name = version_dic.get("proj")
        block_name = version_dic.get("block")
        proj_obj, _ = Proj.objects.get_or_create({"name": proj_name}, name=proj_name)
        block_obj, _ = Block.objects.get_or_create(
            {"name": block_name, "proj": proj_obj}, name=block_name, proj=proj_obj)
        version_obj = Version.objects.create(name=version_dic.get("name"), block=block_obj, owner=owner_obj, data=version_dic.get("data"))
        return HttpResponse(
            json.dumps({"version_created": version_obj.name}),
            content_type="application/json")

@method_decorator(csrf_exempt, name="dispatch")
class FlowPost(View):
    """be report post flow data"""
    def post(self, request, *args, **kwargs):
        flow_dic = json.loads(request.body.decode())
        if not flow_dic:
            return HttpResponseBadRequest("input flow_dic is NA")
        owner_name = flow_dic.get("owner")
        owner_obj, _ = User.objects.get_or_create({"name": owner_name}, name=owner_name)
        proj_name = flow_dic.get("proj")
        block_name = flow_dic.get("block")
        version_name = flow_dic.get("version")
        proj_obj, _ = Proj.objects.get_or_create({"name": proj_name}, name=proj_name)
        block_obj, _ = Block.objects.get_or_create(
            {"name": block_name, "proj": proj_obj}, name=block_name, proj=proj_obj)
        version_obj, _ = Version.objects.get_or_create(
            {"name": version_name, "block": block_obj, "owner": owner_obj},
            name=version_name, block=block_obj, owner=owner_obj)
        flow_obj = Flow.objects.create(
            name=flow_dic.get("name"), version=version_obj, owner=owner_obj, data=flow_dic.get("data"))
        return HttpResponse(
            json.dumps({"flow_created": flow_obj.name}),
            content_type="application/json")

@method_decorator(csrf_exempt, name="dispatch")
class StagePost(View):
    """be report post stage data"""
    def post(self, request, *args, **kwargs):
        stage_dic = json.loads(request.body.decode())
        if not stage_dic:
            return HttpResponseBadRequest("input stage_dic is NA")
        owner_name = stage_dic.get("owner")
        owner_obj, _ = User.objects.get_or_create({"name": owner_name}, name=owner_name)
        proj_name = stage_dic.get("proj")
        block_name = stage_dic.get("block")
        version_name = stage_dic.get("version")
        flow_name = stage_dic.get("flow")
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
            name=stage_dic.get("name"), flow=flow_obj, owner=owner_obj, data=stage_dic.get("data"))
        return HttpResponse(
            json.dumps({"stage_created": stage_obj.name}),
            content_type="application/json")
