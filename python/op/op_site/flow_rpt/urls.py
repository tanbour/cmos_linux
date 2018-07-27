"""be report url"""
from django.urls import include, path
from rest_framework.urlpatterns import format_suffix_patterns
from . import views

app_name = "flow_rpt"
urlpatterns = [
    path("runner/projs/", views.RunnerProj.as_view(), name="runner_proj"),
    path("runner/blocks/", views.RunnerBlock.as_view(), name="runner_block"),
    path("runner/flows/", views.RunnerFlow.as_view(), name="runner_flow"),
    path("runner/stages/", views.RunnerStage.as_view(), name="runner_stage"),
    path("runner/upload/", views.RunnerUpload.as_view(), name="runner_upload"),
    path("user_check/", views.UserCheck.as_view(), name="user_check"),
    path("projs/", views.ProjList.as_view(), name="proj_list"),
    path("projs/<pk>", views.ProjDetail.as_view(), name="proj_detail"),
    path("blocks/", views.BlockList.as_view(), name="block_list"),
    path("blocks/<pk>", views.BlockDetail.as_view(), name="block_detail"),
    path("flows/", views.FlowList.as_view(), name="flow_list"),
    path("flows/<pk>", views.FlowDetail.as_view(), name="flow_detail"),
    path("stages/", views.StageList.as_view(), name="stage_list"),
    path("stages/<pk>", views.StageDetail.as_view(), name="stage_detail"),
    path("users/", views.UserList.as_view(), name="user_list"),
    path("users/<pk>", views.UserDetail.as_view(), name="user_detail"),
    path("titles/", views.TitleList.as_view(), name="title_list"),
    path("titles/<pk>", views.TitleDetail.as_view(), name="title_detail"),
    path("flows_status/", views.FlowStatusList.as_view(), name="flow_status_list"),
    path("flows_status/<pk>", views.FlowStatusDetail.as_view(), name="flow_status_detail"),
    path("proj_signoffs/", views.ProjSignoffList.as_view(), name="proj_signoff_list")
]

urlpatterns = format_suffix_patterns(urlpatterns)
