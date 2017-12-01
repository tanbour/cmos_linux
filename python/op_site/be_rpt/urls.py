"""be report url"""
from django.conf.urls import url
from . import views

urlpatterns = [
    url(r"^$", views.ProjList.as_view(), name="proj_list"),
    url(r"^(?P<proj_name>\w+)/$", views.BlockList.as_view(), name="block_list"),
    url(r"^(?P<proj_name>\w+)/(?P<block_name>\w+)/$", views.VersionList.as_view(), name="version_list"),
    url(r"^(?P<proj_name>\w+)/(?P<block_name>\w+)/(?P<version_name>\w+)/$", views.VersionDetail.as_view(), name="version_detail"),
]
