#!/bin/csh

########################################################################
# PROGRAM:     check_eda_tech_file.csh
# CREATOR:     Daniel Wen <danielw@alchip.com>
# DATE:        Fri Mar 17 13:46:01 CST 2017
# DESCRIPTION: Extract EDA version and tech files from EDA log file
#	       Need to define the EDA run directory
# USAGE:       ./check_eda_tech_file.csh
########################################################################

set REDHAWK_DIR = /proj/Baron/WORK/jeasonc/RedHawk/BaronIo_03080
set REDHAWK_DIR = /proj/PS02_ES2/WORK/yangw/REDHAWK/static/ES3_0314_fullchip/
set HSPICE_DIR  =
set STARRC_DIR  = /proj/Baron/WORK/vincentl/STARRC/try
set PIPO_LOG_DIR    = /proj/Baron/WORK/romains/PV/virtuoso_lib/
set CALIBRE_DRC_DIR = /proj/Baron/WORK/romains/PV/IP/AFE/drc
set CALIBRE_LVS_DIR = /proj/Baron/WORK/romains/PV/IP/AFE/lvs
set CALIBRE_ANT_DIR = /proj/Baron/WORK/romains/PV/IP/AFE/ant
set CALIBRE_DFM_DIR =

#1. REDHAWK check
echo "1. REDHAWK check" > eda_tech_file.rep
if ($REDHAWK_DIR == "") then
   echo "    WARNING: no REDHAWK run dir provided, skip" >> eda_tech_file.rep
else
   if (!(-e ${REDHAWK_DIR})) then
       echo "    WARNING: defined REDHAWK run dir not found, please check." >> eda_tech_file.rep
   else
       set RH_LOG = `find ${REDHAWK_DIR} | grep '/redhawk.log$'`
       if ( $RH_LOG == "") then
            echo "    WARNING: no redhawk.log found in run dir, skip:" >> eda_tech_file.rep
            echo "    	${REDHAWK_DIR}" >> eda_tech_file.rep
       else
            echo "checking REDHAWK EDA/Tech..."
            #	echo "    Log file        : ${RH_LOG}" >> eda_tech_file.rep
            set RH_VERSION = `cat ${RH_LOG}| grep '^RedHawk' | grep -v ended | awk '{print $2}'`
            set RH_TECH    = `cat ${RH_LOG}| grep '^File name is' | grep tech | awk '{print $4}'`
            echo "    REDHAWK version : ${RH_VERSION}" >> eda_tech_file.rep
            echo "    REDHAWK techfile: ${RH_TECH}"    >> eda_tech_file.rep
       endif
   endif
endif

#2. STARRC check
echo "2. STARRC check" >> eda_tech_file.rep
echo "checking STARRC EDA/Tech..."
if ($STARRC_DIR == "") then
   echo "    WARNING: no STARRC run dir provided, skip" >> eda_tech_file.rep
else
   if (!(-e ${STARRC_DIR})) then
       echo "    WARNING: defined STARRC run dir not found, please check." >> eda_tech_file.rep
   else
       set STAR_SUM        = `find $STARRC_DIR | grep '.star_sum$'`
       if ( $STAR_SUM[1] == "") then
            echo "    WARNING: no STARRC .star_sum found" >> eda_tech_file.rep
       else
              set STAR_TECH_LOG   = `find $STARRC_DIR | grep 'tech_file.asc$'`
              set STAR_TECH_SET   = `find $STARRC_DIR | grep 'xtract.tech$'`
              if ( $STAR_TECH_LOG[1] == "") then
                 echo "    WARNING: no STARRC .tech_file.asc found" >> eda_tech_file.rep
              else
                 set STAR_VERSION    = `grep '^Version' ${STAR_SUM} | awk '{print $2}' | sort -u`
                 set STAR_TECH_FILES = `grep tcad_file $STAR_TECH_SET | perl -p -i -e "s#.*tcad_file##g"`
                 set STAR_MAP_FILES = `grep MAPPING_FILE $STAR_TECH_LOG | awk '{print $2}' | sort -u`
                 #if ( $#STAR_VERSION > 1 ) then
            	 #    echo "    Error: multiple STARRC versions: ${STAR_VERSION}" >> eda_tech_file.rep
                 #else
            	     echo "    STARRC version  : $STAR_VERSION" >> eda_tech_file.rep
            	     echo "    STARRC nxgrd    :" >> eda_tech_file.rep
            	     foreach grd ( $STAR_TECH_FILES )
            	        echo "    	$grd" >> eda_tech_file.rep
            	     end
            	     echo "    STARRC mapfile  :" >> eda_tech_file.rep
            	     echo "    	$STAR_MAP_FILES" >> eda_tech_file.rep
                 #endif
              endif
        endif
   endif
endif

#3. HSPICE check
echo "3. HSPICE check" >> eda_tech_file.rep
echo "checking HSPICE EDA/Tech..."
if ($HSPICE_DIR == "") then
   echo "    WARNING: no HSPICE run dir provided, skip" >> eda_tech_file.rep
