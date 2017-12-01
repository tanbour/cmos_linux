from django.http import HttpResponse, HttpResponseBadRequest
from django.shortcuts import render
from django.views.decorators.csrf import csrf_exempt
from django.views import View
from django.views.generic.list import ListView
from django.views.generic.detail import DetailView
from django.utils.decorators import method_decorator
from .models import User, Title, Proj, Block, Version
from django.utils import timezone as tz
import json

# Create your views here.
class ProjList(ListView):
    """be report project list"""
    model = Proj
    def get_context_data(self, **kwargs):
        context = super(ProjList, self).get_context_data(**kwargs)
        context["proj_head_lst"] = Title.objects.first().proj
        return context

class BlockList(ListView):
    """be report block list"""
    model = Block
    def get_queryset(self):
        self.proj_name = self.kwargs.get("proj_name")
        return Block.objects.filter(proj__name=self.proj_name)
    def get_context_data(self, **kwargs):
        context = super(BlockList, self).get_context_data(**kwargs)
        context["block_head_lst"] = Title.objects.first().block
        context["proj_name"] = self.proj_name
        return context

class VersionList(ListView):
    """be report version list"""
    model = Version
    def get_queryset(self):
        self.proj_name = self.kwargs.get("proj_name")
        self.block_name = self.kwargs.get("block_name")
        return Version.objects.filter(
            block__name=self.block_name, block__proj__name=self.proj_name)
    def get_context_data(self, **kwargs):
        context = super(VersionList, self).get_context_data(**kwargs)
        context["version_head_lst"] = Title.objects.first().version
        context["proj_name"] = self.proj_name
        context["block_name"] = self.block_name
        return context

class VersionDetail(DetailView):
    """be report version details"""
    model = Version
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
        context['now'] = tz.now()
        return context

@method_decorator(csrf_exempt, name="dispatch")
class ProjPost(View):
    """be report post project data"""
    def post(self, request, *args, **kwargs):
        proj_dic = json.loads(request.body.decode()).get("proj_dic", {})
        if not proj_dic:
            return HttpResponseBadRequest("input proj_dic is NA")
        proj_obj, create_flg = Proj.objects.update_or_create(
            {"name": proj_dic.get("name"), "data": proj_dic.get("data")},
            name=proj_dic.get("name"))
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
        proj_obj = Proj.objects.get(name=proj_name)
        if not proj_obj:
            return HttpResponseBadRequest("project object is NA")
        block_obj, create_flg = Block.objects.update_or_create(
            {"name": block_dic.get("name"), "proj": proj_obj, "data": block_dic.get("data")},
            name=block_dic.get("name"), proj=proj_obj)
        return HttpResponse(
            json.dumps({"block_name": block_obj.name, "create_flg": create_flg}),
            content_type="application/json")
