# -*- coding: utf-8 -*-
# Generated by Django 1.11.3 on 2017-08-02 01:51
from __future__ import unicode_literals

from django.db import migrations


class Migration(migrations.Migration):

    dependencies = [
        ('pj_app', '0002_auto_20170801_1429'),
    ]

    operations = [
        migrations.RemoveField(
            model_name='dcchkdsggroup',
            name='run',
        ),
        migrations.RemoveField(
            model_name='dcchkdsgrpt',
            name='group',
        ),
        migrations.RemoveField(
            model_name='dcclkgaterpt',
            name='run',
        ),
        migrations.DeleteModel(
            name='DcChkDsgGroup',
        ),
        migrations.DeleteModel(
            name='DcChkDsgRpt',
        ),
        migrations.DeleteModel(
            name='DcClkGateRpt',
        ),
    ]
