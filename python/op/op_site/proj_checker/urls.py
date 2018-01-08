"""project checker url"""
from django.urls import include, path
from rest_framework.urlpatterns import format_suffix_patterns
from . import views

app_name = "proj_checker"
urlpatterns = [
    path("projs/", views.ProjList.as_view(), name="proj_list"),
    path("projs/<pk>", views.ProjDetail.as_view(), name="proj_detail"),
]

urlpatterns = format_suffix_patterns(urlpatterns)
