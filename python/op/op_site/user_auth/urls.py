"""project checker url"""
from django.urls import include, path
from rest_framework.urlpatterns import format_suffix_patterns
from . import views

app_name = "user_auth"
urlpatterns = [
    path("check/", views.UserCheck.as_view(), name="check"),
]

urlpatterns = format_suffix_patterns(urlpatterns)
