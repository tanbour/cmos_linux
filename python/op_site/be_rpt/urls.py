"""be report url"""
from django.urls import include, path
from . import views

app_name = "be_rpt"
urlpatterns = [
    path("show/", views.ProjList.as_view(), name="proj_list"),
    path("show/<proj_name>/", views.BlockList.as_view(), name="block_list"),
    path("show/<proj_name>/<block_name>/", views.VersionList.as_view(), name="version_list"),
    path("show/<proj_name>/<block_name>/<version_name>/", views.VersionDetail.as_view(), name="version_detail"),
    path("post/user/", views.UserPost.as_view(), name="post_user"),
    path("post/project/", views.ProjPost.as_view(), name="post_project"),
    path("post/block/", views.BlockPost.as_view(), name="post_block"),
    path("post/version/", views.VersionPost.as_view(), name="post_version"),
]
