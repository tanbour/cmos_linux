# ICC2 db lib----------------------------------------------------------------------
{%- set sn = local._multi_inst.upper().split('.') %}
{%- set sn_std_new = ['DB_STD', sn[1], sn[2]]|join('_') %}
{%- set sn_mem_new = ['DB_MEM', sn[1], sn[2]]|join('_') %}
{%- set sn_ip_new = ['DB_IP', sn[1], sn[2]]|join('_') %}
{%- set sn_io_new = ['DB_IO', sn[1], sn[2]]|join('_') %}
set DB_STD_{{sn[1]}}_{{sn[2]}}  "{{liblist[sn_std_new]}}"
set DB_MEM_{{sn[1]}}_{{sn[2]}}  "{{liblist[sn_mem_new]}}"
set DB_IP_{{sn[1]}}_{{sn[2]}}  "{{liblist[sn_ip_new]}}"
set DB_IO_{{sn[1]}}_{{sn[2]}}  "{{liblist[sn_io_new]}}"

# ICC2 AOCV table----------------------------------------------------------------------
{%- if local.ENABLE_AOCV == "true" %}
{%- set sn = local._multi_inst.upper().split('.') %}
{%- set sn_new = ['AOCV', sn[1], sn[2], sn[4]]|join('_') %}
set AOCV_{{sn[1]}}_{{sn[2]}}_{{sn[4]}}  "{{liblist[sn_new]}}"
{%- endif %}

# ICC2 POCV table----------------------------------------------------------------------
{%- if local.ENABLE_POCV == "true" %}
{%- set sn = local._multi_inst.upper().split('.') %}
{%- set sn_new = ['POCV', sn[1], sn[2]]|join('_') %}
set POCV_{{sn[1]}}_{{sn[2]}}}}  "{{liblist[sn_new]}}"
{%- endif %}
