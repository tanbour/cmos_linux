from django.shortcuts import render
from django.views.generic import ListView, DetailView
from .models import User, Title, Proj, Block, Version
from django.utils import timezone as tz

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
