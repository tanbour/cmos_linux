## -----------------------------------------------------------------------------
## HEADER $Id: procs.tcl,v 1.1 2012/06/15 14:00:10 hiroyukih___jp.sony.com Exp $
## HEADER_MSG    Lynx Design System: Production Flow
## HEADER_MSG    Version 2010.12-SP5
## HEADER_MSG    Copyright (c) 2011 Synopsys
## HEADER_MSG    Perforce Label: lynx_flow_2010.12-SP5
## HEADER_MSG 
## -----------------------------------------------------------------------------
## DESCRIPTION:
## * This file contains Lynx procedure definitions.
## -----------------------------------------------------------------------------

## -----------------------------------------------------------------------------
## These procedures/variables are not uniformly available
## for all tools used in the flow. This section of code creates
## the procedures/variables if they are not available.
## -----------------------------------------------------------------------------

if { ![info exists synopsys_root] } {
  set synopsys_root "synopsys_root"
}

if { ![info exists synopsys_program_name] } {
  set synopsys_program_name "tcl"
}

if { $synopsys_program_name == "tcl" } {
  set sh_product_version [info patchlevel]
}

if { [info command date] != "date" } {
  proc date {} {
    return [clock format [clock seconds] -format {%a %b %e %H:%M:%S %Y}]
  }
}

if { [info command parse_proc_arguments] != "parse_proc_arguments" } {

  proc parse_proc_arguments { required_switch args options_ref } {

    global define_proc_attributes_booleans

    upvar $options_ref options

    set parent_level [expr [info level] - 1]
    set parent_name [lindex [info level $parent_level] 0]
    set parent_name [regsub {^::} $parent_name {}]

    if { $required_switch == "-args" } {
      for { set i 0 } { $i < [llength $args] } { incr i } {
        set arg [lindex $args $i]
        if { [lsearch $define_proc_attributes_booleans($parent_name) $arg] >= 0 } {
          ## This is a boolean switch
          set options($arg) 1
        } else {
          ## This is not a boolean switch
          incr i
          set options($arg) [lindex $args $i]
        }
      }
    }
  }

}

if { [info command define_proc_attributes] != "define_proc_attributes" } {

  unset -nocomplain define_proc_attributes_booleans

  proc define_proc_attributes args {

    global define_proc_attributes_booleans

    set proc_name ""
    set proc_args [list]

    for { set i 0 } { $i < [llength $args] } { incr i } {
      set arg [lindex $args $i]
      if { $i == 0 } {
        set proc_name $arg
        continue
      }
      switch -- $arg {
        -info {
          incr i
          continue
        }
        -hidden {
          continue
        }
        -define_args {
          incr i
          set proc_args [lindex $args $i]
        }
        default {
          puts stderr "Error: define_proc_attributes: Unrecognized argument: $arg"
        }
      }
    }

    if { $proc_name != "" } {
      set define_proc_attributes_booleans($proc_name) [list]
      foreach proc_arg $proc_args {
        set switch_name [lindex $proc_arg 0]
        set switch_type [lindex $proc_arg end-1]
        if { $switch_type == "boolean" } {
          lappend define_proc_attributes_booleans($proc_name) $switch_name
        }
      }
    } else {
      puts stderr "Error: define_proc_attributes: Procedure name not defined."
    }

  }

}

## -----------------------------------------------------------------------------
## sproc_msg:
## -----------------------------------------------------------------------------

proc sproc_msg { args } {

  ## Assigning default value of "bell" since that is never used.

  set options(-info)    "\b"
  set options(-warning) "\b"
  set options(-error)   "\b"
  set options(-setup)   "\b"
  set options(-issue)   "\b"
  set options(-header)  0
  parse_proc_arguments -args $args options

  if       { $options(-info)   != "\b" } {
    puts "SNPS_INFO   : $options(-info)"
  } elseif { $options(-warning) != "\b" } {
    puts "SNPS_WARNING: $options(-warning)"
  } elseif { $options(-error)  != "\b" } {
    puts "SNPS_ERROR  : $options(-error)"
  } elseif { $options(-setup)  != "\b" } {
    puts "SNPS_SETUP  : $options(-setup)"
  } elseif { $options(-issue)  != "\b" } {
    puts "SNPS_ISSUE  : $options(-issue)"
  } elseif { $options(-header) } {
    puts "SNPS_HEADER : ## ------------------------------------- "
  } else {
    puts "SNPS_ERROR  : Unrecognized arguments for sproc_msg : $args"
  }
}

define_proc_attributes sproc_msg \
  -info "Standard message printing procedure." \
  -define_args {
  {-info    "Info message"    AString string optional}
  {-warning "Warning message" AString string optional}
  {-error   "Error message"   AString string optional}
  {-setup   "Setup message"   AString string optional}
  {-issue   "Issue message"   AString string optional}
  {-header  "Header flag"     ""      boolean optional}
}

## -----------------------------------------------------------------------------
## sproc_source:
## -----------------------------------------------------------------------------

proc sproc_source { args } {

  global synopsys_program_name

  set options(-file) ""
  set options(-quiet) 0
  set options(-optional) 0
  parse_proc_arguments -args $args options

  if { [llength $options(-file)] > 0 } {
    ## The file specification is not empty.
    foreach file $options(-file) {
      if { [ file exists $file ] } {
        sproc_msg -info "SCRIPT_START : [file normalize $file]"
        if { $synopsys_program_name == "tcl" } {
          uplevel 1 source $file
        } elseif { $synopsys_program_name == "cdesigner" } {
          uplevel 1 source $file
        } else {
          if { $options(-quiet) } {
            uplevel 1 source $file
          } else {
            uplevel 1 source -e -v $file
          }
        }
        sproc_msg -info "SCRIPT_STOP  : [file normalize $file]"
      } else {
        if { $options(-optional) } {
          sproc_msg -warning "sproc_source: The specified file does not exist; '$file'"
        } else {
          sproc_msg -error "sproc_source: The specified file does not exist; '$file'"
        }
      }
    }
  } else {
    ## The file specification is empty.
    if { $options(-optional) } {
      sproc_msg -warning "sproc_source: An empty file specification was provided; file is optional."
    } else {
      sproc_msg -error   "sproc_source: An empty file specification was provided; file is not optional."
    }
  }

}

define_proc_attributes sproc_source \
  -info "Provides a standard way to source files." \
  -define_args {
  {-file "The file to source." AString string required}
  {-quiet "Echo minimal file content." "" boolean optional}
  {-optional "File being sourced is optional." "" boolean optional}
}

## -----------------------------------------------------------------------------
## sproc_broadcast_decision:
## -----------------------------------------------------------------------------

proc sproc_broadcast_decision { args } {

  global env SEV SVAR TEV

  set options(-decision) ""
  parse_proc_arguments -args $args options

  ## Write decision to log file, as a metric.

  sproc_msg -info "METRIC | INTEGER INFO.DECISION | $options(-decision)"

  ## Write decision to dec file.

  set dec_file [file rootname $SEV(log_file)].dec
  set fid [open $dec_file w]
  puts $fid "SNPS_INFO: METRIC | INTEGER INFO.DECISION | $options(-decision)"
  close $fid

}

define_proc_attributes sproc_broadcast_decision \
  -info "Standard procedure for communicating decision information to the RTM." \
  -define_args {
  {-decision "Specifies the decision value to communicate to the RTM." AnInt int required}
}

## -----------------------------------------------------------------------------
## sproc_pinfo:
## -----------------------------------------------------------------------------

proc sproc_pinfo { args } {

  set options(-mode) ""
  parse_proc_arguments -args $args options

  set parent_level [expr [info level] - 1]
  set parent_name [lindex [info level $parent_level] 0]
  set parent_name [regsub {^::} $parent_name {}]

  switch $options(-mode) {
    start   { sproc_msg -info "PROC_START : $parent_name" }
    stop    { sproc_msg -info "PROC_STOP  : $parent_name" }
    default { sproc_msg -error "Invalid argument to sproc_pinfo" }
  }
}

define_proc_attributes sproc_pinfo \
  -info "Prints standard messages at procedure boundaries." \
  -define_args {
  {-mode "Specifies which message to print" AnOos one_of_string
    {required value_help {values {start stop}}}
  }
}

## -----------------------------------------------------------------------------
## sproc_script_start:
## -----------------------------------------------------------------------------

proc sproc_script_start {} {

  global LYNX
  global env SEV SVAR TEV
  global sh_product_version
  global synopsys_program_name

  sproc_metric_time -start
  sproc_metric_system -start_of_script

}

define_proc_attributes sproc_script_start \
  -info "Standard procedure for starting a script." \
  -define_args {
}

## -----------------------------------------------------------------------------
## sproc_script_stop:
## -----------------------------------------------------------------------------

proc sproc_script_stop { args } {

  global LYNX
  global env SEV SVAR TEV
  global sh_product_version
  global synopsys_program_name

  set options(-exit) 0
  parse_proc_arguments -args $args options

  ## -------------------------------------
  ## Generate end-of-script metrics.
  ## -------------------------------------

  sproc_metric_time -stop
  sproc_metric_system -end_of_script

  ## -------------------------------------
  ## Exit processing.
  ## -------------------------------------

  if { $LYNX(rtm_present) } {
    if { $SEV(dont_exit) } {
      ## User is requesting that no exit be performed.
    } else {
      ## Check to see if explicit exit is being requested.
      if { $options(-exit) } {
        exit
      }
    }
  } else {
    exit
  }

}

define_proc_attributes sproc_script_stop \
  -info "Standard procedure for ending a script." \
  -define_args {
  {-exit  "Perform an exit." "" boolean optional}
}

## -----------------------------------------------------------------------------
## sproc_refresh_file_system:
## -----------------------------------------------------------------------------

proc sproc_refresh_file_system { args } {


  global env SEV SVAR TEV

  set options(-dir) ""
  set options(-quiet) 0

  parse_proc_arguments -args $args options

  if { !$options(-quiet) } { sproc_pinfo -mode start }

  if { [file isdirectory $options(-dir)] } {

    if { !$options(-quiet) } { sproc_msg -info "sproc_refresh_file_system: Refreshing directory: '$options(-dir)'" }
    catch { exec ls -al $options(-dir) }

    if { [file writable $options(-dir)] } {
      if { !$options(-quiet) } {  sproc_msg -info "sproc_refresh_file_system: Refreshing directory: '$options(-dir)'" }
      set file $options(-dir)/sproc_refresh_file_system.[pid]
      set fid [open $file w]
      puts $fid "xxx"
      close $fid
      catch { exec rmdir $options(-dir) }
      file delete -force $file
    } else {
      if { !$options(-quiet) } { sproc_msg -warning "sproc_refresh_file_system: The directory specified is not writeable: '$options(-dir)'" }
    }

  } else {
    if { !$options(-quiet) } { sproc_msg -error "sproc_refresh_file_system: The directory specified does not exist: '$options(-dir)'" }
  }

  if { !$options(-quiet) } { sproc_pinfo -mode stop }

}

define_proc_attributes sproc_refresh_file_system \
  -info "Provides a standard way to for an NFS file system refresh." \
  -define_args {
  {-dir "The directory to refresh." AString string required}
  {-quiet  "quiet" "" boolean optional}
}

## -----------------------------------------------------------------------------
## sproc_printvars:
## -----------------------------------------------------------------------------

proc sproc_printvars { args } {

  sproc_pinfo -mode start

  global env SEV SVAR TEV
  global SNPS_tool
  global SNPS_vars_to_print

  set options(-filename) ""
  set options(-tool) 0
  set options(-env) 0
  set options(-SEV) 0
  set options(-SVAR) 0
  set options(-TEV) 0

  parse_proc_arguments -args $args options

  if { $options(-filename) != "" } {
    set fid [open $options(-filename) w]
  } else {
    set fid stdout
  }

  ## -------------------------------------
  ## Define tool variables to print
  ## -------------------------------------

  set SNPS_vars_to_print [list]
  lappend SNPS_vars_to_print search_path
  lappend SNPS_vars_to_print link_library
  lappend SNPS_vars_to_print target_library
  lappend SNPS_vars_to_print synthetic_library

  ## -------------------------------------
  ## Grab variables from the context from which this procedure was invoked.
  ## -------------------------------------

  array set tmp_env  [array get env]
  array set tmp_SEV  [array get SEV]
  array set tmp_SVAR [array get SVAR]
  array set tmp_TEV  [array get TEV]

  uplevel #0 {
    foreach var $SNPS_vars_to_print {
      if { [info exists $var] } {
        eval set SNPS_tool($var) \$$var
      }
    }
  }

  ## -------------------------------------
  ## Now print the variables that were just grabbed.
  ## -------------------------------------

  puts $fid "## [string repeat "-" 77]"
  puts $fid "## Start of variable printing."
  puts $fid "## [string repeat "-" 77]"

  if { $options(-tool) } {
    puts $fid "## [string repeat "-" 77]"
    puts $fid "## Tool variable settings"
    puts $fid "## [string repeat "-" 77]"
    set name_list [lsort [array names SNPS_tool]]
    foreach name $name_list {
      set length [llength $SNPS_tool($name)]
      if { $length == 0 } {
        puts $fid "set $name \"\""
      } elseif { $length == 1 } {
        puts $fid "set $name $SNPS_tool($name)"
      } else {
        puts -nonewline $fid "set $name \{ "
        foreach item $SNPS_tool($name) {
          if { [llength $item] > 1 } {
            puts -nonewline $fid "\{ $item \} "
          } else {
            puts -nonewline $fid "$item "
          }
        }
        puts $fid "\}"
      }
    }
  }

  if { $options(-SEV) } {
    puts $fid "## [string repeat "-" 77]"
    puts $fid "## SEV variable settings"
    puts $fid "## [string repeat "-" 77]"
    set name_list [lsort [array names tmp_SEV]]
    foreach name $name_list {
      set length [llength $tmp_SEV($name)]
      if { $length == 0 } {
        puts $fid "set SEV\($name\) \"\""
      } elseif { $length == 1 } {
        puts $fid "set SEV\($name\) $tmp_SEV($name)"
      } else {
        puts -nonewline $fid "set SEV\($name\) \{ "
        foreach item $tmp_SEV($name) {
          if { [llength $item] > 1 } {
            puts -nonewline $fid "\{ $item \} "
          } else {
            puts -nonewline $fid "$item "
          }
        }
        puts $fid "\}"
      }
    }
  }

  if { $options(-SVAR) } {
    puts $fid "## [string repeat "-" 77]"
    puts $fid "## SVAR variable settings"
    puts $fid "## [string repeat "-" 77]"
    set name_list [lsort [array names tmp_SVAR]]
    foreach name $name_list {

      set length [llength $tmp_SVAR($name)]
      if { $length == 0 } {
        puts $fid "set SVAR\($name\) \"\""
      } elseif { $length == 1 } {

        if { [regexp {\[} $tmp_SVAR($name)] } {
          puts $fid "set SVAR\($name\) \{$tmp_SVAR($name)\}"
        } else {
          puts $fid "set SVAR\($name\) $tmp_SVAR($name)"
        }

      } else {
        puts -nonewline $fid "set SVAR\($name\) \{ "
        foreach item $tmp_SVAR($name) {
          if { [llength $item] > 1 } {
            puts -nonewline $fid "\{ $item \} "
          } else {
            puts -nonewline $fid "$item "
          }
        }
        puts $fid "\}"
      }
    }
  }

  if { $options(-TEV) } {
    puts $fid "## [string repeat "-" 77]"
    puts $fid "## TEV variable settings"
    puts $fid "## [string repeat "-" 77]"
    set name_list [lsort [array names tmp_TEV]]
    foreach name $name_list {
      set length [llength $tmp_TEV($name)]
      if { $length == 0 } {
        puts $fid "set TEV\($name\) \"\""
      } elseif { $length == 1 } {
        puts $fid "set TEV\($name\) $tmp_TEV($name)"
      } else {
        puts -nonewline $fid "set TEV\($name\) \{ "
        foreach item $tmp_TEV($name) {
          if { [llength $item] > 1 } {
            puts -nonewline $fid "\{ $item \} "
          } else {
            puts -nonewline $fid "$item "
          }
        }
        puts $fid "\}"
      }
    }
  }

  if { $options(-env) } {
    puts $fid "## [string repeat "-" 77]"
    puts $fid "## Shell variable settings"
    puts $fid "## [string repeat "-" 77]"
    set name_list [lsort [array names tmp_env]]
    foreach name $name_list {
      puts $fid "setenv $name '$tmp_env($name)'"
    }
  }

  puts $fid "## [string repeat "-" 77]"
  puts $fid "## End of variable printing."
  puts $fid "## [string repeat "-" 77]"

  if { $options(-filename) != "" } {
    close $fid
  }

  sproc_pinfo -mode stop
}

define_proc_attributes sproc_printvars \
  -info "Procedure for printing variables." \
  -define_args {
  {-filename "Name of file for output information" AString string optional}
  {-tool  "Print tool variables" "" boolean optional}
  {-env   "Print Shell variables" "" boolean optional}
  {-SEV   "Print SEV variables" "" boolean optional}
  {-SVAR  "Print SVAR variables" "" boolean optional}
  {-TEV   "Print TEV variables" "" boolean optional}
}

## -----------------------------------------------------------------------------
## sproc_cat_file:
## -----------------------------------------------------------------------------

proc sproc_cat_file { args } {

  sproc_pinfo -mode start

  set options(-file) ""
  parse_proc_arguments -args $args options

  set cnt 0
  set limit 100
  while { ![file exists $options(-file)] && ( $cnt < $limit ) } {
    incr cnt
    after 1000
    sproc_msg -warning "Waiting for file: $options(-file)"
    sproc_msg -warning "Loop interation $cnt of $limit at [date]"
  }

  if { [file exists $options(-file)] } {
    set fid [open $options(-file) r]
    puts [read $fid]
    close $fid
  } else {
    sproc_msg -error "File argument to sproc_cat_file '$options(-file)' does not exist."
  }

  sproc_pinfo -mode stop
}

define_proc_attributes sproc_cat_file \
  -info "Cats specified file to logfile." \
  -define_args {
  {-file  "The file to cat to logfile." AString string required}
}

## -----------------------------------------------------------------------------
## sproc_uniquify_list:
## -----------------------------------------------------------------------------

proc sproc_uniquify_list { args } {

  set options(-list) ""
  parse_proc_arguments -args $args options

  set output_list [list]

  foreach element $options(-list) {
    if { ![info exists list_of_found_elements($element)] } {
      set list_of_found_elements($element) 1
      lappend output_list $element
    }
  }

  return $output_list
}

define_proc_attributes sproc_uniquify_list \
  -info "Returns a list with no duplicate elements." \
  -define_args {
  {-list "Input list needing to be uniquified." AString string required}
}

## -----------------------------------------------------------------------------
## sproc_which:
## -----------------------------------------------------------------------------

proc sproc_which { args } {

  sproc_pinfo -mode start

  ## -------------------------------------
  ## The behavior of the 'which' command is not
  ## completely uniform across all platforms.
  ## This procedure provides a standard method that is used across the flow
  ## and can be easily modified if system specific alterations are required.
  ## -------------------------------------

  set options(-app) ""

  parse_proc_arguments -args $args options

  catch { exec sh -c "which $options(-app)" } results

  if { [regexp $options(-app) [lindex $results 0]] } {
    set return_value [lindex $results 0]
  } else {
    set return_value NULL
    sproc_msg -error "sproc_which: Unable to locate: $options(-app)"
  }

  sproc_pinfo -mode stop
  return $return_value
}

define_proc_attributes sproc_which \
  -info "Returns the full path to the specified application." \
  -define_args {
  {-app "The application to locate." AString string required}
}

## -----------------------------------------------------------------------------
## sproc_xfer:
## -----------------------------------------------------------------------------

proc sproc_xfer { args } {

  sproc_pinfo -mode start

  global env SEV SVAR TEV
  global rtl_verilog_files
  global rtl_sverilog_files
  global rtl_vhdl_info
  global netlist_verilog_files
  global netlist_vhdl_files
  global db_files
  global ddc_files

  ## -------------------------------------
  ## Process arguments.
  ## -------------------------------------

  set options(-f)       ""
  set options(-d)       ""
  set options(-rename)  ""
  set options(-link)    1
  set options(-type)    RTL_VLOG
  set options(-lib)     "WORK"

  parse_proc_arguments -args $args options

  ## -------------------------------------
  ## Check arguments.
  ## -------------------------------------

  set error 0

  if { ($options(-f) == "") && ($options(-d) == "") } {
    sproc_msg -error "sproc_xfer: either -f or -d required."
    incr error
  }
  if { ($options(-f) != "") && ($options(-d) != "") } {
    sproc_msg -error "sproc_xfer: -f and -d are mutually exclusive."
    incr error
  }
  if { [regexp {^\.} $options(-rename)] || [regexp {^\/} $options(-rename)] } {
    sproc_msg -error "sproc_xfer: -rename must be a simple relative filespec."
    incr error
  }
  set type_options [list RTL_VLOG RTL_SVLOG RTL_VHDL NETLIST_VLOG NETLIST_VHDL DB DDC NONE]
  if { [lsearch $type_options $options(-type)] < 0 } {
    sproc_msg -error "sproc_xfer: -type value not valid: $options(-type)"
    incr error
  }

  if { $error > 0 } {
    sproc_pinfo -mode stop
    return
  }

  ## -------------------------------------
  ## Continue
  ## -------------------------------------

  ## -------------------------------------
  ## Make sure that specified filespec_src
  ## exists and is correct w/r/t being
  ## either a file or a directory.
  ## -------------------------------------

  if { $options(-f) != "" } {
    set filespec_src $options(-f)
    set is_file 1
  } else {
    set filespec_src $options(-d)
    set is_file 0
  }

  sproc_msg -info "sproc_xfer: filespec_src is $filespec_src"

  set error 0

  if { ![file exists $filespec_src] } {
    sproc_msg -error "sproc_xfer: source file $filespec_src does not exist as of [date]."
    incr error
  } else {
    if { $is_file && [file isdirectory $filespec_src] } {
      sproc_msg -error "sproc_xfer: source file $filespec_src is not a file."
      incr error
    }
    if { !$is_file && ![file isdirectory $filespec_src] } {
      sproc_msg -error "sproc_xfer: source file $filespec_src is not a directory."
      incr error
    }
  }

  if { $error > 0 } {
    sproc_pinfo -mode stop
    return
  }

  ## -------------------------------------
  ## Calculate filespec_dst
  ## -------------------------------------

  if { $options(-rename) == "" } {
    set filespec_dst $SEV(dst_dir)/[file tail $filespec_src]
  } else {
    set filespec_dst $SEV(dst_dir)/$options(-rename)
  }

  sproc_msg -info "sproc_xfer: filespec_dst is $filespec_dst"

  ## -------------------------------------
  ## Do the copy or link
  ## -------------------------------------

  file delete -force $filespec_dst
  if { [file exists $filespec_dst] } {
    sproc_msg -error "sproc_xfer: unable to delete destination file $filespec_dst prior to copy"
  } else {
    file mkdir [file dirname $filespec_dst]
    if { $options(-link) } {
      file link $filespec_dst [file normalize $filespec_src]
    } else {
      file copy -force $filespec_src $filespec_dst
      set cmd "chmod -R +w $filespec_dst"
      eval exec $cmd
    }
  }

  ## -------------------------------------
  ## Process the -type and -lib information
  ## -------------------------------------

  switch $options(-type) {
    RTL_VLOG     { lappend rtl_verilog_files     $filespec_dst }
    RTL_SVLOG    { lappend rtl_sverilog_files    $filespec_dst }
    RTL_VHDL     { lappend rtl_vhdl_info         [list $filespec_dst $options(-lib)] }
    NETLIST_VLOG { lappend netlist_verilog_files $filespec_dst }
    NETLIST_VHDL { lappend netlist_vhdl_files    $filespec_dst }
    DB           { lappend db_files              $filespec_dst }
    DDC          { lappend ddc_files             $filespec_dst }
  }

  sproc_pinfo -mode stop
}

define_proc_attributes sproc_xfer \
  -info "Procedure for transferring data to and from work directories." \
  -define_args {
  {-f      "Specifies the name of the file to transfer." AString string optional}
  {-d      "Specifies the name of the dir to transfer." AString string optional}
  {-rename "Allows renaming of the file or dir being transferred." AString string optional}
  {-link   "If set to 1, the file (or directory) is linked, instead of copied." AnOos one_of_string
    {optional value_help {values { 1 0 }}}}
  {-type   "Specifies the format of the file being transferred." AnOos one_of_string
    {optional value_help {values {RTL_VLOG RTL_SVLOG RTL_VHDL NETLIST_VLOG NETLIST_VHDL DB DDC NONE}}}
  }
  {-lib    "Used in conjunction with file type RTL_VHDL. Specifies the name of the library for the VHDL file." AString string optional}
}

## -----------------------------------------------------------------------------
## sproc_gen_tcl_type_file:
## -----------------------------------------------------------------------------

proc sproc_tcl_type_file { args } {

  sproc_pinfo -mode start

  ## -------------------------------------
  ## Process arguments.
  ## -------------------------------------

  ##
  ## There are no arguments for this procedure.
  ## The call to parse_proc_arguments is present to
  ## support built-in help functionality for commands.
  ##

  parse_proc_arguments -args $args options

  ## -------------------------------------
  ## -------------------------------------
  ## -------------------------------------

  global env SEV SVAR TEV
  global rtl_verilog_files
  global rtl_sverilog_files
  global rtl_vhdl_info
  global netlist_verilog_files
  global netlist_vhdl_files
  global db_files
  global ddc_files

  set varnames [list \
    rtl_verilog_files \
    rtl_sverilog_files \
    rtl_vhdl_info \
    netlist_verilog_files \
    netlist_vhdl_files \
    db_files \
    ddc_files \
    ]

  set fid [open $SEV(dst_dir)/tcl_type_file w]
  foreach varname $varnames {
    set cmd "set items \$$varname"
    eval $cmd
    puts $fid "set $varname \[list \\"
    foreach item $items {
      if { $varname == "rtl_vhdl_info" } {
        puts $fid "  { $item } \\"
      } else {
        puts $fid "  $item \\"
      }
    }
    puts $fid "\]"
  }
  close $fid

  sproc_pinfo -mode stop
}

define_proc_attributes sproc_tcl_type_file \
  -info "This procedure works in conjuction with sproc_xfer. It is used to create a file containing variables definitions that describe the format of input files to the SYN step.  The generated file provides a convenient method for ensuring consistency of processing for elaboration and formal verification functions requiring identical input data." \
  -define_args {
}

## -----------------------------------------------------------------------------
## sproc_tool_environment_setup:
## -----------------------------------------------------------------------------

proc sproc_tool_environment_setup { args } {

  sproc_pinfo -mode start

  global env SEV SVAR TEV PTVAR FMVAR
  global link_library
  global search_path
  global synopsys_program_name
  global synthetic_library
  global target_library
  global db_load_ccs_power_data
  global power_model_preference
  global MAP_wc_lib_to_other_lib

  ## -------------------------------------
  ## Process args
  ## -------------------------------------

  ##
  ## When running correlation tasks for the SYN step, it is neccessary
  ## to override the default settings for library setup. The arguments
  ## -lib_condition_min/-lib_condition_max and -disable_min_lib are provided for this purpose.
  ##

  set options(-lib_condition_min) [ lindex $SVAR(setup,lib_conditions) end ]
  set options(-lib_condition_max) [ lindex $SVAR(setup,lib_conditions) 0 ]
  set options(-disable_min_lib) 0
  set options(-debug) 0

  parse_proc_arguments -args $args options

  sproc_msg -info "synopsys_program_name = $synopsys_program_name"

  ##
  ## SVAR(mcmm,enable_icc) is defunct from Lynx but is left in sproc_tool_environment_setup 
  ## to give half a chance at resurecting BC/WC support at the sproc_tool_environment_setup
  ## level should it ever be needed.  Lynx ICC is fulltime MCMM so SVAR(mcmm,enable_icc) = 1
  ##
  set SVAR(mcmm,enable_icc) 1
  set SVAR(mcmm,enable_dc) 1

  ## -------------------------------------
  ## The variables SVAR(lib,$lib,db_filelist,$lib_condition) are automatically derived variables.
  ## They are set to SVAR(lib,$lib,db_nldm_filelist,$lib_condition) if SVAR(lib,$lib,use_ccs) is 0.
  ## They are set to SVAR(lib,$lib,db_ccs_filelist,$lib_condition)  if SVAR(lib,$lib,use_ccs) is 1.
  ## -------------------------------------

  foreach lib $SVAR(setup,lib_types_list) {
    foreach lib_condition $SVAR(setup,lib_conditions) {
      foreach mode $SVAR(setup,modes) {
        foreach rc_condition $SVAR(setup,rc_conditions) {
          if { $SVAR(lib,$lib,use_ccs) } {
            set SVAR(lib,$lib,db_filelist,$mode,$lib_condition,$rc_condition) $SVAR(lib,$lib,db_ccs_filelist,$mode,$lib_condition,$rc_condition)
          } else {
            set SVAR(lib,$lib,db_filelist,$mode,$lib_condition,$rc_condition) $SVAR(lib,$lib,db_nldm_filelist,$mode,$lib_condition,$rc_condition)
          }
        }
      }
    }
  }

  ## -------------------------------------
  ## Check that each library has an equal number
  ## of DB files across all operating conditions.
  ## -------------------------------------

  ## -------------------------------------
  ## Some data maintained in the flow exists for WC opconds only.
  ## A one-to-one mapping is employed to map from WC opconds to other opconds.
  ## The mapping is very dependent upon the ordering of DB files in the related SVARs.
  ##
  ## Consider the following two variables that are used to specify DB files:
  ##   set SVAR(lib,my_lib,db_filelist,OC_WC) "file1 file2 file3"
  ##   set SVAR(lib,my_lib,db_filelist,OC_BC) "file4 file5 file6"
  ## The files 1-3 are used to specify the DB files for worst case opconds.
  ## The files 4-6 are used to specify the DB files for best case opconds.
  ## The set of cells defined in file1 must match the set of cells defined in file4.
  ## The same relationship applies between file2 & file5, and between file3 & file6.
  ##
  ## The variable MAP_wc_lib_to_other_lib is used to provide mapping information.
  ## from each worst case opcond library to equivalent libraries at other opconds.
  ## -------------------------------------

  unset -nocomplain MAP_wc_lib_to_other_lib

  foreach lib $SVAR(link_libs) {
    foreach mode $SVAR(setup,modes) {
      foreach rc_condition $SVAR(setup,rc_conditions) {

        set error 0

        set db_file_count_for_WC [llength $SVAR(lib,$lib,db_filelist,$mode,$options(-lib_condition_max),$rc_condition)]

        foreach lib_condition $SVAR(setup,lib_conditions) {
          set db_file_count [llength $SVAR(lib,$lib,db_filelist,$mode,$lib_condition,$rc_condition)]
          if { $db_file_count != $db_file_count_for_WC } {
            set error 1
          }
        }

        if { $error } {
          sproc_msg -warning "The number of DB files must be identical for all operating conditions: $lib $mode $rc_condition"
          foreach lib_condition $SVAR(setup,lib_conditions) {
            set db_file_count [llength $SVAR(lib,$lib,db_filelist,$mode,$lib_condition,$rc_condition)]
            sproc_msg -warning "SVAR(lib,$lib,db_filelist,$mode,$lib_condition,$rc_condition) has $db_file_count entries."
          }
        } else {
          foreach lib_condition $SVAR(setup,lib_conditions) {
            for { set i 0 } { $i < $db_file_count_for_WC } { incr i } {
              set wc_lib      [file tail [lindex $SVAR(lib,$lib,db_filelist,$mode,$options(-lib_condition_max),$rc_condition) $i]]
              set lib_condition_lib [file tail [lindex $SVAR(lib,$lib,db_filelist,$mode,$lib_condition,$rc_condition) $i]]
              set MAP_wc_lib_to_other_lib($mode,$lib_condition,$rc_condition,$wc_lib) $lib_condition_lib
            }
          }
        }
      }
    }
  }

  ## -------------------------------------
  ## MW reference list
  ## -------------------------------------

  if { (($synopsys_program_name == "dc_shell") && [shell_is_in_topographical_mode]) || \
      ($synopsys_program_name == "icc_shell") || \
      ($synopsys_program_name == "primerail") \
    } {
    sproc_msg -info "Setting up Milkyway reference library. "
    set SVAR(lib,mw_reflist) ""
    foreach lib $SVAR(link_libs) {
      foreach rlib $SVAR(lib,$lib,mw_reflist) {
        lappend SVAR(lib,mw_reflist) [file normalize $rlib]
      }
    }
    if { [ file exist  $SVAR(src,mdb) ] == 1 } {
      sproc_msg -info "Update mw reference list ..."
      set_mw_lib_reference -mw_reference_library $SVAR(lib,mw_reflist) $SVAR(src,mdb)
    } else {
      sproc_msg -info "Skip update mdb ..."
    }

  } else {
    sproc_msg -info "$synopsys_program_name does not require a Milkyway reference library. "
  }

  ## -------------------------------------
  ## search path
  ## -------------------------------------

  if { ($synopsys_program_name == "dc_shell") || \
      ($synopsys_program_name == "fm_shell") || \
      ($synopsys_program_name == "mvrc") || \
      ($synopsys_program_name == "icc_shell") || \
      ($synopsys_program_name == "pt_shell") || \
      ($synopsys_program_name == "gca_shell") || \
      ($synopsys_program_name == "primerail") \
    } {

    sproc_msg -info "Setting up search path. "

    ## key for including tool search_paths like to dw
    set tmp(search_path) $search_path

    foreach lib $SVAR(link_libs) {
      foreach lib_condition $SVAR(setup,lib_conditions) {
        foreach mode $SVAR(setup,modes) {
          foreach rc_condition $SVAR(setup,rc_conditions) {
            foreach db_file $SVAR(lib,$lib,db_filelist,$mode,$lib_condition,$rc_condition) {
              lappend tmp(search_path) [ file dirname $db_file ]
            }
          }
        }
      }
    }

  } else {
    sproc_msg -info "$synopsys_program_name does not require a search path. "
  }

  ## -------------------------------------
  ## link library
  ## -------------------------------------

  foreach scenario $SVAR(mcmm,scenario_icc_all) {
    lappend tmp_modes     [ sproc_get_scenario_info -scenario $scenario -type mode ]
    lappend tmp_lib_conds [ sproc_get_scenario_info -scenario $scenario -type lib_condition ]
    lappend tmp_rc_conds  [ sproc_get_scenario_info -scenario $scenario -type rc_condition ]
  }
  set tmp_modes     [ sproc_uniquify_list -list $tmp_modes ]
  set tmp_lib_conds [ sproc_uniquify_list -list $tmp_lib_conds ]
  set tmp_rc_conds  [ sproc_uniquify_list -list $tmp_rc_conds ]

  if { ($synopsys_program_name == "dc_shell") || \
      ($synopsys_program_name == "mvrc") || \
      ($synopsys_program_name == "icc_shell") \
    } {

    sproc_msg -info "Setting up link library. "
    set tmp(link_library) "*"

    foreach lib $SVAR(link_libs) {
      foreach lib_cond $tmp_lib_conds {
        foreach mode $tmp_modes {
          foreach rc_condition $tmp_rc_conds {
            foreach db_file $SVAR(lib,$lib,db_filelist,$mode,$lib_cond,$rc_condition) {
              lappend tmp(link_library) [ file tail $db_file ]
            }
          }
        }
      }
    }

    ## These variables are being used to limit CCS memory usage.
    set db_load_ccs_power_data false
    set power_model_preference nlpm

  } elseif { $synopsys_program_name == "pt_shell" } {
    sproc_msg -info "Setting up link library for PT"
    set tmp(link_library) "*"

    foreach lib $SVAR(link_libs) {
      foreach db_file $SVAR(lib,$lib,db_filelist,$PTVAR(DB,MODE),$PTVAR(LIB_COND),$PTVAR(RC_COND)) {
        lappend tmp(link_library) [ file tail $db_file ]
      }
    }

  } elseif { ($synopsys_program_name == "fm_shell") } {
    sproc_msg -info "Setting up link library. "
    foreach lib $SVAR(link_libs) {
      foreach db_file $SVAR(lib,$lib,db_filelist,$FMVAR(MODE),$options(-lib_condition_max),[ lindex $SVAR(setup,rc_conditions) 0 ]) {
        read_db $db_file
      }
    }
  } else {

    sproc_msg -info "$synopsys_program_name does not require a link library. "

  }

  ## -------------------------------------
  ## target library
  ## -------------------------------------

  if { ($synopsys_program_name == "dc_shell") || ($synopsys_program_name == "icc_shell") } {

    sproc_msg -info "Setting up target library. "
    set tmp(target_library) ""
    foreach lib $SVAR(target_libs) {
      foreach lib_cond $tmp_lib_conds {
        foreach mode $tmp_modes {
          foreach rc_condition $tmp_rc_conds {
            foreach db_file $SVAR(lib,$lib,db_filelist,$mode,$lib_cond,$rc_condition) {
              lappend tmp(target_library) [ file tail $db_file ]
            }
          }
        }
      }
    }

  } else {
    sproc_msg -info "$synopsys_program_name does not require a target library. "
  }

  ## -------------------------------------
  ## min / max library relationship
  ## -------------------------------------

  #if { $options(-disable_min_lib) } {

  #  sproc_msg -info "Skipping setup of min library relationships."

  #} else {

  #  if { ($synopsys_program_name == "icc_shell") && !$SVAR(mcmm,enable_icc) } {

  #    #sproc_msg -info "Setting up min library relationship. "
  #    #foreach lib $SVAR(link_libs) {
  #    #  foreach mode $SVAR(setup,modes) {
  #    #    foreach rc_condition $SVAR(setup,rc_conditions) {
  #    #      for {set i 0} {$i < [llength $SVAR(lib,$lib,db_filelist,$mode,$options(-lib_condition_max),$rc_condition)]} {incr i} {
  #    #        set_min_library [ file tail [ lindex $SVAR(lib,$lib,db_filelist,$mode,$options(-lib_condition_max),$rc_condition) $i ] ] \
  #    #          -min_version [ file tail [ lindex $SVAR(lib,$lib,db_filelist,$mode,$options(-lib_condition_min),$rc_condition) $i ] ]
  #    #      }
  #    #    }
  #    #  }
  #    #}

  #  } else {
  #    sproc_msg -info "$synopsys_program_name does not require a min library relationship. "
  #    sproc_msg -info "or alternatively is being configured to not use them."
  #  }

  #}

  ## -------------------------------------
  ## Make some adjustments for MCMM operation
  ## -------------------------------------

  if { (($synopsys_program_name == "dc_shell") && $SVAR(mcmm,enable_dc)) || \
      (($synopsys_program_name == "icc_shell") && $SVAR(mcmm,enable_icc)) \
    } {

    sproc_msg -info "Making MCMM adjustments ."

    set lib_conditions [list]
    if { $synopsys_program_name == "dc_shell" } {
      foreach scenario $SVAR(mcmm,scenario_dc_all) {
        lappend lib_conditions [sproc_get_scenario_info -scenario $scenario -type lib_condition]
      }
    } else {
      foreach scenario $SVAR(mcmm,scenario_icc_all) {
        lappend lib_conditions [sproc_get_scenario_info -scenario $scenario -type lib_condition]
      }
    }
    set lib_conditions [ sproc_uniquify_list -list $lib_conditions ]

    foreach lib $SVAR(link_libs) {
      foreach lib_condition $tmp_lib_conds {
        foreach mode $tmp_modes {
          foreach rc_condition $tmp_rc_conds {
            foreach db_file $SVAR(lib,$lib,db_filelist,$mode,$lib_condition,$rc_condition) {
              lappend tmp(link_library) [ file tail $db_file ]
            }
          }
        }
      }
    }

    foreach lib $SVAR(target_libs) {
      foreach lib_condition $tmp_lib_conds {
        foreach mode $tmp_modes {
          foreach rc_condition $tmp_rc_conds {
            foreach db_file $SVAR(lib,$lib,db_filelist,$mode,$lib_condition,$rc_condition) {
              lappend tmp(target_library) [ file tail $db_file ]
            }
          }
        }
      }
    }
  }

  ## -------------------------------------
  ## Add DesignWare to the environment (e.g. link library, synthetic library)
  ## -------------------------------------

  if { $synopsys_program_name == "dc_shell" } {

    sproc_msg -info "Setting up DesignWare. "

    set sldb_files [list dw_foundation.sldb]

    foreach sldb_file $sldb_files {
      foreach path $tmp(search_path) {
        if { [file exists $path/$sldb_file] } {
          sproc_msg -info "Using DesignWare library $sldb_file"
          lappend tmp(link_library) $sldb_file
          lappend tmp(synthetic_library) $sldb_file
        }
      }
    }

  } else {
    sproc_msg -info "$synopsys_program_name does not require a setting up DesignWare. "
  }

  ## -------------------------------------
  ## Remove duplicate elements from the lists,
  ## and assign the final value.
  ## -------------------------------------

  if { [ info exists SVAR(lib,mw_reflist) ] } {
    set SVAR(lib,mw_reflist) [ sproc_uniquify_list -list $SVAR(lib,mw_reflist) ]
    sproc_msg -setup "set SVAR(lib,mw_reflist) \[list \\"
    foreach item $SVAR(lib,mw_reflist) { sproc_msg -setup "  $item \\" }
    sproc_msg -setup "\]"
  }
  if { [ info exists tmp(link_library) ] } {
    set link_library [ sproc_uniquify_list -list $tmp(link_library) ]
    sproc_msg -setup "set link_library \[list \\"
    foreach item $link_library { sproc_msg -setup "  $item \\" }
    sproc_msg -setup "\]"
  }
  if { [ info exists tmp(search_path) ] } {
    set search_path [ sproc_uniquify_list -list $tmp(search_path) ]
    sproc_msg -setup "set search_path \[list \\"
    foreach item $search_path { sproc_msg -setup "  $item \\" }
    sproc_msg -setup "\]"
  }
  if { [ info exists tmp(synthetic_library) ] } {
    set synthetic_library [ sproc_uniquify_list -list $tmp(synthetic_library) ]
    sproc_msg -setup "set synthetic_library \[list \\"
    foreach item $synthetic_library { sproc_msg -setup "  $item \\" }
    sproc_msg -setup "\]"
  }
  if { [ info exists tmp(target_library) ] } {
    set target_library [ sproc_uniquify_list -list $tmp(target_library) ]
    sproc_msg -setup "set target_library \[list \\"
    foreach item $target_library { sproc_msg -setup "  $item \\" }
    sproc_msg -setup "\]"
  }

  sproc_pinfo -mode stop
}

