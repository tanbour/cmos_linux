"""project checker url"""
from django.urls import include, path
from rest_framework.urlpatterns import format_suffix_patterns
from . import views

app_name = "job_sum"
urlpatterns = [
    path("runner/jobs/", views.RunnerJobs.as_view(), name="runner_jobs"),
    path("runner/servers/", views.RunnerServers.as_view(), name="runner_servers"),
    path("jobs/", views.JobList.as_view(), name="job_list"),
    path("servers/", views.ServerList.as_view(), name="server_list"),
]

urlpatterns = format_suffix_patterns(urlpatterns)
