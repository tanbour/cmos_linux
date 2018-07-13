from rest_framework import serializers
from .models import User, Queue, Job, Proj, Host, Cpu, Slot, Mem
from django.conf import settings
from django.utils import timezone as tz
import pytz

class JobSerializer(serializers.ModelSerializer):
    class Meta:
        model = Job
        fields = ("id", "name", "owner", "queue", "status", "data")
        depth = 1

class QueueSerializer(serializers.ModelSerializer):
    class Meta:
        model = Queue
        fields = ("id", "name")

class UserSerializer(serializers.ModelSerializer):
    job_owner = JobSerializer(many=True, read_only=True)
    class Meta:
        model = User
        fields = ("id", "name", "data", "job_owner")

class CpuSerializer(serializers.ModelSerializer):
    class Meta:
        model = Cpu
        fields = ("value", "time", "host")

class SlotSerializer(serializers.ModelSerializer):
    class Meta:
        model = Slot
        fields = ("value", "time", "host")

class MemSerializer(serializers.ModelSerializer):
    class Meta:
        model = Mem
        fields = ("value", "time")

class ProjSerializer(serializers.ModelSerializer):
    class Meta:
        model = Proj
        fields = ("id", "name", "data")

class HostSerializer(serializers.ModelSerializer):
    cpu_host = serializers.SerializerMethodField()
    slot_host = serializers.SerializerMethodField()
    mem_host = serializers.SerializerMethodField()
    # cpu_host = CpuSerializer(many=True, read_only=True)
    # slot_host = SlotSerializer(many=True, read_only=True)
    # mem_host = MemSerializer(many=True, read_only=True)
    queue_host = QueueSerializer(many=True, read_only=True)
    proj_host = ProjSerializer(many=True, read_only=True)
    class Meta:
        model = Host
        fields = ("id", "name", "freq", "ram", "t_slot", "group", "status",
                  "cpu_host", "slot_host","mem_host", "queue_host", "proj_host")
        depth = 1
    def gen_bt_et(self, q_s):
        b_t = self.context["request"].GET.get("bt")
        e_t = self.context["request"].GET.get("et")
        if not b_t or not e_t:
            e_t = q_s.order_by("-time").first().time
            b_t = e_t - tz.timedelta(days=1)
        else:
            e_t = pytz.timezone(settings.TIME_ZONE).localize(tz.datetime.fromtimestamp(int(e_t)))
            b_t = pytz.timezone(settings.TIME_ZONE).localize(tz.datetime.fromtimestamp(int(b_t)))
        return b_t, e_t
    def get_cpu_host(self, host_obj):
        queryset = Cpu.objects.filter(host=host_obj)
        b_t, e_t = self.gen_bt_et(queryset)
        queryset = queryset.filter(time__gt=b_t, time__lte=e_t).order_by("-time")
        serializer = CpuSerializer(instance=queryset, many=True, read_only=True)
        return serializer.data
    def get_slot_host(self, host_obj):
        queryset = Slot.objects.filter(host=host_obj)
        b_t, e_t = self.gen_bt_et(queryset)
        queryset = queryset.filter(time__gt=b_t, time__lte=e_t).order_by("-time")
        serializer = SlotSerializer(instance=queryset, many=True, read_only=True)
        return serializer.data
    def get_mem_host(self, host_obj):
        queryset = Mem.objects.filter(host=host_obj)
        b_t, e_t = self.gen_bt_et(queryset)
        queryset = queryset.filter(time__gt=b_t, time__lte=e_t).order_by("-time")
        serializer = MemSerializer(instance=queryset, many=True, read_only=True)
        return serializer.data
