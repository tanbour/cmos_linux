from django.http import HttpResponse, HttpResponseBadRequest
from django.shortcuts import render
from django.views.decorators.csrf import csrf_exempt
from django.views import View
from django.views.generic.list import ListView
from django.views.generic.detail import DetailView
from django.utils.decorators import method_decorator
from django.core.exceptions import ObjectDoesNotExist, MultipleObjectsReturned
from .models import User, Title, Proj, Block, Version
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
        context["level"] = "proj"
        return context

class BlockList(ListView):
    """be report block list"""
    model = Block
    template_name = "be_rpt/list_page.html"
    def get_queryset(self):
        self.proj_name = self.kwargs.get("proj_name")
        return Block.objects.filter(proj__name=self.proj_name)
    def get_context_data(self, **kwargs):
        context = super(BlockList, self).get_context_data(**kwargs)
        context["head_lst"] = Title.objects.first().block
        context["owner_distinct_lst"] = Block.objects.distinct("owner")
        context["level"] = "block"
        context["proj_name"] = self.proj_name
        return context

class VersionList(ListView):
    """be report version list"""
    model = Version
    template_name = "be_rpt/list_page.html"
    def get_queryset(self):
        self.proj_name = self.kwargs.get("proj_name")
        self.block_name = self.kwargs.get("block_name")
        return Version.objects.filter(
            block__name=self.block_name, block__proj__name=self.proj_name)
    def get_context_data(self, **kwargs):
        context = super(VersionList, self).get_context_data(**kwargs)
        context["head_lst"] = Title.objects.first().version
        context["owner_distinct_lst"] = Version.objects.distinct("owner")
        context["level"] = "version"
        context["proj_name"] = self.proj_name
        context["block_name"] = self.block_name
        return context

class VersionDetail(DetailView):
    """be report version details"""
    model = Version
    template_name = "be_rpt/detail_page.html"
    def get_object(self):
        self.proj_name = self.kwargs.get("proj_name")
        self.block_name = self.kwargs.get("block_name")
        self.version_name = self.kwargs.get("version_name")
        return Version.objects.get(
            name=self.version_name, block__name=self.block_name, block__proj__name=self.proj_name)
    def get_context_data(self, **kwargs):
        context = super(VersionDetail, self).get_context_data(**kwargs)
        context["proj_name"] = self.proj_name
        context["block_name"] = self.block_name
        context["version_name"] = self.version_name
        return context

@method_decorator(csrf_exempt, name="dispatch")
class UserPost(View):
    """be report post user data"""
    def post(self, request, *args, **kwargs):
        user_dic = json.loads(request.body.decode()).get("user_dic", {})
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
        proj_dic = json.loads(request.body.decode()).get("proj_dic", {})
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
        block_dic = json.loads(request.body.decode()).get("block_dic")
        if not block_dic:
            return HttpResponseBadRequest("input block_dic is NA")
        proj_name = block_dic.get("proj")
        try:
            proj_obj = Proj.objects.get(name=proj_name)
        except ObjectDoesNotExist:
            return HttpResponseBadRequest(f"project object named {proj_name} is NA")
        except MultipleObjectsReturned:
            return HttpResponseBadRequest(
                f"multiple project object named {proj_name} is returned")
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
        version_dic = json.loads(request.body.decode()).get("version_dic")
        if not version_dic:
            return HttpResponseBadRequest("input version_dic is NA")
        proj_name = version_dic.get("proj")
        block_name = version_dic.get("block")
        try:
            proj_obj = Proj.objects.get(name=proj_name)
        except ObjectDoesNotExist:
            return HttpResponseBadRequest(f"project object named {proj_name} is NA")
        except MultipleObjectsReturned:
            return HttpResponseBadRequest(
                f"multiple project object named {proj_name} is returned")
        try:
            block_obj = Block.objects.get(name=block_name, proj=proj_obj)
        except ObjectDoesNotExist:
            return HttpResponseBadRequest(f"block object named {block_name} is NA")
        except MultipleObjectsReturned:
            return HttpResponseBadRequest(
                f"multiple block object named {block_name} is returned")
        owner_name = version_dic.get("owner")
        owner_obj, _ = User.objects.get_or_create({"name": owner_name}, name=owner_name)
        version_obj = Version.objects.create(name=version_dic.get("name"), block=block_obj, owner=owner_obj, data=version_dic.get("data"))
        return HttpResponse(
            json.dumps({"version_created": version_obj.name}),
            content_type="application/json")
