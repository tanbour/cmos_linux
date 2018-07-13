# /bin/csh 
set work_dir = `pwd`
set ck = 0
set topname = `ls $work_dir/adsRpt/*.PinInst.unconnect.logic | sed "s?.PinInst.unconnect.logic??g" | sed "s?$work_dir/adsRpt/??g"`
if ( $1 != "") then
   if ( -e $1 ) then
      set work_dir = $1
   else
      echo "NOT exists dir"
      exit
   endif
endif
#check setup data
if ( -e $work_dir/adsRpt/apache.refCell.noLefLib ) then
   echo "please check :  ../adsRpt/apache.refCell.noLefLib"
   set ck = 1
endif
if ( -e $work_dir/adsRpt/apache.refCell.noLib ) then
   echo "please check :  ../adsRpt/apache.refCell.noLib"
   set ck = 1
endif
if ( -e $work_dir/adsRpt/apache.noLibPins ) then
   echo "please check :  ../adsRpt/apache.noLibPins"
   set ck = 1
endif
if ( -e $work_dir/adsRpt/apache.refCell.noLef ) then
   echo "please check :  ../adsRpt/apache.refCell.noLef"
   set ck = 1
endif
if ( -e $work_dir/adsRpt/apache.noLefPins ) then
   echo "please check :  ../adsRpt/apache.noLefPins"
   set ck = 1
endif
if ( -e $work_dir/adsRpt/apache.rcBogus ) then
   echo "please check :  ../adsRpt/apache.rcBogus"
   set ck = 1
endif
if ( -e $work_dir/adsRpt/apache.staBogus ) then
   echo "please check :  ../adsRpt/apache.staBogus"
   set ck = 1
endif
if ( -e $work_dir/adsRpt/apache.refCell.noPGArc ) then
   echo "please check :  ../adsRpt/apache.refCell.noPGArc"
   set ck = 1
endif
if ( -e $work_dir/adsRpt/shorts.rpt ) then
   if ( `ls -l $work_dir/adsRpt/shorts.rpt | awk '{print $5}'` != 0 ) then
      echo "please check :  ../adsRpt/shorts.rpt"
      set ck = 1
   endif
endif
if ( `ls -l $work_dir/adsRpt/*.PinInst.unconnect.logic | awk '{print $5}'` != 101 ) then
   echo "please check :  ../adsRpt/${topname}.PinInst.unconnect.logic"
   set ck = 1
endif
if ( -e $work_dir/adsRpt/${topname}.PinInst.unconnect ) then
   if (`ls -l $work_dir/adsRpt/${topname}.PinInst.unconnect | awk '{print $5}'` != 0 ) then
      echo "please check :  ../adsRpt/${topname}.PinInst.unconnect"
      set ck = 1
   endif
endif
if ( -e $work_dir/adsRpt/${topname}.power.unused ) then
   if (`ls -l $work_dir/adsRpt/${topname}.power.unused | awk '{print $5}'` != 152 ) then
      echo "please check :  ../adsRpt/${topname}.power.unused"
      set ck = 1
   endif
endif
if ( -e $work_dir/adsRpt/${topname}.Via.unconnect ) then
   if (`ls -l $work_dir/adsRpt/${topname}.Via.unconnect | awk '{print $5}'` != 0 ) then
      echo "please check :  ../adsRpt/${topname}.Via.unconnect"
      set ck = 1
   endif
endif
if ( -e $work_dir/adsRpt/${topname}.Wire.unconnect ) then
   if (`ls -l $work_dir/adsRpt/${topname}.Wire.unconnect | awk '{print $5}'` != 0 ) then
      echo "please check :  ../adsRpt/${topname}.Wire.unconnect"
      set ck = 1
   endif
endif
if ( -e $work_dir/adsRpt/${topname}.Via.partial_connect ) then
   if (`ls -l $work_dir/adsRpt/${topname}.Via.partial_connect | awk '{print $5}'` != 0 ) then
      echo "please check :  ../adsRpt/${topname}.Via.partial_connect"
      set ck = 1
   endif
endif
if ( -e $work_dir/adsRpt/${topname}.Instance.unconnect ) then
   if ( `ls -l $work_dir/adsRpt/${topname}.Instance.unconnect | awk '{print $5}'` != 86 ) then
      echo "please check :  ../adsRpt/${topname}.Instance.unconnect"
      set ck = 1
   endif
endif
if ($ck == 0) then
   echo "redhawk power result no problem"
endif
