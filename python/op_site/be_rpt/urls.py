"""be report url"""
from django.urls import include, path
from rest_framework.urlpatterns import format_suffix_patterns
from . import views

app_name = "be_rpt"
urlpatterns = [
    path("projs/", views.ProjList.as_view(), name="proj_list"),
    path("projs/<pk>", views.ProjDetail.as_view(), name="proj_detail"),
    path("blocks/", views.BlockList.as_view(), name="block_list"),
    path("blocks/<pk>", views.BlockDetail.as_view(), name="block_detail"),
    path("versions/", views.VersionList.as_view(), name="version_list"),
    path("versions/<pk>", views.VersionDetail.as_view(), name="version_detail"),
    path("flows/", views.FlowList.as_view(), name="flow_list"),
    path("flows/<pk>", views.FlowDetail.as_view(), name="flow_detail"),
    path("stages/", views.StageList.as_view(), name="stage_list"),
    path("stages/<pk>", views.StageDetail.as_view(), name="stage_detail"),
    path("users/", views.UserList.as_view(), name="user_list"),
    path("users/<pk>", views.UserDetail.as_view(), name="user_detail"),
    path("titles/", views.TitleList.as_view(), name="title_list"),
    path("titles/<pk>", views.TitleDetail.as_view(), name="title_detail"),
    # path("post/user/", views.UserPost.as_view(), name="post_user"),
    # path("post/project/", views.ProjPost.as_view(), name="post_project"),
    # path("post/block/", views.BlockPost.as_view(), name="post_block"),
    # path("post/version/", views.VersionPost.as_view(), name="post_version"),
    # path("post/flow/", views.FlowPost.as_view(), name="post_flow"),
    # path("post/stage/", views.StagePost.as_view(), name="post_stage"),
]

urlpatterns = format_suffix_patterns(urlpatterns)
