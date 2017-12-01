from django.shortcuts import render
from django.views.generic import ListView
from .models import User, Title, Proj, Block, Version

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
    def get_context_data(self, **kwargs):
        context = super(ProjList, self).get_context_data(**kwargs)
        a = self.kwargs['proj_name']
        return context
