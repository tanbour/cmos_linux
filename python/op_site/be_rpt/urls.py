"""be report url"""
from django.urls import include, path
from . import views

app_name = "be_rpt"
urlpatterns = [
    path("projs/", views.ProjList.as_view(), name="proj_list"),
    path("blocks/<proj_pk>/", views.BlockList.as_view(), name="block_list"),
    path("versions/<block_pk>/", views.VersionList.as_view(), name="version_list"),
    path("version/<version_pk>/", views.VersionDetail.as_view(), name="version_detail"),
    path("post/user/", views.UserPost.as_view(), name="post_user"),
    path("post/project/", views.ProjPost.as_view(), name="post_project"),
    path("post/block/", views.BlockPost.as_view(), name="post_block"),
    path("post/version/", views.VersionPost.as_view(), name="post_version"),
]
