from django.conf import settings
from rest_framework import views
from rest_framework.response import Response
from rest_framework import status
import pam

class UserCheck(views.APIView):
    """ldap user auth check"""
    def post(self, request):
        user = request.data.get("user")
        password = request.data.get("password")
        pam_p = pam.pam()
        if not pam_p.authenticate(user, password):
            return Response({"message": f"user {user} is unauthorized"}, status=status.HTTP_401_UNAUTHORIZED)
        return Response({"check_flg": True})
