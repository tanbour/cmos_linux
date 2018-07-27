from rest_framework import generics
from .models import Proj
from .serializers import ProjSerializer

# Create your views here.
class ProjList(generics.ListCreateAPIView):
    """be report project list"""
    queryset = Proj.objects.all()
    serializer_class = ProjSerializer

class ProjDetail(generics.RetrieveUpdateDestroyAPIView):
    """be report project detail"""
    queryset = Proj.objects.all()
    serializer_class = ProjSerializer
