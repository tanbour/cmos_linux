from rest_framework import views
from rest_framework.response import Response
from rest_framework import status
from rest_framework import generics
from .models import User, Queue, Job, Host, Proj, Slot, Cpu, Mem
from .serializers import UserSerializer, QueueSerializer, JobSerializer, HostSerializer, ProjSerializer, SlotSerializer, CpuSerializer
import time

# Create your views here.
class RunnerJobs(views.APIView):
    """runner platform post job info"""
    def post(self, request, format=None):
        for data_dic in request.data:
            job_name = data_dic.get("job_id")
            queue_name = data_dic.get("queue")
            owner_name = data_dic.get("user")
            status = data_dic.get("status")
            # created_time = pytz.timezone(settings.TIME_ZONE).localize(dateutil.parser.parse(
            #     created_time) if created_time else tz.datetime.now())
            if not job_name:
                return Response({"message": "job name is NA"}, status=status.HTTP_400_BAD_REQUEST)
            if not queue_name:
                return Response({"message": "queue name is NA"}, status=status.HTTP_400_BAD_REQUEST)
            if not owner_name:
                return Response({"message": "owner name is NA"}, status=status.HTTP_400_BAD_REQUEST)
            if not status:
                return Response({"message": "job status is NA"}, status=status.HTTP_400_BAD_REQUEST)
            owner_obj, _ = User.objects.get_or_create({"name": owner_name}, name=owner_name)
            queue_obj, _ = Queue.objects.get_or_create({"name": queue_name}, name=queue_name)
            job_obj, created_flg = Job.objects.update_or_create(
                {"name": job_name, "queue": queue_obj, "owner": owner_obj,
                 "status": status, "data": data_dic.get("data", {})},
                name=job_name)
        return Response({"message": "filling db with jobs done"})

class JobList(generics.ListAPIView):
    """job list"""
    queryset = Job.objects.all()
    serializer_class = JobSerializer
    def get_queryset(self, *args, **kwargs):
        queryset = self.queryset.order_by("-name")
        if not queryset:
            return queryset
        bt = self.request.GET.get("bt")
        et = self.request.GET.get("et")
        if not bt or not et:
            et = queryset.first().data.get("submit_time", int(time.time()))
            bt = et - 24*3600
        else:
            if bt.isdigit:
                bt = int(bt)
            else:
                return Response({"message": f"get para bt is not digit"}, status=status.HTTP_400_BAD_REQUEST)
            if et.isdigit:
                et = int(et)
            else:
                return Response({"message": f"get para et is not digit"}, status=status.HTTP_400_BAD_REQUEST)
        qs_lst = []
        for job_obj in queryset:
            j_s_t = job_obj.data.get("submit_time", 0)
            if j_s_t > bt and j_s_t <= et:
                qs_lst.append(job_obj)
        return qs_lst

class RunnerServers(views.APIView):
    """runner platform post server info"""
    def post(self, request, format=None):
        for data_dic in request.data:
            name = data_dic.get("name")
            freq = data_dic.get("freq")
            ram = data_dic.get("ram")
            total_slots = data_dic.get("total_slots")
            run_slots = data_dic.get("run_slots")
            slot_ut = data_dic.get("slot_ut")
            group = data_dic.get("group")
            status = data_dic.get("status")
            queue_lst = data_dic.get("queue")
            cpu = data_dic.get("cpu")
            mem = data_dic.get("mem")
            proj = data_dic.get("proj")
            # created_time = pytz.timezone(settings.TIME_ZONE).localize(dateutil.parser.parse(
            #     created_time) if created_time else tz.datetime.now())
            if not name:
                return Response({"message": "host name is NA"}, status=status.HTTP_400_BAD_REQUEST)
            if not cpu:
                return Response({"message": "cpu usage is NA"}, status=status.HTTP_400_BAD_REQUEST)
            if not mem:
                return Response({"message": "mem usage is NA"}, status=status.HTTP_400_BAD_REQUEST)
            host_obj, created_flg = Host.objects.update_or_create(
                {"name": name, "freq": freq, "ram": ram, "t_slot": total_slots, "group": group,
                 "status": status},
                name=name)
            for queue in queue_lst:
                queue_obj, created_flg = Queue.objects.get_or_create({"name": queue}, name=queue)
                queue_obj.host.add(host_obj)
            # proj_obj, created_flg = Proj.objects.get_or_create({"name": proj}, name=proj)
            # proj_obj.host.add(host_obj)
            Cpu.objects.create(value=cpu, host=host_obj)
            Slot.objects.create(value=slot_ut, host=host_obj)
            Mem.objects.create(value=mem, host=host_obj)
        return Response({"message": "filling db with hosts done"})

class ServerList(generics.ListAPIView):
    """server list"""
    queryset = Host.objects.all()
    serializer_class = HostSerializer
