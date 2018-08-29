proc check_clock_cell_type { } {
set total_count 0

  foreach_in_collection clock [ get_clocks -quiet * ] {
    foreach_in_collection source [ get_attribute -quiet $clock sources ] {
      # all cells from clock source
      set clock_cells [ all_fanout -flat -from $source -only_cells ]

      # exclude leaf flipflops
      set clock_cells [ remove_from_collection $clock_cells [ all_fanout -flat -from $source -only_cells -endpoints_only ] ]

#     ########################################################################
#     # check non-ulvt cells
#     #
     set non-ulvt_cells [ filter_collection $clock_cells "ref_name !~ *ULVT" ]
     set count [ sizeof_collection ${non-ulvt_cells} ]
     if { $count == 0 } {
       echo [ format "INFO: %d non-ulvt cells used in %s." $count [ get_attribute $clock full_name ] ]
     } else {
       echo [ format "WARNING: %d non-ulvt cells used in %s." $count [ get_attribute $clock full_name ] ]
       foreach_in_collection cell ${non-ulvt_cells} {
         echo [ format "%s (%s)" [ get_attribute $cell full_name ] [ get_attribute $cell ref_name ] ]
       }
     }
      ########################################################################
      # check non-symmetricdcap cells
      #
      set non_symmetricdcap_cells [ filter_collection $clock_cells "( ref_name !~ CKL* ) &&  ( ref_name !~DCCK*) && ( ref_name !~CKBD*BWP*) && ( ref_name !~CKND*BWP*) && ( ref_name !~CKMUX*) && (ref_name =~*BWP*)"]
      set count [ sizeof_collection $non_symmetricdcap_cells ]
echo [ format "------------------------------------------------------------------------" ]
      if { $count == 0 } {
        echo [ format "INFO: %d non-symmetricdcap cells used in %s." $count [ get_attribute $clock full_name ] ]
      } else {
        echo [ format "WARNING: %d non-symmetricdcap cells used in %s." $count [ get_attribute $clock full_name ] ]
        foreach_in_collection cell $non_symmetricdcap_cells {
          echo [ format "%s (%s)" [ get_attribute $cell full_name ] [ get_attribute $cell ref_name ] ]
        }
      }
      echo [ format "" ]
set total_count [ expr $total_count + $count ]
    }
  }
echo [ format "------------------------------------------------------------------------" ]
echo [ format "INFO: Total %d non-symmetricdcap cells used." $total_count ]
}

