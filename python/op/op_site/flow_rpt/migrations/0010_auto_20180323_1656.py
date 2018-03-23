# Generated by Django 2.0.3 on 2018-03-23 08:56

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('flow_rpt', '0009_auto_20180321_1626'),
    ]

    operations = [
        migrations.AlterField(
            model_name='block',
            name='name',
            field=models.CharField(max_length=50),
        ),
        migrations.AlterField(
            model_name='flow',
            name='name',
            field=models.CharField(max_length=100),
        ),
        migrations.AlterField(
            model_name='proj',
            name='name',
            field=models.CharField(max_length=50, unique=True),
        ),
        migrations.AlterField(
            model_name='stage',
            name='name',
            field=models.CharField(max_length=200),
        ),
        migrations.AlterField(
            model_name='stage',
            name='version',
            field=models.CharField(max_length=50),
        ),
    ]