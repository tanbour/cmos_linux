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
    path("op/projs/", views.OpProj.as_view(), name="op_proj"),
    path("op/blocks/", views.OpBlock.as_view(), name="op_block"),
    path("op/versions/", views.OpVersion.as_view(), name="op_version"),
    path("op/flows/", views.OpFlow.as_view(), name="op_flow"),
    path("op/stages/", views.OpStage.as_view(), name="op_stage"),
]

urlpatterns = format_suffix_patterns(urlpatterns)