else
   if (!(-e ${HSPICE_DIR})) then
       echo "    WARNING: defined HSPICE run dir not found, please check." >> eda_tech_file.rep
   else
       set HSPICE_VERSION = `grep 'HSPICE' ${HSPICE_DIR}/* | grep '1\*\*' | awk '{print $4}' | sort -u`
       set HSPICE_TECH    = `grep '^\.lib' ${HSPICE_DIR}/* | awk '{print $2}' | sort -u | perl -p -i -e "s#'##g"`
       echo "    HSPICE version : $HSPICE_VERSION" >> eda_tech_file.rep
       echo "    HSPICE techfile: $HSPICE_TECH" >> eda_tech_file.rep
   endif
endif


#4. PIPO(Virtuoso Strmin/Strmout) check
echo "4. PIPO(Virtuoso Strmin/Strmout) check" >> eda_tech_file.rep
echo "checking PIPO EDA/Tech..."
if ($PIPO_LOG_DIR == "") then
   echo "    WARNING: no PIPO LOG dir provided, skip" >> eda_tech_file.rep
else
   if (!(-e ${PIPO_LOG_DIR})) then
       echo "    WARNING: defined PIPO LOG dir not found, please check." >> eda_tech_file.rep
   else
       set PIPO_LOG = `find $PIPO_LOG_DIR | egrep '\.LOG|\.log'`
       set VIRTUOSO_VERSION = `grep sub-version $PIPO_LOG | awk '{print $4}' | sort -u`
       set VIRTUOSO_TECH        = `grep loadTechFile $PIPO_LOG | awk '{print $3}' | sort -u`
       set VIRTUOSO_MAP         = `grep layerMap $PIPO_LOG | awk '{print $3}' | sort -u`
       echo "    VIRTUOSO version : $VIRTUOSO_VERSION" >> eda_tech_file.rep
       echo "    VIRTUOSO techfile: $VIRTUOSO_TECH" >> eda_tech_file.rep
       echo "    VIRTUOSO layermap: $VIRTUOSO_MAP" >> eda_tech_file.rep
   endif
endif

#5. Calibre check
echo "5. Caliber check" >> eda_tech_file.rep
echo "checking Calibre EDA/Tech..."
if ($CALIBRE_DRC_DIR == "") then
   echo "    WARNING: no Caliber DRC run dir provided, skip" >> eda_tech_file.rep
else
   if (!(-e ${CALIBRE_DRC_DIR})) then
       echo "    WARNING: defined Caliber DRC run dir not found, please check." >> eda_tech_file.rep
   else
       set CALIBRE_DRC_LOG     = `find $CALIBRE_DRC_DIR | grep 'calibre.log$'`
       set CALIBRE_DRC_VERSION = `cat $CALIBRE_DRC_LOG | grep '//  Calibre v' | awk '{print $3}'`
       set CALIBRE_DRC_DECK    = `cat $CALIBRE_DRC_LOG | grep '^include' | awk '{print $2}'`
       echo "    CALIBRE DRC version  : $CALIBRE_DRC_VERSION" >> eda_tech_file.rep
       echo "    CALIBRE DRC rule deck: $CALIBRE_DRC_DECK" >> eda_tech_file.rep
   endif
endif

if ($CALIBRE_ANT_DIR == "") then
   echo "    WARNING: no Caliber ANT run dir provided, skip" >> eda_tech_file.rep
else
   if (!(-e ${CALIBRE_ANT_DIR})) then
       echo "    WARNING: defined Caliber ANT run dir not found, please check." >> eda_tech_file.rep
   else
       set CALIBRE_ANT_LOG     = `find $CALIBRE_ANT_DIR | grep 'calibre.log$'`
       set CALIBRE_ANT_VERSION = `cat $CALIBRE_ANT_LOG | grep '//  Calibre v' | awk '{print $3}'`
       set CALIBRE_ANT_DECK    = `cat $CALIBRE_ANT_LOG | grep '^include' | awk '{print $2}'`
       echo "    CALIBRE ANT version  : $CALIBRE_ANT_VERSION" >> eda_tech_file.rep
       echo "    CALIBRE ANT rule deck: $CALIBRE_ANT_DECK" >> eda_tech_file.rep
   endif
endif

if ($CALIBRE_LVS_DIR == "") then
   echo "    WARNING: no Caliber LVS run dir provided, skip" >> eda_tech_file.rep
else
   if (!(-e ${CALIBRE_ANT_DIR})) then
       echo "    WARNING: defined Caliber ANT run dir not found, please check." >> eda_tech_file.rep
   else
       set CALIBRE_LVS_LOG     = `find $CALIBRE_LVS_DIR | grep 'calibre.log$'`
       set CALIBRE_LVS_VERSION = `cat $CALIBRE_LVS_LOG | grep '\/\/  Calibre v' | awk '{print $3}'`
       set CALIBRE_LVS_DECK    = `cat $CALIBRE_LVS_LOG | grep '^include' | awk '{print $2}'`
       echo "    CALIBRE LVS version  : $CALIBRE_LVS_VERSION" >> eda_tech_file.rep
       echo "    CALIBRE LVS rule deck: $CALIBRE_LVS_DECK" >> eda_tech_file.rep
   endif
endif

echo ""
echo "eda_tech_file.rep:"
cat eda_tech_file.rep
#END
