"""be report url"""
from django.conf.urls import url
from . import views

urlpatterns = [
    url(r"^$", views.ProjList.as_view(), name="proj_list"),
]
