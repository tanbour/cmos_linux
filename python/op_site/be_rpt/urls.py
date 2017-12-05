"""be report url"""
from django.urls import include, path
from . import views

app_name = "be_rpt"
urlpatterns = [
    path("projs/", views.ProjList.as_view(), name="proj_list"),
    path("blocks/<proj_pk>/", views.BlockList.as_view(), name="block_list"),
    path("versions/<block_pk>/", views.VersionList.as_view(), name="version_list"),
    path("flows/<version_pk>/", views.FlowList.as_view(), name="flow_list"),
    path("stages/<flow_pk>/", views.StageList.as_view(), name="stage_list"),
    path("stage/<stage_pk>/", views.StageDetail.as_view(), name="stage_detail"),
    path("post/user/", views.UserPost.as_view(), name="post_user"),
    path("post/project/", views.ProjPost.as_view(), name="post_project"),
    path("post/block/", views.BlockPost.as_view(), name="post_block"),
    path("post/version/", views.VersionPost.as_view(), name="post_version"),
    path("post/flow/", views.FlowPost.as_view(), name="post_flow"),
    path("post/stage/", views.StagePost.as_view(), name="post_stage"),
]