define_proc_attributes sproc_tool_environment_setup \
  -info "Sets required library variables" \
  -define_args {
  {-lib_condition_min "Min Operating Condition" AString string optional}
  {-lib_condition_max "Max Operating Condition" AString string optional}
  {-disable_min_lib "Disable min library relationships." "" boolean optional}
  {-debug       "Print debugging info" "" boolean optional}
}

## -----------------------------------------------------------------------------
## sproc_set_operating_conditions:
## -----------------------------------------------------------------------------

proc sproc_set_operating_conditions { args } {

  sproc_pinfo -mode start

  global env SEV SVAR TEV
  global link_library
  global synopsys_program_name

  set options(-lib_condition_min) OC_BC
  set options(-lib_condition_max) OC_WC
  set options(-lib_condition) ""
  set options(-oc_mode) "ocv"
  parse_proc_arguments -args $args options

  sproc_msg -info "Beginning sproc_set_operating_conditions:"
  sproc_msg -info "-lib_condition = $options(-lib_condition)"
  sproc_msg -info "-oc_mode = $options(-oc_mode)"

  if { $options(-oc_mode) == "ocv" } {
    if { $options(-lib_condition) == "" } {
      sproc_msg -error "You must specify -lib_condition"
      sproc_script_stop -exit
    }
  }

  ## -------------------------------------
  ## Reset the operating condition before it can be applied (in some tools)
  ## -------------------------------------

  set_operating_conditions

  ## -------------------------------------
  ## Set the operating condition
  ## -------------------------------------

  switch $options(-oc_mode) {
    ocv {

      set libname [lindex $SVAR(libsetup,db_libname_opcond,$options(-lib_condition)) 0]
      set opcond  [lindex $SVAR(libsetup,db_libname_opcond,$options(-lib_condition)) 1]

      set_operating_conditions \
        -analysis_type on_chip_variation \
        -max_library $libname \
        -min_library $libname \
        -max $opcond \
        -min $opcond

      set set_operating_condition_cmd [list \
        set_operating_conditions \
        -analysis_type on_chip_variation \
        -max_library $libname \
        -min_library $libname \
        -max $opcond \
        -min $opcond \
        ]
    }

    bc_wc {

      set libname_wc [lindex $SVAR(libsetup,db_libname_opcond,$options(-lib_condition_max)) 0]
      set opcond_wc  [lindex $SVAR(libsetup,db_libname_opcond,$options(-lib_condition_max)) 1]
      set libname_bc [lindex $SVAR(libsetup,db_libname_opcond,$options(-lib_condition_min)) 0]
      set opcond_bc  [lindex $SVAR(libsetup,db_libname_opcond,$options(-lib_condition_min)) 1]

      set_operating_conditions \
        -analysis_type bc_wc \
        -max_library $libname_wc \
        -min_library $libname_bc \
        -max $opcond_wc \
        -min $opcond_bc

      set set_operating_condition_cmd [list \
        set_operating_conditions \
        -analysis_type bc_wc \
        -max_library $libname_wc \
        -min_library $libname_bc \
        -max $opcond_wc \
        -min $opcond_bc \
        ]

      if { $synopsys_program_name == "pt_shell" } {
        sproc_msg -error "BC_WC configuration in PT is discouraged."
        sproc_msg -error "See PT-009 for more information."
      }
    }
  }

  ## -------------------------------------
  ## Print some useful information
  ## -------------------------------------

  sproc_msg -setup "$set_operating_condition_cmd"

  sproc_pinfo -mode stop
  return $set_operating_condition_cmd
}

define_proc_attributes sproc_set_operating_conditions \
  -info "Pre-packaged operating conditions ." \
  -define_args {
  {-lib_condition_min "Min Operating Condition" AString string optional}
  {-lib_condition_max "Max Operating Condition" AString string optional}
  {-lib_condition "Operating Condition Type" AString string optional}
  {-oc_mode "Operating Condition Mode" AnOos one_of_string
    {required value_help {values {ocv bc_wc}}}
  }
}

## -----------------------------------------------------------------------------
## sproc_set_tlu_plus_files:
## -----------------------------------------------------------------------------

proc sproc_set_tlu_plus_files { args } {

  sproc_pinfo -mode start

  global env SEV SVAR TEV
  global synopsys_program_name

  set options(-rc_type) ""
  set options(-min_max) 0
  set options(-mf)      "emf_rmf"
  parse_proc_arguments -args $args options

  if { ($synopsys_program_name == "dc_shell") && ![shell_is_in_topographical_mode] } {
    sproc_msg -warning "Cannot execute set_tlu_plus_files in non-topo mode."
    sproc_pinfo -mode stop
    return
  }

  sproc_msg -info "Beginning sproc_set_tlu_plus_files:"
  sproc_msg -info "-rc_type = $options(-rc_type)"
  sproc_msg -info "-min_max = $options(-min_max)"
  sproc_msg -info "-mf      = $options(-mf)"

  ## -------------------------------------
  ## set the TLU
  ## -------------------------------------

  set set_tlu_plus_files_cmd ""

  if { $options(-min_max) } {

    set rc_type_min RC_MIN_1
    set rc_type_max RC_MAX_1

    switch $options(-mf) {
      emf_rmf {
        set_tlu_plus_files \
          -max_emulation_tluplus $SVAR(tech,tlup_emf_file,$rc_type_max) \
          -min_emulation_tluplus $SVAR(tech,tlup_emf_file,$rc_type_min) \
          -max_tluplus  $SVAR(tech,tlup_file,$rc_type_max) \
          -min_tluplus  $SVAR(tech,tlup_file,$rc_type_min) \
          -tech2itf_map $SVAR(tech,map_file_mdb2itf)

        set set_tlu_plus_files_cmd [list \
          set_tlu_plus_files \
          -max_emulation_tluplus $SVAR(tech,tlup_emf_file,$rc_type_max) \
          -min_emulation_tluplus $SVAR(tech,tlup_emf_file,$rc_type_min) \
          -max_tluplus  $SVAR(tech,tlup_file,$rc_type_max) \
          -min_tluplus  $SVAR(tech,tlup_file,$rc_type_min) \
          -tech2itf_map $SVAR(tech,map_file_mdb2itf) \
          ]
      }
      emf {
        set_tlu_plus_files \
          -max_tluplus  $SVAR(tech,tlup_emf_file,$rc_type_max) \
          -min_tluplus  $SVAR(tech,tlup_emf_file,$rc_type_min) \
          -tech2itf_map $SVAR(tech,map_file_mdb2itf)

        set set_tlu_plus_files_cmd [list \
          set_tlu_plus_files \
          -max_tluplus  $SVAR(tech,tlup_emf_file,$rc_type_max) \
          -min_tluplus  $SVAR(tech,tlup_emf_file,$rc_type_min) \
          -tech2itf_map $SVAR(tech,map_file_mdb2itf) \
          ]
      }
      rmf {
        set_tlu_plus_files \
          -max_tluplus  $SVAR(tech,tlup_file,$rc_type_max) \
          -min_tluplus  $SVAR(tech,tlup_file,$rc_type_min) \
          -tech2itf_map $SVAR(tech,map_file_mdb2itf)

        set set_tlu_plus_files_cmd [list \
          set_tlu_plus_files \
          -max_tluplus  $SVAR(tech,tlup_file,$rc_type_max) \
          -min_tluplus  $SVAR(tech,tlup_file,$rc_type_min) \
          -tech2itf_map $SVAR(tech,map_file_mdb2itf) \
          ]
      }
    }

  } else {

    switch $options(-mf) {
      emf_rmf {
        set_tlu_plus_files \
          -max_emulation_tluplus  $SVAR(tech,tlup_emf_file,$options(-rc_type)) \
          -max_tluplus  $SVAR(tech,tlup_file,$options(-rc_type)) \
          -tech2itf_map $SVAR(tech,map_file_mdb2itf)

        set set_tlu_plus_files_cmd [list \
          set_tlu_plus_files \
          -max_emulation_tluplus  $SVAR(tech,tlup_emf_file,$options(-rc_type)) \
          -max_tluplus  $SVAR(tech,tlup_file,$options(-rc_type)) \
          -tech2itf_map $SVAR(tech,map_file_mdb2itf) \
          ]
      }
      emf {
        set_tlu_plus_files \
          -max_tluplus  $SVAR(tech,tlup_emf_file,$options(-rc_type)) \
          -tech2itf_map $SVAR(tech,map_file_mdb2itf)

        set set_tlu_plus_files_cmd [list \
          set_tlu_plus_files \
          -max_tluplus  $SVAR(tech,tlup_emf_file,$options(-rc_type)) \
          -tech2itf_map $SVAR(tech,map_file_mdb2itf) \
          ]
      }
      rmf {
        set_tlu_plus_files \
          -max_tluplus  $SVAR(tech,tlup_file,$options(-rc_type)) \
          -tech2itf_map $SVAR(tech,map_file_mdb2itf)

        set set_tlu_plus_files_cmd [list \
          set_tlu_plus_files \
          -max_tluplus  $SVAR(tech,tlup_file,$options(-rc_type)) \
          -tech2itf_map $SVAR(tech,map_file_mdb2itf) \
          ]
      }
    }

  }

  ## -------------------------------------
  ## Print some useful information
  ## -------------------------------------

  foreach item $set_tlu_plus_files_cmd {
    sproc_msg -setup "$item"
  }

  sproc_pinfo -mode stop
  return $set_tlu_plus_files_cmd
}

define_proc_attributes sproc_set_tlu_plus_files \
  -info "Invoke TLU+ settings." \
  -define_args {
  {-rc_type "RC Corner" AString string optional}
  {-min_max "Select Min/Max RC Corners" "" boolean optional}
  {-mf "Metal fill estimation mode" AnOos one_of_string
    {optional value_help {values {emf_rmf emf rmf}}}
  }
}

## -----------------------------------------------------------------------------
## sproc_tool_environment_display:
## -----------------------------------------------------------------------------

proc sproc_tool_environment_display {} {

  sproc_pinfo -mode start

  global env SEV SVAR TEV
  global link_library
  global link_path
  global search_path
  global synopsys_program_name
  global synthetic_library
  global target_library

  if { [info exists link_library] } {
    sproc_msg -setup "set link_library \[list \\"
    foreach item $link_library { sproc_msg -setup "  $item \\" }
    sproc_msg -setup "\]"
  }

  if { [info exists link_path] } {
    sproc_msg -setup "set link_path \[list \\"
    foreach item $link_path { sproc_msg -setup "  $item \\" }
    sproc_msg -setup "\]"
  }

  if { [info exists search_path] } {
    sproc_msg -setup "set search_path \[list \\"
    foreach item $search_path { sproc_msg -setup "  $item \\" }
    sproc_msg -setup "\]"
  }

  if { [info exists synthetic_library] } {
    sproc_msg -setup "set synthetic_library \[list \\"
    foreach item $synthetic_library { sproc_msg -setup "  $item \\" }
    sproc_msg -setup "\]"
  }

  if { [info exists target_library] } {
    sproc_msg -setup "set target_library \[list \\"
    foreach item $target_library { sproc_msg -setup "  $item \\" }
    sproc_msg -setup "\]"
  }

  if { [info exists SVAR(lib,mw_reflist)] } {
    sproc_msg -setup "set SVAR(lib,mw_reflist) \[list \\"
    foreach item $SVAR(lib,mw_reflist) { sproc_msg -setup "  $item \\" }
    sproc_msg -setup "\]"
  }

  sproc_pinfo -mode stop
}

define_proc_attributes sproc_tool_environment_display \
  -info "Standard routine for displaying environmental tool startup." \
  -define_args {
}

## -----------------------------------------------------------------------------
## sproc_metric_system:
## -----------------------------------------------------------------------------

proc sproc_metric_system { args } {

  sproc_pinfo -mode start

  global env SEV SVAR TEV
  global sh_product_version
  global synopsys_program_name

  set xxx1 [clock seconds]

  set options(-start_of_script) 0
  set options(-end_of_script) 0
  parse_proc_arguments -args $args options

  if { $options(-start_of_script) } {

    sproc_msg -info "METRIC | STRING SYS.MACHINE      | [exec uname -n]"
    sproc_msg -info "METRIC | STRING SYS.TOOL_NAME    | $synopsys_program_name"
    if { ![info exists sh_product_version] || $sh_product_version == "" } {
      set sh_product_version NaM
    }
    sproc_msg -info "METRIC | STRING SYS.TOOL_VERSION | $sh_product_version"

  }

  if { $options(-end_of_script) } {

    sproc_msg -info "METRIC | STRING SYS.PROJECT_NAME   | $SEV(project_name)"
    sproc_msg -info "METRIC | STRING SYS.PROJECT_DIR    | $SEV(project_dir)"
    sproc_msg -info "METRIC | STRING SYS.TECHLIB_NAME   | $SEV(techlib_name)"
    sproc_msg -info "METRIC | STRING SYS.TECHLIB_DIR    | $SEV(techlib_dir)"
    sproc_msg -info "METRIC | STRING SYS.WORKAREA_DIR   | $SEV(workarea_dir)"
    sproc_msg -info "METRIC | STRING SYS.BLOCK_DIR      | $SEV(block_dir)"
    sproc_msg -info "METRIC | STRING SYS.USER           | [exec whoami]"
    sproc_msg -info "METRIC | STRING SYS.SCRIPT_NAME    | [file normalize $SEV(script_file)]"
    sproc_msg -info "METRIC | STRING SYS.SCRIPT_VERSION | [sproc_script_version]"

    set script_type unknown
    if { [regexp "/scripts_global/" $SEV(script_file)] } {
      set script_type global
    }
    if { [regexp "/scripts_global/$SEV(techlib_name)/" $SEV(script_file)] } {
      set script_type techlib
    }
    if { [regexp "/scripts_block/" $SEV(script_file)] } {
      set script_type block
    }
    sproc_msg -info "METRIC | STRING SYS.SCRIPT_TYPE | $script_type"

    sproc_msg -info "METRIC | TAG SYS.TAG.01 | [lindex $SVAR(tag01) 0] !! [lindex $SVAR(tag01) 1]"
    sproc_msg -info "METRIC | TAG SYS.TAG.02 | [lindex $SVAR(tag02) 0] !! [lindex $SVAR(tag02) 1]"
    sproc_msg -info "METRIC | TAG SYS.TAG.03 | [lindex $SVAR(tag03) 0] !! [lindex $SVAR(tag03) 1]"
    sproc_msg -info "METRIC | TAG SYS.TAG.04 | [lindex $SVAR(tag04) 0] !! [lindex $SVAR(tag04) 1]"
    sproc_msg -info "METRIC | TAG SYS.TAG.05 | [lindex $SVAR(tag05) 0] !! [lindex $SVAR(tag05) 1]"
    sproc_msg -info "METRIC | TAG SYS.TAG.06 | [lindex $SVAR(tag06) 0] !! [lindex $SVAR(tag06) 1]"
    sproc_msg -info "METRIC | TAG SYS.TAG.07 | [lindex $SVAR(tag07) 0] !! [lindex $SVAR(tag07) 1]"
    sproc_msg -info "METRIC | TAG SYS.TAG.08 | [lindex $SVAR(tag08) 0] !! [lindex $SVAR(tag08) 1]"
    sproc_msg -info "METRIC | TAG SYS.TAG.09 | [lindex $SVAR(tag09) 0] !! [lindex $SVAR(tag09) 1]"
    sproc_msg -info "METRIC | TAG SYS.TAG.10 | [lindex $SVAR(tag10) 0] !! [lindex $SVAR(tag10) 1]"

    sproc_msg -info "METRIC | STRING SYS.BLOCK        | $SVAR(design_name)"
    sproc_msg -info "METRIC | STRING SYS.STEP         | $SEV(step)"
    sproc_msg -info "METRIC | STRING SYS.LOG          | [file normalize $SEV(log_file)]"
    sproc_msg -info "METRIC | STRING SYS.SRC          | $SEV(src)"
    sproc_msg -info "METRIC | STRING SYS.DST          | $SEV(dst)"

    if { ![info exists TEV(num_jobs)] }        { set TEV(num_jobs) 1 }
    if { ![info exists TEV(num_cores)] }       { set TEV(num_cores) 1 }
    if { ![info exists TEV(num_child_jobs)] }  { set TEV(num_child_jobs) 1 }
    if { ![info exists TEV(num_child_cores)] } { set TEV(num_child_cores) 1 }

    sproc_msg -info "METRIC | INTEGER INFO.NUM_JOBS        | $TEV(num_jobs)"
    sproc_msg -info "METRIC | INTEGER INFO.NUM_CORES       | $TEV(num_cores)"
    sproc_msg -info "METRIC | INTEGER INFO.NUM_CHILD_JOBS  | $TEV(num_child_jobs)"
    sproc_msg -info "METRIC | INTEGER INFO.NUM_CHILD_CORES | $TEV(num_child_cores)"

    if { [info exists env(LSB_JOBID)] } {
      set lsf_job_id $env(LSB_JOBID)
    } else {
      set lsf_job_id NaM
    }
    sproc_msg -info "METRIC | STRING INFO.LSF_JOB_ID | $lsf_job_id"

    if { $SEV(dont_run) || $SEV(dont_exit) } {
      if { $SEV(analysis_task) } {
        sproc_msg -info "METRIC | STRING SYS.TASK_TYPE | ANALYZE_INTERACTIVE"
      } else {
        sproc_msg -info "METRIC | STRING SYS.TASK_TYPE | OPTIMIZE_INTERACTIVE"
      }
    } else {
      if { $SEV(analysis_task) } {
        sproc_msg -info "METRIC | STRING SYS.TASK_TYPE | ANALYZE"
      } else {
        sproc_msg -info "METRIC | STRING SYS.TASK_TYPE | OPTIMIZE"
      }
    }

    switch $synopsys_program_name {
      cdesigner -
      tmax_tcl -
      leda -
      mvrc -
      mvrc_shell -
      tcl {
        sproc_msg -info "METRIC | INTEGER INFO.MEMORY_USED | NaM"
      }
      default {
        sproc_msg -info "METRIC | INTEGER INFO.MEMORY_USED | [sproc_metric_format {%d} [expr int([mem])]]"
      }
    }

    if { [info command list_licenses] == "list_licenses" } {
      redirect -var report {
        list_licenses
      }
      set license_list [list]
      set lines [split $report "\n"]
      foreach line $lines {
        if { [regexp {^\s*$} $line] } {
          continue
        }
        if { [regexp {^\s+[\w\-]+} $line] } {
          lappend license_list [lindex $line 0]
        }
      }
    } elseif { $synopsys_program_name == "tmax_tcl" } {
      redirect -var report {
        report_licenses
      }
      set license_list [list] 
      set lines [split $report "\n"]
      foreach line $lines {
        if { [regexp {^\s*$} $line] } {
          continue
        } else {
          lappend license_list [lindex $line 0]
        }
      }
    } else {
      set license_list [list LicenseDataUnavailable]
    }
    sproc_msg -info "METRIC | STRING INFO.LICENSES | $license_list"

  }

  set xxx2 [clock seconds]
  set xxx [expr $xxx2 - $xxx1]
  sproc_msg -info "METRICS sproc_metric_system took $xxx seconds"

  sproc_pinfo -mode stop
}

define_proc_attributes sproc_metric_system \
  -info "Used to generate metrics related to task execution." \
  -define_args {
  {-start_of_script "Indicates routine is being called at start of script execution." "" boolean optional}
  {-end_of_script "Indicates routine is being called at end of script execution." "" boolean optional}
}

## -----------------------------------------------------------------------------
## sproc_script_version:
## -----------------------------------------------------------------------------

