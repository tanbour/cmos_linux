# Generated by Django 2.0.4 on 2018-04-18 06:50

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('flow_rpt', '0010_auto_20180323_1656'),
    ]

    operations = [
        migrations.AddField(
            model_name='user',
            name='proj_admin',
            field=models.ManyToManyField(related_name='user_proj', to='flow_rpt.Proj'),
        ),
    ]
