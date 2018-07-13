suppress_message ERRDM-045
proc SelectDrcError {drc_errors {add 0}} {
   set error_data [add_to_collection -u "" [get_attr $drc_errors error_data]]
   gui_show_error_data $error_data
   append_to_collection -u drc_error_data [get_attr $drc_errors error_data]
   set cmd "gui_set_current_errors -data_name {[get_object_name $drc_error_data]}"
   eval $cmd 
   gui_set_error_browser_option -show_mode selected
   change_selection
   if {$add} {
      gui_set_selected_errors -force -add $drc_errors
   } else {
      gui_set_selected_errors -force -replace $drc_errors
   }
}
proc DeselectDrcError {} {
  gui_set_error_browser_option -show_mode none
}

   
