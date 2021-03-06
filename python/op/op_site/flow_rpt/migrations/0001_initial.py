# Generated by Django 2.0.3 on 2018-03-12 09:27

import django.contrib.postgres.fields.jsonb
from django.db import migrations, models
import django.db.models.deletion


class Migration(migrations.Migration):

    initial = True

    dependencies = [
    ]

    operations = [
        migrations.CreateModel(
            name='Block',
            fields=[
                ('id', models.AutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('name', models.CharField(max_length=20)),
                ('data', django.contrib.postgres.fields.jsonb.JSONField(blank=True, default=dict)),
            ],
        ),
        migrations.CreateModel(
            name='Flow',
            fields=[
                ('id', models.AutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('name', models.CharField(max_length=50)),
                ('created_time', models.DateTimeField()),
                ('status', models.CharField(max_length=20)),
                ('data', django.contrib.postgres.fields.jsonb.JSONField(blank=True, default=dict)),
                ('block', models.ForeignKey(on_delete=django.db.models.deletion.CASCADE, related_name='flow_block', to='flow_rpt.Block')),
            ],
        ),
        migrations.CreateModel(
            name='Proj',
            fields=[
                ('id', models.AutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('name', models.CharField(max_length=20, unique=True)),
                ('data', django.contrib.postgres.fields.jsonb.JSONField(blank=True, default=dict)),
            ],
        ),
        migrations.CreateModel(
            name='Stage',
            fields=[
                ('id', models.AutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('name', models.CharField(max_length=50)),
                ('created_time', models.DateTimeField()),
                ('status', models.CharField(max_length=20)),
                ('version', models.CharField(max_length=20)),
                ('data', django.contrib.postgres.fields.jsonb.JSONField(blank=True, default=dict)),
                ('flow', models.ForeignKey(on_delete=django.db.models.deletion.CASCADE, related_name='stage_flow', to='flow_rpt.Flow')),
            ],
        ),
        migrations.CreateModel(
            name='Title',
            fields=[
                ('id', models.AutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('proj', django.contrib.postgres.fields.jsonb.JSONField(blank=True, default=list)),
                ('block', django.contrib.postgres.fields.jsonb.JSONField(blank=True, default=list)),
                ('flow', django.contrib.postgres.fields.jsonb.JSONField(blank=True, default=list)),
                ('stage', django.contrib.postgres.fields.jsonb.JSONField(blank=True, default=list)),
            ],
        ),
        migrations.CreateModel(
            name='User',
            fields=[
                ('id', models.AutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('name', models.CharField(max_length=20, unique=True)),
                ('data', django.contrib.postgres.fields.jsonb.JSONField(blank=True, default=dict)),
            ],
        ),
        migrations.AddField(
            model_name='stage',
            name='owner',
            field=models.ForeignKey(on_delete=django.db.models.deletion.CASCADE, related_name='stage_owner', to='flow_rpt.User'),
        ),
        migrations.AddField(
            model_name='proj',
            name='owner',
            field=models.ForeignKey(blank=True, null=True, on_delete=django.db.models.deletion.CASCADE, related_name='proj_owner', to='flow_rpt.User'),
        ),
        migrations.AddField(
            model_name='flow',
            name='owner',
            field=models.ForeignKey(on_delete=django.db.models.deletion.CASCADE, related_name='flow_owner', to='flow_rpt.User'),
        ),
        migrations.AddField(
            model_name='block',
            name='milestone',
            field=models.ForeignKey(blank=True, null=True, on_delete=django.db.models.deletion.SET_NULL, related_name='block_milestone', to='flow_rpt.Stage'),
        ),
        migrations.AddField(
            model_name='block',
            name='owner',
            field=models.ForeignKey(blank=True, null=True, on_delete=django.db.models.deletion.CASCADE, related_name='block_owner', to='flow_rpt.User'),
        ),
        migrations.AddField(
            model_name='block',
            name='proj',
            field=models.ForeignKey(on_delete=django.db.models.deletion.CASCADE, related_name='block_proj', to='flow_rpt.Proj'),
        ),
        migrations.AlterUniqueTogether(
            name='block',
            unique_together={('name', 'proj')},
        ),
    ]
