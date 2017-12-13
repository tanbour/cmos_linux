from rest_framework import generics
from .models import Proj
from .serializers import ProjSerializer

# Create your views here.
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
    serializer_class = ProjSerializer