proc sproc_script_version {} {

  sproc_pinfo -mode start

  global LYNX
  global env SEV SVAR TEV

  ## Determine version of $SEV(script_file)

  set version "Nam"

  if { [file exists $SEV(script_file)] } {

    set fid [open $SEV(script_file) r]

    while { [gets $fid line] >= 0 } {

      ## -------------------------------------
      ## Perforce format example:
      ## set line {## HEADER $Id: //sps/lynx/ds_tmp/scripts_global/10_syn/dc_elaborate.tcl#4}
      ## -------------------------------------

      set re {^## HEADER \$Id: [\w\/\.]+#([\d]+)}

      if { [regexp $re $line match version] } {
        break
      }

      ## -------------------------------------
      ## CVS format example:
      ## set line {## HEADER $Id: tool_launch_part1.make,v 1.2 2010/04/02 21:34:44 gamble Exp}
      ## -------------------------------------

      set re {^## HEADER \$Id: [\w\/\.\,]+\s+([\d\.]+)}

      if { [regexp $re $line match version] } {
        break
      }

    }

    close $fid
  }

  sproc_pinfo -mode stop
  return $version

}

define_proc_attributes sproc_script_version \
  -info "Used to determine the version of a script." \
  -define_args {
}

## -----------------------------------------------------------------------------
## sproc_metric_time:
## -----------------------------------------------------------------------------

proc sproc_metric_time { args } {

  sproc_pinfo -mode start

  global SEV
  global SNPS_time_start

  set options(-start) 0
  set options(-stop) 0

  parse_proc_arguments -args $args options

  if { $options(-start) } {
    sproc_msg -info "METRIC | TIMESTAMP SYS.START_TIME | [clock seconds]"
    sproc_msg -info "SYS.START_TIME | [date]"
    set SNPS_time_start [clock seconds]
  }
  if { $options(-stop) } {
    sproc_msg -info "METRIC | TIMESTAMP SYS.STOP_TIME | [clock seconds]"
    sproc_msg -info "SYS.STOP_TIME | [date]"
    set SNPS_time_stop [clock seconds]
    set SNPS_time_total_seconds [expr $SNPS_time_stop - $SNPS_time_start]
    set dhms [sproc_metric_time_elapsed -start $SNPS_time_start -stop $SNPS_time_stop]
    sproc_msg -info "METRIC | TIME INFO.ELAPSED_TIME.TOTAL | $SNPS_time_total_seconds"
    sproc_msg -info "INFO.ELAPSED_TIME.TOTAL | $dhms"
  }

  sproc_pinfo -mode stop
}

define_proc_attributes sproc_metric_time \
  -info "Used to generate metrics related to duration of task execution." \
  -define_args {
  {-start "Indicates routine is being called to provide start time info.." "" boolean optional}
  {-stop "Indicates routine is being called to provide stop time info." "" boolean optional}
}


## -----------------------------------------------------------------------------
## sproc_clean_string:
## -----------------------------------------------------------------------------

proc sproc_clean_string { args } {

  sproc_pinfo -mode start

  set options(-string) ""
  parse_proc_arguments -args $args options

  set string_before $options(-string)

  set string_after [regsub -all {[\*]} $string_before {}]
  set string_after [regsub -all {[\/\-\(\)\[\]\=\%\&\@\!\~]} $string_after {_}]

  if {![regexp $string_after $string_before]} {
    sproc_msg -warn "string $string_before changed to $string_after to remove hazardous characters"
  }

  sproc_pinfo -mode stop

  return $string_after

}

define_proc_attributes sproc_clean_string \
  -info "removes characters not supported for metric strings" \
  -define_args {
  {-string  "The string that needs cleaning." AString string required}
}


## -----------------------------------------------------------------------------
## sproc_verify_pv_task:
## -----------------------------------------------------------------------------

proc sproc_verify_pv_task { args } {

  sproc_pinfo -mode start

  global env TEV SVAR
  global LYNX

  set options(-task) ""
  set options(-summary_file) ""
  set options(-results_file) ""
  
  parse_proc_arguments -args $args options

  if { ![file exists $options(-summary_file)] } {
    sproc_msg -error "Summary file does not exist: $options(-summary_file)."
    sproc_pinfo -mode stop
    return fail
  }
  if { ($options(-task) == "lvs_compare") || ($options(-task) == "lvs_extract") || ($options(-task) == "drc") } {
    if { ![file exists $options(-results_file)] } {
      sproc_msg -error   "Results file does not exist: $options(-results_file)."
      sproc_pinfo -mode stop
      return fail
    }
  }

  switch $options(-task) {

    lvs_compare {
      set fid [open $options(-summary_file) r]
      sproc_msg -info "Start to echo the summary section of $options(-summary_file)."

      set pass_sum 0
      while { ([gets $fid line] >= 0) && (![regexp {^\s*Comparison summary} $line match]) } {
        puts $line
        if { [regexp {^Top .* compare result:\s*PASS} $line] } {
          set pass_sum 1
        }	
      }
      close $fid
      sproc_msg -info "End echo of $options(-summary_file)."
      sproc_msg -info "See $options(-summary_file) for additional details."

      if { $TEV(lvs_operation) == "LVS_FULL" } {
        ## We have already verified results file for full LVS runs.
	set pass_res 1
      } else {
        set fid [open $options(-results_file) r]
        set pass_res 0
        sproc_msg -info "Stat to echo $options(-results_file)."
        while { [gets $fid line] >= 0 } {
          puts $line
          if { [regexp {^.* is done.} $line] } {
            set pass_res 1
          }
        }
        close $fid
        sproc_msg -info "End echo of $options(-results_file)."
      }

      if { $pass_sum && $pass_res } {
        sproc_pinfo -mode stop
        return pass
      } else {
        sproc_msg -error "LVS comparison has failed."
        sproc_pinfo -mode stop
	return fail
      }
    }

    fill {
      set fid [open $options(-summary_file) r]

      set pass 0
      while { [gets $fid line] >= 0 } {
        if { [regexp {^IC Validator is done} $line] } {
          set pass 1
        }
        if { [regexp {^Hercules is done} $line] } {
          set pass 1
        }
      }
      close $fid

      if { $pass } {
        sproc_pinfo -mode stop
        return pass
      } else {
        sproc_msg -error "FILL insertion has failed."
        sproc_pinfo -mode stop
	return fail
      }
    }

    drc -
    lvs_extract {
      ##
      ## Verify that the run completed.
      ##
      set fid [open $options(-results_file) r]      
      set run_completed 0
      sproc_msg -info "Start to echo $options(-results_file)."
      while { [gets $fid line] >= 0 } {
        puts $line
        if { [regexp {^.* is done.} $line] } {
          set run_completed 1
        }
      }
      close $fid
      sproc_msg -info "End echo of $options(-results_file)."

      ##
      ## Verify layout results.
      ##
      set fid [open $options(-summary_file) r]
     
      sproc_msg -info "Start to echo the summary section of $options(-summary_file)."
      set rule_violations [list]
      set code Unrecognized
      set total_num_type 0
      set total_num_errors 0
      set catch_code 0
      while { [gets $fid line] >= 0 } {
        puts $line
        if { [regexp {^\s*ERROR SUMMARY} $line match] } {
	  set catch_code 1
        } elseif { [regexp {^\s*LAYOUT ERRORS RESULTS: CLEAN} $line match] } {
          break
        } elseif { [regexp {^\s*ERROR DETAILS} $line match] } {
          break
        } elseif { [regexp {^\s*Error limit exceeded} $line match] } {
	  ## Filter this line
	} elseif { [regexp {^\s*$} $line match] } {
	  ## Filter empty line
	} else {
          if { [regexp {(\d+) violations* found\.} $line match count] } {
            ## Capture error code & count.
	    if { $code == "No Comment" } {
              ##
              ## The "No Comment" text in the summary_file is absolutely useless.
              ## Try to process the first characters of the current line into something more useful.
              ## First, grab all alpha and underscore characters at start of line.
              ##
              regexp {^([\w\s]+)} $line match first_chars
              ##
              ## Next, remove all of the spaces in what we grabbed.
              ## We will use what is left as an alternate rule code.
              ##
              regsub -all { } $first_chars {} alt_code
              set code_count [list $alt_code $count]
            } else {
              set code_count [list $code $count]
            }
            lappend rule_violations $code_count
	    set catch_code 1
          } else {
            if { $catch_code } {
	      ## Look for rule code.
              if { [regexp {^\s*([\w\.\/\:]+)\s*: } $line] } {
                regexp {^\s*([\w\.\/\:]+)\s*: } $line match code
              } elseif { [regexp {^(No Comment)} $line] } {
                regexp {^(No Comment)} $line match code
              } elseif { [regexp {^([\w\.\/]+) } $line] } {
                regexp {^([\w\.\/]+) } $line match code
              } elseif { [regexp {^\s*([\w]+\:[\w]+)\s+} $line] } {
                regexp {^\s*([\w]+\:[\w]+)\s+} $line match code
	      } elseif { [regexp {^\s*(([\w]+\:[\w]+)+)\s+} $line] } {
	        regexp {^\s*(([\w]+\:[\w]+)+)\s+} $line match code          
	      } elseif { [regexp {^<([\w]+)>\s+} $line] } {
	        regexp {^<([\w]+)>\s+} $line match code
	      } elseif { [regexp {^<([\w]+\.[\w]+)>\s} $line] } {
	        regexp {^<([\w]+\.[\w]+)>\s} $line match code
	      } elseif { [regexp {^<([\w]+\.[\w]+_[\w]+)>\s} $line] } {
	        regexp {^<([\w]+\.[\w]+_[\w]+)>\s} $line match code
              } else {
                set code "Unrecognized: $line"
	      }
	      set catch_code 0
            }
          }
        }
      }
      close $fid
      sproc_msg -info "End echo of $options(-summary_file)."

      foreach rule_violation $rule_violations {
        set code  [lindex $rule_violation 0]
        set count [lindex $rule_violation 1]
	incr total_num_type
	set total_num_errors [expr $total_num_errors + [lindex $rule_violation 1]]
      }

      ##
      ## The above code created the variable "rule_violations".
      ## The format is:
      ## set rule_violations { {code1 count1} {code2 count2} ... }
      ## Source an optional script to processes this variable
      ## in order to provide detailed waiver controls.
      ## The sourced script must set the binary variable
      ## "rule_violations_error" if an error condition is found.
      ##
      ## This is turned off by default and is turned on during
      ## regression testing.  You can use this collateral to create
      ## your own waiver mechanism.
      ##
      set rule_violations_error 1

      ## DRC waiver mechanism.
      if { $TEV(check_drc) != "" } {
        sproc_source -file $TEV(check_drc)
      }

      ## Return status
      if { !$run_completed  } {
        sproc_msg -error "Run has failed to complete...see $options(-results_file) for additional details."
        return fail
      } else {
        sproc_msg -info "See $options(-summary_file) for additional details."
        if { $rule_violations_error && ([llength $rule_violations] > 0) } {
          sproc_msg -error "DRC analysis reporting errors"
          sproc_pinfo -mode stop
          return [list fail $total_num_type $total_num_errors]
        } else {
          sproc_pinfo -mode stop
          return [list pass $total_num_type $total_num_errors]
        }
      }
    }

    lcc {
      set fid [open $options(-summary_file) r]
      sproc_msg -info "Start to echo $options(-summary_file)."
      set lcc_pass 0
      set lcc_fail 0
      while { [gets $fid line] >= 0 } {
        puts $line
        if { [regexp {^PrimeYield LCC failed!} $line] } {
          set lcc_fail 1
        }
        if { [regexp {^PrimeYield LCC clear!} $line] } {
          set lcc_pass 1
        }
      }
      close $fid
      sproc_msg -info "End echo of $options(-summary_file)."

      if { $lcc_pass && !$lcc_fail } {
        set pass 1
      } else {
        set pass 0
      }

      if { $pass } {
        sproc_pinfo -mode stop
        return pass
      } else {
        sproc_msg -error "LCC analysis reporting errors."
        sproc_pinfo -mode stop
        return fail
      }
    }

    cmp {
      set fid [open $options(-summary_file) r]
      sproc_msg -info "Start to echo $options(-summary_file)."
      set pass 1
      while { [gets $fid line] >= 0 } {
        puts $line
        if { [regexp {^Number of hot spots detected [1-9]+[0-9]*} $line] } {
          set pass 0
        }
        if { [regexp {^Number of ROW band violations detected [1-9]+[0-9]*} $line] } {
          set pass 0
        }
        if { [regexp {^Number of COLUMN band violations detected [1-9]+[0-9]*} $line] } {
          set pass 0
        }
      }
      close $fid
      sproc_msg -info "End echo of $options(-summary_file)."
      
      if { $pass } {
        sproc_pinfo -mode stop
        return pass
      } else {
        sproc_msg -error "CMP analysis reporting errors."
        sproc_pinfo -mode stop
        return fail
      }
    }

  }
}

define_proc_attributes sproc_verify_pv_task \
  -info "Performs checks to verify task pass/fail status." \
  -define_args {
  {-task "Type of task being used" AnOos one_of_string {required value_help {values {lvs_compare lvs_extract fill drc lcc cmp}}} }
  {-summary_file  "Summary file used in conjunction with all checkes" AString string optional}
  {-results_file  "Results file used in conjunction with lvs checkes" AString string optional}
}

## -----------------------------------------------------------------------------
## sproc_metric_verify:
## -----------------------------------------------------------------------------

proc sproc_metric_verify { args } {

  sproc_pinfo -mode start

  global env SEV SVAR TEV
  global LYNX

  if { ( $SEV(metrics_enable) == 0 ) } {
    sproc_pinfo -mode stop
    return
  }

  set options(-tool) ""
  set options(-pass) 0
  set options(-num_type) ""
  set options(-num_errors) ""
  parse_proc_arguments -args $args options

  switch $options(-tool) {

    formal {
      if { $options(-pass) } {
        sproc_msg -info "METRIC | BOOLEAN VERIFY.PASS_FORMAL | 1"
      } else {
        sproc_msg -info "METRIC | BOOLEAN VERIFY.PASS_FORMAL | 0"
      }
    }

    lvs_extract {
      if { $options(-pass) } {
        sproc_msg -info "METRIC | BOOLEAN VERIFY.LVS.PASS_EXTRACT | 1"
      } else {
        sproc_msg -info "METRIC | BOOLEAN VERIFY.LVS.PASS_EXTRACT | 0"
      }

      if { $options(-num_type) == "" } {
        sproc_msg -info "METRIC | INTEGER VERIFY.LVS.NUM_TYPES | NaM"
      } else {
        sproc_msg -info "METRIC | INTEGER VERIFY.LVS.NUM_TYPES | $options(-num_type)"
      }
      
      if { $options(-num_errors) == "" } {
        sproc_msg -info "METRIC | INTEGER VERIFY.LVS.NUM_ERRORS | NaM"
      } else {
        sproc_msg -info "METRIC | INTEGER VERIFY.LVS.NUM_ERRORS | $options(-num_errors)"
      }
      
      if { $SVAR(tech,drc_tool) == "icv" } {
	sproc_msg -info "METRIC | STRING VERIFY.LVS.TOOL | ICV"
      } else {
	sproc_msg -info "METRIC | STRING VERIFY.LVS.TOOL | HERC"
      }

    }

    lvs_compare {
      if { $options(-pass) } {
        sproc_msg -info "METRIC | BOOLEAN VERIFY.LVS.PASS_COMPARE | 1"
      } else {
        sproc_msg -info "METRIC | BOOLEAN VERIFY.LVS.PASS_COMPARE | 0"
      }
    }

    fill {
      if { $options(-pass) } {
        sproc_msg -info "METRIC | BOOLEAN VERIFY.PASS_FILL | 1"
      } else {
        sproc_msg -info "METRIC | BOOLEAN VERIFY.PASS_FILL | 0"
      }
    }

    drc {
      if { $options(-pass) } {
        sproc_msg -info "METRIC | BOOLEAN VERIFY.DRC.PASS | 1"
      } else {
        sproc_msg -info "METRIC | BOOLEAN VERIFY.DRC.PASS | 0"
      }

      if { $options(-num_type) == "" } {
        sproc_msg -info "METRIC | INTEGER VERIFY.DRC.NUM_TYPES | NaM"
      } else {
        sproc_msg -info "METRIC | INTEGER VERIFY.DRC.NUM_TYPES | $options(-num_type)"
      }
      
      if { $options(-num_errors) == "" } {
        sproc_msg -info "METRIC | INTEGER VERIFY.DRC.NUM_ERRORS | NaM"
      } else {
        sproc_msg -info "METRIC | INTEGER VERIFY.DRC.NUM_ERRORS | $options(-num_errors)"
      }
      
      if { $SVAR(tech,drc_tool) == "icv" } {
	sproc_msg -info "METRIC | STRING VERIFY.DRC.TOOL | ICV"
      } else {
	sproc_msg -info "METRIC | STRING VERIFY.DRC.TOOL | HERC"
      }

    }

    lcc {
      if { $options(-pass) } {
        sproc_msg -info "METRIC | BOOLEAN VERIFY.PASS_LCC | 1"
      } else {
        sproc_msg -info "METRIC | BOOLEAN VERIFY.PASS_LCC | 0"
      }
    }

    cmp {
      if { $options(-pass) } {
        sproc_msg -info "METRIC | BOOLEAN VERIFY.PASS_CMP | 1"
      } else {
        sproc_msg -info "METRIC | BOOLEAN VERIFY.PASS_CMP | 0"
      }
    }

  }

  sproc_pinfo -mode stop
}

define_proc_attributes sproc_metric_verify \
  -info "Gathers verification information for metrics reporting." \
  -define_args {
  {-tool "Type of tool being used" AnOos one_of_string
    {required value_help {values {formal lvs_extract lvs_compare fill drc lcc cmp}}}
  }
  {-pass "Flag to indicate successful verification." "" boolean optional}
  {-num_type "Number of DRC error types." "" int optional}
  {-num_errors "Total number of DRC errors." "" int optional}
}

## -----------------------------------------------------------------------------
## sproc_metric_atpg:
## -----------------------------------------------------------------------------

proc sproc_metric_atpg { args } {

  sproc_pinfo -mode start

  global env SEV SVAR TEV

  if { ( $SEV(metrics_enable) == 0 ) } {
    sproc_pinfo -mode stop
    return
  }

  parse_proc_arguments -args $args options

  ## Set default values

  set total_faults NaM
  set test_coverage NaM
  set fault_coverage 0
  set atpg_effectiveness 0

  ## Generate and parse report

  redirect -variable report {
    report_summaries
  }

  set fault_types "Iddq Transition Path_delay Bridging Dynamic_bridging Hold_time IDDQ_bridging"

  foreach fault_type $fault_types {
    set ${fault_type}_faults "NaM"
    set ${fault_type}_coverage "NaM"
  }
  set lines [split $report "\n"]
  foreach line $lines {
    foreach fault_type $fault_types {
      regexp "$fault_type\\s+\(\[\\.\\d\]+\)\\s+\(\[\\.\\d\]+\)\\%" $line matchVar ${fault_type}_faults ${fault_type}_coverage
      regexp {total faults\s+([\d]+)} $line matchVar total_faults
      regexp {test coverage\s+([\.\d]+)\%} $line matchVar fault_coverage
    }
  }

  ## Print results

  sproc_msg -info "METRIC | INTEGER ATPG.TRANSITION.FAULTS         | $Transition_faults"
  sproc_msg -info "METRIC | DOUBLE  ATPG.TRANSITION.COVERAGE       | $Transition_coverage"
  sproc_msg -info "METRIC | INTEGER ATPG.BRIDGING.FAULTS           | $Bridging_faults"
  sproc_msg -info "METRIC | DOUBLE  ATPG.BRIDGING.COVERAGE         | $Bridging_coverage"
  sproc_msg -info "METRIC | INTEGER ATPG.HOLD_TIME.FAULTS          | $Hold_time_faults"
  sproc_msg -info "METRIC | DOUBLE  ATPG.HOLD_TIME.COVERAGE        | $Hold_time_coverage"
  sproc_msg -info "METRIC | INTEGER ATPG.IDDQ_BRIDGING.FAULTS      | $IDDQ_bridging_faults"
  sproc_msg -info "METRIC | DOUBLE  ATPG.IDDQ_BRIDGING.COVERAGE    | $IDDQ_bridging_coverage"
  sproc_msg -info "METRIC | INTEGER ATPG.IDDQ.FAULTS               | $Iddq_faults"
  sproc_msg -info "METRIC | DOUBLE  ATPG.IDDQ.COVERAGE             | $Iddq_coverage"
  sproc_msg -info "METRIC | INTEGER ATPG.PATH_DELAY.FAULTS         | $Path_delay_faults"
  sproc_msg -info "METRIC | DOUBLE  ATPG.PATH_DELAY.COVERAGE       | $Path_delay_coverage"
  sproc_msg -info "METRIC | INTEGER ATPG.DYNAMIC_BRIDGING.FAULTS   | $Dynamic_bridging_faults"
  sproc_msg -info "METRIC | DOUBLE  ATPG.DYNAMIC_BRIDGING.COVERAGE | $Dynamic_bridging_coverage"
  sproc_msg -info "METRIC | INTEGER ATPG.STUCK_AT.FAULTS   | $total_faults"
  sproc_msg -info "METRIC | DOUBLE  ATPG.STUCK_AT.COVERAGE | $fault_coverage"
  sproc_pinfo -mode stop
}

define_proc_attributes sproc_metric_atpg \
  -info "Gathers ATPG information for metrics reporting." \
  -define_args {
}

## -----------------------------------------------------------------------------
## sproc_metric_normalize:
## -----------------------------------------------------------------------------

proc sproc_metric_normalize { args } {

  sproc_pinfo -mode start

  ## table contains the multiplier for converting from supplied unit to normalized default
  set default_power_unit mw
  set normalize_lut(w)    1e+3
  set normalize_lut(mw)   1e+0
  set normalize_lut(uw)   1e-3
  set normalize_lut(nw)   1e-6
  set normalize_lut(pw)   1e-9

  set default_time_unit ps
  set normalize_lut(s)    1e+12
  set normalize_lut(ns)   1e+3
  set normalize_lut(ps)   1e+0

  set default_area_unit um
  set normalize_lut(nm)   1e-3
  set normalize_lut(um)   1e+0
  set normalize_lut(m)    1e+6

  set options(-value) ""
  set options(-current_unit) ""

  parse_proc_arguments -args $args options

  set val $options(-value)

  if { $val=="NaM" } {
    sproc_msg -info "Passing through special case value $val"
    sproc_pinfo -mode stop
    return $val
  }

  if { ![scan $val "%f" match] } {
    sproc_msg -error "sproc_metric_normalize cannot process value $val"
    sproc_pinfo -mode stop
    return "NaM"
  }

  if { $options(-current_unit) != "" } {
    set cur_unit [string tolower $options(-current_unit)]
    if { [array names normalize_lut -exact $cur_unit] != "" } {
      set norm_scalar $normalize_lut($cur_unit)
    } else {
      sproc_msg -error "sproc_metric_normalize not configured to convert $cur_unit"
      sproc_pinfo -mode stop
      return "NaM"
    }
  }

  set val_out [expr $val * $norm_scalar]

  sproc_pinfo -mode stop

  return $val_out

}

define_proc_attributes sproc_metric_normalize \
  -info "Used to convert metric numbers from one unit standard to another." \
  -define_args {
  {-value "value to convert" decimal string required}
  {-current_unit "Units of current value" AString string required}
}

## -----------------------------------------------------------------------------
## sproc_metric_format:
## -----------------------------------------------------------------------------

proc sproc_metric_format { format_string arg } {
  if { $arg == "NaM" } {
    return "NaM"
  } else {
    return [format $format_string $arg]
  }
}

define_proc_attributes sproc_metric_format \
  -info "Used to return NaM value or formatted value as part of metrics processing." \
  -define_args {
}

## -----------------------------------------------------------------------------
## sproc_metric_time_elapsed:
## -----------------------------------------------------------------------------

proc sproc_metric_time_elapsed { args } {

  sproc_pinfo -mode start

  set options(-start) 0
  set options(-stop) 0
  parse_proc_arguments -args $args options

  set seconds_in_day [expr 24 * 3600.0]
  set total_seconds [expr $options(-stop) - $options(-start)]
  set num_days_f [expr floor($total_seconds / $seconds_in_day)]
  set partial_day_f [expr ($total_seconds / $seconds_in_day) - $num_days_f]
  set num_days [expr int($num_days_f)]
  set partial_day [expr int($partial_day_f * $seconds_in_day)]
  set hms [clock format $partial_day -format %T -gmt true]
  set dhms [format "%02d:%s" $num_days $hms]

  sproc_pinfo -mode stop
  return "$dhms"
}

define_proc_attributes sproc_metric_time_elapsed \
  -info "Used to generate metrics related to duration of task execution." \
  -define_args {
  {-start "Indicates start time in seconds." "" int required}
  {-stop  "Indicates stop time in seconds." "" int required}
}

## -----------------------------------------------------------------------------
## sproc_rpt_start:
## -----------------------------------------------------------------------------

proc sproc_rpt_start {} {
  global SNPS_rpt_time_start

  set SNPS_rpt_time_start [clock seconds]
}

define_proc_attributes sproc_rpt_start \
  -info "Called at start of report processing. Used for metrics generation." \
  -define_args {
}

## -----------------------------------------------------------------------------
## sproc_rpt_stop:
## -----------------------------------------------------------------------------

proc sproc_rpt_stop { args } {
  global SNPS_rpt_time_start

  parse_proc_arguments -args $args options

  set SNPS_rpt_time_stop [clock seconds]

  set time_total_seconds [expr $SNPS_rpt_time_stop - $SNPS_rpt_time_start]
  set dhms [sproc_metric_time_elapsed -start $SNPS_rpt_time_start -stop $SNPS_rpt_time_stop]
  sproc_msg -info "METRIC | TIME INFO.ELAPSED_TIME.REPORT | $time_total_seconds"
  sproc_msg -info "INFO.ELAPSED_TIME.REPORT | $dhms"
}

define_proc_attributes sproc_rpt_stop \
  -info "Called at stop of report processing. Used for metrics generation." \
  -define_args {
}

## -----------------------------------------------------------------------------
## sproc_copyMDB:
## -----------------------------------------------------------------------------

proc sproc_copyMDB { args } {

  sproc_pinfo -mode start

  global env SEV SVAR TEV
  global synopsys_program_name

  set options(-update_reflib) 0
  parse_proc_arguments -args $args options

  sproc_msg -info "Starting sproc_copyMDB : [date]"

  ## -------------------------------------
  ## Check for open library ..
  ## -------------------------------------

  switch $synopsys_program_name {
    "milkyway" -
    "icc_shell" {
      redirect /dev/null {catch {set tmp [current_mw_lib]}}
      if { $tmp != "" } {
        sproc_msg -warning "Milkyway library '[get_attribute [current_mw_lib] path]' is already open."
        sproc_pinfo -mode stop
        return
      }
    }
    default {
      sproc_msg -warning "Unable to verify if MW is open so assuming it is not."
    }
  }

  ## -------------------------------------
  ## Check for src library == dst library
  ## -------------------------------------

  if { $options(-src) == $options(-dst) } {
    sproc_msg -warning "Milkyway source '$options(-src)' equals destination '$options(-dst)', so not copying."
    sproc_pinfo -mode stop
    return
  }

  ## Check for existence of source library
  if { ![file exists $options(-src)] } {
    sproc_msg -error "Milkyway source library '$options(-src)' does not exist, so not copying."
    sproc_pinfo -mode stop
    return
  }

  ## Check for existence of dest library (& delete)
  if { [file exists $options(-dst)] } {
    sproc_msg -warning "Milkyway '$options(-dst)' exists, so deleting prior to copy."
    file delete -force $options(-dst)
  }

  ## -------------------------------------
  ## Copy the library
  ## -------------------------------------

  sproc_msg -info "Copying Milkyway library '$options(-src)' to '$options(-dst)'"

  switch $synopsys_program_name {
    "milkyway" -
    "icc_shell" {

      set limit_try 3
      set count_try 0
      set try_flag 1

      while { $try_flag } {
        incr count_try

        sproc_refresh_file_system -dir $options(-src)
        file delete -force $options(-dst)
        redirect -variable foo {
          #set copy_mw_lib_status [copy_mw_lib -from $SEV(src_dir)/$SVAR(design_name).mdb -to $SEV(dst_dir)/$SVAR(design_name).mdb]
          set copy_mw_lib_status [copy_mw_lib -from $options(-src) -to $options(-dst)]
	  if {[file exists $options(-dst)/ILM]}  {sh rm -rf $options(-dst)/ILM}
	  if {[file exists $options(-dst)/FRAM]} {sh rm -rf $options(-dst)/FRAM}
	  #copy_mw_cel -from_library $options(-src) -from $SEV(design_name) -to_library $options(-dst) -to $SEV(design_name)
        }

        if { $copy_mw_lib_status == 1 } {
          sproc_msg -info "The copy_mw_lib command was successful on attempt $count_try of $limit_try."
          set try_flag 0
        } else {
          if { $count_try < $limit_try } {
            sproc_msg -warning "FILE_SYSTEM_ISSUE: The copy_mw_lib command was not successful on attempt $count_try of $limit_try."
          } else {
            sproc_msg -error   "FILE_SYSTEM_ISSUE: The copy_mw_lib command was not successful on attempt $count_try of $limit_try."
            set try_flag 0
          }
        }

      }

      ## -------------------------------------
      ## Update reference libraries.
      ## Note: Generally we don't want to update reflibs without reason.
      ## Some possible reasons include:
      ## - New models, which Lynx updates automatically @ step boundaries.
      ## - Tool bugs.
      ## -------------------------------------

      if { $options(-update_reflib) } {
        set_mw_lib_reference -mw_reference_library $SVAR(lib,mw_reflist) $SEV(dst_dir)/$SVAR(design_name).mdb
      }

    }
    default {
      ## file copy -force $options(-src) $options(-dst)
      exec cp -RL $options(-src) $options(-dst)
    }
  }

  sproc_refresh_file_system -dir $options(-dst)

  sproc_msg -info "Finishing sproc_copyMDB : [date]"

  sproc_pinfo -mode stop
}

define_proc_attributes sproc_copyMDB \
  -info "Milkyway library copy procedure." \
  -define_args {
  {-src "Source milkyway library"       AString string required}
  {-dst "Destination milkyway library"  AString string required}
  {-update_reflib  "Operation in new developmental mode." "" boolean optional}
}

## -----------------------------------------------------------------------------
## sproc_remove_mw_cel:
## -----------------------------------------------------------------------------

proc sproc_remove_mw_cel { args } {

  sproc_pinfo -mode start

  global env SEV SVAR TEV
  global synopsys_program_name
  global LYNX

  set options(-skip_check) 0
  parse_proc_arguments -args $args options

  sproc_msg -info "Starting sproc_remove_mw_cel : [date]"

  ##
  ## delete redundant views from MW for those views expected 
  ##
  remove_mw_cel -verbose -all_view -version_kept 1 $SVAR(design_name)

  set view_names "$SVAR(design_name)_sdrc"
  foreach view_name $view_names {
    if { [ sizeof [ get_mw_cels -quiet $view_name.* ] ] > 0 } {
      remove_mw_cel -verbose -all_view -version_kept 1 $view_name
    }
  }

  ##
  ## interrogate the MW and look for redundant or unexpected views
  ##
  if { $options(-skip_check) } {
    sproc_msg -info "  sproc_remove_mw_cel : skip additional checks of MW."
  } else {
    sproc_msg -info "  sproc_remove_mw_cel : performing additional checks of MW."

    ##
    ## build a datastructure (ie ds) of expected and allowable views
    ##
    set num 0

    set design_names "$SVAR(design_name)"
    foreach {design_name junk} [join $SVAR(hier,macros_soft)] { 
      set design_names "$design_names $design_name"
    }

    ## expected views
    foreach design_name $design_names { 
      set ds($num,name) "$design_name\.CEL"
      set ds($num,hit) 0
      incr num
      set ds($num,name) "$design_name\.ILM"
      set ds($num,hit) 0
      incr num
      set ds($num,name) "$design_name\.FILL"
      set ds($num,hit) 0
      incr num
      set ds($num,name) "$design_name\.FRAM"
      set ds($num,hit) 0
      incr num
      set ds($num,name) "$design_name\.err"
      set ds($num,hit) 0
      incr num
    }

    ## from "verify_lvs"
    set ds($num,name) "$SVAR(design_name)_lvs\.err"
    set ds($num,hit) 0
    incr num

    ## from "signoff_drc"
    set ds($num,name) "$SVAR(design_name)_sdrc\.err"
    set ds($num,hit) 0
    incr num

    ## from "fix_signal_em"
    set ds($num,name) "$SVAR(design_name)_signalem\.err"
    set ds($num,hit) 0
    incr num

    ## from "analyze_rail" ... not sure about the robustness of this list
    set ds($num,name) "$SVAR(design_name)\.PARA"
    set ds($num,hit) 0
    incr num
    set ds($num,name) "$SVAR(design_name)\.RAIL"
    set ds($num,hit) 0
    incr num
    set ds($num,name) "$SVAR(design_name)_VDD_integrity\.err"
    set ds($num,hit) 0
    incr num
    set ds($num,name) "$SVAR(design_name)_VSS_integrity\.err"
    set ds($num,hit) 0
    incr num
    set ds($num,name) "$SVAR(design_name)_VDD_export\.err"
    set ds($num,hit) 0
    incr num
    set ds($num,name) "$SVAR(design_name)_VSS_export\.err"
    set ds($num,hit) 0
    incr num

    ## from "signoff_autofix_drc"
    set ds($num,name) "$SVAR(design_name)_ADR_sdrc\.err"
    set ds($num,hit) 0
    incr num
    set ds($num,name) "$SVAR(design_name)_ADR_1_sdrc\.err"
    set ds($num,hit) 0
    incr num
    set ds($num,name) "$SVAR(design_name)_signoff_fix\.err"
    set ds($num,hit) 0
    incr num

    ##
    ## grab the complete list of views in the MW
    ##
    redirect "$SEV(dst_dir)/$SVAR(design_name).list_mw_cels.0" { 
      list_mw_cels -all_views -all_versions  
    }

    ##
    ## mark identifiable items from datastructure (ie ds) as "VALID"
    ##
    set fid_in  [open "$SEV(dst_dir)/$SVAR(design_name).list_mw_cels.0" r]
    set fid_out [open "$SEV(dst_dir)/$SVAR(design_name).list_mw_cels.1" w]
    while { [gets $fid_in line] >= 0 } {
      if { [ regexp "^1" $line ] } {
        ## skip
      } else {
        set hit 0
        for {set i 0} {$i < $num} {incr i} {
          if { ( $ds($i,hit) == 0 ) && [ regexp $ds($i,name) $line ] } {
            puts $fid_out "VALID $line"
            set ds($i,hit) 1
            set hit 1
            break
          }
        }
        if { $hit == 0 } {
          puts $fid_out "$line"
        }
      }
    }
    close $fid_in
    close $fid_out

    ##
    ## list views not marked as "VALID" for follow-up
    ##
    set cnt 0
    set fid_in  [open "$SEV(dst_dir)/$SVAR(design_name).list_mw_cels.1" r]
    while { [gets $fid_in line] >= 0 } {
      if { [ regexp "VALID " $line ] == 0 } {
        if { $LYNX(regression_testing) } {
          sproc_msg -error "  sproc_remove_mw_cel : \"$line\" is an unexpected or redundant view found in the MW.  Please investigate."
        } else {
          sproc_msg -warning "  sproc_remove_mw_cel : \"$line\" is an unexpected or redundant view found in the MW.  Please investigate."
        }
        incr cnt
      }
    }
  
    if { $cnt == 0 } {
      sproc_msg -info "  sproc_remove_mw_cel : $cnt unexpected or redundant views found in the MW."
    } else {
      if { $LYNX(regression_testing) } {
        sproc_msg -error "  sproc_remove_mw_cel : $cnt unexpected or redundant views found in the MW.  Please investigate."
      } else {
        sproc_msg -warning "  sproc_remove_mw_cel : $cnt unexpected or redundant views found in the MW.  Please investigate."
      }
    }
  }

  sproc_msg -info "Finishing sproc_remove_mw_cel : [date]"

  sproc_pinfo -mode stop
}

define_proc_attributes sproc_remove_mw_cel \
  -info "Perform a remove_mw_cel and additional MW view integrity validation." \
  -define_args {
    {-skip_check  "Skip an additional check looking for redundant or unrecognized views in MW." "" boolean optional}
}

## -----------------------------------------------------------------------------
## sproc_pt_sdc:
## -----------------------------------------------------------------------------

proc sproc_pt_sdc { args } {

  sproc_pinfo -mode start

  global env SEV SVAR TEV

  ## -------------------------------------
  ## Get arguments
  ## -------------------------------------

  set options(-scenario) ""
  parse_proc_arguments -args $args options

  ## -------------------------------------
  ## Get individual components of requested scenario.
  ## -------------------------------------

  set MM_TYPE [sproc_get_scenario_info -scenario $options(-scenario) -type mm_type]
  set OC_TYPE [sproc_get_scenario_info -scenario $options(-scenario) -type lib_condition]
  set RC_TYPE [sproc_get_scenario_info -scenario $options(-scenario) -type rc_type]

  ## -------------------------------------
  ## Find best-suited SDC file.
  ## -------------------------------------

  set use_mcmm_sdc 0

  if { [regexp {^10_syn} $SEV(step)] } {
    if { $SVAR(mcmm,enable_dc) } {
      set use_mcmm_sdc 1
    }
  } else {
    set use_mcmm_sdc 1
  }

  if { $use_mcmm_sdc == 0 } {

    set fname_src_sdc $SEV(src_dir)/$SVAR(design_name).sdc

    sproc_msg -info "sproc_pt_sdc: Looking for non-MCMM SDC file."
    sproc_msg -info "sproc_pt_sdc:   $fname_src_sdc"

    if { [file exists $fname_src_sdc] } {
      sproc_msg -info  "sproc_pt_sdc: Non-MCMM SDC file was found."
    } else {
      sproc_msg -error "sproc_pt_sdc: Non-MCMM SDC file was not found."
      sproc_script_stop -exit
    }

  } else {

    set fname_src_sdc $SEV(src_dir)/$SVAR(design_name).$options(-scenario).sdc

    sproc_msg -info "sproc_pt_sdc: Looking for Exact MCMM SDC file."
    sproc_msg -info "sproc_pt_sdc:   $fname_src_sdc"

    if { [file exists $fname_src_sdc] } {

      sproc_msg -info  "sproc_pt_sdc: Exact MCMM SDC file was found."

    } else {

      sproc_msg -info  "sproc_pt_sdc: Exact MCMM SDC file was not found."

      set alt_sdc_files [list]
      sproc_msg -info  "sproc_pt_sdc: Globbing for $SEV(src_dir)/$SVAR(design_name).$MM_TYPE.$OC_TYPE.*.sdc"
      set alt_sdc_files [concat $alt_sdc_files [glob -nocomplain $SEV(src_dir)/$SVAR(design_name).$MM_TYPE.$OC_TYPE.*.sdc]]
      sproc_msg -info  "sproc_pt_sdc: Globbing for $SEV(src_dir)/$SVAR(design_name).$MM_TYPE.*.*.sdc"
      set alt_sdc_files [concat $alt_sdc_files [glob -nocomplain $SEV(src_dir)/$SVAR(design_name).$MM_TYPE.*.*.sdc]]

      if { [llength $alt_sdc_files] > 0 } {
        set fname_src_sdc [lindex $alt_sdc_files 0]
        sproc_msg -info  "sproc_pt_sdc: Non-exact MCMM SDC file was found."
        sproc_msg -info  "sproc_pt_sdc:   $fname_src_sdc"
      } else {
        sproc_msg -error "sproc_pt_sdc: Non-exact MCMM SDC file was not found."
        sproc_script_stop -exit
      }

    }

  }

  ## -------------------------------------
  ## Define file naming conventions
  ## -------------------------------------

  set fname_filtered_sdc "$SEV(dst_dir)/[file tail $fname_src_sdc].$options(-scenario)"
  set fname_bad_sdc      "$SEV(dst_dir)/[file tail $fname_src_sdc].$options(-scenario).bad"

  sproc_msg -info "sproc_pt_sdc: Using $fname_src_sdc as source SDC."
  sproc_msg -info "sproc_pt_sdc: Using $fname_filtered_sdc as filtered SDC."
  sproc_msg -info "sproc_pt_sdc: Using $fname_bad_sdc as bad SDC."

  ## Open files
  set fid_src_sdc      [open "$fname_src_sdc"  r]
  set fid_filtered_sdc [open "$fname_filtered_sdc" w]
  set fid_bad_sdc      [open "$fname_bad_sdc"      w]

  set partial_line ""
  while { [gets $fid_src_sdc tmp_line] >= 0 } {

    ## Handle lines ending with "\"
    if { [regexp {\\$} $tmp_line] } {
      regsub {\\$} $tmp_line {} tmp_line
      append partial_line $tmp_line
      continue
    } else {
      append partial_line $tmp_line
      set line $partial_line
      set partial_line ""
    }

    ## Perform filtering

    switch -regexp $line {

      {set_ideal_network .*logic_[0-1]*} - 
      {set_wire_load_mode} -
      {set_wire_load_model} -
      {set_operating_conditions} {
        puts $fid_bad_sdc "$line"
      }
      {set_driving_cell} {
        puts $fid_bad_sdc "$line"
        regsub {\-library\s+([\w\.]+)\s+} $line "" line
        puts $fid_filtered_sdc "$line"
      }

      default {
        puts $fid_filtered_sdc "$line"
      }

    }
  }

  ## Close files
  close $fid_src_sdc
  close $fid_filtered_sdc
  close $fid_bad_sdc

  ## read the SDC
  sproc_msg -info "sproc_pt_sdc:   reading $fname_filtered_sdc as valid PT SDC."
  read_sdc $fname_filtered_sdc

  sproc_pinfo -mode stop
}

define_proc_attributes sproc_pt_sdc \
  -info "Procedure to filter SDC files for PT and then read them." \
  -define_args {
    {-scenario "The scenario to make sure all PT runs generate unique files " AString string required}
  }

## -----------------------------------------------------------------------------
## sproc_pt_upf:
## -----------------------------------------------------------------------------

proc sproc_pt_upf { args } {

  sproc_pinfo -mode start

  global env SEV SVAR TEV

  ## -------------------------------------
  ## Get arguments
  ## -------------------------------------

  set fname_src_upf $SEV(src_dir)/$SVAR(design_name).upf

  sproc_msg -info "sproc_pt_upf:   $fname_src_upf"

  ## -------------------------------------
  ## Define file naming conventions
  ## -------------------------------------

  set fname_filtered_upf "$SEV(dst_dir)/[file tail $fname_src_upf].filtered"

  sproc_msg -info "sproc_pt_upf: Using $fname_src_upf as source UPF."
  sproc_msg -info "sproc_pt_upf: Using $fname_filtered_upf as filtered UPF."

  ## Open files
  set fid_src_upf      [open "$fname_src_upf"  r]
  set fid_filtered_upf [open "$fname_filtered_upf" w]

  set partial_line ""
  while { [gets $fid_src_upf tmp_line] >= 0 } {

    ## Handle lines ending with "\"
    if { [regexp {\\$} $tmp_line] } {
      regsub {\\$} $tmp_line {} tmp_line
      append partial_line $tmp_line
      continue
    } else {
      append partial_line $tmp_line
      set line $partial_line
      set partial_line ""
    }

    ## Perform filtering

    switch -regexp $line {

      {set_related_supply_net} {
        regsub {\-power } $line "" line
        regsub {\-ground } $line "" line
        puts "sproc_pt_upf: Power/Ground construct being filtered"
        puts $fid_filtered_upf "$line"
      }

      default {
        puts $fid_filtered_upf "$line"
      }

    }
  }

  ## Close files
  close $fid_src_upf
  close $fid_filtered_upf

  sproc_pinfo -mode stop
}

define_proc_attributes sproc_pt_upf \
  -info "Procedure to filter UPF files for PT and then read them." \
  -define_args {
}

## -----------------------------------------------------------------------------
## sproc_pt_adjust_virtual_clock_latency:
## -----------------------------------------------------------------------------

proc sproc_pt_adjust_virtual_clock_latency { args } {

  sproc_pinfo -mode start

  global env SEV SVAR TEV

  set options(-max) 0
  set options(-min) 0
  parse_proc_arguments -args $args options

  if { $options(-max) & $options(-min) } {
    sproc_msg -error "sproc_pt_adjust_virtual_clock_latency: Cannot select both -max and -min"
    sproc_pinfo -mode stop
    return
  }

  foreach_in_collection clock [get_clocks -quiet] {
    set clock_name [get_object_name $clock]
    set clock_sources [get_attribute $clock sources]
    if { [sizeof_collection $clock_sources] == 0 } {

      set org_clock_latency_rise_max [get_attribute -quiet $clock clock_latency_rise_max]
      set org_clock_latency_fall_max [get_attribute -quiet $clock clock_latency_fall_max]
      set org_clock_latency_rise_min [get_attribute -quiet $clock clock_latency_rise_min]
      set org_clock_latency_fall_min [get_attribute -quiet $clock clock_latency_fall_min]

      set adj_clock_latency_rise_max $org_clock_latency_rise_max
      set adj_clock_latency_fall_max $org_clock_latency_fall_max
      set adj_clock_latency_rise_min $org_clock_latency_rise_min
      set adj_clock_latency_fall_min $org_clock_latency_fall_min

      if { $options(-max) } {
        set adj_clock_latency_rise_min $org_clock_latency_rise_max
        set adj_clock_latency_fall_min $org_clock_latency_fall_max
      }
      if { $options(-min) } {
        set adj_clock_latency_rise_max $org_clock_latency_rise_min
        set adj_clock_latency_fall_max $org_clock_latency_fall_min
      }

      sproc_msg -info "Virtual Clock : $clock_name"
      sproc_msg -info "Original latency info:"
      sproc_msg -info "  clock_latency_rise_max: $org_clock_latency_rise_max"
      sproc_msg -info "  clock_latency_fall_max: $org_clock_latency_fall_max"
      sproc_msg -info "  clock_latency_rise_min: $org_clock_latency_rise_min"
      sproc_msg -info "  clock_latency_fall_min: $org_clock_latency_fall_min"
      sproc_msg -info "Adjusted latency info:"
      sproc_msg -info "  clock_latency_rise_max: $adj_clock_latency_rise_max"
      sproc_msg -info "  clock_latency_fall_max: $adj_clock_latency_fall_max"
      sproc_msg -info "  clock_latency_rise_min: $adj_clock_latency_rise_min"
      sproc_msg -info "  clock_latency_fall_min: $adj_clock_latency_fall_min"

      set_clock_latency -rise -max $adj_clock_latency_rise_max $clock
      set_clock_latency -fall -max $adj_clock_latency_fall_max $clock
      set_clock_latency -rise -min $adj_clock_latency_rise_min $clock
      set_clock_latency -fall -min $adj_clock_latency_fall_min $clock

    }
  }

  sproc_pinfo -mode stop
}

define_proc_attributes sproc_pt_adjust_virtual_clock_latency \
  -info "Procedure to filter SDC files for PT and then read them." \
  -define_args {
  {-max "Set all latencies for virtual clocks to max values." "" boolean optional}
  {-min "Set all latencies for virtual clocks to min values." "" boolean optional}
}

## -----------------------------------------------------------------------------
## sproc_upf_adjust: procedure for processing UPF files for ICC
## -----------------------------------------------------------------------------

proc sproc_upf_adjust { args } {

  sproc_pinfo -mode start

  global SEV SVAR

  ## -------------------------------------
  ## Get arguments
  ## -------------------------------------

  set fname_src_upf $SEV(src_dir)/$SVAR(design_name).upf

  sproc_msg -info "sproc_upf_adjust:   $fname_src_upf"

  ## -------------------------------------
  ## Define file naming conventions
  ## -------------------------------------

  set fname_filtered_upf "$SEV(dst_dir)/[file tail $fname_src_upf].filtered"

  sproc_msg -info "sproc_upf_adjust: Using $fname_src_upf as source UPF."
  sproc_msg -info "sproc_upf_adjust: Using $fname_filtered_upf as filtered UPF."

  ## Open files
  set fid_src_upf      [open "$fname_src_upf"  r]
  set fid_filtered_upf [open "$fname_filtered_upf" w]

  while { [gets $fid_src_upf line] >= 0 } {

    ## Perform filtering

    switch -regexp $line {

      {create_supply_port} {
        foreach mac_inst [sproc_get_macros -inst -hard -no_auto] {
          if {[regexp "create_supply_port $mac_inst.*" $line]} {
            set line "#$line"
            sproc_msg -info "sproc_upf_adjust: removing this line from upf: $line"
          }
        }
      }

      default {
      }

    }
    puts $fid_filtered_upf "$line"
  }

  ## Close files
  close $fid_src_upf
  close $fid_filtered_upf

  sproc_pinfo -mode stop
}

define_proc_attributes sproc_upf_adjust \
  -info "Used to make required modifications to UPF in hierarchica flow." \
  -define_args {
}

## -----------------------------------------------------------------------------
## sproc_icc_mcmm_scenario_list_not:
## -----------------------------------------------------------------------------

proc sproc_icc_mcmm_scenario_list_not { args } {

  sproc_pinfo -mode start

  ## Get arguments
  set options(-base_list)  ""
  set options(-removal_list)  ""
  parse_proc_arguments -args $args options

  set not_list [list]
  foreach scenario $options(-base_list) {
    if { [lsearch $options(-removal_list) $scenario] < 0 } {
      lappend not_list $scenario
    }
  }

  return $not_list

  sproc_pinfo -mode stop

}

define_proc_attributes sproc_icc_mcmm_scenario_list_not \
  -info "Procedure to return the list of non intersecting elements." \
  -define_args {
  {-base_list  "The original list " AString string required}
  {-removal_list  "The removal list " AString string required}
}

## -----------------------------------------------------------------------------
## sproc_icc_mcmm_sdc:
## -----------------------------------------------------------------------------

proc sproc_icc_mcmm_sdc { args } {

  sproc_pinfo -mode start

  global env SEV SVAR TEV

  ## Get arguments
  set options(-src_sdc)  ""
  set options(-new_mode)  0
  parse_proc_arguments -args $args options

  ## Validate src_sdc exists ... if not look for cloning candidate
  set src_sdc $options(-src_sdc)
  if { ![file exists $src_sdc] } {
    sproc_msg -warning "sproc_icc_mcmm_sdc: Specified SDC file $src_sdc does not exist."

    sproc_msg -warning "sproc_icc_mcmm_sdc:   We are looking to clone from the same mode."
    set tmp [ file rootname [ file rootname [ file rootname $src_sdc ] ] ]
    set tmp [ glob -nocomplain $tmp*.sdc ]

    if { [llength $tmp] > 0 } {
      foreach t $tmp {
        sproc_msg -warning "sproc_icc_mcmm_sdc:     Note cloning candidates include $t"
      }
      set src_sdc [lindex $tmp 0]
    } else {
      sproc_msg -warning "sproc_icc_mcmm_sdc:   Unable to clone from the same mode."
      sproc_msg -warning "sproc_icc_mcmm_sdc:   We are now looking to clone from a non scenario based sdc."
      set tmp "[ file rootname [ file rootname [ file rootname [ file rootname $src_sdc ] ] ] ].sdc"
      if { [file exists $tmp] } {
        set src_sdc [lindex $tmp 0]
      } else {
        sproc_msg -error "sproc_icc_mcmm_sdc: Unable to resolve an SDC for $options(-src_sdc)"
        sproc_pinfo -mode stop
        return
      }
    }
    sproc_msg -warning "sproc_icc_mcmm_sdc:   Cloning from $src_sdc"
  }

  ## Define file naming conventions
  set fname_filtered_sdc "$SEV(dst_dir)/[file tail $options(-src_sdc)]"
  set fname_bad_sdc      "$SEV(dst_dir)/[file tail $options(-src_sdc)].bad"

  sproc_msg -info "sproc_icc_mcmm_sdc:   Using $src_sdc as source SDC."
  sproc_msg -info "sproc_icc_mcmm_sdc:   Using $fname_filtered_sdc as filtered SDC."
  sproc_msg -info "sproc_icc_mcmm_sdc:   Using $fname_bad_sdc as bad SDC."

  ## Open files
  set fid_src_sdc      [open "$src_sdc"  r]
  set fid_filtered_sdc [open "$fname_filtered_sdc" w]
  set fid_bad_sdc      [open "$fname_bad_sdc"      w]

  set partial_line ""
  while { [gets $fid_src_sdc tmp_line] >= 0 } {

    ## Handle lines ending with "\"
    if { [regexp {\\$} $tmp_line] } {
      regsub {\\$} $tmp_line {} tmp_line
      append partial_line $tmp_line
      continue
    } else {
      append partial_line $tmp_line
      set line $partial_line
      set partial_line ""
    }

    ## Perform filtering
    switch -regexp $line {
      {set_voltage} -
      {create_voltage_area} -
      {set_operating_conditions} {
        puts $fid_bad_sdc "$line"
      }
      default {
        puts $fid_filtered_sdc "$line"
      }
    }
  }

  ## Close files
  close $fid_src_sdc
  close $fid_filtered_sdc
  close $fid_bad_sdc

  ## read the SDC
  if { $options(-new_mode) } {
    sproc_msg -info "sproc_icc_mcmm_sdc:   identifed $fname_filtered_sdc as valid ICC MCMM SDC."
    sproc_pinfo -mode stop
    return $fname_filtered_sdc
  } else {
    sproc_msg -info "sproc_icc_mcmm_sdc:   reading $fname_filtered_sdc as valid ICC MCMM SDC."
    read_sdc $fname_filtered_sdc
  }

  sproc_pinfo -mode stop
}

define_proc_attributes sproc_icc_mcmm_sdc \
  -info "Procedure to filter SDC files for ICC MCMM and then read them." \
  -define_args {
  {-src_sdc  "The original SDC files to filter " AString string required}
  {-new_mode  "Operation in new developmental mode." "" boolean optional}
}

## -----------------------------------------------------------------------------
## sproc_filter_def :
## -----------------------------------------------------------------------------

proc sproc_filter_def  { args } {

  sproc_pinfo -mode start

  global env SEV SVAR TEV

  ## Get arguments
  set options(-src_def)  ""
  set options(-dst_def)  ""
  set options(-purge_SCANCHAINS)  0
  set options(-purge_nonfixed_COMPONENTS)  0
  set options(-purge_switch_cells)  0
  parse_proc_arguments -args $args options

  ## Validate src_def exists.

  set number_of_deleted_components 0

  ## ----------------------------------------
  ##
  ## purge scan chains
  ##

  ## Open files
  set fid_src [open "$options(-src_def)" r]
  set fid_dst [open "$options(-dst_def).1" w]
 
  set mode "copy" 
  while { [gets $fid_src line] >= 0 } {

    if { $mode == "copy" } {
      if { $options(-purge_SCANCHAINS) && [regexp {^SCANCHAINS\s+([\d]+)\s+;} $line] } { 
        sproc_msg -info "Purging SCANCHAINS section."
        set mode "purge_SCANCHAINS"
      } else { 
        puts $fid_dst $line
      }
    } elseif { $mode == "purge_SCANCHAINS" } {
      if { [regexp {^END\s+SCANCHAINS} $line] } { 
        set mode "copy"
      }
    } else {
      puts $fid_dst $line
    }

  }

  ## Close files
  close $fid_src
  close $fid_dst

  ## ----------------------------------------
  ##
  ## purge non fixed components
  ##

  ## Open files
  set fid_src [open "$options(-dst_def).1" r]
  set fid_dst [open "$options(-dst_def).2" w]
 
  set mode "copy" 
  while { [gets $fid_src line] >= 0 } {

    if { $mode == "copy" } {
      if { $options(-purge_nonfixed_COMPONENTS) && [regexp {^COMPONENTS\s+([\d]+)\s+;} $line] } { 
        sproc_msg -info "Purging non fixed COMPONENTS items."
        set mode "purge_nonfixed_COMPONENTS"
      }
      puts $fid_dst $line
    } elseif { $mode == "purge_nonfixed_COMPONENTS" } {
      if { [regexp {^END\s+COMPONENTS} $line] } { 
        set mode "copy"
        puts $fid_dst $line
      } elseif { [regexp {\s+FIXED\s+} $line] } { 
        puts $fid_dst $line
      } else {
        incr number_of_deleted_components
      }
    } else {
      puts $fid_dst $line
    }

  }

  ## Close files
  close $fid_src
  close $fid_dst
  file delete -force "$options(-dst_def).1" 

  ## ----------------------------------------

  ##
  ## purge header cells from components
  ##

  ## determine the ref_names of switch cells to purge
  if { $options(-purge_switch_cells) } {
    set t1 [ sproc_get_switch_cells ]
    set t2 [ get_attribute $t1 ref_name ]
    set header_cell_ref_names [ sproc_uniquify_list -list $t2 ]
  }

  ## Open files
  set fid_src [open "$options(-dst_def).2" r]
  set fid_dst [open "$options(-dst_def).3" w]
 
  set mode "copy" 
  while { [gets $fid_src line] >= 0 } {

    if { $mode == "copy" } {
      if { $options(-purge_switch_cells) && [regexp {^COMPONENTS\s+([\d]+)\s+;} $line] } { 
        sproc_msg -info "Purging header cells COMPONENTS items."
        set mode "header_cells_COMPONENTS"
      }
      puts $fid_dst $line
    } elseif { $mode == "header_cells_COMPONENTS" } {
      if { [regexp {^END\s+COMPONENTS} $line] } { 
        set mode "copy"
        puts $fid_dst $line
      } else {
        set delete_line 0
        foreach header_cell_ref_name $header_cell_ref_names {
          if { [regexp " $header_cell_ref_name " $line] } { 
            set delete_line 1
          }  
        }  
        if { $delete_line == 0 } {
          puts $fid_dst $line
        } else {
          incr number_of_deleted_components
        }
      }
    } else {
      puts $fid_dst $line
    }

  }

  ## Close files
  close $fid_src
  close $fid_dst
  file delete -force "$options(-dst_def).2" 

  ## ----------------------------------------

  ##
  ## adjust component # for the # of items deleted
  ##

  ## Open files
  set fid_src [open "$options(-dst_def).3" r]
  set fid_dst [open "$options(-dst_def)" w]
 
  while { [gets $fid_src line] >= 0 } {

    if { [regexp {^COMPONENTS\s+([\d]+)\s+;} $line] } { 
      regsub {^COMPONENTS\s+} $line "" line
      regsub {\s+;} $line "" line
      set line [expr $line - $number_of_deleted_components]
      set line "COMPONENTS $line ;"
    } 
    puts $fid_dst $line

  }

  ## Close files
  close $fid_src
  close $fid_dst
  file delete -force "$options(-dst_def).3" 

  sproc_pinfo -mode stop
}

define_proc_attributes sproc_filter_def  \
  -info "Procedure to filter a DEF file." \
  -define_args {
  {-src_def  "The original DEF." AString string required}
  {-dst_def  "The final DEF." AString string required}
  {-purge_SCANCHAINS  "Remove the SCANCHAINS section from the DEF." "" boolean optional}
  {-purge_nonfixed_COMPONENTS  "Remove the non fixed items in the COMPONENTS section of the DEF." "" boolean optional}
  {-purge_switch_cells  "Remove header cells from the COMPONENTS section of the DEF." "" boolean optional}
}

## -----------------------------------------------------------------------------
## sproc_remove_ideal_nets:
## -----------------------------------------------------------------------------

proc sproc_remove_ideal_network { args } {

  sproc_pinfo -mode start

  set options(-restore_clocks) 0
  parse_proc_arguments -args $args options

  ##
  ## as best practices
  ##  - remove all ideal networks (except on CTS) ... so that high fanout items 
  ##    get bufferred visa AHFS during place_opt.
  ##  - re-appliction on CTS network is to deal with data/clock mixing & is 
  ##    a work around that should go away someday
  ##
  if { [llength [all_scenarios]] == 0 } {
    remove_ideal_network -all
    if { $options(-restore_clocks) } {
      set clks [ all_fanout -flat -clock_tree ]
      if { [sizeof $clks] > 0 } { set_ideal_network $clks }
    }
  } else {
    set tmp_current_scenario [current_scenario]
    foreach scenario [all_scenarios] {

      set need_to_activate 0
      if { [ lsearch [all_active_scenarios] $scenario ] < 0 } {
        set need_to_activate 1
        set orig_active_scenarios [all_active_scenarios]
        set_active_scenarios "$orig_active_scenarios $scenario"
      }

      current_scenario $scenario
      remove_ideal_network -all
      if { $options(-restore_clocks) } {
        set clks [ all_fanout -flat -clock_tree ]
        if { [sizeof $clks] > 0 } { set_ideal_network $clks }
      }

      if { $need_to_activate } {
        set_active_scenarios $orig_active_scenarios
      }

    }
    current_scenario $tmp_current_scenario
  }

  sproc_pinfo -mode stop

}

define_proc_attributes sproc_remove_ideal_network \
  -info "Utility removing ideal nets ." \
  -define_args {
    {-restore_clocks  "Restore ideal network status on clocks during place_opt" "" boolean optional}
}

## -----------------------------------------------------------------------------
## sproc_screen_icc_port_layer_correctness:
## -----------------------------------------------------------------------------

proc sproc_screen_icc_port_layer_correctness { args } {

  sproc_pinfo -mode start

  global SVAR

  set options(-verbose) 0
  parse_proc_arguments -args $args options

  if { !$SVAR(is_chip) } {

    ##
    ## Robustness in the context of multi-layer pins and other situtations
    ## not perfectly understood.  If you encounter any problems simply 
    ## terminated usage of this proc.  Also advise of the situation so we
    ## can improve it.  Thanks.
    ##

    ## grab max layer routing layer mode
    set max_layer_mode [ get_route_zrt_common_options -name max_layer_mode ]

    ## grab max layer routing layer 
    redirect -variable report {  report_ignored_layers }
    set lines [split $report "\n"]
    set max_routing_layer "tbd"
    foreach line $lines {
      regexp {Max_routing_layer:\s+([\w\.]+)} $line matchVar max_routing_layer 
    }
    set max_routing_layer_index [lsearch [sproc_convert_to_metal_layer_name] $max_routing_layer]

    ##
    ## grab ports, for each port validate port is on a layer between any min
    ## and may layer constraints, if not generate a message
    ##
    set errors 0
    foreach_in_collection port [ get_ports ] {
      set port_layer [get_attribute $port layer]
      set net [all_connected $port]
  
      set max_layer [get_attribute $net max_layer]
      if { $max_layer == "no_max_layer" } {
        set max_index $max_routing_layer_index
      } else {
        set max_index [lsearch [sproc_convert_to_metal_layer_name] $max_layer]
      }

      set min_layer [get_attribute $net min_layer]
      if { $min_layer == "no_min_layer" } {
        set min_index 0
      } else {
        set min_index [lsearch [sproc_convert_to_metal_layer_name] $min_layer]
      }

      ## construction list of allowable layers for port
      incr min_index 
      incr max_index 
      set allowable_layer_list [sproc_convert_to_metal_layer_name -from $min_index -to $max_index]

      ## validate port is witin allowable_layer_list
      if { [lsearch $allowable_layer_list $port_layer] < 0 } {
         set port_name [get_attribute $port full_name]
         sproc_msg -error "Port \"$port_name\" is on layer \"$port_layer\" but is restricted to layers \"$allowable_layer_list\"."
         incr errors
      } elseif { $options(-verbose) } {
         set port_name [get_attribute $port full_name]
         sproc_msg -info "Port \"$port_name\" is on layer \"$port_layer\" but is restricted to layers \"$allowable_layer_list\"."
      } else {
      }
    }

    if { ( $errors > 0 ) && ( $max_layer_mode == "hard" ) } {
      sproc_msg -error "$errors errors were identified by sproc_screen_icc_port_layer_correctness."
      sproc_msg -error "set_route_zrt_common_options -max_layer_mode = \"$max_layer_mode\", as such the router may"
      sproc_msg -error "encounter DRC closure issues depending on other factors."
    } elseif { ( $errors > 0 ) } {
      sproc_msg -error "$errors errors were identified by sproc_screen_icc_port_layer_correctness."
      sproc_msg -error "set_route_zrt_common_options -max_layer_mode = \"$max_layer_mode\", as such the router may"
      sproc_msg -error "tolerate this situation.  You should be sure this is by design and not by accident."
    } else {
      sproc_msg -info "$errors errors were identified by sproc_screen_icc_port_layer_correctness."
    } 
  } else {
    sproc_msg -info "SVAR(is_chip) = $SVAR(is_chip) so screen skipped by sproc_screen_icc_port_layer_correctness."
  }

  sproc_pinfo -mode stop

}

define_proc_attributes sproc_screen_icc_port_layer_correctness \
  -info "Utility checking for port metal layers vs any min / max layer constraints." \
  -define_args {
    {-verbose "Used to enable verbose mode." "" boolean optional}
}

## -----------------------------------------------------------------------------
## sproc_screen_icc_constraint_quality:
## -----------------------------------------------------------------------------

proc sproc_screen_icc_constraint_quality { args } {

  sproc_pinfo -mode start

  set options(-verbose) 0
  set options(-current_scenario_only) 0
  parse_proc_arguments -args $args options

  set errors 0

  if { $options(-current_scenario_only) } {
    sproc_msg -warning "sproc_screen_icc_constraint_quality is being ran w/ \"-current_scenario_only\"."
    set scenarios [current_scenario] 
  } else {
    ## validate number of active scenarios
    set n1 [ llength [all_active_scenarios] ]
    set n2 [ llength [all_scenarios] ] 
    if { $n1 < $n2 } {
      sproc_msg -warning "Only $n1 out of $n2 scenarios are active for analysis by  sproc_screen_icc_constraint_quality."
    }
    set scenarios [all_active_scenarios] 
  }

  ## loop over active scenarios
  foreach scenario $scenarios {
    current_scenario $scenario

    ## check for critical range
    set cr [ get_attribute [current_design] critical_range ]
    if { $cr == "" } {
      sproc_msg -warning "Lynx detected [current_scenario] lacks critical range constraint."
      sproc_msg -warning "Although not a requirement it is highly recommended."
      incr errors
    } else {
      sproc_msg -info "Lynx detected [current_scenario] critical range constraint : $cr"
    }
    
    ## check for max transition
    set mt [ get_attribute [current_design] max_transition ]
    if { $mt == "" } {
      sproc_msg -warning "Lynx detected [current_scenario] lacks max transition constraint."
      sproc_msg -warning "Although not a requirement it is highly recommended."
      incr errors
    } else {
      sproc_msg -info "Lynx detected [current_scenario] max transition constraint : $mt"
    }

  }
  
  sproc_msg -info "$errors types of possible issues were identified by sproc_screen_icc_constraint_quality."

  sproc_pinfo -mode stop

}

define_proc_attributes sproc_screen_icc_constraint_quality \
  -info "Utility checking for a few items that if missed can materially impact flow performance." \
  -define_args {
    {-verbose "Used to enable verbose mode." "" boolean optional}
    {-current_scenario_only "Used to enable analysis of the current scenario only." "" boolean optional}
}

## -----------------------------------------------------------------------------
## sproc_screen_icc_scenario_setup:
## -----------------------------------------------------------------------------

proc sproc_screen_icc_scenario_setup { args } {

  sproc_pinfo -mode start

  set options(-verbose) 0
  parse_proc_arguments -args $args options

  set errors 0

  ## analyze leakage scenarios for possible issues
  set scenarios [get_scenarios -leakage_power true *]
  set num_scenarios [ llength $scenarios ]
  if { $num_scenarios == 0 } {
    sproc_msg -error "$num_scenarios scenarios have been identified as \"set_scenario_options -leakage_power true\"."
    sproc_msg -error "Although not a requirement 1 scenario is highly recommended."
    incr errors
  } elseif { $num_scenarios > 1 } {
    sproc_msg -error "$num_scenarios scenarios have been identified as \"set_scenario_options -leakage_power true\"."
    sproc_msg -error "Although not a requirement 1 scenario is highly recommended."
    sproc_msg -error "You should be advised there may be optimization engines that complain about multiple leakage scenarios."
    incr errors
  } 
  
  ## analyze cts scenarios for possible issues
  set scenarios [get_scenarios -cts_mode true *]
  set num_scenarios [ llength $scenarios ]
  if { $num_scenarios == 0 } {
    sproc_msg -error "$num_scenarios scenarios have been explicitly identified as \"set_scenario_options -cts_mode true\"."
    sproc_msg -error "As such tool will simply use the current_scenario at the point of CTS.  Atleast 1 scenario is highly recommended."
    incr errors
  }
  set scenarios [get_scenarios -cts_mode true -setup false *]
  set num_scenarios [ llength $scenarios ]
  if { $num_scenarios > 0 } {
    sproc_msg -error "$num_scenarios scenarios have been explicitly identified as \"set_scenario_options -cts_mode true -setup false\"."
    sproc_msg -error "As the CTS engine currently requires the max side graph to be present this is not a robust configuration."
    sproc_msg -error "Also look closely as the CTO for the scenario is likely implicitly = max."
    incr errors
  }

  
  ## analyze scenarios for possible configuration issues
  set scenarios [get_scenarios -dynamic_power true -setup false *]
  set num_scenarios [ llength $scenarios ]
  if { $num_scenarios > 0 } {
    sproc_msg -error "$num_scenarios scenarios have been explicitly identified as \"set_scenario_options -dynamic_power true -setup false\"."
    sproc_msg -error "This is not a robust configuration as dynamic power is costed against the max side graph graph."
    incr errors
  }

  sproc_msg -info "$errors types of possible issues were identified by sproc_screen_icc_scenario_setup."

  sproc_pinfo -mode stop

}

define_proc_attributes sproc_screen_icc_scenario_setup \
  -info "Utility checking for issues w/ scenario setup." \
  -define_args {
    {-verbose "Used to enable verbose mode." "" boolean optional}
}

## -----------------------------------------------------------------------------
## sproc_screen_icc_for_ideal_nets:
## -----------------------------------------------------------------------------

proc sproc_screen_icc_for_ideal_nets { args } {

  sproc_pinfo -mode start

  parse_proc_arguments -args $args options

  ##
  ## at a certain point in the flow ideal nets should no longer exists.  this
  ## utility can be use to check for any and generates an error if detected
  ## - filter out Tie High / Low nets which got introduced w/ 08.09
  ## - filter out ILM nets which got introduced w/ 09.06
  ##
  sproc_msg -info "  Checking for ideal nets."
  ## set ideal_nets [ get_nets -hier -filter "ideal_net==true" -quiet ]
  set ideal_nets [ all_ideal_nets ]

  sproc_msg -issue "STAR(9000330064) ILM creation translating physical tie cells to virtual tie cells."
  set ilm_ideal_nets [ add_to_collection "" "" ]
  foreach_in_collection net $ideal_nets {
    foreach_in_collection ilm [get_ilms -quiet *] {
      set inst_ilm [ get_attribute $ilm full_name ]
      if { [regexp "^$inst_ilm" [get_attribute $net full_name] ] } {
        set ilm_ideal_nets [ add_to_collection $ilm_ideal_nets $net ]
      }
    }
  }
  set ideal_nets [ remove_from_collection $ideal_nets $ilm_ideal_nets ]

  set count [ sizeof_collection $ideal_nets ]

  if { $count > 0 } {
    sproc_msg -error "There should be no ideal nets left in the design, but $count"
    sproc_msg -error "ideal nets were identified.  Please investigate."
    foreach_in_collection net $ideal_nets {
      sproc_msg -warning "  [get_attribute $net full_name] is an ideal net, please investigate."
    }
  } else {
    sproc_msg -issue "$count possible issues were identified by sproc_screen_icc_for_ideal_nets."
  }

  sproc_pinfo -mode stop

}

define_proc_attributes sproc_screen_icc_for_ideal_nets \
  -info "Utility checking for ideal nets ." \
  -define_args {
}

## -----------------------------------------------------------------------------
## sproc_screen_icc_utilization:
## -----------------------------------------------------------------------------

proc sproc_screen_icc_utilization { args } {

  sproc_pinfo -mode start

  global SVAR placer_max_cell_density_threshold

  parse_proc_arguments -args $args options

  ##
  ## Establish a low_utilization_threshold.  this is a pseudo arbitrary # for
  ## which we have choosen 0.65
  ##
  set low_utilization_threshold 0.65

  ## determine the actual utilization of the design
  redirect -variable report { report_design_physical -utilization }
  set lines [split $report "\n"]
  set actual_utilization -1
  foreach line $lines {
    if { [ regexp {Cell/Core Ratio\s+:\s+([\d\.]+)\%} $line matchVar actual_utilization ] } {
      set actual_utilization [expr $actual_utilization / 100.0]
    }
  }

  if { $actual_utilization < 0 } {
    sproc_msg -error "sproc_screen_icc_utilization: Unable to determine utilization of the design."
  } else {
    if { ( $actual_utilization < $low_utilization_threshold ) && ( $placer_max_cell_density_threshold < 0 ) } {
      sproc_msg -warning "sproc_screen_icc_utilization: The design appears to have a utilization = $actual_utilization.  It"
      sproc_msg -warning "sproc_screen_icc_utilization: also appears absent placer_max_cell_density_threshold which can assist"
      sproc_msg -warning "sproc_screen_icc_utilization: with creating some clumping for low utilized designs.  You may want to"
      sproc_msg -warning "sproc_screen_icc_utilization: consider enabling placer_max_cell_density_threshold by way of"
      sproc_msg -warning "sproc_screen_icc_utilization: SVAR(misc,placer_max_cell_density_threshold) for future DC and ICC runs."
    } elseif { $actual_utilization > $placer_max_cell_density_threshold } {
      sproc_msg -warning "sproc_screen_icc_utilization: The design appears to have a utilization = $actual_utilization which"
      sproc_msg -warning "sproc_screen_icc_utilization: is greater than SVAR(misc,placer_max_cell_density_threshold) = $placer_max_cell_density_threshold."
      sproc_msg -warning "sproc_screen_icc_utilization: You may wish to consider drop SVAR(misc,placer_max_cell_density_threshold)"
      sproc_msg -warning "sproc_screen_icc_utilization: for future DC and ICC runs."
    }
  }

  sproc_pinfo -mode stop

}

define_proc_attributes sproc_screen_icc_utilization \
  -info "Utility checking for appropriate placement configuration based on utilization." \
  -define_args {
}

## -----------------------------------------------------------------------------
## sproc_get_macros: 
## -----------------------------------------------------------------------------

proc sproc_get_macros { args } {

  sproc_pinfo -mode start

  global SVAR SEV TEV synopsys_program_name

  set options(-hard) 0
  set options(-logic) 0
  set options(-soft) 0
  set options(-inst) 0
  set options(-design_pairs) 0
  set options(-mim) 0
  set options(-model_info) 0
  set options(-force) 0
  set options(-no_auto) 0
  set options(-allow_duplicates) 0
  set options(-comma) 0
  
  parse_proc_arguments -args $args options

  if { $options(-soft) && $options(-model_info) } {
    sproc_msg -error "sproc_get_macros does not support use of both -soft and -model_info switches."
    sproc_pinfo -mode stop
    return
  }

  if { $options(-mim) && $options(-model_info) } {
    sproc_msg -error "sproc_get_macros does not support use of both -mim and -model_info switches."
    sproc_pinfo -mode stop
    return
  }
  if { $options(-mim) && $options(-inst) } {
    sproc_msg -error "sproc_get_macros does not support use of both -mim and -inst switches."
    sproc_msg -error "The -mim switch returns the mim instance names."
    sproc_pinfo -mode stop
    return
  }
  if { $options(-mim) && ($SVAR(dp,mim_master_list) == "") } {
    sproc_msg -error "Must populate SVAR(dp,mim_master_list) before executing -mim switch."
    sproc_pinfo -mode stop
    return
  }

  ## Special soft macro handling for hierarchical characaterize flows
  if { $SEV(step)=="00_syn" && $options(-logic) && !$options(-force) } {
    sproc_msg -warning "SPECIAL FLOW NOTICE: Skipping return of logic macros for characterize step 00_syn"
    set options(-logic) 0
  }


  ## -------------------------------------
  ## Print a summary of the macro definitions.
  ## -------------------------------------

  set hard_designs {}
  set soft_designs {}
  set logic_designs {}
  foreach type { hard soft logic } {
    sproc_msg -info "These are the ${type} macros currently defined by SVAR(hier,macros_${type}):"
    if { [llength $SVAR(hier,macros_${type})] == 0 } {
      sproc_msg -info "  <there are no ${type} macros defined>"
    } else {
      foreach element $SVAR(hier,macros_${type}) {
        switch $type {
          hard {
            set des  [lindex $element 0]
            set inst [lindex $element 1]
            sproc_msg -info "  design:$des, instance:$inst, model_type:[lindex $element 2]"
            lappend hard_designs [lindex $element 0]
          }
          soft {
            set des  [lindex $element 0]
            set inst [lindex $element 1]
            sproc_msg -info "  design:$des, instance:$inst"
            lappend soft_designs [lindex $element 0]
            if { [ regexp $des $hard_designs ] } {
              sproc_msg -error "macro setup issue: Macro $des cannot be configured as both a soft macro and hard macro."
            }
          } 
          logic {
            set des  [lindex $element 0]
            set inst [lindex $element 1]
            sproc_msg -info "  design:$des, instance:$inst, model_type:[lindex $element 2]"
            if { ![ regexp $des $soft_designs ] } {
              if { $SEV(step)=="00_syn" } {
                sproc_msg -error "Macro $des must also be a soft macro for proper characterize flow operation"
              } else {
                sproc_msg -warning "Macro $des is a logic macro but not a soft macro. It is recommended to set as both and may be assumed in the future."
              }
            }
            if { [ regexp $des $hard_designs ] } {
              sproc_msg -error "macro setup issue: Macro $des cannot be configured as both a logic macro and hard macro."
            }
          }
        }
      }
    }
    sproc_msg -info "End of ${type} macro list."
    sproc_msg -info ""
  }

  sproc_msg -info "These are the mim masters defined by SVAR(dp,mim_master_list):"
  if { [llength $SVAR(dp,mim_master_list)] == 0 } {
    sproc_msg -info "  <there are no mim masters defined>"
  } else {
    foreach mm $SVAR(dp,mim_master_list) {
      sproc_msg -info "  mim master: $mm"
    }
    if { ![regexp $mm $SVAR(hier,macros_logic)] } {
      sproc_msg -error "macro setup issue: the mim_master $mm must also be setup as a logic macro"
    }
    if { [regexp $mm $SVAR(hier,macros_hard)] } {
      sproc_msg -error "macro setup issue: the mim_master $mm cannot be a hard macro"
    }
  }
  sproc_msg -info "End of mim master list."
  sproc_msg -info ""

  ## -------------------------------------
  ## Continue with the procedure.
  ## -------------------------------------

  set element_list [list]
  set return_list  [list]

  if { $options(-hard) } {
    set element_list [concat $element_list $SVAR(hier,macros_hard)]
  }
  if { $options(-soft) } {
    set element_list [concat $element_list $SVAR(hier,macros_soft)]
  }
  if { $options(-logic) } {
    set element_list [concat $element_list $SVAR(hier,macros_logic)]
  }
  if { $options(-mim) } {
    set element_list [concat $element_list $SVAR(hier,macros_soft)]
    set mim_refs [get_attribute [get_cells $SVAR(dp,mim_master_list)] ref_name]
  }

  if { $options(-model_info) } {

    foreach element $element_list {
      set design [lindex $element 0]
      set inst   [lindex $element 1]
      set model  [lindex $element 2]
      if { $options(-inst) } {
        ## Automatically respond to any hierarchical path changes to instance name
        set inst_wild [regsub -all {/} $inst {?}]
        if { $synopsys_program_name == "fm_shell" } {
          set inst $inst_wild
        } else {
          set inst [get_attribute [get_cells -hier -filter full_name=~$inst_wild] full_name]
        }
        set return_element [list $inst $model]
      } else {
        set return_element [list $design $model]
      }
      lappend return_list $return_element
    }

  } else {

    foreach element $element_list {
      if { $options(-inst) || $options(-design_pairs) } {
        set inst [lindex $element 1]
        if { !$options(-no_auto) } {
          ## Automatically respond to any hierarchical path changes to instance name
          set inst_wild [regsub -all {/} $inst {?}]
          if { $synopsys_program_name == "fm_shell" } {
            set inst $inst_wild
          } else {
            set inst [get_attribute [get_cells -hier -filter full_name=~$inst_wild] full_name]
          }
        }
        if { $options(-design_pairs) } {
          lappend return_list [list [lindex $element 0] $inst] 
        } else {
          lappend return_list $inst
        }
      } elseif { $options(-mim) } {
        foreach mim_master $mim_refs {
          if { [lindex $element 0] == $mim_master } {
            set inst [lindex $element 1]
            if { !$options(-no_auto) } {
              ## Automatically respond to any hierarchical path changes to instance name
              set inst_wild [regsub -all {/} $inst {?}]
              if { $synopsys_program_name == "fm_shell" } {
                set inst $inst_wild
              } else {
                set inst [get_attribute [get_cells -hier -filter full_name=~$inst_wild] full_name]
              }
            }
            lappend return_list $inst
          }
        }
      } else {
        lappend return_list [lindex $element 0]
      }

    }

    if { !$options(-allow_duplicates) } {
      set return_list [sproc_uniquify_list -list $return_list]
    }

    if { $options(-comma) } {
      set return_list [join $return_list ","]
    }

  }

  sproc_pinfo -mode stop
  return $return_list

}

define_proc_attributes sproc_get_macros \
  -info "Retrieve information about subdesign macros." \
  -define_args {
  {-hard             "Get hard macro info" "" boolean optional}
  {-logic            "Get macro info (pre-DP)" "" boolean optional}
  {-soft             "Get macro info (post-DP)" "" boolean optional}
  {-inst             "Return instance names instead of design names" "" boolean optional}
  {-design_pairs     "Return design and instance pairs" "" boolean optional}
  {-mim              "Return all MIM instance names" "" boolean optional}
  {-force            "Force return of LM even if in step 00_syn where they are supressed" "" boolean optional}
  {-model_info       "Return list of designs and models." "" boolean optional}
  {-no_auto          "Disables automatic instance name updates which require a design be loaded" "" boolean optional}
  {-allow_duplicates "Allow duplicate entries in returned lists" "" boolean optional}
  {-comma            "Return comma separated list" "" boolean optional}
}

## -----------------------------------------------------------------------------
## sproc_get_preferred_direction:
## -----------------------------------------------------------------------------

proc sproc_get_preferred_direction { args } {

  sproc_pinfo -mode start

  global env SEV SVAR TEV

  set options(-layer_name) ""
  parse_proc_arguments -args $args options

  set return_value NO_DIRECTION_FOUND

  ## -------------------------------------
  ## Parse data from SVAR(tech,metal_layer_info_list), so that
  ## changes in variable format do not affect this procedure.
  ## -------------------------------------
  foreach item $SVAR(tech,metal_layer_info_list) {
    set name [lindex $item 0]
    set dir  [lindex $item 1]
    if { $name == $options(-layer_name) } {
      set return_value $dir
    }
  }

  if { $return_value == "NO_DIRECTION_FOUND" } {
    sproc_msg -error "Unable to identify direction for layer $options(-layer_name)"
  }

  sproc_pinfo -mode stop
  return $return_value
}

define_proc_attributes sproc_get_preferred_direction \
  -info "Returns preferred metal layer direction." \
  -define_args {
  {-layer_name "Layer to query for preferred metal layer direction." AString string required}
}

## -----------------------------------------------------------------------------
## sproc_convert_to_metal_layer_name:
## -----------------------------------------------------------------------------

proc sproc_convert_to_metal_layer_name { args } {

  sproc_pinfo -mode start

  global env SEV SVAR TEV

  set options(-list) ""
  set options(-from) ""
  set options(-to) ""
  parse_proc_arguments -args $args options

  ## -------------------------------------
  ## Parse data from SVAR(tech,metal_layer_info_list), so that
  ## changes in variable format do not affect this procedure.
  ## -------------------------------------
  unset -nocomplain metal_layer_name_list
  unset -nocomplain metal_layer_dir_list
  foreach item $SVAR(tech,metal_layer_info_list) {
    set name [lindex $item 0]
    set dir  [lindex $item 1]
    lappend metal_layer_name_list $name
    lappend metal_layer_dir_list $dir
  }

  ## -------------------------------------
  ## Determine max number of metal layers
  ## -------------------------------------
  set max_layer_number [llength $metal_layer_name_list]

  ## Check for valid query range
  if { $options(-to) < $options(-from) } {
    set to_temp $options(-to)
    set options(-to) $options(-from)
    set options(-from) $to_temp
  }

  ## Set lower layer.
  if { $options(-from) != "" } {
    set lower_layer $options(-from)
  } else {
    set lower_layer 1
  }

  ## Set higher layer.
  if { $options(-to) != "" } {
    set higher_layer $options(-to)
  } else {
    set higher_layer  $max_layer_number
  }

  ## List option overrides to/from
  if { $options(-list) == "" } {
    for {set x $lower_layer} { $x <= $higher_layer } { incr x } {
      lappend options(-list) $x
    }
  }

  set layer_name_list [list]

  foreach layer_number $options(-list) {
    if { ($layer_number >= 1) && ( $layer_number <= $max_layer_number) } {
      lappend layer_name_list [lindex $metal_layer_name_list [expr $layer_number - 1]]
    } else {
      sproc_msg -error "Metal layer number out of range."
      sproc_msg -error "Metal layer number must be between 1 and $max_layer_number."
      sproc_msg -error "The metal layer number used was $layer_number"
      sproc_pinfo -mode stop
      return ""
    }
  }

  sproc_pinfo -mode stop
  return $layer_name_list
}

define_proc_attributes sproc_convert_to_metal_layer_name \
  -info "Maps a list of layers expressed as integers into a list of metal layer names." \
  -define_args {
  {-list "The list of metal layers in integer format." AString string optional}
  {-to   "Query to"                                    AnInt int optional}
  {-from "Query from"                                  AnInt int optional}
}

## -----------------------------------------------------------------------------
## sproc_pkg_star:
## -----------------------------------------------------------------------------

proc sproc_pkg_star { args } {

  sproc_pinfo -mode start

  global env SEV SVAR TEV
  global synopsys_program_name
  global link_library
  global target_library
  global search_path

  ## -------------------------------------
  ## Ensure we are running the supported tool.
  ## -------------------------------------

  if { ($synopsys_program_name != "dc_shell") && ($synopsys_program_name != "icc_shell") } {
    sproc_msg -error "This procedure only supports DesignCompiler & ICCompiler."
    sproc_pinfo -mode stop
    return
  }

  ## -------------------------------------
  ## Process arguments
  ## -------------------------------------

  set options(-design) ""
  set options(-database) ""
  set options(-star_name) "STAR.tbdNum"
  set options(-overwrite) 0

  parse_proc_arguments -args $args options

  if { ![file exists $options(-database)] } {
    sproc_msg -error "The database specified by -database does not exist."
    sproc_pinfo -mode stop
    return
  }

  ## -------------------------------------
  ## Define some usefull local variables
  ## -------------------------------------

  set dir(star)    $options(-star_name)
  set dir(inputs)  $options(-star_name)/inputs
  set dir(libs)    $options(-star_name)/libs
  set dir(logs)    $options(-star_name)/logs
  set dir(rpts)    $options(-star_name)/rpts
  set dir(scripts) $options(-star_name)/scripts
  set dir(work)    $options(-star_name)/work

  ## -------------------------------------
  ## Create the STAR directory
  ## -------------------------------------

  if { $options(-overwrite) && [ file exists $dir(star) ] } {
    sproc_msg -info "Removing existing STAR directory."
    exec chmod -R 777 $dir(star)
    file delete -force $dir(star)
  }

  if { [file exists $dir(star)] } {
    sproc_msg -error "STAR directory already exists, and -overwrite not specified."
    sproc_pinfo -mode stop
    return
  } else {
    sproc_msg -info "Creating STAR directory."
    foreach index [array names dir] {
      file mkdir $dir($index)
    }
  }

  ## -------------------------------------
  ## Ensure that this procedure is called with a valid design already loaded.
  ## -------------------------------------

  sproc_msg -info "Checking initial design status."

  switch $synopsys_program_name {
    dc_shell {
      if { [current_design] != {} } {
        remove_design -all
        read_ddc $options(-database)
        link
      } else {
        sproc_msg -error "This procedure must be invoked with a loaded design."
      }
    }
    icc_shell {
      if { [sizeof_collection [current_mw_lib]] == 1 } {
        close_mw_lib
      } else {
        sproc_msg -error "This procedure must be invoked with a loaded design."
        sproc_pinfo -mode stop
        return
      }
    }
  }

  ## -------------------------------------
  ## Copy the design into the STAR directory
  ## -------------------------------------

  sproc_msg -info "Copying design data to $dir(inputs)"

  file copy -force $options(-database) $dir(inputs)

  ## -------------------------------------
  ## Copy the libraries into the STAR directory (physical)
  ## -------------------------------------

  sproc_msg -info "Copying physical libs to $dir(libs)"

  switch $synopsys_program_name {

    icc_shell {

      ## -------------------------------------
      ## Find the design's references
      ## -------------------------------------

      set design_reflib_list [list]

      file delete -force tmp_file
      write_mw_lib_files -reference_control_file -output tmp_file $options(-database)

      set fid [open "tmp_file" r]
      while { [gets $fid line] >= 0 } {
        if { [regexp {^\s*REFERENCE} $line] } {
          regexp {REFERENCE\s+(\S+)} $line {} reflib
          set design_reflib_list "$design_reflib_list $reflib"
        }
      }
      close $fid

      ## -------------------------------------
      ## Find the reference's references
      ## -------------------------------------

      set reference_reflib_list [list]

      foreach reflib $design_reflib_list {

        file delete -force tmp_file
        write_mw_lib_files -reference_control_file -output tmp_file $reflib

        if { ![file exists tmp_file] } {
          continue
        }
        set fid [open "tmp_file" r]
        while { [gets $fid line] >= 0 } {
          if { [regexp {REFERENCE} $line] } {
            set reflib [lindex $line 1]
            set reference_reflib_list "$reference_reflib_list $reflib"
          }
        }
        close $fid

      }

      set all_reflib_list [lsort -unique "$design_reflib_list $reference_reflib_list"]

      if { $all_reflib_list == "" } {
        sproc_msg -error "There appears to be a problem as all_reflib_list appears empty."
      }

      ## -------------------------------------
      ## Copy the reference libs
      ## -------------------------------------

      foreach reflib $all_reflib_list {
        sproc_msg -info "Copying $reflib"
        file copy -force $reflib $dir(libs)
      }

      ## -------------------------------------
      ## Update references for all libs
      ## -------------------------------------

      set reflib_cmd_list [list]

      set org_libs "$options(-database) $all_reflib_list"

      foreach org_lib $org_libs {

        if { [lsearch $org_libs $org_lib] == 0 } {
          ## The first entry is the design
          set new_lib ./work/[file tail $org_lib]
        } else {
          set new_lib ./libs/[file tail $org_lib]
        }

        sproc_msg -info "Updating references for $new_lib"

        set old_reflib_list [list]

        file delete -force tmp_file
        write_mw_lib_files -reference_control_file -output tmp_file $org_lib

        if { ![file exists tmp_file] } {
          continue
        }
        set fid [open "tmp_file" r]
        while { [gets $fid line] >= 0 } {
          if { [regexp {REFERENCE} $line] } {
            set reflib [lindex $line 1]
            set old_reflib_list "$old_reflib_list $reflib"
          }
        }
        close $fid

        if { [llength $old_reflib_list] > 0 } {

          if { $synopsys_program_name == "icc_shell" } {
            set new_reflib_list [list]
          } else {
            set reflib_cmd "remove_reference_library -from $new_lib -all"
            lappend reflib_cmd_list $reflib_cmd
          }

          foreach old_reflib $old_reflib_list {
            set new_reflib ../libs/[file tail $old_reflib]
            sproc_msg -info "   Old reference is : $old_reflib"
            sproc_msg -info "   New reference is : $new_reflib"

            if { $synopsys_program_name == "icc_shell" } {
              set new_reflib_list "$new_reflib_list $new_reflib \\\n"
            } else {
              set reflib_cmd "add_reference_library -to $new_lib $new_reflib"
              lappend reflib_cmd_list $reflib_cmd
            }
          }

          if { $synopsys_program_name == "icc_shell" } {
            set reflib_cmd "set ref_list \[list \\\n${new_reflib_list}\]"
            lappend reflib_cmd_list $reflib_cmd
            set reflib_cmd "set_mw_lib_reference -mw_reference_library \$ref_list $new_lib \n"
            lappend reflib_cmd_list $reflib_cmd
          }

        }
      }
    }

    dc_shell {
      if { [shell_is_in_topographical_mode] } {
        foreach reflib $SVAR(lib,mw_reflist) {
          file copy -force $reflib $dir(libs)
        }
      }
    }

  }

  ## -------------------------------------
  ## Copy the libraries into the STAR directory (logical)
  ## -------------------------------------

  sproc_msg -info "Copying logical libs to $dir(libs)"

  switch $synopsys_program_name {

    dc_shell -
    icc_shell {

      set library_file_list [list]

      if { $synopsys_program_name == "dc_shell" } {
        redirect -variable rpt {
          list_libs
        }
      } else {
        open_mw_cel -library $options(-database) $options(-design)
        current_design $options(-design)
        link -force
        redirect -variable rpt {
          list_libs
        }
        close_mw_lib
      }

      set lines [split $rpt "\n"]
      set dash_count 0
      foreach line $lines {
        if { [regexp {^----} $line] } {
          incr dash_count
          continue
        }
        if { $dash_count != 2 } {
          continue
        }
        ## in 2007.12-SP3 a M | m shows up on the first of the line, so remove them.
        regsub {^m } $line { } line
        regsub {^M } $line { } line
        if { [llength $line] == 3 } {
          set lib  [lindex $line 0]
          set file [lindex $line 1]
          set path [lindex $line 2]
          set library_file_list "$library_file_list $path/$file"
        }
      }

      if { [info exist all_reflib_list] == 0 } {
        set all_reflib_list [list]
      }
      set lm_search_path [list]
      set db_copied 0
      foreach file $library_file_list {
        if { ([file extension $file] == ".sldb") || ([file tail $file] == "gtech.db") } {
          ## Dont copy libs in tool release
        } else {

          ## if using db is in the MW/LM ... then use it, else copy it

          set lm_hit 0
          foreach reflib $all_reflib_list {
            if { [ regexp $reflib $file ] == 1 } {
              set lm_hit 1
              lappend lm_search_path "./libs/[file tail $reflib]/LM"
              sproc_msg -info "   Using a MW [file tail $reflib]/LM view of $file"
            }
          }

          if { $lm_hit == 0 } {
            sproc_msg -info "   Copying $file"
            file copy -force $file $dir(libs)
            incr db_copied 
          }

        }
      }
      set lm_search_path [lsort -unique $lm_search_path]

      if { $synopsys_program_name == "dc_shell" } {

        if { [file exists ../work/000_inputs/ilm/] } {
          file mkdir $dir(libs)/ilm/
          set ilm_files [glob -nocomplain ../work/000_inputs/ilm/*.ddc]
          foreach file $ilm_files {
            sproc_msg -info "   Copying $file"
            file copy -force $file $dir(libs)/ilm/
          }
        }

      }

      if { $db_copied == 0 } {
        sproc_msg -error "There appears to be a problem as no dbs copied."
      }

    }

  }

  ## -------------------------------------
  ## Process tlu_plus information
  ## -------------------------------------

  sproc_msg -info "Copying TLU+ data to $dir(libs)"

  if { ($synopsys_program_name == "icc_shell") || (($synopsys_program_name == "dc_shell") && [shell_is_in_topographical_mode]) } {

    set num_scenarios 0
    set scenario_names($num_scenarios)   undefined
    set tlup_lib_max($num_scenarios)     undefined
    set tlup_lib_min($num_scenarios)     undefined
    set tlup_lib_max_emf($num_scenarios) undefined
    set tlup_lib_min_emf($num_scenarios) undefined
    set tlup_lib_map($num_scenarios)     undefined

    if { $synopsys_program_name == "icc_shell" } {
      open_mw_lib $options(-database)
      open_mw_cel $options(-design)

      set_active_scenarios -all
      if { [ llength [all_scenarios] ] > 0 } {
        set scenarios_list [all_scenarios]
      } else {
        set scenarios_list "undefined"
      }

      foreach scenario $scenarios_list {
        if { [ llength [all_scenarios] ] > 0 } {
          current_scenario $scenario
        }
        set scenario_names($num_scenarios)   $scenario
        set tlup_lib_max($num_scenarios)     undefined
        set tlup_lib_min($num_scenarios)     undefined
        set tlup_lib_max_emf($num_scenarios) undefined
        set tlup_lib_min_emf($num_scenarios) undefined
        set tlup_lib_map($num_scenarios)     undefined

        redirect -variable rpt {
          report_tlu_plus_files
        }

        set lines [split $rpt "\n"]
        foreach line $lines {
          regexp {^\s*Max TLU\+ file: (\S+)} $line matchVar tlup_lib_max($num_scenarios)
          regexp {^\s*Min TLU\+ file: (\S+)} $line matchVar tlup_lib_min($num_scenarios)
          regexp {^\s*Max EMULATION TLU\+ file: (\S+)} $line matchVar tlup_lib_max_emf($num_scenarios)
          regexp {^\s*Min EMULATION TLU\+ file: (\S+)} $line matchVar tlup_lib_min_emf($num_scenarios)
          regexp {^\s*Tech2ITF mapping file: (\S+)} $line matchVar tlup_lib_map($num_scenarios)
        }

        incr num_scenarios
      }

      close_mw_lib
    } else {
      if { [ llength [all_scenarios] ] > 0 } {
        set scenarios_list [all_scenarios]
        set_active_scenarios -all
      } else {
        set scenarios_list "undefined"
      }
      foreach scenario $scenarios_list {
        if { [ llength [all_scenarios] ] > 0 } {
          current_scenario $scenario
        }
        set scenario_names($num_scenarios)   $scenario
        set tlup_lib_max($num_scenarios)     undefined
        set tlup_lib_min($num_scenarios)     undefined
        set tlup_lib_max_emf($num_scenarios) undefined
        set tlup_lib_min_emf($num_scenarios) undefined
        set tlup_lib_map($num_scenarios)     undefined

        redirect -variable rpt {
          report_tlu_plus_files
        }

        set lines [split $rpt "\n"]
        foreach line $lines {
          regexp {^\s*Max TLU\+ file: (\S+)} $line matchVar tlup_lib_max($num_scenarios)
          regexp {^\s*Min TLU\+ file: (\S+)} $line matchVar tlup_lib_min($num_scenarios)
          regexp {^\s*Max EMULATION TLU\+ file: (\S+)} $line matchVar tlup_lib_max_emf($num_scenarios)
          regexp {^\s*Min EMULATION TLU\+ file: (\S+)} $line matchVar tlup_lib_min_emf($num_scenarios)
          regexp {^\s*Tech2ITF mapping file: (\S+)} $line matchVar tlup_lib_map($num_scenarios)
        }

        incr num_scenarios
      }

    }
    for {set x 0} { $x < $num_scenarios } {incr x} {
      if { [file exists $tlup_lib_max($x)]     } { file copy -force $tlup_lib_max($x)     $dir(libs) }
      if { [file exists $tlup_lib_min($x)]     } { file copy -force $tlup_lib_min($x)     $dir(libs) }
      if { [file exists $tlup_lib_max_emf($x)] } { file copy -force $tlup_lib_max_emf($x) $dir(libs) }
      if { [file exists $tlup_lib_min_emf($x)] } { file copy -force $tlup_lib_min_emf($x) $dir(libs) }
      if { [file exists $tlup_lib_map($x)]     } { file copy -force $tlup_lib_map($x)     $dir(libs) }
    }

  }

  ## -------------------------------------
  ## Create the script file
  ## -------------------------------------

  sproc_msg -info "Creating the_script.tcl"

  set filename $dir(scripts)/the_script.tcl

  set fid [open $filename w]

  set database [file tail $options(-database)]
  puts $fid "file delete -force ./work/$database"

  if { $synopsys_program_name == "icc_shell" } {
    puts $fid "copy_mw_lib -from ./inputs/$database -to ./work/$database \n"
  } else {
    puts $fid "file copy -force ./inputs/$database ./work/$database \n"
  }

  switch $synopsys_program_name {

    dc_shell {

      puts $fid "lappend search_path ./libs/ $lm_search_path \n"

      puts $fid "set link_library \[list \\"
      puts $fid "  * \\"
      foreach file $library_file_list {
        puts $fid "  [file tail $file] \\"
      }
      foreach design_name [sproc_get_macros -logic] {
        puts $fid "  ./libs/ilm/$design_name.ddc \\"
      }
      foreach design_name [sproc_get_macros -hard] {
        if { [shell_is_in_topographical_mode] } {
          puts $fid "  $design_name.ILM \\"
        } else {
          puts $fid "  ./libs/ilm/$design_name.ddc \\"
        }
      }
      puts $fid "\] \n"

      puts $fid "set target_library \[list \\"
      foreach file $target_library {
        puts $fid "  [file tail $file] \\"
      }
      puts $fid "\] \n"

      if { [shell_is_in_topographical_mode] } {

        ## Need to create MW
        file copy -force $SVAR(tech,mw_tech_file) $dir(libs)
        set new_tf ./libs/[file tail $SVAR(tech,mw_tech_file)]
        set new_reflibs ""
        foreach reflib $SVAR(lib,mw_reflist) {
          set new_reflib \$\{STAR_dir\}/libs/[file tail $reflib]
          lappend new_reflibs $new_reflib
        }

        puts $fid "set STAR_dir \[pwd\] \n"
        puts $fid "file delete -force ./work/mw_lib_name \n"
        puts $fid "create_mw_lib \\"
        puts $fid "  -technology $new_tf \\"
        puts $fid "  -mw_reference_library \[list \\"

        foreach new_rlib $new_reflibs {
          puts $fid "    $new_rlib \\"
        }

        puts $fid "  \] \\"
        puts $fid "  ./work/mw_lib_name \n"
        puts $fid "open_mw_lib ./work/mw_lib_name \n"

        puts $fid "read_ddc ./work/$database"
        puts $fid "current_design $options(-design)"
        puts $fid "link \n"

        ## Need to set TLU+
        for {set x 0} { $x < $num_scenarios } { incr x } {
          if { [ llength [all_scenarios] ] > 0 } {
            puts $fid "current_scenario $scenario_names($x)"
          }
          puts $fid "unset_tlu_plus_files"
          puts $fid "set_tlu_plus_files \\"
          if { $tlup_lib_max($x) != "undefined" } {
            puts $fid "  -max_tluplus ./libs/[file tail $tlup_lib_max($x)] \\"
          }
          if { $tlup_lib_min($x) != "undefined" } {
            puts $fid "  -min_tluplus ./libs/[file tail $tlup_lib_min($x)] \\"
          }
          if { $tlup_lib_max_emf($x) != "undefined" } {
            puts $fid "  -max_emulation_tluplus ./libs/[file tail $tlup_lib_max_emf($x)] \\"
          }
          if { $tlup_lib_min_emf($x) != "undefined" } {
            puts $fid "  -min_emulation_tluplus ./libs/[file tail $tlup_lib_min_emf($x)] \\"
          }
          if { $tlup_lib_map($x) != "undefined" } {
            puts $fid "  -tech2itf_map ./libs/[file tail $tlup_lib_map($x)] "
          }
          puts $fid "\n"
        }

        puts $fid "report_mw_lib -mw_reference_library ./work/$database"
        puts $fid "report_tlu_plus_files \n"
      }

      ## Need to perform layer setup.

      puts $fid "report_preferred_routing_direction \n"
      puts $fid "remove_ignored_layers -all"
      set min_routing_layer [sproc_convert_to_metal_layer_name -list 1]
      set max_routing_layer [sproc_convert_to_metal_layer_name -list $SVAR(route,layer_signal_max)]
      puts $fid "set_ignored_layers -min_routing_layer $min_routing_layer -max_routing_layer $max_routing_layer"
      puts $fid "report_ignored_layers \n"

    }

    icc_shell {

      puts $fid "lappend search_path ./libs/ $lm_search_path \n"

      puts $fid "set link_library \[list \\"
      puts $fid "  * \\"
      foreach file $library_file_list {
        puts $fid "  [file tail $file] \\"
      }
      puts $fid "\] \n"

      puts $fid "set target_library \[list \\"
      foreach file $target_library {
        puts $fid "  [file tail $file] \\"
      }
      puts $fid "\] \n"

      foreach reflib_cmd $reflib_cmd_list {
        puts $fid $reflib_cmd
      }
      puts $fid ""

      puts $fid "open_mw_cel -library ./work/$database $options(-design)"
      puts $fid "current_design $options(-design)"
      puts $fid " \n"
      if { $scenario_names(0) != "undefined" } {
        puts $fid "set_active_scenarios -all \n"
        puts $fid " \n"
      }

      ## Need to set TLU+
      for {set x 0} { $x < $num_scenarios } { incr x } {
        set scenario_names($num_scenarios)   $scenario
        if { $scenario_names(0) != "undefined" } {
          puts $fid "current_scenario $scenario_names($x)"
        }
        puts $fid "unset_tlu_plus_files"
        puts $fid "set_tlu_plus_files \\"
        if { $tlup_lib_max($x) != "undefined" } {
          puts $fid "  -max_tluplus ./libs/[file tail $tlup_lib_max($x)] \\"
        }
        if { $tlup_lib_min($x) != "undefined" } {
          puts $fid "  -min_tluplus ./libs/[file tail $tlup_lib_min($x)] \\"
        }
        if { $tlup_lib_max_emf($x) != "undefined" } {
          puts $fid "  -max_emulation_tluplus ./libs/[file tail $tlup_lib_max_emf($x)] \\"
        }
        if { $tlup_lib_min_emf($x) != "undefined" } {
          puts $fid "  -min_emulation_tluplus ./libs/[file tail $tlup_lib_min_emf($x)] \\"
        }
        if { $tlup_lib_map($x) != "undefined" } {
          puts $fid "  -tech2itf_map ./libs/[file tail $tlup_lib_map($x)] "
        }
        puts $fid "\n"
      }

      puts $fid "## report_mw_lib -mw_reference_library ./work/$database \n"
      puts $fid "## report_tlu_plus_files \n"

    }

  }

  puts $fid "## Insert code to demonstrate STAR here. \n"

  close $fid

  ## -------------------------------------
  ## Create the README file
  ## -------------------------------------

  set filename $dir(star)/README

  set fid [open $filename w]

  puts $fid "\n"
  puts $fid "Date     : STAR assembled on [date] \n"
  puts $fid "Location : STAR created in [pwd] \n"
  puts $fid "Source   : STAR created from $options(-database) \n"
  puts $fid "To reproduce the STAR, load the tool and then execute 'Run' at your shell. \n"
  puts $fid "Example tool versions loading:"
  puts $fid "  module load tool/version \n"
  puts $fid "Read CRM for more info.\n"

  close $fid

  ## -------------------------------------
  ## Create the Run file
  ## -------------------------------------

  set filename $dir(star)/Run

  set fid [open $filename w]

  puts $fid "\n"

  switch $synopsys_program_name {
    dc_shell {
      puts $fid "$SEV(cmd_dc)  -f ./scripts/the_script.tcl | \\"
      puts $fid "  tee ./logs/the_script.log"
    }
    icc_shell {
      puts $fid "$SEV(cmd_icc) -f ./scripts/the_script.tcl | \\"
      puts $fid "  tee ./logs/the_script.log"
    }
  }

  puts $fid "\n"

  close $fid

  file attributes $filename -permissions ugo+x

  sproc_pinfo -mode stop
}

define_proc_attributes sproc_pkg_star \
      -info "\
      Procedure that assists in packaging a STAR. \
      Supports MW format for icc_shell. \
      Supports DDC format for dc_shell. \
      Note that all logfiles from the flow contain
    useful techlib setup information prefixed \
      with the string SNPS_SETUP. \
  " \
  -define_args {
  {-design     "Design within database from which to create the STAR" AString string required}
  {-database   "Path and filename of database from which to create the STAR (DDC or MW)"   AString string required}
  {-star_name  "Directory in which to package the STAR (default is STAR.tbdNum)" AString string optional}
  {-overwrite  "Overwrite if the STAR directory already exists" "" boolean optional}
}

## -----------------------------------------------------------------------------
## sproc_pkg_misc_library_data:
## -----------------------------------------------------------------------------

proc sproc_pkg_misc_library_data { args } {

  sproc_pinfo -mode start

  global env SEV SVAR TEV
  global synopsys_program_name
  global link_library
  global target_library
  global search_path

  ## -------------------------------------
  ## Process arguments
  ## -------------------------------------

  set options(-dst) "misc_library_data"
  set options(-allow_overwrite) 0

  parse_proc_arguments -args $args options

  ## -------------------------------------
  ## Create the STAR directory
  ## -------------------------------------

  if { [file exists $options(-dst)] && ( $options(-allow_overwrite) == 0 ) } {
    sproc_msg -warning "$options(-dst) directory already exists, and -allow_overwrite not specified."
    sproc_pinfo -mode stop
    return
  } else {
    sproc_msg -info "Creating STAR directory."
    file mkdir $options(-dst)
  }

  ## -------------------------------------

  set src_files [list]
  lappend src_files $SVAR(tech,mw_tech_file)
  lappend src_files $SVAR(tech,signal_em_constraints_file)
  lappend src_files $SVAR(tech,map_file_gds_out)

  set scenarios [all_active_scenarios]
  if { [llength $scenarios] > 0 } {
    foreach scenario [all_active_scenarios] {
      current_scenario $scenario
      set tmp [ sproc_icc_map_tlup_to_nxtgrd ]
      if { [ llength $tmp ] == 1 } {
        lappend src_files [ lindex $tmp 0 ]
      } else {
        lappend src_files [ lindex $tmp 0 ]
        lappend src_files [ lindex $tmp 1 ]
      }
    }
  } else {
    set tmp [ sproc_icc_map_tlup_to_nxtgrd ]
    if { [ llength $tmp ] == 1 } {
      lappend src_files [ lindex $tmp 0 ]
    } else {
      lappend src_files [ lindex $tmp 0 ]
      lappend src_files [ lindex $tmp 1 ]
    }
  }

  ## -------------------------------------

  foreach src_file $src_files {

    set dst_file "$options(-dst)/[file tail $src_file]"

    sproc_msg -info " "
    sproc_msg -info "  copying >$src_file<"
    sproc_msg -info "       to >$dst_file<"
    file copy -force $src_file $dst_file

  }

  ## -------------------------------------

  sproc_pinfo -mode stop
}

define_proc_attributes sproc_pkg_misc_library_data \
  -info "Procedure that assists in packaging library data for a STAR." \
  -define_args {
  {-dst  "Directory in which to package the data (default is misc_library_data)" AString string optional}
  {-allow_overwrite  "Allow overwrite if the dst directory or data already exists" "" boolean optional}
}

## -----------------------------------------------------------------------------
## sproc_get_spec_info:
## -----------------------------------------------------------------------------

proc sproc_get_spec_info { args } {

  sproc_pinfo -mode start

  parse_proc_arguments -args $args options

  switch $options(-info) {
    lib {
      set return_value [file dirname [file dirname $options(-spec)]]
    }
    cell {
      set return_value [file tail [file dirname $options(-spec)]]
    }
    pin {
      set return_value [file tail $options(-spec)]
    }
    lib_cell {
      set return_value [file dirname $options(-spec)]
    }
    lib_cell_pin {
      set return_value $options(-spec)
    }
  }

  sproc_pinfo -mode stop
  return $return_value
}

define_proc_attributes sproc_get_spec_info \
  -info "Returns info about cell spec" \
  -define_args {
  {-info "Info to return from cell spec" AnOos one_of_string
    {required value_help {values {lib cell pin lib_cell lib_cell_pin}}}
  }
  {-spec "The cell spec" AString string required}
}

## -----------------------------------------------------------------------------
## sproc_get_scenario_info:
## -----------------------------------------------------------------------------

proc sproc_get_scenario_info { args } {

  sproc_pinfo -mode start

  global env SEV SVAR TEV

  parse_proc_arguments -args $args options

  set error_flag 0

  ## Check that the scenario name is properly formatted

  sproc_msg -info "$options(-scenario)"
  set mode          [ lindex [ split $options(-scenario) "-" ] 0 ]
  set corner        [ lindex [ split $options(-scenario) "-" ] 1 ]
  set lib_condition [ lindex [ split $corner "_" ] 0 ]
  set rc_condition  [ lindex [ split $corner "_" ] 1 ]
  set tmp           [ lindex [ split $corner "_" ] 2 ]
  set sta_condition [ lindex [ split $corner "_" ] 3 ]
  set function_mode [ lrange [ split $corner "_" ] 4 end ]

  if { ( $mode == "" ) || $lib_condition == "" || $rc_condition == "" || $tmp == "" || $sta_condition == "" } {
    sproc_msg -error "The scenario name is not of the proper format."
    sproc_msg -error "  -scenario : $options(-scenario)"
    set error_flag 1
  }
  if { [lsearch $SVAR(setup,modes) $mode ] == -1 } {
    sproc_msg -issue "There is no longer a strict requirement on modal naming."
    sproc_msg -warning "Invalid scenario name field: $mm_type"
    sproc_msg -warning "Valid values are: $SVAR(setup,mm_types_list)"
    ## set error_flag 1
  }
  if { [lsearch $SVAR(setup,lib_conditions) $lib_condition] == -1 } {
    sproc_msg -error "Invalid scenario name field: $lib_condition"
    sproc_msg -error "Valid values are: $SVAR(setup,lib_conditions)"
    set error_flag 1
  }
  if { [lsearch $SVAR(setup,rc_conditions) $rc_condition ] == -1 } {
    sproc_msg -error "Invalid scenario name field: $rc_condition"
    sproc_msg -error "Valid values are: $SVAR(setup,rc_conditions)"
    set error_flag 1
  }
  if { [lsearch $SVAR(setup,tmp) $tmp ] == -1 } {
    sproc_msg -error "Invalid scenario name field: $tmp"
    sproc_msg -error "Valid values are: $SVAR(setup,tmp)"
    set error_flag 1
  }
  if { [lsearch $SVAR(setup,sta_condition) $sta_condition ] == -1 } {
    sproc_msg -error "Invalid scenario name field: $sta_condition"
    sproc_msg -error "Valid values are: $SVAR(setup,sta_condition)"
    set error_flag 1
  }
  foreach function_mode_tmp $function_mode {
    if { [lsearch $SVAR(setup,function_mode) $function_mode_tmp ] == -1 } {
      sproc_msg -error "Invalid scenario name field: $function_mode_tmp"
      sproc_msg -error "Valid values are: $SVAR(setup,function_mode)"
      set error_flag 1
    }
  }

  if { $error_flag } {
    set return_value ERROR
  } else {
    switch $options(-type) {
      mode          { set return_value $mode }
      lib_condition { set return_value $lib_condition }
      rc_condition  { set return_value $rc_condition }
      tmp           { set return_value $tmp }
      sta_condition { set return_value $sta_condition }
      function_mode { set return_value $function_mode }
    }
  }

  sproc_pinfo -mode stop
  return $return_value
}

define_proc_attributes sproc_get_scenario_info \
  -info "Returns information about a scenario" \
  -define_args {
  {-scenario "The scenario name" AString string required}
  {-type     "The portion of the scenario name to return" AnOos one_of_string
    {required value_help {values {mode lib_condition rc_condition tmp sta_condition function_mode}}}
  }
}

## -----------------------------------------------------------------------------
## sproc_correlation_paths:
## -----------------------------------------------------------------------------

proc sproc_correlation_paths { args } {

  sproc_pinfo -mode start

  set options(-max_paths) 100
  parse_proc_arguments -args $args options

  set timing_paths [ \
    get_timing_paths \
    -delay_type max \
    -max_paths $options(-max_paths) \
    ]

  set fid [open $options(-script) w]

  set path_count 1

  foreach_in_collection path $timing_paths {
    set startpoint         [get_attribute $path startpoint]
    set endpoint           [get_attribute $path endpoint]
    set startpoint_name    [get_attribute $startpoint full_name]
    set endpoint_name      [get_attribute $endpoint   full_name]

    set points [get_attribute $path points]
    foreach_in_collection point $points {
      set object [get_attribute $point object]
      set point_name [get_attribute $object full_name]
      set point_rise_fall [get_attribute $point rise_fall]
    }
    if { ($point_rise_fall != "rise") && ($point_rise_fall != "fall") } {
      sproc_msg -error "Rise/Fall for endpoint $endpoint_name is unknown. (rise_fall attribute)"
      set point_rise_fall unknown
    }
    if { $endpoint_name != $point_name } {
      sproc_msg -error "Rise/Fall for endpoint $endpoint_name is unknown. (endpoint not equal to last point)"
      set point_rise_fall unknown
    }

    set path_name [format "%08s" $path_count]

    puts $fid "redirect \$RPT_DIR/path.$path_name {"
      puts $fid "  report_timing \\"
      puts $fid "    -delay max \\"
      puts $fid "    -tran -cap -path full_clock -crosstalk_delta \\"
      puts $fid "    -input_pins -nets -crosstalk_delta -derate \\"
      puts $fid "    -significant_digits 4 -nosplit \\"
      puts $fid "    -from $startpoint_name \\"
      switch $point_rise_fall {
        rise {
          puts $fid "    -rise_to $endpoint_name "
        }
        fall {
          puts $fid "    -fall_to $endpoint_name "
        }
        unknown {
          puts $fid "    -to $endpoint_name "
        }
      }
    puts $fid "}\n"

    incr path_count
  }

  close $fid

  sproc_pinfo -mode stop
}

define_proc_attributes sproc_correlation_paths \
  -info "Generate paths file for correlation purposes." \
  -define_args {
  {-script "The script to create." AString string required}
  {-max_paths "The number of paths to check." AnInt int optional}
}

## -----------------------------------------------------------------------------
## sproc_run_atpg:
## -----------------------------------------------------------------------------

proc sproc_run_atpg { args } {

  sproc_pinfo -mode start

  global env SEV SVAR TEV
  global sh_product_version

  set options(-enable_distributed) 0
  parse_proc_arguments -args $args options

  ## -------------------------------------
  ## See if any faults remain to be processed.
  ## Execute the run_atpg command if faults are present.
  ## (If faults are not present, an error message is generated.)
  ## -------------------------------------

  set faults_present 1
  redirect -variable report {
    report_summaries faults
  } 
  set lines [split $report "\n"]
  foreach line $lines {
    if { [regexp {^\s*Not detected\s+ND\s+(\d+)} $line match count] } {
      if { $count == 0 } {
        set faults_present 0
      }
    }
  } 
  if { $faults_present == 0 } {
    sproc_msg -warning "No ND faults remain to be tested. Skipping the run_atpg command."
    sproc_pinfo -mode stop
    return
  } else {
    sproc_msg -info "The non-detected fault count is currently at $faults_present"
  }

  ## -------------------------------------
  ## Faults are present, so continue with processing.
  ## -------------------------------------

  ##
  ## An error occurs if the fault list is smaller than the number of distributed processors.
  ## Just to be safe, the arbitrary min fault count of 13 is used to disable distribution. 
  ##
  if { $options(-enable_distributed) && ($faults_present < 13) } {
    sproc_msg -issue "Disabling distribution for this limited fault list of $faults_present"
    set options(-enable_distributed) 0
  }

  if { $options(-enable_distributed) && ($TEV(num_child_jobs) > 1) && $SEV(job_enable) } {

    if { ($SEV(job_app) == "lsf") || ($SEV(job_app) == "grd") } {
      sproc_msg -info "Valid value for SEV(job_app)"
    } else {
      sproc_msg -error "Unknown value for SEV(job_app)"
      sproc_script_stop -exit
    }

    set atpg_dist_dir $SEV(tmp_dir)/dist_atpg
    file mkdir $atpg_dist_dir
    set_messages -log $atpg_dist_dir/atpg_job.log -replace
    set_distributed \
      -work_dir $atpg_dist_dir \
      -slave_setup_timeout 1000 \
      -verbose

    switch $SEV(job_app) {
      lsf {
        set app [sproc_which -app bsub]
      }
      grd {
        set app [sproc_which -app qsub]
      }
    }

    if { $TEV(distributed_job_args) == "" } {
      set fname [file rootname $SEV(log_file)].rtm_job_cmd
      set job_args [sproc_distributed_job_args -file $fname]
    } else {
      set job_args $TEV(distributed_jobs_args)
    }

    add_distributed_processors \
      -lsf $app \
      -options $job_args \
      -nservers $TEV(num_child_jobs)

    report_distributed_processors

    report_settings distributed

    run_atpg -auto -distributed

  } else {

    run_atpg -auto

  }

  sproc_pinfo -mode stop
}

define_proc_attributes sproc_run_atpg \
  -info "Controls TetraMax parallel job execution." \
  -define_args {
  {-enable_distributed "Enable distributed operation" ""  boolean optional}
}

## -----------------------------------------------------------------------------
## sproc_bbox_to_poly:
## -----------------------------------------------------------------------------

proc sproc_bbox_to_poly { args } {

  sproc_pinfo -mode start

  set options(-bbox) ""
  parse_proc_arguments -args $args options

  ## Remove all {} if included
  regsub -all {\{||\}} $options(-bbox) {} options(-bbox)

  if {[llength $options(-bbox)] != 4} {
    sproc_msg -error "Input must be a valid bbox with the four points: lx ly ux uy."
    sproc_pinfo -mode stop
    return
  }

  sproc_msg -info "The input bbox is: $options(-bbox)"
  scan $options(-bbox) "%f %f %f %f" lx ly ux uy
  set return_list "{$lx $ly} {$ux $ly} {$ux $uy} {$lx $uy} {$lx $ly}"
  sproc_msg -info "The output points are: $return_list"

  sproc_pinfo -mode stop
  return $return_list
}

define_proc_attributes sproc_bbox_to_poly \
  -info "Returns polygon points for the input bbox." \
  -define_args {
  {-bbox    "Bounding box coordinates." AString string required}
}

## -----------------------------------------------------------------------------
## sproc_insert_halos:
## -----------------------------------------------------------------------------

proc sproc_insert_halos { args } {

  sproc_pinfo -mode start

  global env SEV SVAR TEV

  set options(-points) ""
  set options(-outer) 0
  set options(-width) $SVAR(libsetup,site_height)
  set options(-placement) 0
  set options(-route) 0
  set options(-rg_type) "signal"
  set options(-all_layers) 0
  set options(-port_sizing) 0
  set options(-prefix) "HALO"

  parse_proc_arguments -args $args options

  set development_rg_mode 1 

  ## -------------------------------------
  ## Perform error checking of inputs.
  ## -------------------------------------

  if { !$options(-placement) && !$options(-route) } {
    sproc_msg -error "Must specify the halo type (i.e. placement/route)."
    sproc_pinfo -mode stop
    return
  }
  if { $options(-width) <= 0 } {
    sproc_msg -error "Must specify a positive width value."
    sproc_pinfo -mode stop
    return
  }

  if { $options(-port_sizing) && $options(-outer) } {
    sproc_msg -error "Cannot specify both -port_sizing and -outer switches."
    sproc_pinfo -mode stop
    return
  }

  if { ($options(-rg_type) != "signal") && ($options(-rg_type) != "preroute") } {
    sproc_msg -error "Must specify either signal or preroute."
    sproc_pinfo -mode stop
    return
  }

  ## -------------------------------------
  ## Create rectangles for blockages.
  ## -------------------------------------
  if { $options(-outer) } {
    set halo_width $options(-width)
  } else {
    set halo_width -$options(-width)
  }

  if {[llength $options(-points)] < 5} {
    set points [sproc_bbox_to_poly -bbox $options(-points)]
  } else {
    set points $options(-points)
  }
  set poly $points
  set delta_poly [resize_polygon -size $halo_width $points]

  if { $halo_width >= 0 } {
    set ring [compute_polygons -boolean not $delta_poly $poly]
  } else {
    set ring [compute_polygons -boolean not $poly $delta_poly]
  }
  set rectangles [convert_from_polygon $ring]

  ## -------------------------------------
  ## Create placement blockages.
  ## -------------------------------------

  if { $options(-placement) } {
    set x 0
    foreach rect $rectangles {
      create_placement_blockage -name $options(-prefix)_pb_$x -bbox $rect
      incr x
    }
  }

if { $development_rg_mode == 0 } {

  ## -------------------------------------
  ## Create route guides.
  ## -------------------------------------

  if { $options(-route) } {

    if { $options(-rg_type) == "signal" } {
      set rg_type "-zero_min_spacing -no_signal_layers"
      set all_layers [sproc_convert_to_metal_layer_name -to $SVAR(route,layer_signal_max)]
    } else {
      set rg_type "-no_preroute_layers"
      set all_layers [sproc_convert_to_metal_layer_name -to $SVAR(route,layer_block_max)]
    }

    set x 0
    if { $options(-all_layers) } {
      ## Create route guides that block all layers.
      foreach rect $rectangles {
        eval create_route_guide -name $options(-prefix)_rg_$x -coordinate {$rect} $rg_type {$all_layers}
        incr x
      }
    } else {
      ## Create route guides for layers on preferred directions only.
      set vertical_layers ""
      set horizontal_layers ""
      
      ## Determine which layers are horizontal/vertical.
      foreach layer $all_layers {
        if { [sproc_get_preferred_direction -layer_name $layer] == "V" } {
          lappend vertical_layers $layer
        } else {
          lappend horizontal_layers $layer
        }
      }
      
      foreach rect $rectangles {
        set llx [lindex [lindex $rect 0] 0]
        set lly [lindex [lindex $rect 0] 1]
        set urx [lindex [lindex $rect 1] 0]
        set ury [lindex [lindex $rect 1] 1]

        ## Determine direction of rectangle.  Assuming larger side is direction.
        if { [expr $ury - $lly] > [expr $urx - $llx] } {
          set rect_dir V
        } else {
          set rect_dir H
        }
        ## Create route guides for layers on preferred directions.
        if { $rect_dir == "V" } {
          eval create_route_guide -name $options(-prefix)_rg_$x -coordinate {$rect} ${rg_type} {$vertical_layers}
        } else {
          eval create_route_guide -name $options(-prefix)_rg_$x -coordinate {$rect} ${rg_type} {$horizontal_layers}
        }  
        incr x
      }
    }

  }
}

  ## -------------------------------------
  ## Resize port shapes.
  ## -------------------------------------

  if { $options(-port_sizing) && $options(-route) && !$options(-outer) } {
    foreach rect $rectangles {
      set llx [lindex [lindex $rect 0] 0]
      set lly [lindex [lindex $rect 0] 1]
      set urx [lindex [lindex $rect 1] 0]
      set ury [lindex [lindex $rect 1] 1]

      ## Determine direction of rectangle.  Assuming larger side is direction.
      if { [expr $ury - $lly] > [expr $urx - $llx] } {
        ## Verticle side
        foreach_in_collection port [get_ports] {
          set terminal [get_terminals -of_objects $port]
          scan [get_attribute $terminal bbox] "{%f %f} {%f %f}" terminal_llx terminal_lly terminal_urx terminal_ury
          set terminal_width [expr $terminal_ury - $terminal_lly]
          set terminal_length [expr $terminal_urx - $terminal_llx]
	  ## Ports on right side.
	  if { $terminal_urx == $urx } {
            set_attribute $terminal bbox_llx [expr $urx - ($options(-width) + $terminal_width)]
          }
          ## Ports on left side.
	  if { $terminal_llx == $llx } {
            set_attribute $terminal bbox_urx [expr $llx + ($options(-width) + $terminal_width)]
          }
        }

      } else {
        ## Horizontal side
        foreach_in_collection port [get_ports] {
          set terminal [get_terminals -of_objects $port]
          scan [get_attribute $terminal bbox] "{%f %f} {%f %f}" terminal_llx terminal_lly terminal_urx terminal_ury
          set terminal_width [expr $terminal_urx - $terminal_llx]
          set terminal_length [expr $terminal_ury - $terminal_lly]
          ## Ports on top side.
	  if { $terminal_ury == $ury } {
            set_attribute $terminal bbox_lly [expr $ury - ($options(-width) + $terminal_width)]
          }
          ## Ports on bottom side.
	  if { $terminal_lly == $lly } {
            set_attribute $terminal bbox_ury [expr $lly + ($options(-width) + $terminal_width)]
          }
        }
      }

    }
  }

if { $development_rg_mode == 1 } {

  ## -------------------------------------
  ## Create route guides.
  ## -------------------------------------

  if { $options(-route) } {
    
    if { $options(-rg_type) == "signal" } {
      set all_layers [sproc_convert_to_metal_layer_name -to $SVAR(route,layer_signal_max)]
      set rg_type "-no_signal_layers"
    } else {
      set rg_type "-no_preroute_layers"
      set all_layers [sproc_convert_to_metal_layer_name -to $SVAR(route,layer_block_max)]
    }

    set x 0
    ## Create route guides that block appropriate layers.
    foreach rect1 $rectangles {

      foreach layer $all_layers {

        ## compute scaler for resizing shapes (eg terminals).  the scaler is slightly
        ## greater than x2 minSpacing to account of minSpacing to the left and the right.
        set layer_scaler [expr 2.1 * [get_layer_attribute -layer $layer minSpacing] ]

        ## compute layer preferred_direction
        set layer_preferred_direction [get_layer_attribute -layer $layer preferred_direction]

        ## compute rect1 orientation
        set llx [lindex [lindex $rect1 0] 0]
        set lly [lindex [lindex $rect1 0] 1]
        set urx [lindex [lindex $rect1 1] 0]
        set ury [lindex [lindex $rect1 1] 1]
        if { [expr $ury - $lly] > [expr $urx - $llx] } {
          set rect_orientation vertical
        } else {
          set rect_orientation horizontal
        }

        ## convert rect1 of potential route_guide into a polygon
        set poly1 [sproc_bbox_to_poly -bbox $rect1]
        set poly1_save $poly1

        ## get shapes (eg routes, terminals) intersecting rect1 ... filter out power & ground ...
        set shapes_net_shapes [ get_net_shapes -intersect $rect1 -filter "layer==$layer" -quiet ]
        set shapes_terminals [ get_terminals -intersect $rect1 -filter "layer==$layer" -quiet ]
        set pg_ports [remove_from_collection [get_ports -all *] [get_ports]]
        foreach_in_collection pg_port $pg_ports { 
          set pg_net [all_connected $pg_port]
          set pg_port_name [get_attribute $pg_port name]
          set shapes_terminals [ filter_collection $shapes_terminals "owner_port!=$pg_port_name" ]
          set pg_net_name [get_attribute $pg_net name]
          set shapes_net_shapes [ filter_collection $shapes_net_shapes "owner_net!=$pg_net_name" ]
        }
        set shapes_net_shapes [ filter_collection $shapes_net_shapes "net_type!=Power" ]
        set shapes_net_shapes [ filter_collection $shapes_net_shapes "net_type!=Ground" ]
        set shapes [ add_to_collection $shapes_net_shapes $shapes_terminals ]

        ## perform polygon computations ... effectively start w/ original rect1
        ## and "not out" each shape.  each shape is padded by x2 minSpacing prior
        ## to "not out"
        foreach_in_collection shape $shapes {
          set poly2 [ convert_to_polygon $shape ]
          set poly2 [ resize_polygon $poly2 -size $layer_scaler]
          set poly2 [ compute_polygons -boolean and $poly1_save $poly2 ]
          set poly2_not [ compute_polygons -boolean xor $poly1_save $poly2 ]
          set poly1 [ compute_polygons -boolean and $poly1 $poly2_not ]
        }

        ##
        ## occassionally this routine is used to create route_guides for preroutes.
        ## when this is done a lot of times pins aren't yet assigned and other anomolies.
        ## as such some of the computations below fail and we get no route_guides.
        ## the following should detect this situation and force suitable route_guides
        ## to be created.  this should be OK as these route_guides get deleted after
        ## power insertion.  is is thought that when the UI to this proc is cleaned
        ## up we can approach this more robustly.
        ##
        if { ( $options(-rg_type) == "preroute" ) && ( $options(-port_sizing) == 0 ) } {
          set poly1 $poly1_save
        }

        ## create route guides that are contoured around actual routes
        if { [ llength [ lindex $poly1 0 ] ] == 2 } {
          set poly1 "{ $poly1 }"
        }
        foreach tmp_poly1 $poly1 {
          set rect2 [convert_from_polygon $tmp_poly1] 
          if { [llength $rect2] == 1 } {
            if { $options(-all_layers) || ( $layer_preferred_direction == $rect_orientation ) } {
              eval create_route_guide -name $options(-prefix)_rg_$x -coordinate $rect2 $rg_type {$layer}
              incr x
            }
          }
        }

      }

    }

  }

}

  sproc_pinfo -mode stop
}

define_proc_attributes sproc_insert_halos \
  -info "Create a ring of halos around the provided polygon at -width in size" \
  -define_args {
  {-points    "List of point that define the polygon" AString string required}
  {-outer     "Set if you want an outer ring."  "" boolean optional}
  {-width     "Width of halos"  AString string optional}
  {-placement "Set if you want placement blockages created." "" boolean optional}
  {-route     "Set if you want route guides created." "" boolean optional}
  {-rg_type   "Type of route guide.  Valid values are signal/preroute." AString string optional}
  {-all_layers "Set if you want route guides to block all layers." "" boolean optional}
  {-port_sizing "Set if you want to resize ports." "" boolean optional}
  {-prefix    "Prefix for halos" AString string optional}
}

## -----------------------------------------------------------------------------
## sproc_get_drivers:
## -----------------------------------------------------------------------------

proc sproc_get_drivers {args} {

  sproc_pinfo -mode start

  global synopsys_program_name

  set options(-object_spec) ""
  parse_proc_arguments -args $args options

  ## If it's not a collection, convert into one

  redirect /dev/null {set size [sizeof_collection $options(-object_spec)]}
  if {$size == ""} {
    set objects {}
    foreach name $options(-object_spec) {
      if {[set stuff [get_ports -quiet $name]] == ""} {
        if {[set stuff [get_cells -quiet $name]] == ""} {
          if {[set stuff [get_pins -quiet $name]] == ""} {
            if {[set stuff [get_nets -quiet $name]] == ""} {
              continue
            }
          }
        }
      }
      set objects [add_to_collection $objects $stuff]
    }
  } else {
    set objects $options(-object_spec)
  }

  if {$objects == ""} {
    sproc_msg -error "No objects given"
    sproc_pinfo -mode stop
    return [add_to_collection "" ""]
  }

  set driver_results {}

  ## Process all cells

  if {[set cells [get_cells -quiet $objects]] != ""} {
    ## Add driver pins of these cells
    set driver_results [add_to_collection -unique $driver_results \
      [get_pins -quiet -of $cells -filter "pin_direction == out || pin_direction == inout"]]
  }

  ## Get any nets
  set nets [get_nets -quiet $objects]

  ## Get any pin-connected nets
  if {[set pins [get_pins -quiet $objects]] != ""} {
    set nets [add_to_collection -unique $nets \
      [get_nets -quiet -of $pins]]
  }

  ## Get any port-connected nets
  if {[set ports [get_ports -quiet $objects]] != ""} {
    set nets [add_to_collection -unique $nets \
      [get_nets -quiet -of $ports]]
  }

  ## Process all nets
  if {$nets != ""} {
    ## Add driver pins of these nets
    set driver_results [add_to_collection -unique $driver_results \
      [get_pins -quiet -leaf -of $nets -filter "pin_direction == out || pin_direction == inout"]]
    set driver_results [add_to_collection -unique $driver_results \
      [get_ports -quiet -of $nets -filter "port_direction == in || port_direction == inout"]]
  }

  sproc_pinfo -mode stop
  return $driver_results
}

define_proc_attributes sproc_get_drivers \
  -info "Return driver ports/pins of object" \
  -define_args {
    {-object_spec "Object(s) to report" "object_spec" string required}
}

## -----------------------------------------------------------------------------
## sproc_get_correct_inst_name:
## -----------------------------------------------------------------------------

proc sproc_get_correct_inst_name { args } {

  sproc_pinfo -mode start

  parse_proc_arguments -args $args options

  set inst_name $options(-inst)

  ## See if the instance name is an exact match.

  set cell [get_cells -quiet $inst_name]

  if { [sizeof_collection $cell] == 1 } {

    ## If so, just return the instance name as is.

    set return_value $inst_name

  } else {

    ## If not, search for a likely alternative.

    set alt_cells [get_cells -hier * -filter "mask_layout_type==macro"]

    regsub -all {/} $inst_name {_} inst_name_new

    set found_flag 0
    foreach_in_collection alt_cell $alt_cells {
      if { !$found_flag } {
        set alt_name [get_attribute $alt_cell full_name]
        regsub -all {/} $alt_name {_} alt_name_new
        if { $inst_name_new == $alt_name_new } {
          set found_flag 1
          set return_value $alt_name
        }
      }
    }

    if { !$found_flag } {
      sproc_msg -error "Unable to resolve instance name $inst_name"
      set return_value CELL_NOT_FOUND
    }

  }

  sproc_pinfo -mode stop
  return $return_value
}

define_proc_attributes sproc_get_correct_inst_name \
  -info "Used to resolve instance names that may have slightly changed due to hier processing." \
  -define_args {
  {-inst "Instance name" AString string required}
}

## -----------------------------------------------------------------------------
## sproc_dump_dct_icc_alignment:
## -----------------------------------------------------------------------------

proc sproc_dump_dct_icc_alignment { args } {

  sproc_pinfo -mode start

  global synopsys_program_name
  global sh_product_version
  global timing_enable_multiple_clocks_per_reg
  global placer_max_cell_density_threshold
  global physopt_hard_keepout_distance
  global placer_soft_keepout_channel_width
  global physopt_area_critical_range
  global physopt_power_critical_range
  global physopt_hard_keepout_distance
  global enable_recovery_removal_arcs
  global physopt_enable_via_res_support
  global physopt_enable_via_res_support
  global physopt_create_missing_physical_libcells

  set options(-fname) "./dct_icc_alignment.rpt"
  parse_proc_arguments -args $args options
  set rpt_name $options(-fname)

  if { ( $synopsys_program_name == "dc_shell" ) && ( [shell_is_in_topographical_mode] == 0 ) } {
    sproc_msg -warning "  DCT is not in topographical mode ... aborting report."
    sproc_pinfo -mode stop
    return
  }

  redirect $rpt_name.report_congestion_options {
    report_congestion_options -all
  }
  redirect $rpt_name.report_ignored_layers {
    report_ignored_layers
  }
  redirect $rpt_name.report_preferred_routing_direction {
    report_preferred_routing_direction
  }
  redirect $rpt_name.report_delay_estimation_options {
    report_delay_estimation_options
  }

  ## -------------------------------------
  ## build the list of checks
  ## -------------------------------------
  set num_checks 0
  set ds($num_checks,variable) "synopsys_program_name"

  incr num_checks
  set ds($num_checks,variable) "sh_product_version"

  incr num_checks
  set ds($num_checks,variable) "enable_recovery_removal_arcs"

  incr num_checks
  set ds($num_checks,variable) "timing_enable_multiple_clocks_per_reg"

  incr num_checks
  set ds($num_checks,variable) "placer_max_cell_density_threshold"

  incr num_checks
  set ds($num_checks,variable) "physopt_hard_keepout_distance"

  incr num_checks
  set ds($num_checks,variable) "placer_soft_keepout_channel_width"

  incr num_checks
  set ds($num_checks,variable) "physopt_area_critical_range"

  incr num_checks
  set ds($num_checks,variable) "physopt_power_critical_range"

  incr num_checks
  set ds($num_checks,variable) "physopt_hard_keepout_distance"

  incr num_checks
  set ds($num_checks,variable) "physopt_enable_via_res_support"

  incr num_checks
  set ds($num_checks,variable) "physopt_create_missing_physical_libcells"

  ## -------------------------------------
  ## determine the values
  ## -------------------------------------
  for {set i 0} {$i <= $num_checks} {incr i} {
    switch $synopsys_program_name {
      dc_shell {

        set tmp "set tmp \$$ds($i,variable)"
        eval $tmp
        set ds($i,value) $tmp

      }
      icc_shell {

        set ds($i,value) [get_app_var $ds($i,variable)]

      }
      default {
        sproc_msg -error "Unrecognized tool $synopsys_program_name in sproc_dump_dct_icc_alignment"
      }
    }
  }

  ##
  ## open FID and create table header & table
  ##
  set fid [open $rpt_name w]
  puts $fid " "
  puts $fid " Report generated on [date]"
  puts $fid " Report generated with $synopsys_program_name"
  puts $fid " "
  puts $fid "   i   Value           Variable                          "
  puts $fid " ---- --------------- -----------------------------------"
  for {set i 0} {$i <= $num_checks} {incr i} {
    set str [ format "  %2d  %-15s %-35s" $i $ds($i,value) $ds($i,variable) ]
    puts $fid "$str"
  }
  puts $fid " "
  close $fid

  sproc_msg -info "Report Generation for DCT / ICC Alignment Ending    : [date]"
  sproc_pinfo -mode stop
}

define_proc_attributes sproc_dump_dct_icc_alignment \
  -info "Dump misc tool settings for DCT / ICC to help assure similar tool alignment." \
  -define_args {
  {-fname    "File name for the report."                      AString string  optional}
}

## -----------------------------------------------------------------------------
## sproc_dump_shape_off_litho_grid:
## -----------------------------------------------------------------------------

proc sproc_dump_shape_off_litho_grid { args } {

  sproc_pinfo -mode start

  set options(-shapes) ""
  set options(-fname) "./shape_off_litho_grid.rpt"
  parse_proc_arguments -args $args options

  ##
  ## initialization
  ##
  if { $options(-shapes) == "" } {
    sproc_msg -warning "sproc_dump_shape_off_litho_grid: \"-shapes\" == \"\" so attempting to auto identify shapes."
    set nets [ get_nets -hier * ] 
    set options(-shapes) [ get_net_shapes -of $nets ]
    set options(-shapes) [ add_to_collection $options(-shapes) [ get_vias -of $nets ] ]
  }
  set myerrors 0
  set mycnt 1
  set mytot [sizeof_collection $options(-shapes)]
  set shapes_off_litho_grid {}
  set mydesign [current_mw_cel]
  set mylib [current_mw_lib]

  if { $mytot == 0 } {
    sproc_msg -warning "sproc_dump_shape_off_litho_grid: There are no shapes to process so exiting."
    sproc_pinfo -mode stop
    return
  }

  ##
  ## figure out unit resolution
  ##
  redirect -var report {
    report_mw_lib -unit_range $mylib
  }

  set units 0
  set lines [split $report "\n"]
  foreach line $lines {
    regexp {^length\s+\S+\s+(\S+)} $line match units
  }
  if {$units == 0} {
    sproc_msg -error "sproc_dump_shape_off_litho_grid: Could not derive units from report_mw_lib output"
    sproc_pinfo -mode stop
    return
  }

  ##
  ## start creating the report
  ##
  set fid [open $options(-fname) w]
  puts $fid " "
  puts $fid " Report generated on [date] "
  puts $fid " "

  ##
  ## save off current user grid in case it is set to something other than default
  ## set the grid to the litho grid, query grid to get litho grid
  ##
  set old_user_grid [get_user_grid $mydesign]
  set_user_grid -reset $mydesign
  set user_grid [get_user_grid $mydesign]

  set litho_grid_x [lindex $user_grid 1 0]
  set litho_grid_y [lindex $user_grid 1 1]

  set litho_grid_units_x [expr int([expr $litho_grid_x * $units])]
  set litho_grid_units_y [expr int([expr $litho_grid_y * $units])]

  foreach_in_collection shape $options(-shapes) {
    set shape_bbox_llx [get_attribute $shape bbox_llx]
    set shape_bbox_lly [get_attribute $shape bbox_lly]
    set shape_bbox_urx [get_attribute $shape bbox_urx]
    set shape_bbox_ury [get_attribute $shape bbox_ury]

    set shape_bbox_llx_units [expr int([expr $shape_bbox_llx * $units])]
    set shape_bbox_lly_units [expr int([expr $shape_bbox_lly * $units])]
    set shape_bbox_urx_units [expr int([expr $shape_bbox_urx * $units])]
    set shape_bbox_ury_units [expr int([expr $shape_bbox_ury * $units])]

    if { [expr $shape_bbox_llx_units % $litho_grid_units_x] != 0 || \
         [expr $shape_bbox_lly_units % $litho_grid_units_y] != 0 || \
         [expr $shape_bbox_urx_units % $litho_grid_units_x] != 0 || \
         [expr $shape_bbox_ury_units % $litho_grid_units_y] != 0 } {
      append_to_collection shapes_off_litho_grid $shape
      incr myerrors 
      puts $fid "litho grid issue detected.  this is error $myerrors."
      puts $fid "   shape = [get_attribute $shape name]"
      puts $fid "   net = [get_attribute $shape owner_net]"
      puts $fid "   bbox = { { $shape_bbox_llx $shape_bbox_lly } { $shape_bbox_urx $shape_bbox_ury } }"
      puts $fid " "
    }
    if {[expr $mycnt % 1000] == 0} {
      sproc_msg -info "sproc_dump_shape_off_litho_grid:   processed $mycnt of $mytot shapes, [date]."
    }
    incr mycnt
  }
  incr mycnt -1
  sproc_msg -info "sproc_dump_shape_off_litho_grid:   processed $mycnt of $mytot shapes, [date]."

  #restore user grid
  set_user_grid -user_grid $old_user_grid $mydesign

  puts $fid " "
  puts $fid " Grid Information"
  puts $fid "   Original Grid : {$old_user_grid}"
  puts $fid "      Litho Grid : {$user_grid}"
  puts $fid " "

  puts $fid " "
  puts $fid "  Processed $mycnt of $mytot shapes."
  if { ( $myerrors > 0 ) } {
    puts $fid "    $myerrors errors were identified."
  } else {
    puts $fid "    No errors were identified."
  } 
  puts $fid " "
  close $fid
 
  sproc_pinfo -mode stop
  return $shapes_off_litho_grid

}

define_proc_attributes sproc_dump_shape_off_litho_grid \
  -info "Utility for identify net shapes off litho grid." \
  -define_args {
    {-fname        "File name for the report." AString string  optional}
    {-shapes "A user specified colletion of net shapes to process" "" string optional}
}


## -----------------------------------------------------------------------------
## sproc_dump_ff_info:
## -----------------------------------------------------------------------------

proc sproc_dump_ff_info { args } {

  sproc_pinfo -mode start

  set options(-include_cts) 0
  set options(-fname) "./ff_status.rpt"
  parse_proc_arguments -args $args options

  sproc_msg -info "Report Generation for FF Info Beginning : [date]"

  ## open FID and create table header
  set fid [open $options(-fname) w]
  puts $fid " "
  puts $fid " Report generated on [date] "
  puts $fid " "
  puts $fid "                                   IS    CTS"
  puts $fid "     BBOX(LL)        ORIEN PLACED FIXED FIXED DONT_TOUCH REF_NAME              FULL_NAME"

  for {set i 0} {$i <= $options(-include_cts)} {incr i} {

    ## get cells of interest
    if { $i == 1 } {
      puts $fid "      ----------> cts elements from this line down <----------"
      set the_cells [ remove_from_collection [ get_cells -of [ all_fanout -clock_tree ] ] \
        [ all_registers ] ]
      set the_cells [ filter $the_cells "is_hierarchical==false" ]
    } else {
      set the_cells [ all_registers ]
    }
    set the_cells [sort_collection $the_cells full_name]

    ## dump table
    foreach_in_collection the_cell $the_cells {
      set str [ format " %-20s" [get_attribute -quiet $the_cell bbox_ll] ]
      set str [ format "%s %-2s" $str [get_attribute -quiet $the_cell orientation] ]
      set str [ format "%s    %-5s" $str [get_attribute -quiet $the_cell is_placed] ]
      set str [ format "%s %-5s" $str [get_attribute -quiet $the_cell is_fixed] ]
      set str [ format "%s %-5s" $str [get_attribute -quiet $the_cell cts_fixed] ]
      set str [ format "%s  %-5s" $str [get_attribute -quiet $the_cell dont_touch] ]
      set str [ format "%s     %-20s" $str [get_attribute -quiet $the_cell ref_name] ]
      set str [ format "%s %-s " $str [get_attribute -quiet $the_cell full_name] ]
      puts $fid $str
    }
  }
  puts $fid " "
  close $fid

  sproc_msg -info "Report Generation for FF Info Ending    : [date]"

  sproc_pinfo -mode stop
}

define_proc_attributes sproc_dump_ff_info \
  -info "Dump snapshot of misc information (e.g. location, orientation, ref_name, etc.) regarding status of FF." \
  -define_args {
  {-fname        "File name for the report." AString string  optional}
  {-include_cts  "Include CTS elements too " ""      boolean optional}
}

## -----------------------------------------------------------------------------
## sproc_dump_cts_route_info:
## -----------------------------------------------------------------------------

proc sproc_dump_cts_route_info { args } {

  sproc_pinfo -mode start

  set options(-fname) "./cts_route_status.rpt"
  parse_proc_arguments -args $args options

  sproc_msg -info "Report Generation for CTS Route Info Beginning : [date]"

  ##
  ## Gather information and compute stats about netshapes
  ##
  ## Note some trickery w/r/t to getting valid CTS pins,
  ## as objects globbed @ a chip level can cause down
  ## stream failures ... hence restricting pin set to
  ## those items that appear to be std cells.
  ##

  set ct_pins [all_fanout -clock_tree]
  set ct_cells [get_cells -of $ct_pins]
  set ct_cells_std [filter $ct_cells "mask_layout_type==std"]
  set ct_cells_not_std [remove_from_collection $ct_cells $ct_cells_std]
  set ct_pins_valid [remove_from_collection $ct_pins [get_pins -of $ct_cells_not_std]]

  ## alpha numeric sort, make sure unique collection, and real
  set the_nets [ sort_collection [ get_nets -of $ct_pins_valid ] full_name ]
  set the_nets_names [ collection_to_list $the_nets -name_only -no_braces ]
  set the_nets_names [ sproc_uniquify_list -list $the_nets_names ]
  set the_nets [ get_nets $the_nets_names ]
  set the_nets [ filter_collection $the_nets "number_of_wires>0" ]

  set ds(ns) [ get_net_shapes -of $the_nets ]
  set ds(ns_number) [ sizeof_collection $ds(ns) ]
  set ds(via) [ get_vias -of [ get_nets -of $ct_pins_valid ] ]
  set ds(via_number) [ sizeof_collection $ds(via) ]

  if { ( $ds(via_number) != 0 ) && ( $ds(ns_number) == 0 ) } {

    sproc_msg -info "sproc_dump_cts_route_info: ICGR appears to be present, proceeding accordingly."
    sproc_msg -warning "Work in progress and hence no functionality"

    set dr 0
    set via 1

  } elseif { ( $ds(via_number) != 0 ) && ( $ds(ns_number) != 0 ) } {

    sproc_msg -warning "sproc_dump_cts_route_info: DR appears to be present, proceeding accordingly."

    set dr 1
    set via 1

  } else {

    sproc_msg -warning "sproc_dump_cts_route_info: no CTS route info identified, aborting."

    set dr 0
    set via 0

  }

  ##
  ## perform dr analysis
  ##
  if { $dr } {

    set ds(length) 0.0
    set layers [ sproc_convert_to_metal_layer_name ]
    foreach layer $layers {
  
      set ds($layer,ns) [ filter $ds(ns) "layer == $layer" ]
      set ds($layer,number) [ sizeof_collection $ds($layer,ns) ]
  
      ## gather information
      foreach orientation "HWIRE VWIRE" {
        set ds($layer,$orientation,ns) [ filter $ds($layer,ns) "object_type == $orientation" ]
        set ds($layer,$orientation,number) [ sizeof_collection $ds($layer,$orientation,ns) ]
        set ds($layer,$orientation,length) 0
        foreach_in_collection ns $ds($layer,$orientation,ns) {
          set ds($layer,$orientation,length) [expr $ds($layer,$orientation,length) + [get_attribute $ns length] ]
        }
      }
  
      set ds($layer,length) [expr $ds($layer,HWIRE,length) + $ds($layer,VWIRE,length) ]
      set ds(length) [expr $ds(length) + $ds($layer,length)]
      if { $ds($layer,length) > 0.0 } {
        set ds($layer,HWIRE,length,percent) [expr 100.0 * $ds($layer,HWIRE,length) / $ds($layer,length) ]
        set ds($layer,VWIRE,length,percent) [expr 100.0 * $ds($layer,VWIRE,length) / $ds($layer,length) ]
      } else {
        set ds($layer,HWIRE,length,percent) 0.0
        set ds($layer,VWIRE,length,percent) 0.0
      }
      if { $ds($layer,number) > 0 } {
        set ds($layer,HWIRE,number,percent) [expr 100.0 * $ds($layer,HWIRE,number) / $ds($layer,number) ]
        set ds($layer,VWIRE,number,percent) [expr 100.0 * $ds($layer,VWIRE,number) / $ds($layer,number) ]
      } else {
        set ds($layer,HWIRE,number,percent) 0.0
        set ds($layer,VWIRE,number,percent) 0.0
      }
  
    }
  
    ## compute composite statistics for layer
    foreach layer $layers {
      set ds($layer,length,percent) [expr 100.0 * $ds($layer,length) / $ds(length) ]
      set ds($layer,number,percent) [expr 100.0 * $ds($layer,number) / $ds(ns_number) ]
    }

  }

  ##
  ## perform via analysis
  ##
  if { $via } {
    ## technology via_layer info
    set via_layers [ get_layers * ]
    set via_layers [ filter $via_layers "is_routing_layer==true" ]
    set via_layers [ filter $via_layers "layer_type==via" ]

    ## statistics of via_layer of design
    foreach_in_collection via_layer $via_layers {
      set via_layer_name [get_attribute $via_layer full_name]
      set ds($via_layer_name,via) [filter_collection $ds(via) "via_layer==$via_layer_name"]
      set ds($via_layer_name,number) [sizeof_collection $ds($via_layer_name,via) ]
      set ds($via_layer_name,number,percent) [ expr 100.0 * $ds($via_layer_name,number) / $ds(via_number) ] 
    }
  }

  ##
  ## report generation
  ##
  if { $via || $dr } {
    ## open FID and create table header
    set fid [open $options(-fname) w]
    puts $fid " "
    puts $fid " Report generated on [date] "
  }

  if { $dr } {
    puts $fid " "
    puts $fid "                   NETSHAPE LENGTH"
    puts $fid " LAYER      TOTAL (  %  ) /    HORIZ (  %  ) /    VERTI (  %  )  "
    foreach layer $layers {
      set str [ format "  %-4s" $layer ]
      set str [ format "%s %10.2f" $str $ds($layer,length) ]
      set str [ format "%s (%5.2f)" $str $ds($layer,length,percent) ]
      set str [ format "%s %10.2f" $str $ds($layer,HWIRE,length) ]
      set str [ format "%s (%5.2f)" $str $ds($layer,HWIRE,length,percent) ]
      set str [ format "%s %10.2f" $str $ds($layer,VWIRE,length) ]
      set str [ format "%s (%5.2f)" $str $ds($layer,VWIRE,length,percent) ]
      puts $fid $str
    }
    set str [ format "       %10.2f " $ds(length) ]
    puts $fid $str

    puts $fid " "
    puts $fid "                    # NETSHAPES"
    puts $fid " LAYER      TOTAL (  %  ) /    HORIZ (  %  ) /    VERTI (  %  )  "
    foreach layer $layers {
      set str [ format "  %-4s" $layer ]
      set str [ format "%s %10.0f" $str $ds($layer,number) ]
      set str [ format "%s (%5.2f)" $str $ds($layer,number,percent) ]
      set str [ format "%s %10.0f" $str $ds($layer,HWIRE,number) ]
      set str [ format "%s (%5.2f)" $str $ds($layer,HWIRE,number,percent) ]
      set str [ format "%s %10.0f" $str $ds($layer,VWIRE,number) ]
      set str [ format "%s (%5.2f)" $str $ds($layer,VWIRE,number,percent) ]
      puts $fid $str
    }
    set str [ format "       %10.0f " $ds(ns_number) ]
    puts $fid $str
  }

  if { $via } {
    puts $fid " "
    puts $fid "    # VIA_LAYERS"
    puts $fid " LAYER      TOTAL (  %  ) "
    foreach_in_collection via_layer $via_layers {
      set via_layer_name [get_attribute $via_layer full_name]
      set ds($via_layer_name,number,percent) 
      set str [ format "  %-4s" $via_layer_name ]
      set str [ format "%s %10.0f" $str $ds($via_layer_name,number) ]
      set str [ format "%s (%5.2f)" $str $ds($via_layer_name,number,percent) ]
      puts $fid $str
    }
    set str [ format "       %10.0f " $ds(via_number) ]
    puts $fid $str
    puts $fid " "
  }

  if { $via && !$dr } {
    puts $fid " "
    puts $fid "   GROUTE     X       Y       NUM     NUM "
    puts $fid "   LENGTH   LENGTH  LENGTH    PINS   WIRES    NAME "
    foreach_in_collection the_net $the_nets {
      set str [ format " %8.3f" [get_attribute -quiet $the_net groute_length] ]
      set str [ format "%s %7d" $str [get_attribute -quiet $the_net x_length] ]
      set str [ format "%s %7d" $str [get_attribute -quiet $the_net y_length] ]
      set str [ format "%s %7d" $str [get_attribute -quiet $the_net num_pins] ]
      set str [ format "%s %7d" $str [get_attribute -quiet $the_net number_of_wires] ]
      set str [ format "%s   %-s " $str [get_attribute -quiet $the_net full_name] ]
      puts $fid $str
    }
    puts $fid " "
  }

  if { $via || $dr } {
    close $fid
  }

  sproc_msg -info "Report Generation for CTS Route Info Ending    : [date]"

  sproc_pinfo -mode stop
}

define_proc_attributes sproc_dump_cts_route_info \
  -info "Dump snapshot of cts route information." \
  -define_args {
  {-fname        "File name for the report."                      AString string  optional}
}

## -----------------------------------------------------------------------------
## sproc_dump_port_info:
## -----------------------------------------------------------------------------

proc sproc_dump_port_info { args } {

  sproc_pinfo -mode start

  global env SEV SVAR TEV

  set options(-fname) "./port_status.rpt"
  set options(-max_metal_length) 50.0
  parse_proc_arguments -args $args options

  sproc_msg -info "Report Generation for Port Info Beginning : [date]"

  ##
  ## Compute and gather stats
  ##

  set ports [get_ports]
  set ports [remove_from_collection $ports [get_ports -quiet -filter "direction==inout"]]
  set ports [ sort_collection $ports {direction full_name} ]
  set num_ports 0

  foreach_in_collection port $ports {

    ## Info about port / net

    set ds($num_ports,name) [get_attribute $port name]
    set ds($num_ports,direction) [get_attribute $port direction]

    set net [get_net -of [get_port $port]]

    if { [sizeof_collection $net] == 0 } {

      ##
      ## Deal with exception case were the MW doesn't see a net on unconnected port.
      ##

      set ds($num_ports,num_loads) 0
      set ds($num_ports,num_ant_loads) 0
      set ds($num_ports,load_ref_name) ""
      ## set ds($num_ports,vias) ""
      set ds($num_ports,num_vias) 0
      ## set ds($num_ports,ns) ""
      set ds($num_ports,num_ns) 0
      set ds($num_ports,length_ns) 0
      set ds($num_ports,area_ns) 0

    } else {

      if { $ds($num_ports,direction) == "in" } {
        if  { [ sizeof_collection [all_connected $net] ] == 1 } {
          set loads [ add_to_collection "" "" ]
        } else {
          set loads [ all_fanout -from $net -flat -only_cells -levels 0 ]
        }
        set ds($num_ports,num_loads) [ sizeof_collection $loads ]
      } else {
        set net_src [ all_connected [ all_fanin -to $net -flat -levels 0 ] ]
        if { [ sizeof_collection $net_src ] == 0 } {
          set loads [ add_to_collection "" "" ]
        } else {
          set loads [ all_fanin -to $net_src -flat -levels 0 ]
        }
        set ds($num_ports,num_loads) [ sizeof_collection $loads ]
      }

      ## Attempt to determine if any of the loads are diodes

      set ds($num_ports,num_ant_loads) 0
      set ds($num_ports,load_ref_name) ""
      foreach_in_collection load $loads {
        set load_name [get_attribute $load full_name]
        set cell_name [file dirname $load_name]
        ##
        ## puts "load_name: $load_name"
        ## puts "cell_name: $cell_name"
        ##
        if { [ regexp ^SNPS_ant_ $load_name ] } {
          incr ds($num_ports,num_ant_loads)
        }
        set ds($num_ports,load_ref_name) "$ds($num_ports,load_ref_name) [get_attribute -quiet $cell_name ref_name]"
      }

      ## Stats on net_shapes

      set ds($num_ports,vias) [get_vias -of $net]
      set ds($num_ports,num_vias) [sizeof_collection $ds($num_ports,vias)]
      set ds($num_ports,ns) [get_net_shapes -of $net]
      set ds($num_ports,num_ns) [sizeof_collection $ds($num_ports,ns)]
      set ds($num_ports,length_ns) 0
      set ds($num_ports,area_ns) 0
      foreach_in_collection ns $ds($num_ports,ns) {
        set ds($num_ports,length_ns) \
          [expr $ds($num_ports,length_ns) + [get_attribute $ns length]]
        set ds($num_ports,area_ns) \
          [expr $ds($num_ports,area_ns) + ( [get_attribute $ns length] * [get_attribute $ns width] ) ]
      }
    }

    incr num_ports

  }

  ##
  ## Screen if unrouted database & suppress no metal warnings
  ##

  set suppress_no_metal 0
  set num_no_metal_ports 0
  for {set i 0} {$i < $num_ports} {incr i} {
    if { $ds($i,length_ns) < 0.00001 } { incr num_no_metal_ports }
  }
  if { [ expr ( ( 1.0 * $num_no_metal_ports ) / $num_ports ) ] > 0.5 } {
    set suppress_no_metal 1
  }

  ##
  ## Analyze data for warnings
  ##

  for {set i 0} {$i < $num_ports} {incr i} {

    set ds($i,comment) ""
    if { [expr $ds($i,num_loads) - $ds($i,num_ant_loads) ] > 1 } {
      if { $ds($i,comment) == "" } {
        set ds($i,comment) "NON-SINGLE POINT CONNECTION"
      } else {
        set ds($i,comment) "$ds($i,comment), NON-SINGLE POINT CONNECTION"
      }
    }
    if { $ds($i,num_loads) < 1 } {
      if { $ds($i,comment) == "" } {
        set ds($i,comment) "UNCONNECTED PORT"
      } else {
        set ds($i,comment) "$ds($i,comment), UNCONNECTED PORT"
      }
    }
    if { $ds($i,length_ns) > $options(-max_metal_length) } {
      if { $ds($i,comment) == "" } {
        set ds($i,comment) "METAL LENGTH > $options(-max_metal_length)"
      } else {
        set ds($i,comment) "$ds($i,comment), METAL LENGTH > $options(-max_metal_length)"
      }
    }
    if { $ds($i,length_ns) < 0.00001 && ( $suppress_no_metal == 0 ) } {
      if { $ds($i,comment) == "" } {
        set ds($i,comment) "NO METAL"
      } else {
        set ds($i,comment) "$ds($i,comment), NO METAL"
      }
    }
  }

  ##
  ## Open FID and create table header & table
  ##

  set fid [open $options(-fname) w]
  puts $fid " "
  puts $fid " Report generated on [date] "
  if { $suppress_no_metal } {
    puts $fid " "
    puts $fid "   The design appears to not be routed yet so suppressing NO METAL warnings."
  }
  puts $fid " "
  puts $fid "               Est.    Net     Net"
  puts $fid " Check    #   Diode   Shape   Shape    #    #         Port                            Load"
  puts $fid " Flag   Loads Loads  Length    Area    NS  VIAS dir   Name                 Comment  Ref Name(s)"
  puts $fid " -----  ----- ----- -------- -------- ---- ---- --- -------------------- ---------- -----------"
  for {set i 0} {$i < $num_ports} {incr i} {
    if { $ds($i,comment) == "" } {
      set str "       "
    } else {
      set str " CHECK "
    }
    set str [ format "%s %5d" $str $ds($i,num_loads) ]
    set str [ format "%s %5d" $str $ds($i,num_ant_loads) ]
    set str [ format "%s %8.2f" $str $ds($i,length_ns) ]
    set str [ format "%s %8.2f" $str $ds($i,area_ns) ]
    set str [ format "%s %4d %4d" $str $ds($i,num_ns) $ds($i,num_vias)]
    set str [ format "%s %-3s" $str $ds($i,direction) ]
    set str [ format "%s %-20s " $str $ds($i,name) ]
    set str [ format "%s %-8s " $str $ds($i,comment) ]
    if { $ds($i,num_loads) > 4 } {
      set str [ format "%s %s " $str "[lrange $ds($i,load_ref_name) 0 3] ..." ]
    } else {
      set str [ format "%s %s " $str $ds($i,load_ref_name) ]
    }
    puts $fid "$str"
  }
  puts $fid " "
  close $fid

  sproc_msg -info "Report Generation for Port Info Ending    : [date]"
  sproc_pinfo -mode stop
}

define_proc_attributes sproc_dump_port_info \
  -info "Dump snapshot of misc information (e.g. loads, net length, name, etc.) regarding ports of a design." \
  -define_args {
  {-fname    "File name for the report."                      AString string  optional}
  {-max_metal_length "Screen for total metal length > # (default=50.0)" "" float optional}
}


## -----------------------------------------------------------------------------
## sproc_dump_single_connection_to_pin_check
##  - the following routine can be used to analyze pins that have been accessed
##    by the router at more than one location
## -----------------------------------------------------------------------------

proc sproc_dump_single_connection_to_pin_check { args } {

  set options(-fname) "./single_connection_to_pin_check.rpt"
  set options(-metal1) "M1"
  parse_proc_arguments -args $args options

  sproc_msg -info "Report Generation for Single Connection to Pin Check Beginning : [date]"
  
  ##
  ## misc initialization
  ##
  set total_problems 0
  set cells [get_cells -hier *]
 
  set fid [open $options(-fname) w]
  puts $fid " "
  puts $fid " Report generated on [date] "
  puts $fid " "
  puts $fid " # isolated    pin        pin w/"
  puts $fid " net shapes  direction   problem"
  puts $fid " ----------  ---------  ----------------------------------"
  
  ## loop over cells
  foreach_in_collection cell $cells {
  
    ## grab key info and loop over pins
    set cell_bbox [get_attribute $cell bbox]
    set pins [get_pins -of $cell]
    foreach_in_collection pin $pins {
  
      ## filter net & via shapes down to those overlapping cell on 'metal1'
      set net [ all_connected $pin ]
    
      set via_shapes [add_to_collection "" ""]
      set via_shapes [add_to_collection $via_shapes [get_vias -of $net -intersect $cell_bbox] ]
      set via_shapes [add_to_collection $via_shapes [get_vias -of $net -within $cell_bbox] ]
      set via_shapes [filter $via_shapes "lower_layer==$options(-metal1)" ]
    
      set net_shapes [add_to_collection "" ""]
      set net_shapes [add_to_collection $net_shapes [get_net_shapes -of $net -intersect $cell_bbox] ]
      set net_shapes [add_to_collection $net_shapes [get_net_shapes -of $net -within $cell_bbox] ]
      set net_shapes [filter $net_shapes "layer==$options(-metal1)" ]
    
      set the_shapes [add_to_collection $via_shapes $net_shapes]
    
      set num_shapes [sizeof $the_shapes]
  
      ## verify shapes overlapping
      if { $num_shapes > 1 } {
        for {set x 0} {$x<$num_shapes} {incr x} {
          set overlaps($x) 0
          set ob1 [index_collection $the_shapes $x]
          set ob1_llx [get_attribute $ob1 bbox_llx]
          set ob1_lly [get_attribute $ob1 bbox_lly]
          set ob1_urx [get_attribute $ob1 bbox_urx]
          set ob1_ury [get_attribute $ob1 bbox_ury]
          for {set y 0} {$y<$num_shapes} {incr y} {
            if { $x != $y } {
              set ob2 [index_collection $the_shapes $y]
              set ob2_llx [get_attribute $ob2 bbox_llx]
              set ob2_lly [get_attribute $ob2 bbox_lly]
              set ob2_urx [get_attribute $ob2 bbox_urx]
              set ob2_ury [get_attribute $ob2 bbox_ury]
              if { ( $ob1_llx <= $ob2_llx ) && ( $ob1_urx >= $ob2_llx ) && ( $ob1_lly <= $ob2_lly ) && ( $ob1_ury >= $ob2_lly ) ||
                   ( $ob1_llx <= $ob2_urx ) && ( $ob1_urx >= $ob2_urx ) && ( $ob1_lly <= $ob2_lly ) && ( $ob1_ury >= $ob2_lly ) ||
                   ( $ob1_llx <= $ob2_urx ) && ( $ob1_urx >= $ob2_urx ) && ( $ob1_lly <= $ob2_ury ) && ( $ob1_ury >= $ob2_ury ) ||
                   ( $ob1_llx <= $ob2_llx ) && ( $ob1_urx >= $ob2_llx ) && ( $ob1_lly <= $ob2_ury ) && ( $ob1_ury >= $ob2_ury ) ||
                   ( $ob2_llx <= $ob1_llx ) && ( $ob2_urx >= $ob1_llx ) && ( $ob2_lly <= $ob1_lly ) && ( $ob2_ury >= $ob1_lly ) ||
                   ( $ob2_llx <= $ob1_urx ) && ( $ob2_urx >= $ob1_urx ) && ( $ob2_lly <= $ob1_lly ) && ( $ob2_ury >= $ob1_lly ) ||
                   ( $ob2_llx <= $ob1_urx ) && ( $ob2_urx >= $ob1_urx ) && ( $ob2_lly <= $ob1_ury ) && ( $ob2_ury >= $ob1_ury ) ||
                   ( $ob2_llx <= $ob1_llx ) && ( $ob2_urx >= $ob1_llx ) && ( $ob2_lly <= $ob1_ury ) && ( $ob2_ury >= $ob1_ury ) } {
                set overlaps($x) [expr $overlaps($x) + 1]
              }
            }
          }
        }
    
        ## look if the are non overlapping shapes (ie isolated_shapes)
        set isolated_shapes 0
        for {set x 0} {$x<$num_shapes} {incr x} {
          if { $overlaps($x) == 0 } {
            incr isolated_shapes
          }
        }
    
        ## if isolated_shapes verify they aren't due to same net connecting to multiple pins
        if { $isolated_shapes > 0 } {
          set num_common_nets 0
          set net1_name [get_attribute $net name]
          set nets [all_connected $pins]
          foreach_in_collection net2 $nets {
            set net2_name [get_attribute $net2 name]
            if { $net1_name == $net2_name } { 
              incr num_common_nets
            } 
          }
          if { $isolated_shapes == $num_common_nets } {
            set isolated_shapes 0
          } else { 
            set isolated_shapes [expr $isolated_shapes - $num_common_nets + 1]
          }
        } 
  
      }
    
      if { $num_shapes > 1 && $isolated_shapes > 0 } {
        set str [ format "    %2d          %3s     %-s " $isolated_shapes [get_attribute $pin direction] [get_attribute $pin full_name] ]
        puts $fid $str
        incr total_problems
      }
    
    }
  
  }
  
  puts $fid " "
  puts $fid "  WARNING : $total_problems pins were identified as having been accessed in more than one location."
  puts $fid " "
  close $fid

  sproc_msg -info "Report Generation for Single Connection To Pin on Check Ending    : [date]"

}

define_proc_attributes sproc_dump_single_connection_to_pin_check \
  -info "Dump pins with more than one route connection accessing it." \
  -define_args {
    {-fname    "File name for the report."   AString string optional}
    {-metal1   "Name of metal1 (default=M1)" AString string optional}
  }



## -----------------------------------------------------------------------------
## sproc_icc_map_tlup_to_nxtgrd:
## -----------------------------------------------------------------------------

proc sproc_icc_map_tlup_to_nxtgrd { args } {

  sproc_pinfo -mode start

  global env SEV SVAR TEV

  parse_proc_arguments -args $args options

  sproc_msg -info "Executing sproc_icc_map_tlup_to_nxtgrd"

  ## determine TLU+ settings
  set tlup_lib_max "unset"
  set tlup_lib_min "unset"
  set tlup_lib_max_emf "unset"
  set tlup_lib_min_emf "unset"
  redirect -variable rpt {
    report_tlu_plus_files
  }

  set lines [split $rpt "\n"]
  foreach line $lines {
    regexp {^\s*Max TLU\+ file: (\S+)} $line matchVar tlup_lib_max
    regexp {^\s*Min TLU\+ file: (\S+)} $line matchVar tlup_lib_min
    regexp {^\s*Max EMULATION TLU\+ file: (\S+)} $line matchVar tlup_lib_max_emf
    regexp {^\s*Min EMULATION TLU\+ file: (\S+)} $line matchVar tlup_lib_min_emf
  }

  if { [ sizeof_collection [ get_mw_cel -quiet $SVAR(design_name).FILL ] ] == 0 } {

    sproc_msg -info "  Using nxtgrd for emulated FILL."

    ## map max TLU+ -> NXTGRD
    set nxtgrd_max "unset"
    if { $tlup_lib_max_emf == "unset" } {
      foreach oc $SVAR(setup,rc_types_list) {
        if { $SVAR(tech,tlup_file,$oc) == $tlup_lib_max } {
          set nxtgrd_max $SVAR(tech,nxtgrd_file,$oc)
        }
      }
    } else {
      foreach oc $SVAR(setup,rc_types_list) {
        if { $SVAR(tech,tlup_emf_file,$oc) == $tlup_lib_max_emf } {
          set nxtgrd_max $SVAR(tech,nxtgrd_emf_file,$oc)
        }
      }
    }

    ## map min TLU+ -> NXTGRD
    set nxtgrd_min "unset"
    if { $tlup_lib_min_emf == "unset" } {
      foreach oc $SVAR(setup,rc_types_list) {
        if { $SVAR(tech,tlup_file,$oc) == $tlup_lib_min } {
          set nxtgrd_min $SVAR(tech,nxtgrd_file,$oc)
        }
      }
    } else {
      foreach oc $SVAR(setup,rc_types_list) {
        if { $SVAR(tech,tlup_emf_file,$oc) == $tlup_lib_min_emf } {
          set nxtgrd_min $SVAR(tech,nxtgrd_emf_file,$oc)
        }
      }
    }

  } else {

    sproc_msg -info "  Using nxtgrd for real FILL."

    ## map max TLU+ -> NXTGRD
    set nxtgrd_max "unset"
    foreach oc $SVAR(setup,rc_types_list) {
      if { $SVAR(tech,tlup_file,$oc) == $tlup_lib_max } {
        set nxtgrd_max $SVAR(tech,nxtgrd_file,$oc)
      }
    }

    ## map min TLU+ -> NXTGRD
    set nxtgrd_min "unset"
    foreach oc $SVAR(setup,rc_types_list) {
      if { $SVAR(tech,tlup_file,$oc) == $tlup_lib_min } {
        set nxtgrd_min $SVAR(tech,nxtgrd_file,$oc)
      }
    }

  }

  if { $nxtgrd_max == "unset" } {
    sproc_msg -error "Unable to perform and TLU+ -> NXTGRD mapping"
    sproc_msg -error "tluplus_lib_max"
    sproc_msg -error "tluplus_lib_min"
    sproc_msg -error "nxtgrd_max"
    sproc_msg -error "nxtgrd_min"
    report_tlu_plus_files
    set return_value ""
  } elseif { ( $nxtgrd_max != "unset" ) && ( $nxtgrd_min == "unset" ) } {
    set return_value $nxtgrd_max
  } elseif { ( $nxtgrd_max != "unset" ) && ( $nxtgrd_min != "unset" ) } {
    set return_value "$nxtgrd_max $nxtgrd_min"
  }

  sproc_pinfo -mode stop
  return $return_value
}

define_proc_attributes sproc_icc_map_tlup_to_nxtgrd \
  -info "Procedure to map TLU+ to NXTGRD for signoff_opt ." \
  -define_args {
}

## -----------------------------------------------------------------------------
## sproc_icc_scenario_management:
## -----------------------------------------------------------------------------

proc sproc_icc_scenario_management { args } {

  sproc_pinfo -mode start

  global env SEV SVAR TEV
  global mcmm_high_capacity_effort_level

  parse_proc_arguments -args $args options

  sproc_msg -info "Executing sproc_icc_scenario_management"

  ## sproc_msg -info "  Initial Active Scenarios : [all_active_scenarios]"
  sproc_msg -info "  Initial Active Scenarios : are not being displayed to avoid a potential runtime penalty."

  if { $options(-scenarios) == "all_scenarios" } {

    sproc_msg -info "  Setting active scenarios to all scenarios ."
    set_active_scenarios -all

  } elseif { $options(-scenarios) == "single_scenario" } {

    sproc_msg -info "  Setting active scenarios to a single scenarios (i.e. first scenario in all_scenarios)."
    set_active_scenarios [ lindex [ all_scenarios ] 0 ]

  } elseif { [ regexp {^get_dominant_scenarios} $options(-scenarios) ] } {

    sproc_msg -info "  Setting active scenarios to dominant scenarios."

    if { [ regexp {^get_dominant_scenarios_} $options(-scenarios) ] } {
      regsub {^get_dominant_scenarios_} $options(-scenarios) "" mcmm_high_capacity_effort_level
    } else {
      set_app_var mcmm_high_capacity_effort_level 0
    }

    set temp_get_dominant_scenarios [ get_dominant_scenarios -scenarios [ all_scenarios ] ]
    if { [llength $temp_get_dominant_scenarios] == 0 } {
      sproc_msg -warning "  gds failed to identify any violating scenarios and as such one random scenario is activated"
      set_active_scenarios [ lindex [ all_scenarios ] 0 ]
    } else {
      set_active_scenarios $temp_get_dominant_scenarios
    }

  } elseif { $options(-scenarios) == "" } {

    sproc_msg -info "  No adjustment is being made to active scenarios."

  } else {

    sproc_msg -info "  Setting active scenarios to user defined scenarios @ runtime via options(-scenarios)."
    set_active_scenarios $options(-scenarios)

  }

  sproc_msg -info "    Note mcmm_high_capacity_effort_level = $mcmm_high_capacity_effort_level"
  sproc_msg -info "      Valid High Capacity Effort Level = 0 .. 10 (conservative to agressive scenario reduction)."
  sproc_msg -info "  Final Active Scenarios   : [all_active_scenarios]"

  sproc_pinfo -mode stop
}

define_proc_attributes sproc_icc_scenario_management \
  -info "Procedure to for scenario management for MCMM." \
  -define_args {
  {-scenarios   "Selection mode or a string of scenarios "      AString string required}
}

## -----------------------------------------------------------------------------
## sproc_macro_setup:
## -----------------------------------------------------------------------------

proc sproc_macro_setup { args } {

  sproc_pinfo -mode start

  global SVAR SEV
  global compile_preserve_subdesign_interfaces

  ##
  ## Get arguments
  ##

  set options(-load_only) 0
  parse_proc_arguments -args $args options

  ##
  ## Configure for correct macro loading.
  ##

  foreach element [sproc_get_macros -hard -logic -model_info] {
    set design_name [lindex $element 0]
    set model       [lindex $element 1]

    if { [info exists design_name_already_used($design_name)] } {
      sproc_msg -info "Macro $design_name already using type $model"
    } else {
      set design_name_already_used($design_name) 1
      if { [shell_is_in_topographical_mode] } {
        switch $model {
          ddc {
            sproc_msg -info "Macro $design_name using model type $model"
            read_ddc $SEV(step_dir)/work/000_inputs/$design_name.ddc
          }
          ddc_ilm {
            sproc_msg -info "Macro $design_name using model type $model"
            read_ddc $SEV(step_dir)/work/000_inputs/ilm/$design_name.ddc
          }
          icc_ilm {
            sproc_msg -info "Macro $design_name using model type $model"
            lappend link_library $design_name.ILM
          }
          default {
            sproc_msg -error "Incorrect model type for macro $design_name: $model"
          }
        }
      } else {
        switch $model {
          ddc {
            sproc_msg -info "Macro $design_name using model type $model"
            read_ddc $SEV(step_dir)/work/000_inputs/$design_name.ddc
          }
          ddc_ilm {
            sproc_msg -info "Macro $design_name using model type $model"
            read_ddc $SEV(step_dir)/work/000_inputs/ilm/$design_name.ddc
          }
          icc_ilm {
            sproc_msg -error "Incorrect model type for macro $design_name: $model"
            sproc_msg -error "The model type icc_ilm is not supported for non-topo."
          }
          default {
            sproc_msg -error "Incorrect model type for macro $design_name: $model"
          }
        }
      }
    }
  }

  ##
  ## If -load_only was specified, do not perform any other functions.
  ##

  if { $options(-load_only) } {
    sproc_msg -info "Skipping optimization controls for macros."
    sproc_pinfo -mode stop
    return
  }

  ##
  ## Set current_design back to the top level in preparation for rest of procedure.
  ##

  current_design $SVAR(design_name)

  ##
  ## Manage treatement of macros
  ##

  foreach element [sproc_get_macros -hard -logic -inst -model_info] {
    set inst  [lindex $element 0]
    set model [lindex $element 1]
    if { [shell_is_in_topographical_mode] } {
      if { $model == "ddc" } {
        if { [get_attribute [get_cells $inst] dct_hier_is_physical_block]!=true } {
          sproc_msg -info "sproc_macro_setup: Setting $inst as physical_hierarchy"
          set_physical_hierarchy $inst
        } else { 
          sproc_msg -info "sproc_macro_setup: instance $inst reference already set as physical_hierarchy"
        }
      } else {
        sproc_msg -info "sproc_macro_setup: Model type $model for $inst needs no additional setup"
      }
    } else {
      sproc_msg -info "sproc_macro_setup: Setting $inst as dont_touch"
      set_dont_touch $inst
    }
  }

  set macros [sproc_get_macros -hard -logic]
  if { [llength $macros] > 0 } {
    ## benefits hierarchical formal verification
    sproc_msg -issue "Applying WA for issues seen with ILMs: setting set_boundary_optimization false and compile_preserve_subdesign_interface true "
    set_boundary_optimization $macros false
    set_app_var compile_preserve_subdesign_interfaces true
  }

  ## soft macro handling
  foreach inst  [sproc_get_macros -inst -soft] {
    sproc_msg -info "sproc_macro_setup: Preventing ungrouping for soft macro $inst"
    set_ungroup $inst false
  }

  set covered_as_logic_mac 0
  foreach macro [sproc_get_macros -soft] {
    foreach lmacro [sproc_get_macro -logic] {
      if { $macro == $lmacro } {
        set covered_as_logic_mac 1
      }
    }
    if { !$covered_as_logic_mac } {
      sproc_msg -info "sproc_macro_setup: Preventing boundary optimization for soft macro $macro"
      set_boundary_optimization $macro false
      sproc_msg -info "sproc_macro_setup: Attributing macro $macro with its current name for restoring later"
      ## special attribute for restoring macro model name after uniquification
      set_attribute [get_designs $macro] orig_soft_macro_name -type string $macro 
      set_app_var compile_preserve_subdesign_interfaces true
    }
  }

  sproc_pinfo -mode stop
}

define_proc_attributes sproc_macro_setup \
  -info "Procedure to consistently configure macros for synthesis." \
  -define_args {
  {-load_only "Only load macros, do not set compilation attributes." "" boolean optional}
}

## -----------------------------------------------------------------------------
## sproc_restore_soft_macro_names:
## -----------------------------------------------------------------------------

proc sproc_restore_soft_macro_names  { args } {

  sproc_pinfo -mode start

  global SVAR SEV

  ## find designs (soft macros) which have attribute indicating original name and restore
  set renamed_sm  [get_object_name [get_designs -filter orig_soft_macro_name!=""]]
  set renamed_sm [lsort -uniq $renamed_sm]
  foreach des $renamed_sm {
    set des_name [get_attribute $des full_name]
    set original_name [get_attribute $des_name orig_soft_macro_name]
    if { $des_name != $original_name } {
      sproc_msg -info "Restore uniquified soft macro name $des_name back to orignal $original_name"
      rename_design $des $original_name
    } else {
      sproc_msg -info "No name change needed to restore soft macro name $des_name"
    }
  }
  sproc_pinfo -mode stop
}

define_proc_attributes sproc_restore_soft_macro_names \
  -info "Procedure to restore soft macro names after uniquification." \
  -define_args {
}

## -----------------------------------------------------------------------------
## sproc_dct_setup_mw:
## -----------------------------------------------------------------------------

proc sproc_dct_setup_mw {} {

  sproc_pinfo -mode start

  global env SEV SVAR TEV
  global mw_reference_library
  global mw_design_library

  set mw_reference_library $SVAR(lib,mw_reflist)
  set mw_design_library $SEV(dst_dir)/$SVAR(design_name).mdb

  if { [file exists $mw_design_library] } {
    file delete -force $mw_design_library
  }

  create_mw_lib \
    -technology $SVAR(tech,mw_tech_file) \
    -mw_reference_library $mw_reference_library \
    $mw_design_library

  open_mw_lib $mw_design_library

  sproc_pinfo -mode stop
}

define_proc_attributes sproc_dct_setup_mw \
  -info "Procedure to consistently create MW database for DCT usage." \
  -define_args {
}

## -----------------------------------------------------------------------------
## sproc_dct_setup_physical:
## -----------------------------------------------------------------------------

proc sproc_dct_setup_physical { args } {

  sproc_pinfo -mode start

  global env SEV SVAR TEV
  global PD
  global fuzzy_matching_enabled
  global LYNX

  set options(-use_physical_constraints) 0
  parse_proc_arguments -args $args options

  ## -------------------------------------
  ## Parse data from SVAR(tech,metal_layer_info_list), so that
  ## changes in variable format do not affect this procedure.
  ## -------------------------------------
  unset -nocomplain metal_layer_name_list
  unset -nocomplain metal_layer_dir_list
  foreach item $SVAR(tech,metal_layer_info_list) {
    set name [lindex $item 0]
    set dir  [lindex $item 1]
    lappend metal_layer_name_list $name
    lappend metal_layer_dir_list $dir
  }

  ## -------------------------------------
  ## Set preferred routing direction.
  ## -------------------------------------

  for { set i 0 } { $i < [llength $metal_layer_name_list] } { incr i } {
    set layer_name [lindex $metal_layer_name_list $i]
    set layer_dir  [lindex $metal_layer_dir_list $i]

    if { ($layer_dir == "H") || ($layer_dir == "V") } {
      sproc_msg -info "Direction for metal layer $layer_name is $layer_dir"
      set_preferred_routing_direction -layers $layer_name -direction $layer_dir
    } else {
      sproc_msg -error "Direction for metal layer $layer_name is $layer_dir"
    }
  }

  report_preferred_routing_direction

  ## -------------------------------------
  ## Set ignored layers.
  ## -------------------------------------

  sproc_set_ignored_layers -verbose 

  ## -------------------------------------
  ## Set delay estimation options.
  ## -------------------------------------

  if { [llength [all_scenarios] ] > 1 } {
    foreach scenario [all_scenarios] {
      current_scenario $scenario
      set rc [lindex [split $scenario .] 2]
      if { ( 0 < $SVAR(tech,preroute_cap_multiplier,$rc) < 1 ) || ( 0 < $SVAR(tech,preroute_res_multiplier,$rc) < 1 ) } {
        set_delay_estimation_options \
          -max_unit_horizontal_capacitance_scaling_factor $SVAR(tech,preroute_cap_multiplier,$rc) \
          -max_unit_vertical_capacitance_scaling_factor $SVAR(tech,preroute_cap_multiplier,$rc) \
          -max_unit_horizontal_resistance_scaling_factor $SVAR(tech,preroute_res_multiplier,$rc) \
          -max_unit_vertical_resistance_scaling_factor $SVAR(tech,preroute_res_multiplier,$rc)
      }
    }
  } else {
    if { ( 0 < $SVAR(tech,preroute_cap_multiplier,RC_MAX_1) < 1 ) || ( 0 < $SVAR(tech,preroute_res_multiplier,RC_MAX_1) < 1 ) } {
      set_delay_estimation_options \
        -max_unit_horizontal_capacitance_scaling_factor $SVAR(tech,preroute_cap_multiplier,RC_MAX_1) \
        -max_unit_vertical_capacitance_scaling_factor $SVAR(tech,preroute_cap_multiplier,RC_MAX_1) \
        -max_unit_horizontal_resistance_scaling_factor $SVAR(tech,preroute_res_multiplier,RC_MAX_1) \
        -max_unit_vertical_resistance_scaling_factor $SVAR(tech,preroute_res_multiplier,RC_MAX_1)
    }
  }

  report_delay_estimation_options

  ## -------------------------------------
  ## Adjust extraction scaling for special 'half' nodes (not common)
  ## -------------------------------------

  if {  0 < $SVAR(tech,process_scaler) < 1  } {

    sproc_msg -info "Scaling extraction by $SVAR(tech,process_scaler)"

    set_extraction_options  \
      -max_process_scale $SVAR(tech,process_scaler) \
      -min_process_scale $SVAR(tech,process_scaler)

  }

  ## -------------------------------------
  ## Process physical constraints
  ## -------------------------------------

  if { $options(-use_physical_constraints) } {

    if { [llength $TEV(constraints_physical)] == 1 } {

      ## If file is compressed, then uncompress and continue with uncompressed file.
      if [regexp {\.def(\.gz)*} $TEV(constraints_physical) ] {
        set constraint_type DEF
      }
      if [regexp {\.tcl(\.gz)*} $TEV(constraints_physical) ] {
        set constraint_type TCL
      }
      if [regexp {floorplan} $TEV(constraints_physical) ] {
        set constraint_type FLOORPLAN
      }
      switch $constraint_type {
        "DEF" {
          sproc_msg -info "Physical constraint format is DEF"
          redirect -var rvar { report_tlu_plus_files }
          if { [regexp {There is no} [split $rvar]] } {
            sproc_msg -issue "No tlu setup on design. DEF extraction may fail"
          }
          extract_physical_constraints $TEV(constraints_physical) -allow_physical_cells
          set po_cell_count [sizeof_collection [all_physical_only_cells -quiet]]
          sproc_msg -info  "  $po_cell_count physical_only_cells extracted from DEF"
          if { $SVAR(pwr,upf_enable) } {
            if { [info exists TEV(voltage_area_file)] } {
              if { $TEV(voltage_area_file)=="" } {
                sproc_msg -error "Voltage areas not part of DEF standard. Review TEV(voltage_area_file) as needed"
              }
            }
          }
        }

        "TCL" {
          sproc_msg -info "Physical constraint format is Tcl"

          set fuzzy_matching_enabled true
          sproc_source -file $TEV(constraints_physical)
          set fuzzy_matching_enabled false
        }

        "FLOORPLAN" {
          sproc_msg -info "Physical constraint format is (assumed to be) from write_floorplan"

          set fuzzy_matching_enabled true
          read_floorplan $TEV(constraints_physical)
          set fuzzy_matching_enabled false
        }

        default {
          sproc_msg -error "Unrecognized file type for TEV(constraints_physical)"
          sproc_msg -error "  $TEV(constraints_physical)"
        }

      }

    }

  } else {

    sproc_msg -warning "Not loading physical constraints file."

  }

  report_physical_constraints

  sproc_pinfo -mode stop
}

define_proc_attributes sproc_dct_setup_physical \
  -info "Procedure to consistently configure layer information for DCT usage." \
  -define_args {
  {-use_physical_constraints "Use physical constraints if they exist." "" boolean optional}
}

## -----------------------------------------------------------------------------
## sproc_multiline_grep:
## -----------------------------------------------------------------------------

proc sproc_multiline_grep { args } {

  sproc_pinfo -mode start

  set options(-v) 0

  parse_proc_arguments -args $args options
  set file         $options(-file)
  set grep_string  $options(-grep_string)
  set output_file $options(-output)
  set inverse $options(-v)

  file delete -force $output_file
  set rid [open $file  r]
  set wid [open $output_file     w]

  set return_status 0
  set lcnt 0
  set match_found 0
  while { [gets $rid line] >= 0 } {
    incr lcnt
    set full_line($lcnt) $line
    if { [regexp "$grep_string" $line] } {
      set match_found 1
    }
    if { ![regexp {\\$} $line] } {
      if { ($match_found && !$inverse) || (!$match_found && $inverse) } {
        for {set i 1} {$i <= $lcnt } {incr i} {
          puts $wid $full_line($i)
        }
        set return_status 1
      }
      set lcnt 0
      set match_found 0
    }
  }

  close $rid
  close $wid
  return $return_status
  sproc_pinfo -mode stop
}

define_proc_attributes sproc_multiline_grep \
  -info "grep lines containing a string even if the line spans multiple lines." \
  -define_args {
  {-file "input file" AString string required}
  {-output "output file" AString string required}
  {-grep_string "string to match" AString string required}
  {-v "output lines that dont match only" "" boolean optional}
}

## -----------------------------------------------------------------------------
## sproc_create_combined_upf:
## -----------------------------------------------------------------------------

proc sproc_create_combined_upf {args} {
  global SVAR SEV

  sproc_pinfo -mode start

  set options(-top_upf) NULL
  set options(-logic) 0
  set options(-file) NULL

  parse_proc_arguments -args $args options

  ## Create UPF file
  sproc_msg -issue "Creating single UPF file $options(-file)"

  set gid [open $options(-file) w]
  puts $gid "## ---------------------------------------------------------------------"
  puts $gid "## INFO: Combined UPF file created by FM sproc_create_combined_upf"
  puts $gid "## ---------------------------------------------------------------------"
  puts $gid ""
  if { $options(-logic) } {
    set element_pairs [sproc_get_macros -logic -hard -design_pairs -no_auto] 
    set element_count [llength  [sproc_get_macros -logic -hard] ]
  } else {
    set element_pairs [sproc_get_macros -hard -design_pairs -no_auto] 
    set element_count [llength  [sproc_get_macros -hard] ]
  }
  foreach element $element_pairs  {
    set macro [lindex $element 0]
    set inst  [lindex $element 1]
    ## For proper formal verification, macro netlists must be step aligned and consistent with macro UPF for hierarchical MV flows
    set macro_upf_file ../../../$macro/$SEV(step)/work/800_outputs/$macro.upf
    if [file exists $macro_upf_file] {

      puts $gid "## -------------------------------------"
      puts $gid "## INFO: Macro $macro UPF"
      puts $gid "## -------------------------------------"
      puts $gid "load_upf -scope $inst $macro_upf_file"
    } else {
      puts $gid "## -------------------------------------"
      puts $gid "## INFO: Macro $macro does not seem to have a UPF."
      puts $gid "## -------------------------------------"
    }
  }
  set top_upf $options(-top_upf)
  if {$element_count>0} {
    sproc_msg -info "Creating a single UPF which loads each hierarchical UPF as required for verification"
  } 
  puts $gid "## -------------------------------------"
  puts $gid "## INFO: Top level UPF"
  puts $gid "## -------------------------------------"
  puts $gid "load_upf $top_upf"
  close $gid

  sproc_pinfo -mode stop

}

define_proc_attributes sproc_create_combined_upf \
  -info "Merge top UPF and macro UPF into a single UPF file. Used to support hierarchical upf data in some verification tools which require a single load_upf" \
  -define_args {
  {-top_upf "Top level UPF file" AString string required}
  {-logic "Include any logic macro upf in the combined (in addition to any hard macros)" "" boolean optional}
  {-file "Combined UPF output file name" AString string required}
}

## -----------------------------------------------------------------------------
## sproc_place_macro:
## -----------------------------------------------------------------------------

proc sproc_place_macro { args } {

  sproc_pinfo -mode start

  set options(-macro) {}
  set options(-snap) 0
  parse_proc_arguments -args $args options
  set macro $options(-macro)

  lappend macro_list $macro
  set inst_name   [lindex $macro 0]
  set orientation [lindex $macro 1]
  set xy          [lindex $macro 2]
  set inst_name [sproc_get_correct_inst_name -inst $inst_name]
  set x [lindex $xy 0]
  set y [lindex $xy 1]
  set xy "$x $y"

  sproc_msg -info "Macro : $inst_name oriented $orientation at $xy"

  set_object_fixed $inst_name false
  set cell [get_cells $inst_name]
  rotate_objects -to $orientation $cell
  if { $options(-snap) } {
    set_object_snap_type -enabled true
  } else {
    set_object_snap_type -enabled false
  }
  move_objects -to $xy $cell
  set_object_snap_type -enabled true
  set_object_fixed $inst_name true

  sproc_pinfo -mode stop
}

define_proc_attributes sproc_place_macro \
  -info "This procedure is used by the flow development team for custom floorplanning." \
  -define_args {
  {-macro "Name of macro to be processed." "" string required}
  {-snap  "Snap to row site" "" boolean optional}
}

## -----------------------------------------------------------------------------
## sproc_set_dont_use:
## -----------------------------------------------------------------------------

proc sproc_set_dont_use {} {

  sproc_pinfo -mode start

  global env SEV SVAR TEV

  foreach libcell_spec $SVAR(libsetup,dont_use_cells) {
    set cells [get_lib_cells -quiet $libcell_spec]
    if { [sizeof_collection $cells] == 0 } {
      sproc_msg -warning "sproc_set_dont_use: cell not found for $libcell_spec"
    } else {
      foreach_in_collection cell $cells {
        set cell_name [get_object_name $cell]
        sproc_msg -info "sproc_set_dont_use: set_dont_use on $cell_name"
        set_dont_use $cell
      }
    }
  }

  sproc_pinfo -mode stop
}

define_proc_attributes sproc_set_dont_use \
  -info "Standard procedure for setting dont_use attributes on library cells." \
  -define_args {
}

## -----------------------------------------------------------------------------
## sproc_set_dont_use_pt_eco:
## -----------------------------------------------------------------------------

proc sproc_set_dont_use_pt_eco { args } {

  sproc_pinfo -mode start

  global env SEV SVAR TEV

  set options(-cell) ""
  parse_proc_arguments -args $args options

  sproc_msg -info "sproc_set_dont_use_pt_eco: $options(-cell)"

  define_user_attribute pt_dont_use \
    -quiet -type boolean -class lib_cell

  set_user_attribute -class lib_cell [get_lib_cell -quiet $options(-cell)] pt_dont_use true

  sproc_pinfo -mode stop

}

define_proc_attributes sproc_set_dont_use_pt_eco \
  -info "Sets attributes to enable dont_use function during PT ECO processing." \
  -define_args {
    {-cell "Library cell to dont_use."  AString string optional}
}

## -----------------------------------------------------------------------------
## sproc_set_ignored_layers:
## -----------------------------------------------------------------------------

proc sproc_set_ignored_layers { args } {

  sproc_pinfo -mode start

  global SVAR 

  ## default "options" to info already in SVARs
  set options(-min_routing_layer) [sproc_convert_to_metal_layer_name -list $SVAR(route,layer_signal_min)]
  set options(-max_routing_layer) [sproc_convert_to_metal_layer_name -list $SVAR(route,layer_signal_max)]
  if { $SVAR(route,rc_congestion_ignored_layers) != "" } {
    set options(-rc_congestion_ignored_layers) [sproc_convert_to_metal_layer_name -list $SVAR(route,rc_congestion_ignored_layers)]
  } else {
    set options(-rc_congestion_ignored_layers) ""
  }
  set options(-verbose) 0
  parse_proc_arguments -args $args options

  ## reset prior settings as updates are cumulative
  ## note "-all" only wrt "-rc_congestion_ignored_layers"
  remove_ignored_layers -max_routing_layer
  remove_ignored_layers -min_routing_layer
  remove_ignored_layers -all

  ## update set_ignored_layers w/ new values
  set_ignored_layers -min_routing_layer $options(-min_routing_layer)
  set_ignored_layers -max_routing_layer $options(-max_routing_layer)
  if { $options(-rc_congestion_ignored_layers) != "" } {
    set_ignored_layers -rc_congestion_ignored_layers $options(-rc_congestion_ignored_layers)
  }

  ## if verbose mode generate report
  if { $options(-verbose) } {
    report_ignored_layers
  }

  sproc_pinfo -mode stop
}

define_proc_attributes sproc_set_ignored_layers \
  -info "Standard procedure for interfacing to set_ignored_layers." \
  -define_args {
    {-min_routing_layer "User supplied minimum routing layer, using SVAR by default"  AString string optional}
    {-max_routing_layer "User supplied maximum routing layer, using SVAR by default"  AString string optional}
    {-rc_congestion_ignored_layers "User supplied layer list, using SVAR by default"  AString string optional}
    {-verbose "Used to enable verbose mode." "" boolean optional}
}

## -----------------------------------------------------------------------------
## sproc_screen_library_checks:
## -----------------------------------------------------------------------------

proc sproc_screen_library_checks { args } {

  sproc_pinfo -mode start

  ## Get arguments
  set options(-report_file) ""
  parse_proc_arguments -args $args options

  if { ![file exists $options(-report_file)] } {
    sproc_msg -error "Could not find report file $options(-report_file)"
  }

  set no_problems 1

  set fid [open $options(-report_file) r]

  sproc_msg -info "Screening check status messages in $options(-report_file)"
  while { [gets $fid line] >= 0 } {
    if { [regexp {INCONSIST} $line match] } {
      sproc_msg -info "check_library status:  $line"
    } 
    if { [regexp {PASS} $line match] } {
      sproc_msg -info "check_library status:  $line"
    }
    if { [regexp {FAIL} $line match] } {
      sproc_msg -info "check_library status:  $line"
    }
  }
  close $fid

  sproc_pinfo -mode stop
  return $no_problems
}

define_proc_attributes sproc_screen_library_checks \
  -info "Checks check_library outputs for various errors." \
  -define_args {
  {-report_file "check_library output reprt" "" string required}
}

## -----------------------------------------------------------------------------
## sproc_screen_mv_checks:
## -----------------------------------------------------------------------------

proc sproc_screen_mv_checks { args } {

  sproc_pinfo -mode start

  ## Get arguments
  set options(-logfile) ""
  set options(-context) build
  parse_proc_arguments -args $args options

  if { ![file exists $options(-logfile)] } {
    sproc_msg -error "Could not find logfile $options(-logfile)"
  }

  set fail_flag 1

  set fid [open $options(-logfile) r]

  while { [gets $fid line] >= 0 } {
    switch $options(-context) {
      build {
        if { [regexp {MVCMP completed with .* 0 error} $line match] } {
          set fail_flag 0
        }
        if { [regexp {MVDBGEN completed with .* 0 error} $line match] } {
          set fail_flag 0
        }
        sproc_msg -info $line
      }
      rtl - netlist {
        ## this flag is only used for context build
        set fail_flag 0
        if { $options(-context)=="rtl" } {
          set critical_errors "X_PROPAGATION"
        } else {
          set critical_errors "X_PROPAGATION ISO_DEVICE_MISSING"
        }
        if { [ regexp {\|ERROR\s+\|(\S+)\s+\|.+\|(\d+)\s+\|} $line mtch err_type err_cnt ] } {
          if { $err_cnt > 0 && [regexp "$err_type" $critical_errors mtch] } {
            sproc_msg -error "MVTools report $err_cnt error(s) of type $err_type - Review reports contained in $options(-logfile)"
          }
        }
      }
      default {
        sproc_msg -error "Should have defaulted to 'build'"
      }
    }
  }

  close $fid

  if { $fail_flag } {
    sproc_msg -error "Failure during build. See $options(-logfile)"
    set return_value 1
  } else {
    set return_value 0
  }

  sproc_pinfo -mode stop
  return $return_value
}

define_proc_attributes sproc_screen_mv_checks \
  -info "Checks intermediate logfiles for errors." \
  -define_args {
  {-logfile "logfile" "" string required}
  {-context {scan based on type builddefault)|rtl|netlist} "" string optional}
}

## -----------------------------------------------------------------------------
## sproc_screen_mv_debugger:
## -----------------------------------------------------------------------------

proc sproc_screen_mv_debugger { args } {

  global product_version
  global LYNX

  sproc_pinfo -mode start

  ## Get arguments
  set options(-report) ""
  parse_proc_arguments -args $args options

  if { ![file exists $options(-report)] } {
    sproc_msg -error "Could not find logfile $options(-report)"
  }

  set fid [open $options(-report) r]

  set error_mv231_found 0
  set error_mv076_found 0
  file delete -force $options(-report).debug_level_shifters
  file delete -force $options(-report).debug_always_on
  while { [gets $fid line] >= 0 } {
    if { [regexp {Warning: Pin '(\S*)'\S* cannot drive '(\S*)'\S} $line match source_pin sink_pin] } {
      set error_mv231_found 1
      set cmd "analyze_mv_design -level_shifter -from_pin $source_pin -to_pin $sink_pin"
      sproc_msg -warning "$cmd"
      redirect -append $options(-report).debug_level_shifters {
        eval $cmd
        report_timing -through $source_pin -through $sink_pin -att -net -in
      }
    }
    if { [regexp {Warning: Always on net '(\S*)'.*MV-076.*} $line match ao_net] } {
      set error_mv076_found 1
      set cmd "analyze_mv_design -always_on -verbose -net $ao_net"
      sproc_msg -warning "$cmd"
      redirect -append $options(-report).debug_always_on {
        eval $cmd
        report_timing -input -net -att -through $ao_net
      }
    } 
  }

  close $fid
  if { $error_mv231_found } {
    sproc_msg -error "sproc_screen_mv_debugger detected MV-231 issues in $options(-report). See analyze_mv_design debug info in file $options(-report).debug_level_shifters"
  }
  if { $error_mv076_found } {
    sproc_msg -error "sproc_screen_mv_debugger detected MV-076 issues in $options(-report). See analyze_mv_design debug info in file $options(-report).debug_always_on"
  }

}

define_proc_attributes sproc_screen_mv_debugger \
  -info "Routine to check report for issues and begin first order detail of cause" \
  -define_args {
  {-report "check_mv_design report" "" string required}
}

## -----------------------------------------------------------------------------
## sproc_get_retention_registers:
## -----------------------------------------------------------------------------

proc sproc_get_retention_registers { args } {

  sproc_pinfo -mode start

  global env SEV SVAR TEV

  ## Get arguments
  parse_proc_arguments -args $args options

  set retention_registers [ add_to_collection "" "" ]

  set power_domains [get_power_domains -hier *]
  redirect -variable report { report_retention_cell -domain $power_domains }
  set lines [split $report "\n"]
  set state "unlocked"
  foreach line $lines {
    if { ( $state == "unlocked" ) && [regexp {^\| Ret Cell Name} $line] } {
      set state "locking"
    } elseif { ( $state == "locking" ) && [regexp {^-------------------} $line] } {
      set state "locked"
    } elseif { ( $state == "locking" ) } {
      set state "unlocked"
    } elseif { ( $state == "locked" ) } {
      set inst_name ""
      regexp {(\s*)([\w\.\/]+)\s+} $line inst_name
      set retention_reg [get_cells -quiet $inst_name]
      if { [sizeof $retention_reg] == 1 } {
        set retention_registers [ add_to_collection $retention_registers $retention_reg ]
      } else {
        set state "unlocked"
      }
    }
  }

  sproc_pinfo -mode stop
  return $retention_registers

}

define_proc_attributes sproc_get_retention_registers \
  -info "Return a collection of retention registers." \
  -define_args {
}

## -----------------------------------------------------------------------------
## sproc_get_switch_cells :
## -----------------------------------------------------------------------------

proc sproc_get_switch_cells { args } {

  sproc_pinfo -mode start

  global env SEV SVAR TEV

  ## Get arguments
  parse_proc_arguments -args $args options

  ## build a list of ref_names for the header cells in the design
  set header_cell_ref_names ""
  redirect -variable report { report_power_switch [get_power_switches * -hierarchical] }
  set lines [split $report "\n"]
  foreach line $lines {
    if { [regexp {^Lib Cell Name} $line] } {
      set line [ regsub {^.*\/} $line "" ]
      set header_cell_ref_names "$header_cell_ref_names $line"
      puts "$line"
    }
  }
  set header_cell_ref_names [ sproc_uniquify_list -list $header_cell_ref_names ]

  ## now build a collection of header cells
  set all_cells [ get_cells -hier * ]
  set header_cells [ add_to_collection "" "" ]
  foreach header_cell_ref_name $header_cell_ref_names { 
    set header_cells [ append_to_collection $header_cells [ filter_collection $all_cells "ref_name==$header_cell_ref_name" ] ]
  }

  sproc_pinfo -mode stop
  return $header_cells

}

define_proc_attributes sproc_get_switch_cells \
  -info "Return a collection of header cells." \
  -define_args {
}

## -----------------------------------------------------------------------------
## sproc_get_ippd_diode:
## -----------------------------------------------------------------------------

proc sproc_get_ippd_diode { args } {

  sproc_pinfo -mode start

  global env SEV SVAR TEV

  sproc_msg -info "sproc_get_ippd_diode : starting execution"

  ## Get arguments
  parse_proc_arguments -args $args options

  set scenarios [all_active_scenarios]

  if { ( [llength $scenarios] > 0 ) } {
    sproc_msg -info "sproc_get_ippd_diode : mcmm mode"

    set tmp [sproc_get_spec_info -info cell -spec $SVAR(libsetup,diode_cell)]
    set the_diode_cell [ get_lib_cells -scenario [current_scenario] */$tmp ]
    set the_diode_cell [ collection_to_list -name_only -no_braces [ index_collection $the_diode_cell 0 ] ]

  } else {
    sproc_msg -error "sproc_get_ippd_diode : non mcmm mode ... this shouldn't occur as the flow is fulltime MCMM."
  }

  if { [llength $the_diode_cell] == 1 } {
    sproc_msg -info "sproc_get_ippd_diode : $the_diode_cell identified for usage."
    set return_value $the_diode_cell
  } else {
    sproc_msg -error "sproc_get_ippd_diode : no diode identified for usage."
    set return_value ""
  }

  sproc_pinfo -mode stop
  return $return_value
}

define_proc_attributes sproc_get_ippd_diode \
  -info "Determine the diode to use for IPPD." \
  -define_args {
}

## -----------------------------------------------------------------------------
## sproc_screen_alib_issues:
## -----------------------------------------------------------------------------

proc sproc_screen_alib_issues { args } {

  sproc_pinfo -mode start

  ## Get arguments
  set options(-log_file) ""
  parse_proc_arguments -args $args options

  if { ![file exists $options(-log_file)] } {
    sproc_msg -error "sproc_screen_alib_issues: Could not find DC log file $options(-log_file)"
  }

  set problems 0

  set fid [open $options(-log_file) r]

  sproc_msg -info "sproc_screen_alib_issues: Screening for evidence of lengthy alib analysis in log file $options(-log_file)"
  while { [gets $fid line] >= 0 } {
    if { [regexp {SYS.MACHINE\s+\|\s+(\w+)} $line match machine] } {
      sproc_msg -info "sproc_screen_alib_issues: running on host $machine"
    } 
    if { [regexp {Analyzing:\s+(.+)} $line match lib] } {
      regsub {"} $lib {} clean_lib
      set lib [file tail $clean_lib]
      sproc_msg -info "sproc_screen_alib_issues: lengthy alib analysis occuring for $lib"
      incr problems
    } 
    if { [regexp {^Warning:.*OPT-1311} $line match] } {
      ## avoiding use of string in message to avoid error message loop
      sproc_msg -info "sproc_screen_alib_issues: OPT_1311 message seen"
      incr problems
    }
    if { [regexp {^Warning:.*OPT-1310} $line match] } {
      ## avoiding use of string in message to avoid error message loop
      sproc_msg -info "sproc_screen_alib_issues: OPT_1310 message seen"
      incr problems
    }
  }
  close $fid

  sproc_pinfo -mode stop
  return $problems
}

define_proc_attributes sproc_screen_alib_issues \
  -info "Checks DC log file for indication of unexpected alib issues which can increase runtime"  \
  -define_args {
  {-log_file "DC log file" "" string required}
}

## -----------------------------------------------------------------------------
## sproc_ippd_rewrire:
## -----------------------------------------------------------------------------

proc sproc_ippd_rewire { args } {

  sproc_pinfo -mode start

  global env SEV SVAR TEV

  ## Get arguments
  parse_proc_arguments -args $args options

  sproc_msg -info "sproc_ippd_rewire : starting execution [date]"

  ## compute the collection of input ports and ippd on which to check ippd wiring
  set ports [get_ports * -filter "direction==in"]
  set the_diodes [get_cells -quiet LYNX_dp_ant_*]

  ##
  ## it is because the optimization engines can slip a buffer between the ippd
  ## and the input port that we must rewire.
  ##
  ## loop over each diode and confirm that it's wired to the proper net / port.  
  ## this can be determined by correlating the "expected_net_name" from the ippd 
  ## extracted from the ippd instance name and making sure the diode is connected 
  ## to one it correlates the highest with. it is nuances w/ [] not being allowable
  ## for an instance name but acceptable for a net / port name that we resort to
  ## correlation for alignment.
  ##
  foreach_in_collection the_diode $the_diodes {
    set the_diode_name [get_attribute $the_diode full_name]
    set the_diode_pin [get_pins -of $the_diode]
    set the_net [all_connected $the_diode_pin]
    set the_net_name [get_attribute $the_net full_name]
    regsub {LYNX_dp_ant_} $the_diode_name "" expected_net_name

    ## perform the correlation
    set high_correlation_score -1
    set high_correlation_name ""
    set num_ports [ sizeof_collection $ports ]
    for {set i 0} {$i<$num_ports} {incr i} {
      set port [ index_collection $ports $i ]
      set name [get_attribute $port full_name]
      set correlation_score [  sproc_string_correlation -string1 $expected_net_name -string2 $name ]
      if { $correlation_score == 999 } {
        set high_correlation_score $correlation_score
        set high_correlation_name $name
        set i $num_ports
      } elseif { $correlation_score > $high_correlation_score } {
        set high_correlation_score $correlation_score
        set high_correlation_name $name
      }
    }

    ## rewire the IPPD or not as necessary
    if { $the_net_name == $high_correlation_name } {
      sproc_msg -info "IPPD rewiring : \"$the_diode_name\" is correctly wired to net \"$high_correlation_name\"."
    } else {
      sproc_msg -info "IPPD rewiring : \"$the_diode_name\" rewired to net \"$high_correlation_name\"."
      if { $the_net_name != "" } {
        disconnect_net $the_net_name $the_diode_pin
      }
      connect_net $high_correlation_name $the_diode_pin
    }

  }

  sproc_msg -info "sproc_ippd_rewire : finishing execution [date]"

  sproc_pinfo -mode stop

}

define_proc_attributes sproc_ippd_rewire \
  -info "Utility for rewiring Lynx inserted ippd." \
  -define_args {
}

## -----------------------------------------------------------------------------
## sproc_string_correlation:
## -----------------------------------------------------------------------------

proc sproc_string_correlation { args } {

  sproc_pinfo -mode start

  global env SEV SVAR TEV

  ## Get arguments
  set options(-string1) ""
  set options(-string2) ""
  parse_proc_arguments -args $args options

  if { [string compare $options(-string1) $options(-string2)] == 0 } {

    ## indicate exact match
    set score 999

  } else {

    ## compute a correlation score.  
    ##   +1 for length match. 
    ##   +1 for every character match. 
    set score 0

    set length1 [ string length $options(-string1) ]
    set length2 [ string length $options(-string2) ]
    if { $length1 == $length2 } {
      set slength $length1
      incr score 
    } elseif { $length1 > $length2 } {
      set slength $length2
    } elseif { $length1 < $length2 } {
      set slength $length1
    }

    for {set i 0} {$i<$slength} {incr i} {
      set character1 [string index $options(-string1) $i]
      set character2 [string index $options(-string2) $i]
      if { $character1 == $character2 } {
        incr score
      }
    }

  }

  sproc_msg -info "sproc_string_correlation: $score is the correlation scored between \"$options(-string1)\" \"$options(-string2)\""

  sproc_pinfo -mode stop
  return $score

}

define_proc_attributes sproc_string_correlation \
  -info "Determine the correlation score between two string." \
  -define_args {
  {-string1 "String #1" AString string required}
  {-string2 "String #2" AString string required}
}

## -----------------------------------------------------------------------------
## sproc_adjust_lppi_operating_condition:
## -----------------------------------------------------------------------------

proc sproc_adjust_lppi_operating_condition { args } {

  sproc_pinfo -mode start

  global env SEV SVAR TEV
  global search_path link_path_per_instance
  global MAP_wc_lib_to_other_lib

  set options(-lib_condition) ""
  parse_proc_arguments -args $args options

  ## -------------------------------------

  if { [lsearch $SVAR(setup,lib_conditions) $options(-lib_condition)] < 0 } {
    sproc_msg -error "The specified value for -lib_condition is invalid."
    sproc_msg -error "  $options(-lib_condition)"
    sproc_script_stop -exit
  }

  ## -------------------------------------

  if { ![info exists link_path_per_instance] } {
    sproc_msg -error "No current link_path_per_instance var set. No adjustment made"
  }

  ## -------------------------------------

  unset -nocomplain new_link_path_per_instance
  set new_link_path_per_instance [list]

  foreach item $link_path_per_instance {
    set inst [lindex $item 0]
    set path [lindex $item 1]

    set new_item [list]
    set new_path [list]

    foreach p $path {
      if { $p == "*" } {
        set new_p "*"
      } else {
        if { [info exists MAP_wc_lib_to_other_lib($options(-lib_condition),$p)] } {
          set new_p $MAP_wc_lib_to_other_lib($options(-lib_condition),$p)
        } else {
          sproc_msg -error "A worst_case-to-$options(-lib_condition) mapping does not exist for:"
          sproc_msg -error "  $p"
          sproc_pinfo -mode stop
          return
        }
      }
      set new_path [concat $new_path $new_p]
    }
    lappend new_link_path_per_instance [list $inst $new_path]
  }

  set link_path_per_instance $new_link_path_per_instance

  sproc_pinfo -mode stop
}

define_proc_attributes sproc_adjust_lppi_operating_condition \
  -info "Modifies the current link_path_per_instance to reference libraries of the provided operating_condition type." \
  -define_args {
  {-lib_condition   "Operating condition to adjust libraries to." AString string required}
}

## -----------------------------------------------------------------------------
## sproc_load_lppi:
## -----------------------------------------------------------------------------

proc sproc_load_lppi { args } {

  sproc_pinfo -mode start

  global env SEV SVAR TEV
  global search_path link_path_per_instance

  set options(-file) ""
  set options(-scope) NULL
  set options(-replace) 0

  parse_proc_arguments -args $args options

  ## -------------------------------------

  if { ![file exists $options(-file)] } {
    sproc_msg -error "The link_path_per_instance file does not exist."
    sproc_msg -error "  $options(-file)"
    sproc_script_stop -exit
  }

  ## -------------------------------------

  set save_lppi [list]

  if { [info exists link_path_per_instance] } {
    if { $options(-replace) } {
      sproc_msg -info "replacing prior link_path_per_instance"
    } else {
      sproc_msg -info "adding to pre-existing link_path_per_instance value"
      set save_lppi $link_path_per_instance
    }
  }


  set link_path_per_instance {{NULL NULL}}

  sproc_source -file $options(-file)

  if { $link_path_per_instance=={NULL NULL} } {
    sproc_msg -error "Sourcing the file $options(-file) did not set the link_path_per_instance variable."
    sproc_script_stop -exit
  }

  ## -------------------------------------

  set new_lppi [list]

  if { $options(-scope)!="NULL" } {
    sproc_msg -info "Loading $options(-file) onto instance scope $options(-scope)"
    foreach item $link_path_per_instance {
      set new_inst $options(-scope)/[lindex $item 0]
      set path [lindex $item 1]
      lappend new_lppi [list $new_inst $path]
    }
  } else {
    sproc_msg -info "Loading $options(-file)"
    set new_lppi $link_path_per_instance
  }

  set link_path_per_instance "$save_lppi $new_lppi"

  sproc_pinfo -mode stop
}

define_proc_attributes sproc_load_lppi \
  -info "Load rather that source link_path_per_instance with options to control how it is applied" \
  -define_args {
  {-file  "The link_path_per_instance file." AString string required}
  {-scope  "Alter the link_path_per_instance to apply to provided instance path" AString string optional}
  {-replace   "Replace existing link_path_per_instance rather than append" AString string optional}
}

## -----------------------------------------------------------------------------
## sproc_set_scenario_options_stack:
## -----------------------------------------------------------------------------

proc sproc_set_scenario_options_stack { args } {

  sproc_pinfo -mode start

  set options(-debug) 1

  set options(-mode) "save"
  set options(-fname) "./report_scenario_options.rpt"

  parse_proc_arguments -args $args options

  sproc_msg -info "sproc_set_scenario_options_stack mode = '$options(-mode)' fname = '$options(-fname)'"

  if { $options(-mode) == "save" } {

    redirect $options(-fname) {
      report_scenario_options -scenarios [all_scenarios]
    }
    set_scenario_options -scenarios [all_scenarios] -reset_all true

  } elseif { $options(-mode) == "restore" } {

    if { $options(-debug) } {
      redirect $options(-fname).restore.pnt1 {
        report_scenario_options -scenarios [all_scenarios]
      }
    }

    set fid [open $options(-fname) r]
    set cntl 0
    while { [gets $fid line] >= 0 } {
      if { ( $cntl == 0 ) && [regexp "Scenario: " $line] } {
        set cntl 1
        regsub {^Scenario: } $line "" line
        regsub " .*$" $line "" line
        set new_line "set_scenario_options -scenarios $line"
      } elseif { ( $cntl == 1 ) && [regexp "^(\s)*$" $line] } {
        eval $new_line
        set cntl 0
      } elseif { $cntl == 1 } {
        regsub {^\s+} $line "-" line
        regsub {\s+:\s+} $line " " line
        set new_line "$new_line $line"
      }
    }
    close $fid

    if { $options(-debug) } {
      redirect $options(-fname).restore.pnt2 {
        report_scenario_options -scenarios [all_scenarios]
      }
    }

  } elseif { $options(-mode) == "report" } {
    redirect $options(-fname) {
      report_scenario_options -scenarios [all_scenarios]
    }

  } else {
    sproc_msg -error "sproc_set_scenario_options_stack -mode = $options(-mode) is illegal"
  }

  sproc_pinfo -mode stop

}

define_proc_attributes sproc_set_scenario_options_stack \
  -info "Utility to assist w/ saving and restoring set_scenario_options state used for some work arounds." \
  -define_args {
  {-fname    "File from which to save / restore set_scenario_options state." AString string  required}
  {-mode     "report / save / restore set_scerario_options state [report,save,restore]" AString string required}
}

## -----------------------------------------------------------------------------
## sproc_distributed_job_args
## -----------------------------------------------------------------------------

proc sproc_distributed_job_args { args } {

  sproc_pinfo -mode start

  global env SEV SVAR TEV

  set options(-file)  ""
  parse_proc_arguments -args $args options

  if { !$SEV(job_enable) } {
    sproc_msg -error "Job distribution is not enabled."
    return
  }

  switch $SEV(job_app) {

    lsf {

      sproc_msg -info "Examining file $options(-file)"

      set fid [open $options(-file) r]
      set lines [read $fid]
      close $fid
      set lines [split $lines \n]
      set original_job_command_line ""
      foreach line $lines {
        if { [regexp {^bsub } $line] } {
          set original_job_command_line $line
        }
      }
      if { $original_job_command_line == "" } {
        sproc_msg -error "Unable to determine original_job_command_line"
      }

      set new_app_args ""
      if { [regexp {\-P\s+\S+} $original_job_command_line match] } {
        set new_app_args "$new_app_args $match"
      }
      if { [regexp {\-J\s+\S+} $original_job_command_line match] } {
        set new_app_args "$new_app_args $match.CHILD"
      }
      if { [regexp {\-q\s+\S+} $original_job_command_line match] } {
        set new_app_args "$new_app_args $match"
      }
      if { [regexp {\-o\s+\S+} $original_job_command_line match] } {
        set new_app_args "$new_app_args $match"
      }
      if { [regexp {(\-R\s+'[^']+')} $original_job_command_line match subMatch] } {
        set new_app_args "$new_app_args $subMatch"
      }

      if { [regexp {span\[hosts=1\]} $new_app_args] } {
        sproc_msg -warning "Detected and suppressing 'span\[hosts=1\]' while developing bsub arguments."
        regsub {span\[hosts=1\]} $new_app_args {} new_app_args 
      }

      sproc_msg -info "New bsub argument for distributed processing: "
      sproc_msg -info "  '$new_app_args'"

    }

    grd {

      sproc_msg -info "Examining file $options(-file)"

      set fid [open $options(-file) r]
      set lines [read $fid]
      close $fid
      set lines [split $lines \n]
      set original_job_command_line ""
      foreach line $lines {
        if { [regexp {^qsub } $line] } {
          set original_job_command_line $line
        }
      }
      if { $original_job_command_line == "" } {
        sproc_msg -error "Unable to determine original_job_command_line"
      }

      set new_app_args ""
      if { [regexp {\-P\s+\S+} $original_job_command_line match] } {
        set new_app_args "$new_app_args $match"
      }
      if { [regexp {\-N\s+\S+} $original_job_command_line match] } {
        set new_app_args "$new_app_args $match.CHILD"
      }
      if { [regexp {\-l\s+\S+} $original_job_command_line match] } {
        set new_app_args "$new_app_args $match"
      }
      ## if { [regexp {\-now\s+\S+} $original_job_command_line match] } {
      ##   set new_app_args "$new_app_args $match"
      ## }
      ## if { [regexp {\-cwd} $original_job_command_line match] } {
      ##   set new_app_args "$new_app_args $match"
      ## }
      ## if { [regexp {\-V} $original_job_command_line match] } {
      ##   set new_app_args "$new_app_args $match"
      ## }

      if { [regexp "$SEV(job_misc4)=" $new_app_args] } {
        sproc_msg -warning "Detected and suppressing '$SEV(job_misc4)=N' while developing qsub arguments."

        set re(1) "\\-l\\s+$SEV(job_misc4)=(\\d+)\\s" 
        set re(2) "\\-l\\s+$SEV(job_misc4)=(\\d+)$" 
        set re(3) "\\s$SEV(job_misc4)=(\\d+)," 
        set re(4) ",$SEV(job_misc4)=(\\d+)\\s" 
        set re(5) ",$SEV(job_misc4)=(\\d+)," 

        regsub $re(1) $new_app_args {}  new_app_args
        regsub $re(2) $new_app_args {}  new_app_args
        regsub $re(3) $new_app_args { } new_app_args
        regsub $re(4) $new_app_args { } new_app_args
        regsub $re(5) $new_app_args {,} new_app_args
      }

      sproc_msg -info "New qsub argument for distributed processing: "
      sproc_msg -info "  '$new_app_args'"

    }

    default {
      sproc_msg -error "Unknown value for SEV(job_app)"
      return
    }

  }

  sproc_pinfo -mode stop

  return $new_app_args

}

define_proc_attributes sproc_distributed_job_args \
  -info "Procedure for computing arguments for distributed jobs." \
  -define_args {
  {-file "rtm_job_cmd file to build arguments from" AString string required}
}

## -----------------------------------------------------------------------------
## sproc_icc_create_qor_snapshot:
## -----------------------------------------------------------------------------

proc sproc_icc_create_qor_snapshot { args } {

  sproc_pinfo -mode start

  global env SEV SVAR TEV

  set options(-name) "unnamed"
  set options(-flags) "-clock_tree -power"

  parse_proc_arguments -args $args options

  ##
  ## It doesn't make a lot of sense to generate qor snapshot in parallel
  ## reporting. It makes more sense to generate them during the mainline.
  ## hence some example logic to skip provide below but not used (ie
  ## commented out.  Possibly will revist in the future.
  ##
  set skip 0

  if { $skip } {
    sproc_msg -warning "sproc_icc_create_qor_snapshot has been configured to skip create_qor_snapshot."
  } else {
    set t1 [clock seconds]
    eval create_qor_snapshot -name $options(-name) $options(-flags)
    set t2 [clock seconds]
    set t3 [expr $t2 - $t1]
    sproc_msg -info "sproc_icc_create_qor_snapshot : elapsed time of create_qor_snaphot = $t3 seconds."
  }

  sproc_pinfo -mode stop

}

define_proc_attributes sproc_icc_create_qor_snapshot \
  -info "Utility to centalize create_qor_snapshot calls to assist with some stability work arounds." \
  -define_args {
  {-name    "The name of the snapshot to be created." AString string  required}
  {-flags   "Optional flags to pass to create qor snapshot." AString string optional}
}

## -----------------------------------------------------------------------------
## sproc_persistent_set_app_var:
## -----------------------------------------------------------------------------

proc sproc_persistent_set_app_var { args } {

  sproc_pinfo -mode start

  ##
  ## This procedure can be used with both app_var and non-app_var variables.
  ## If processing a non-app_var, the '-non_app_var' flag must be set to 1.
  ## If processing a app_var, the '-non_app_var' flag must be set to 0, which is the default.
  ##
  ## All variable names are prefixed with "lynx_" before storage on the database.
  ## The addition and removal of this prefix is handled by the procedure.
  ##

  set options(-name) "tbd"
  set options(-value) "lynx_read"
  set options(-non_app_var) 0

  parse_proc_arguments -args $args options

  eval upvar #0 $options(-name) $options(-name)

  set attr_name "lynx_$options(-name)"
  set attr_value [get_attribute -quiet [current_mw_cel] $attr_name]
  set length_attr_value [llength $attr_value]

  if { $options(-value) != "lynx_read" } {

    if { $length_attr_value > 0 } {
      sproc_msg -warning "sproc_persistent_set_app_var : '$attr_name' already exists on the database, overwriting prior value."
    }
    if { $options(-non_app_var) } {
      set $options(-name) $options(-value)
      sproc_msg -info "sproc_persistent_set_app_var : Executed 'set $options(-name) $options(-value)'"
    } else {
      set_app_var $options(-name) $options(-value)
      sproc_msg -info "sproc_persistent_set_app_var : Executed 'set_app_var $options(-name) $options(-value)'"
    }
    define_user_attribute $attr_name -type string -class mw_cel
    set_attribute [current_mw_cel] $attr_name $options(-value)
    sproc_msg -info "sproc_persistent_set_app_var : Stored '$attr_name' on the database w/ the value '$options(-value)'"

  } elseif { ($options(-value) == "lynx_read") && ($length_attr_value == 0) } {

    sproc_msg -warning "sproc_persistent_set_app_var : Attempted to read '$attr_name' but found it doesn't exist, no restoration performed."

  } elseif { ($options(-value) == "lynx_read") && ($length_attr_value > 0) } {

    if { $options(-non_app_var) } {
      set $options(-name) $attr_value
    } else {
      set_app_var $options(-name) $attr_value
    }
    sproc_msg -info "sproc_persistent_set_app_var : Read '$attr_name' and restored '$options(-name)' w/ the value '$attr_value'."

  } else {

    sproc_msg -error "sproc_persistent_set_app_var : Incorrectly configured."

  }

  sproc_pinfo -mode stop

}

define_proc_attributes sproc_persistent_set_app_var \
  -info "Used to read and store user defined attributes onto a database." \
  -define_args {
  {-name    "The name of the variable." AString string required}
  {-value   "The value of the variable to be stored on the MW." AString string optional}
  {-non_app_var "If set to 1, the variable is treated as a non-app_var." "" boolean optional}
}

## -----------------------------------------------------------------------------
## sproc_early_complete:
## -----------------------------------------------------------------------------

proc sproc_early_complete  {} {

  sproc_pinfo -mode start

  global SEV SVAR
  global synopsys_program_name

  if { $SVAR(misc,early_complete_enable) } {
    sproc_msg -warning "Early complete enabled."

    sproc_export -early

    if { "$SEV(icc,data_tmp_dir)$SVAR(dst,mdb)" != $SVAR(dst,mdb) } {
      exec cp -r $SEV(icc,data_tmp_dir)$SVAR(dst,mdb) $SVAR(dst,mdb)
    }

    sh perl $SEV(scripts_dir)/scripts/generic/check_warn_snps.pl  ./LOG/$SEV(dst)/log > ./summary/$SEV(dst)/$SEV(dst)_warn.sum
    sh perl $SEV(scripts_dir)/scripts/generic/check_error_snps.pl ./LOG/$SEV(dst)/log > ./summary/$SEV(dst)/$SEV(dst)_error.sum
    sh perl $SEV(scripts_dir)/scripts/generic/check_fatal.pl      $SEV(scripts_dir)/scripts/fatal_error_list ./summary/$SEV(dst)/$SEV(dst)_error.sum  $SEV(dst)
    sh perl $SEV(scripts_dir)/scripts/generic/metric_snps.pl      ./LOG/$SEV(dst)/log > ./summary/$SEV(dst)/$SEV(dst)_metric.sum

    echo $SEV(sum_dir)/$SEV(dst).early
    if { $SEV(design_name) == "ZTOP" } { exec touch $SEV(sum_dir)/$SEV(dst).pass }
    set fname $SEV(sum_dir)/$SEV(dst).early

    set fid [open $fname w]
    puts $fid "Early complete at [date]"
    close $fid
    # prevent next report action lead some error for next stage
    sproc_msg -info "Sleep 600 ..."
    exec sleep 600
  } else {
    sproc_msg -warning "Early complete disabled."
  }
  sproc_pinfo -mode stop
}

define_proc_attributes sproc_early_complete  \
  -info "Procedure to signal early completion of task to RTM." \
  -define_args {
}

## -----------------------------------------------------------------------------
## sproc_get_metric_value:
## -----------------------------------------------------------------------------

## -------------------------------------
## Given a source directory, task, and metric name,
## return the value of the metric by extracting it from
## the task.metrics file in the logs/source directory.
## -------------------------------------
 
proc sproc_get_metric_value { args } {

  sproc_pinfo -mode start

  set options(-source) ""
  set options(-task) ""
  set options(-metric) ""
  parse_proc_arguments -args $args options

  set value ""
  set error 0

  if {$options(-metric) == "" } {
    sproc_msg -error "sproc_get_metric_value: option -metric must be specified"
    incr error
  }

  if { $options(-source) == "" } {
    sproc_msg -error "sproc_get_metric_value: option -source must be specified"
    incr error
  } elseif { ![file isdir ../logs/$options(-source)] } {
    sproc_msg -error "sproc_get_metric_value: Specified source log directory ../logs/$options(-source) does not exist"
    incr error
  }

  if { $options(-task) == "" } {
    sproc_msg -error "sproc_get_metric_value: option -task must be specified"
    incr error
  } else {
    set metric_file ../logs/$options(-source)/$options(-task).metrics
    if { ![file exists $metric_file] } {
      sproc_msg -error "sproc_get_metric_value: Metrics file ($metric_file) for source $options(-source) and task $options(-task) does not exist" 
      incr error
    }
  }

  if {$error == 0 } {
    set fid [open $metric_file r]
    while { [gets $fid line] >= 0 } {
      set tmp [split $line "|"] 
      if { [lindex $tmp 0] == $options(-metric) } {
        set value [lindex $tmp 2]
        continue
      }
    }
    close $fid
    if { $value == "" } {
      sproc_msg -error "Cannot find metric $options(-metric) for source $options(-source) and task $options(-task)"
    } else {
      sproc_msg -info "Found metric $options(-metric) with value $value for source $options(-source) and task $options(-task)"
    }
  }

  sproc_pinfo -mode stop 

  return $value
}

define_proc_attributes sproc_get_metric_value \
  -info "Return the value of a metric for a specified source directory and task" \
  -define_args {
  {-source "The source directory from which to extract the metric." AString string required}
  {-task "The task script that generated the metric." AString string required}
  {-metric "The metric to extract" AString string required}
}

## -----------------------------------------------------------------------------
## sproc_clone_scenario_icc :
## -----------------------------------------------------------------------------

proc sproc_clone_scenario_icc { args } {

  sproc_pinfo -mode start

  global SEV SVAR

  ## Get arguments
  set options(-ref_scenario)  ""
  set options(-new_scenario)  ""
  set options(-debug)  0
  parse_proc_arguments -args $args options

  set fname "$SEV(dst_dir)/$SVAR(design_name).$options(-ref_scenario).write_script"

  ## generate most info from ref_scenario for future leverage
  if { [ get_scenarios -active true $options(-ref_scenario) ] == "" } {
    set_active_scenarios "[all_active_scenario] $options(-ref_scenario)"
  }
  current_scenario $options(-ref_scenario)
  write_script \
    -no_annotated_check -no_annotated_delay -no_cg \
    -nosplit -format dctcl -output $fname

  ## filter reference material into SDC, SAEF, important, etc.
  sproc_filter_write_script -infile $fname

  ## create new scenario and start to construct it
  create_scenario $options(-new_scenario)
  source $fname.flt.sdc
  source $fname.flt.saif
  source $fname.flt.important

  ## apply new scenario OC and RC
  set OC_TYPE [sproc_get_scenario_info -scenario $options(-new_scenario) -type lib_condition]
  set RC_TYPE [sproc_get_scenario_info -scenario $options(-new_scenario) -type rc_type]
  sproc_set_operating_conditions -lib_condition $OC_TYPE -oc_mode ocv
  sproc_set_tlu_plus_files -rc_type $RC_TYPE

  ## recreate scenario options
  if { [get_scenarios -setup true $options(-ref_scenario)] != "" } {
    set_scenario_options -scenario $options(-new_scenario) -setup true
  } else {
    set_scenario_options -scenario $options(-new_scenario) -setup false
  }

  if { [get_scenarios -hold true $options(-ref_scenario)] != "" } {
    set_scenario_options -scenario $options(-new_scenario) -hold true
  } else {
    set_scenario_options -scenario $options(-new_scenario) -hold false
  }

  if { [get_scenarios -leakage_power true $options(-ref_scenario)] != "" } {
    set_scenario_options -scenario $options(-new_scenario) -leakage_power true
  } else {
    set_scenario_options -scenario $options(-new_scenario) -leakage_power false
  }

  if { [get_scenarios -dynamic_power true $options(-ref_scenario)] != "" } {
    set_scenario_options -scenario $options(-new_scenario) -dynamic_power true
  } else {
    set_scenario_options -scenario $options(-new_scenario) -dynamic_power false
  }

  if { [get_scenarios -cts_mode true $options(-ref_scenario)] == "" } {
    set_scenario_options -scenario $options(-new_scenario) -cts_mode false
  } else {
    set_scenario_options -scenario $options(-new_scenario) -cts_mode true
  }

  if { [get_scenarios -cts_corner max $options(-ref_scenario)] != "" } {
     set_scenario_options -scenario $options(-new_scenario) -cts_corner max
  } elseif { [get_scenarios -cts_corner min $options(-ref_scenario)] != "" } {
     set_scenario_options -scenario $options(-new_scenario) -cts_corner min
  } elseif { [get_scenarios -cts_corner min_max $options(-ref_scenario)] != "" } {
     set_scenario_options -scenario $options(-new_scenario) -cts_corner min_max
  } else {
     set_scenario_options -scenario $options(-new_scenario) -cts_corner none
  }

  sproc_pinfo -mode stop

}

define_proc_attributes sproc_clone_scenario_icc  \
  -info "Procedure used to clone (create) one scenario from a pre existing scenario." \
  -define_args {
  {-ref_scenario  "The reference scenario " AString string required}
  {-new_scenario  "The new scenario " AString string required}
}

## -----------------------------------------------------------------------------
## sproc_filter_write_script:
## -----------------------------------------------------------------------------

proc sproc_filter_write_script { args } {

  sproc_pinfo -mode start

  ## Get arguments
  set options(-infile)  ""
  set options(-outfile)  ""
  set options(-debug)  0
  parse_proc_arguments -args $args options

  if { $options(-outfile)  == "" } {
    set options(-outfile) "$options(-infile).flt"
  }

  set fid_r [open $options(-infile) r]

  set fid_w_sdc       [open $options(-outfile).sdc w]
  set fid_w_saif      [open $options(-outfile).saif w]
  set fid_w_important [open $options(-outfile).important w]

  if { $options(-debug) } {
    set fid_w_sdc_object      [open $options(-outfile).sdc.object w]
    set fid_w_sdc_basic       [open $options(-outfile).sdc.basic w]
    set fid_w_sdc_secondary   [open $options(-outfile).sdc.secondary w]
    set fid_w_sdc_environment [open $options(-outfile).sdc.environment w]
    set fid_w_sdc_ambiguous   [open $options(-outfile).sdc.ambiguous w]
    set fid_w_other           [open $options(-outfile).other w]
  }

  ##
  ## sort out the write_script content into
  ##   sdc  : minus set_operating_conditions
  ##   saif
  ##
  while { ( [gets $fid_r line] >= 0 ) } {
    switch -regexp $line {

      {^all_clocks} -
      {^all_inputs} -
      {^all_outputs} -
      {^all_registers} -
      {^current_design} -
      {^current_instance} -
      {^get_cells} -
      {^get_clocks} -
      {^get_libs} -
      {^get_lib_cells} -
      {^get_lib_pins} -
      {^get_nets} -
      {^get_pins} -
      {^get_ports} -
      {^set_hierarchy_separator} {
        ## slice out the SDC "object access functions" content

        ## note these are "object access" and would be used by other SDC commands and would
        ## be the operative command being executed.  as such we don't wish to capture lines
        ## that begin with this (eg current_design foo).  left here for debug only
        ## >> puts $fid_w_sdc $line

        if { $options(-debug) } {
          puts $fid_w_sdc_object $line
        }
      }

      {^create_clock} -
      {^create_generated_clock} -
      {^group_path} -
      {^set_clock_gating_check} -
      {^set_clock_groups} -
      {^set_clock_latency} -
      {^set_clock_sense} -
      {^set_clock_transition} -
      {^set_clock_uncertainty} -
      {^set_false_path} -
      {^set_ideal_latency} -
      {^set_ideal_transition} -
      {^set_input_delay} -
      {^set_max_delay} -
      {^set_min_delay} -
      {^set_multicycle_path} -
      {^set_output_delay} -
      {^set_propagated_clock} {
        ## slice out the SDC "basic timing assertions" content
        puts $fid_w_sdc $line
        if { $options(-debug) } {
          puts $fid_w_sdc_basic $line
        }
      }

      {^set_disable_timing} -
      {^set_max_time_borrow} {
        ## slice out the SDC "secondary timing assertions" content
        puts $fid_w_sdc $line
        if { $options(-debug) } {
          puts $fid_w_sdc_secondary $line
        }
      }

      {^create_voltage_area} -
      {^set_case_analysis} -
      {^set_driving} -
      {^set_driving_cell} -
      {^set_fanout_load} -
      {^set_input_transition} -
      {^set_ideal_network} -
      {^set_level_shifter_strategy} -
      {^set_level_shifter_threshold} -
      {^set_load\s+(?![\d])} -
      {^set_logic_dc} -
      {^set_logic_one} -
      {^set_logic_zero} -
      {^set_max_area} -
      {^set_max_capacitance} -
      {^set_max_dynamic_power} -
      {^set_max_fanout} -
      {^set_max_leakage_power} -
      {^set_max_transition} -
      {^set_min_capacitance} -
      {^set_min_fanout} -
      {^set_min_porosity} -
      {^set_operating_conditions} -
      {^set_port_fanout_number} -
      {^set_resistance\s+(?![\d])} -
      {^set_wire_load_min_block_size} -
      {^set_wire_load_mode} -
      {^set_wire_load_model} -
      {^set_wire_load_selection_group} {
        ## slice out the SDC "environment assertions" content
        puts $fid_w_sdc $line
        if { $options(-debug) } {
          puts $fid_w_sdc_environment $line
        }
      }

      {^set_timing_derate} -
      {^set_units} {
        ## slice out the SDC "ambiguous" content (ie in SDC file but not listed in man page)
        puts $fid_w_sdc $line
        if { $options(-debug) } {
          puts $fid_w_sdc_ambiguous $line
        }
      }

      {^set_switching_activity} {
        ## slice out the saif content
        puts $fid_w_saif $line
      }

      {^set_critical_range} -
      {^set_fix_hold} -
      {^set_latency_adjustment_options} -
      {^set_tlu_plus_files} {
        ## slice out the important layered content for scenario recreation
        puts $fid_w_important $line
      }

      default {
        ## information thought not to be important for scenario recreation
        if { $options(-debug) } {
          puts $fid_w_other $line
        }
      }
    }
  }
  close $fid_r
  close $fid_w_sdc
  close $fid_w_saif
  close $fid_w_important
  if { $options(-debug) } {
    close $fid_w_sdc_object      
    close $fid_w_sdc_basic       
    close $fid_w_sdc_secondary   
    close $fid_w_sdc_environment 
    close $fid_w_sdc_ambiguous 
    close $fid_w_other
  }

  sproc_pinfo -mode stop

}

define_proc_attributes sproc_filter_write_script \
  -info "Procedure to filter write script to assist w/ scenario recreation." \
  -define_args {
  {-infile  "The original write script " AString string required}
  {-outfile  "The original write script " AString string optional}
  {-debug  "Optional debug flag "     ""      boolean optional}
}

## -----------------------------------------------------------------------------
## sproc_retention_register_setup:
## -----------------------------------------------------------------------------

proc sproc_retention_register_setup { args } {

  ## -------------------------------------
  ## Retention register support requires the usage of tech-specific models.
  ## The procedure sproc_retention_register_setup helps ensure consistency of setup.
  ## This may only be needed during RTL-gates verification.
  ## For netlist comparisons, the retention registers might be treated as black boxes.
  ## -------------------------------------

  sproc_pinfo -mode start

  global SEV SVAR hdlin_upf_library

  parse_proc_arguments -args $args options

  ## -------------------------------------
  ## Parse the model file and determine the list of new models.
  ## -------------------------------------

  set rreg_file $SEV(tscript_dir)/formality_models_for_retention_registers.v

  if { ![file exists $rreg_file] } {
    sproc_msg -error "Unable to find file '$rreg_file'."
    return
  }

  set retention_register_list [list]

  set fid [open $rreg_file r]
  while { [gets $fid line] >= 0 } {
    if { [regexp {^module\s+(\w+)\s+\(} $line match retention_register] } {
      lappend retention_register_list $retention_register
    }
  }
  close $fid

  ## -------------------------------------
  ## Remove the old models.
  ## -------------------------------------

  foreach retention_register $retention_register_list {
    set design_list [list]
    set design_list [concat $design_list [find_designs i:/*/$retention_register]]
    foreach design $design_list {
      sproc_msg -info "Removing retention register model '$design'"
      remove_design -shared_lib $design
    }
  }

  ## -------------------------------------
  ## Read the new models.
  ## -------------------------------------

  set hdlin_upf_library UPF_LIB

  set filelist "$SEV(tscript_dir)/GENUPFRR.v $rreg_file"

  if { $options(-container) == "r" } {
    read_verilog -r -libname UPF_LIB -technology_library $filelist
  } else {
    read_verilog -i -libname UPF_LIB -technology_library $filelist
  }

  sproc_pinfo -mode stop

}

define_proc_attributes sproc_retention_register_setup \
  -info "Library-specific aid for setting up Formality to handle retention registers." \
  -define_args {
  {-container "Choose r or i" AnOos one_of_string
    {required value_help {values {r i}}}
  }
}

## -----------------------------------------------------------------------------
## Source user-defined procedures.
## -----------------------------------------------------------------------------

if { [file exists .././scripts/conf/user_procs.tcl] } {
  ## Alternate location for a Primetime DMSA slave
  sproc_source -file .././scripts/conf/user_procs.tcl
} elseif { [file exists ./scripts/conf/user_procs.tcl] } {
  ## Normal location.
  sproc_source -file ./scripts/conf/user_procs.tcl
}

## -----------------------------------------------------------------------------
## End Of File
## -----------------------------------------------------------------------------
