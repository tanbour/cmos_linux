"""be report url"""
from django.conf.urls import url
from . import views

urlpatterns = [
    url(r"^show/$", views.ProjList.as_view(), name="proj_list"),
    url(r"^show/(?P<proj_name>\w+)/$", views.BlockList.as_view(), name="block_list"),
    url(r"^show/(?P<proj_name>\w+)/(?P<block_name>\w+)/$", views.VersionList.as_view(), name="version_list"),
    url(r"^show/(?P<proj_name>\w+)/(?P<block_name>\w+)/(?P<version_name>\w+)/$", views.VersionDetail.as_view(), name="version_detail"),
    url(r"^post/project/$", views.ProjPost.as_view(), name="post_project"),
    url(r"^post/block/$", views.BlockPost.as_view(), name="post_block"),
    # url(r"^post/version/$", views.VersionPost.as_view(), name="post_version"),
]
