#!  /usr/bin/perl -w

use strict;
use lib '/filer/home/chandlerh/MDGRAPE-4A/check_area/IC/';
use lib '/filer/home/chandlerh/MDGRAPE-4A/check_area/IC/Synopsys/';
use Synopsys::Lib_paser;
use Netlist::Paser;
use COMMON::GetConfig;
use COMMON::GetLine;
use File::Basename;
use File::Find;
use File::Copy;
use File::Glob;
use Term::ANSIColor qw(:constants);
$Term::ANSIColor::AUTORESET = 1;
$Synopsys::Lib_paser::Debug = 0;
$Synopsys::Lib_paser::SIMPLE = 1;
#$synopsys2::Lib_paser::SIMPLE = 0;

my $file = shift;
my $ConfigFile = shift;

###########################################
## Get Config
############################################
print STDERR "#####################################################################################################################\n";
print STDERR "# PROGRAM     : check_area.Linux\n";
print STDERR "# DESCRIPTION : check leakage / gate count from netlist\n";
print STDERR "# WRITTEN BY  : Marshal Su ( marshals\@alchip.com )\n";
print STDERR "#             : v2.00 support caculate memory bit\n";
print STDERR "#             : v2.01 support caculate 'area of high input number of combination cell' / 'all input combination cell'\n";
print STDERR "#             : v2.03 speed up when load lib\n";
print STDERR "#             : v2.04 support caculate the leakage for GDCAP/DCAP cell\n";
print STDERR "#             : v2.05 support Samsung 28lpp\n";
print STDERR "#             : v2.07 support Samsung 14lpp\n";
print STDERR "#             : v2.08 fix bug about the leakage power calcuation for Samsung 14lpp\n";
print STDERR "#             : v2.09 correct the power unit\n";
print STDERR "#             : v2.10 fix a bug when 'cell_leakage_power' defined together with the leakage{} in lib\n";
print STDERR "#             : v2.11 fix a bug for multi-top\n";
print STDERR "#             : v2.12 support C34 cell in ss28lpp\n";
print STDERR "#             : v2.13 change leakage power unit to 'uW'\n";
print STDERR "#             : v2.14 support synopsys 28nm\n";
print STDERR "#             : v2.15 support S8T for ss28lpp\n";
print STDERR "#####################################################################################################################\n\n\n";
sleep 1;

##############
print STDERR "INFO: Read in Config file $ConfigFile ...\n";
if (!defined $ConfigFile and !-f "./config.check_area" ) {
  print STDERR "Usage: check_area Netlist [ config.check_area ]\n";
  exit;
}
if ( !defined $ConfigFile and -f "./config.check_area" ) {
  print STDERR "Warning: Use the Default config file: ./config.check_area\n";
  $ConfigFile = "./config.check_area";
}
print STDERR "############################################ Configures ############################################\n";
my $config = COMMON::GetConfig->new();
my %LIB_PATTERN                 = $config->GetConfig( File => $ConfigFile, Error => 1, Type => "HASH", Key => "LIB_PATTERN", );
my @RPT_LIB_ORDER               = $config->GetConfig( File => $ConfigFile, Error => 1, Type => "ARRAY", Key => "RPT_LIB_ORDER", );
my @EXCLUDE_FILE_PATTERN        = $config->GetConfig( File => $ConfigFile, Error => 1, Type => "ARRAY", Key => "EXCLUDE_FILE_PATTERN", );
my $RPT_BLOCK_AREA              = $config->GetConfig( File => $ConfigFile, Error => 1, Type => "", Key => "RPT_BLOCK_AREA", );
my @VT_INDEX                    = $config->GetConfig( File => $ConfigFile, Error => 1, Type => "ARRAY", Key => "VT_INDEX", );
my $NAND_NAME                   = $config->GetConfig( File => $ConfigFile, Error => 1, Type => "", Key => "NAND_NAME", );
#my $TOP_NAME                    = $config->GetConfig( File => $ConfigFile, Error => 1, Type => "", Key => "TOP_NAME", );
my $TOP_NAME                    = shift;
my $high_input_thr              = $config->GetConfig( File => $ConfigFile, Error => 1, Type => "", Key => "HIGH_INPUT_THR", );
my $RPT_DUPLICATED_MODULE       = $config->GetConfig( File => $ConfigFile, Error => 1, Type => "", Key => "RPT_DUPLICATED_MODULE", );
print STDERR "####################################################################################################\n\n\n";

if ( !-f $file ) {
  print STDERR "Error: No such file : $file\n";
  exit;
}

if ( !defined $TOP_NAME ) {
  $TOP_NAME = "aa";
}
###########################################
## Get block list
############################################
my $block_list = COMMON::GetLine->new();
my %RPT_BLOCKS;

if ( !-f $RPT_BLOCK_AREA ) {
  print STDERR "Warning: No such file for RPT_BLOCK_AREA: $RPT_BLOCK_AREA\n";
} else {
  $block_list->get_line($RPT_BLOCK_AREA);
  %RPT_BLOCKS = %{$block_list->{line}};
}
############################################
## read lib
############################################
my %lib;
my %loaded;
foreach my $lib_type ( keys %LIB_PATTERN ) {
  $lib{$lib_type} = Synopsys::Lib_paser->new();
  print STDERR "INFO: Load $lib_type Library\n";
  foreach my $std_lib ( split /\s+/, $LIB_PATTERN{$lib_type} ) {
    foreach my $lib_file ( glob $std_lib ) {
      my $name = basename $lib_file;
      my $is_skip = 0;
      foreach my $EXCLUDE_FILE_PATTERN ( @EXCLUDE_FILE_PATTERN ) {
        if ( $lib_file =~ /$EXCLUDE_FILE_PATTERN/ ) {
          $is_skip = 1;
        }
      }
      next if ( $is_skip );
      next if ( exists $loaded{$name} );
      $lib{$lib_type}->LoadLib($lib_file);
      $loaded{$name} = 1;
    }
  }
}
#foreach my $lib_type ( keys %lib ) {
#print $lib_type;
#foreach my $ref_name ( keys %{$lib{$lib_type}->{Info}} ) {
#  foreach my $pg ( keys %{$lib{$lib_type}->{Info}{$ref_name}{leakage_power}} ) {
#    print "$ref_name $lib{$lib_type}->{Info}{$ref_name}{leakage_power}{$pg}\n"
#  }
#}
#}

#print STDERR "Area of $NAND_NAME: $lib{SC}->{Info}{AN2D0BWP35CD3NM}{leakage_power} $lib{SC}->{Info}{AN2D0BWP35CD3NM}{leakage_power_cac}\n";
print STDERR "Area of $NAND_NAME: $lib{SC}->{Info}{$NAND_NAME}{area}\n";
############################################
## read verilog
############################################
my $netlist = Netlist::Paser->new();
$netlist->read_verilog($file);
## link
if ( $TOP_NAME eq "aa" ) {
  print STDERR "Warning: No module name match $TOP_NAME!\n";
  print STDERR "INFO: Automatically Trace ...";
  $TOP_NAME = $netlist->get_top_name();
  print STDERR "Find $TOP_NAME as TOP name\n";
}

print STDERR "Link $TOP_NAME ...\n";
$netlist->get_hier_cells($TOP_NAME, $TOP_NAME, "");

############################################
## Anylize the blocks
############################################
my %area;
my %num;
my %no_area;
my %no_leakage;
my %no_lib;
foreach my $ins ( keys %RPT_BLOCKS ) {
  if ( exists $netlist->{cell}{"$TOP_NAME"}{$ins} ) {
    print STDERR "Analyze Hierarchical : $ins ( $netlist->{cell}{$TOP_NAME}{$ins} ) ...\n";
    $netlist->get_hier_cells($ins, $netlist->{cell}{"$TOP_NAME"}{$ins}, "");
  } elsif ( exists $netlist->{ref_index}{$ins} ) {
    my $tmp_ins;
    foreach my $tt (keys %{$netlist->{ref_index}{$ins}} ) {
      $tmp_ins = $tt;
    }
    print STDERR "Analyze Hierarchical for module : $ins -> $tmp_ins ...\n";
    $netlist->get_hier_cells($tmp_ins, $netlist->{cell}{"$TOP_NAME"}{$tmp_ins}, "");
  } else {
    print STDERR "Can not Find: $ins ...\n";
  }
}

$RPT_BLOCKS{$TOP_NAME} = 1;

foreach my $ins ( sort keys %RPT_BLOCKS ) {
  my %areas;
  if ( exists $netlist->{cell}{$ins}) {
    print STDERR "Begin Caculate Areas for $ins ...\n";
    &get_area( $ins, \%area);
  } elsif ( exists $netlist->{ref_index}{$ins} ) {
    my $tmp_ins;
    foreach my $tt (keys %{$netlist->{ref_index}{$ins}} ) {
      $tmp_ins = $tt;
    }
    print STDERR "Begin Caculate Areas for $ins -> $tmp_ins ...\n";
    &get_area( $tmp_ins, \%area);
  }
}

############################################
## Report
############################################
# print 
foreach my $ref_name ( keys %no_lib ) {
  print "Warning: No lib deinfed for $ref_name\n";
}
foreach my $ref_name ( keys %no_area ) {
  print "Warning: No area defined for $ref_name\n";
}

foreach my $ref_name ( keys %no_leakage ) {
  print "Warning: No Leakage defined for $ref_name\n";
}
#TOP
&report_area( $TOP_NAME, $TOP_NAME, @RPT_LIB_ORDER );
&report_leakage( $TOP_NAME );
foreach my $ins ( sort keys %area ) {
  next if ( $ins eq $TOP_NAME ) ;
  print "#######################################################################\n";
  &report_area( $ins, $netlist->{cell}{$TOP_NAME}{$ins} , @RPT_LIB_ORDER );
  &report_leakage( $ins );

}

sub report_leakage {
  my ( $top ) = @_;

  printf "\nReport SC Leakage Information for $top: \n";
  printf( "+------------+------------+---------+------------------+---------+-------------------+---------+\n");
  printf( "|    Type    |   #Count   |   (%%)   |    Area(um^2)    |   (%%)   |    Leakage(uW)    |   (%%)   |\n") ;
  printf( "+------------+------------+---------+------------------+---------+-------------------+---------+\n");
  foreach my $VT ( @VT_INDEX ) {
    printf( "| %-10s | %10s | %7s | %16s | %7s | %17s | %7s |\n", 
               $VT, sprintf("%6d", $area{$top}{VT}{$VT}{number}),                sprintf("%3.2f%%", $area{$top}{VT}{$VT}{number}  / $area{$top}{number}{SC} * 100),
                    sprintf ( "%6.3f", $area{$top}{VT}{$VT}{area}),              sprintf("%3.2f%%", $area{$top}{VT}{$VT}{area}    / $area{$top}{area}{SC} * 100 ),
                    sprintf ( "%6.3f", $area{$top}{VT}{$VT}{leakage} * 1000000), sprintf("%3.2f%%", $area{$top}{VT}{$VT}{leakage} / $area{$top}{leakage}{SC} * 100 )
          );
    printf( "+------------+------------+---------+------------------+---------+-------------------+---------+\n");
  }
  
  printf( "| %-10s | %10s | %7s | %16s | %7s | %17s | %7s |\n",
               "Total",  sprintf("%6d", $area{$top}{number}{SC}), sprintf("%3.2f%%", 100), 
                         sprintf("%6.3f", $area{$top}{area}{SC}), sprintf("%3.2f%%", 100),
                         sprintf("%6.3f", $area{$top}{leakage}{SC} * 1000000), sprintf("%3.2f%%", 100)
        );
  printf( "+------------+------------+---------+------------------+---------+-------------------+---------+\n");
  
  
  printf( "\n" ) ;
  printf( "------------------------ Leakage summary for Excel format ----------------------------\n\n" ) ;
  printf( "Type #Count (%%) Area(um^2) (%%) Leakage(uW) (%%)\n" ) ;
  foreach my $VT ( @VT_INDEX ) {
    printf( "%1s %1d %1.2f%% %1.3f %1.2f%% %6.3f %1.2f%%\n",
               $VT, $area{$top}{VT}{$VT}{number},  $area{$top}{VT}{$VT}{number}  / $area{$top}{number}{SC} * 100,
                    $area{$top}{VT}{$VT}{area},    $area{$top}{VT}{$VT}{area}    / $area{$top}{area}{SC} * 100,
                    $area{$top}{VT}{$VT}{leakage}*1000000, $area{$top}{VT}{$VT}{leakage} / $area{$top}{leakage}{SC} * 100
          );
  }
  printf( "Total %1d %1.2f%% %1.3f %1.2f%% %6.3f %1.2f%%\n\n",
                         $area{$top}{number}{SC}, 100,
                         $area{$top}{area}{SC}, 100,
                         $area{$top}{leakage}{SC}*1000000, 100
        );
  printf( "--------------------------------------------------------------------------------------\n" ) ;
}

#
#if ( $RPT_DUPLICATED_MODULE eq "yes" ) {
#  print STDERR "INFO: Report the duplicated module\n";
#  
#}

sub get_area {
  my ( $top, $areas ) = @_;

  my $total = 0;
  my $ins_num = 0;

  foreach my $VT ( @VT_INDEX ) {
    $$areas{$top}{VT}{$VT}{area} = 0;
    $$areas{$top}{VT}{$VT}{number} = 0;
    $$areas{$top}{VT}{$VT}{leakage} = 0;
  }

  foreach my $cell ( keys %{$netlist->{cell}{$top}} ) {
    my $ref_name = $netlist->{cell}{$top}{$cell};
    
    my $exists_ref = 0;
    foreach my $lib_type ( keys %lib ) {
      if ( exists $lib{$lib_type}->{Info}{$ref_name} ) {
        $exists_ref = 1;
        if ( $lib_type eq "SC" ) {
          my $VT_index = $lib{$lib_type}->{Info}{$ref_name}{VT};
          my $VT = $VT_INDEX[$VT_index];
          if ( exists $$areas{$top}{VT}{$VT} ) {
            $$areas{$top}{VT}{$VT}{area} += $lib{$lib_type}->{Info}{$ref_name}{area};
            $$areas{$top}{VT}{$VT}{number} ++;
            foreach my $pg ( keys %{ $lib{$lib_type}->{Info}{$ref_name}{leakage_power} } ) {
              #print "$ref_name $pg $lib{$lib_type}->{Info}{$ref_name}{power_unit}\n";
              $$areas{$top}{VT}{$VT}{leakage} += $lib{$lib_type}->{Info}{$ref_name}{leakage_power}{$pg} / $lib{$lib_type}->{Info}{$ref_name}{power_unit};
              print "$top, $VT, $lib_type, $ref_name $lib{$lib_type}->{Info}{$ref_name}{leakage_power}{$pg}\n" if $lib{$lib_type}->{Info}{$ref_name}{leakage_power}{$pg} == 0;
            }
          } else {
            $$areas{$top}{VT}{$VT}{area} = $lib{$lib_type}->{Info}{$ref_name}{area};
            $$areas{$top}{VT}{$VT}{number} = 1;
            $$areas{$top}{VT}{$VT}{leakage} = 0;
            foreach my $pg ( keys %{ $lib{$lib_type}->{Info}{$ref_name}{leakage_power} } ) {
              $$areas{$top}{VT}{$VT}{leakage} += $lib{$lib_type}->{Info}{$ref_name}{leakage_power}{$pg} / $lib{$lib_type}->{Info}{$ref_name}{power_unit};
              print "$top, $VT, $lib_type, $ref_name $lib{$lib_type}->{Info}{$ref_name}{leakage_power}{$pg}\n" if $lib{$lib_type}->{Info}{$ref_name}{leakage_power}{$pg} == 0;
            }
          }
          if ( $lib{$lib_type}->{Info}{$ref_name}{is_seq} == 0 ) {
            if ( $lib{$lib_type}->{Info}{$ref_name}{input_number} >= $high_input_thr ) {
              if ( exists $$areas{$top}{non_seq_highinput_area} ) {
                $$areas{$top}{non_seq_highinput_area}   += $lib{$lib_type}->{Info}{$ref_name}{area};
                $$areas{$top}{non_seq_highinput_number} ++;
              } else {
                $$areas{$top}{non_seq_highinput_area} = $lib{$lib_type}->{Info}{$ref_name}{area};
                $$areas{$top}{non_seq_highinput_number} = 1;
              }
            }
            if ( exists $$areas{$top}{non_seq_area} ) {
              $$areas{$top}{non_seq_area}   += $lib{$lib_type}->{Info}{$ref_name}{area};
              $$areas{$top}{non_seq_number} ++;
            } else {
              $$areas{$top}{non_seq_area} = $lib{$lib_type}->{Info}{$ref_name}{area};
              $$areas{$top}{non_seq_number} = 1;
            }
          }
        }

        my $area = 0;
        if ( !exists $lib{$lib_type}->{Info}{$ref_name}{area} or !defined $lib{$lib_type}->{Info}{$ref_name}{area} ) {
          $no_area{$ref_name} = 1;
        } else {
          $area = $lib{$lib_type}->{Info}{$ref_name}{area};
        }
        my $leakage_power = 0;
        if ( !exists $lib{$lib_type}->{Info}{$ref_name}{leakage_power} or !defined $lib{$lib_type}->{Info}{$ref_name}{leakage_power} ) {
          if ( !exists $lib{$lib_type}->{Info}{$ref_name}{leakage_power_cac} or !defined $lib{$lib_type}->{Info}{$ref_name}{leakage_power_cac} ) {
            $no_leakage{$ref_name} = 1;
          } else {
            foreach my $pg ( keys %{$lib{$lib_type}->{Info}{$ref_name}{leakage_power_cac}} ) {
              $leakage_power += $lib{$lib_type}->{Info}{$ref_name}{leakage_power_cac}{$pg};
            }
            #print "Warning: Use leakage_power_cac information for $ref_name in library, $leakage_power\n";
          }
        } else {
          foreach my $pg ( keys %{$lib{$lib_type}->{Info}{$ref_name}{leakage_power}} ) {
            $leakage_power += $lib{$lib_type}->{Info}{$ref_name}{leakage_power}{$pg};
          }
          #print "111 $ref_name $leakage_power\n";
        }
        ### for memory bit
        my $bits = 0;
        if ( $lib_type =~ /^mem/ ) {
#print "$ref_name $cell\n";
          if ( $ref_name =~ /(\d+)(x|X)(\d+)/ ) {
            $bits = $1 * $3;
          }
        }
        ##
        #print "111 $ref_name $leakage_power\n";
        if ( exists $$areas{$top}{area}{$lib_type} ) {
          $$areas{$top}{area}{$lib_type} += $area;
          $$areas{$top}{number}{$lib_type} ++;
          $$areas{$top}{leakage}{$lib_type} += $leakage_power / $lib{$lib_type}->{Info}{$ref_name}{power_unit};
          $$areas{$top}{mem_bits}{$lib_type} += $bits;
        } else {
          $$areas{$top}{area}{$lib_type}  = $area;
          $$areas{$top}{number}{$lib_type} = 1;
          $$areas{$top}{leakage}{$lib_type} = $leakage_power / $lib{$lib_type}->{Info}{$ref_name}{power_unit};
          $$areas{$top}{mem_bits}{$lib_type} = $bits;
        }
      }
    }
    if ( $exists_ref == 0 ) {
      if ( exists $netlist->{module}{$ref_name} ) {
      } else {
        $no_lib{$ref_name} = 1;
      }
    }
  }
}

sub report_area {
  my ( $TOP, $TOP_NAME, @order ) = @_;

#  my @order = split /\s+/, $order;
  my %total;

  my $port_number = 0 ;
  if ( exists $netlist->{module}{$TOP_NAME}{port_number} ) {
    foreach my $dir  ( keys %{$netlist->{module}{$TOP_NAME}{port_number}} ) {
      $port_number += $netlist->{module}{$TOP_NAME}{port_number}{$dir};
    }
  } else {
    print "No port_number information for: $TOP_NAME\n";
  }

  print "\nReport Area/Gate Count/Instance Number for $TOP:\n";
  printf( "     Instance                  Instance Number          Area            Leakage(uW)       Gate Count (M)        Memory Bits\n" );
  printf( "----------------------------  ------------------  ------------------ ----------------- ------------------  ------------------\n" );

  foreach my $lib_type ( @order ) {
    if ( exists $area{$TOP}{area}{$lib_type} ) {
      printf( "%-28s  %18d  %15.3f  %12.6f %15.3f  %19d\n", $lib_type, $area{$TOP}{number}{$lib_type},
                                                                  $area{$TOP}{area}{$lib_type},
                                                                  $area{$TOP}{leakage}{$lib_type} * 1000000,
                                                                  $area{$TOP}{area}{$lib_type} / $lib{SC}->{Info}{$NAND_NAME}{area} / 1000000.000,
                                                                  $area{$TOP}{mem_bits}{$lib_type}
      );
      if ( exists $total{number} ) {
        $total{number} += $area{$TOP}{number}{$lib_type};
      } else {
        $total{number} = $area{$TOP}{number}{$lib_type};
      }
      if ( exists $total{area} ) {
        $total{area} += $area{$TOP}{area}{$lib_type};
      } else {
        $total{area} = $area{$TOP}{area}{$lib_type};
      }
      if ( exists $total{leakage} ) {
        $total{leakage} += $area{$TOP}{leakage}{$lib_type};
      } else {
        $total{leakage} = $area{$TOP}{leakage}{$lib_type};
      }
      if ( exists $total{mem_bits} ) {
        $total{mem_bits} += $area{$TOP}{mem_bits}{$lib_type};
      } else {
        $total{mem_bits} = $area{$TOP}{mem_bits}{$lib_type};
      }

    }
  }

  foreach my $lib_type ( sort keys %{$area{$TOP}{area}} ) {
    my $is_next = 0;
    foreach my $lib_type_tmp ( @order ) {
      $is_next = 1 if ($lib_type eq $lib_type_tmp );
    }
    next if ( $is_next );

    if ( exists $area{$TOP}{area}{$lib_type} ) {
      printf( "%-28s  %18d  %15.3f  %12.6f %15.3f  %19d\n", $lib_type, $area{$TOP}{number}{$lib_type},
                                                                  $area{$TOP}{area}{$lib_type},
                                                                  $area{$TOP}{leakage}{$lib_type} *1000000,
                                                                  $area{$TOP}{area}{$lib_type} / $lib{SC}->{Info}{$NAND_NAME}{area} / 1000000.000,
                                                                  $area{$TOP}{mem_bits}{$lib_type}
      );
      if ( exists $total{number} ) {
        $total{number} += $area{$TOP}{number}{$lib_type};
      } else {
        $total{number} = $area{$TOP}{number}{$lib_type};
      }
      if ( exists $total{area} ) {
        $total{area} += $area{$TOP}{area}{$lib_type};
      } else {
        $total{area} = $area{$TOP}{area}{$lib_type};
      }
      if ( exists $total{leakage} ) {
        $total{leakage} += $area{$TOP}{leakage}{$lib_type};
      } else {
        $total{leakage} = $area{$TOP}{leakage}{$lib_type};
      }
      if ( exists $total{mem_bits} ) {
        $total{mem_bits} += $area{$TOP}{mem_bits}{$lib_type};
      } else {
        $total{mem_bits} = $area{$TOP}{mem_bits}{$lib_type};
      }
    }
  }
  printf( "-----------------------------------------------------------------------------------------------------------------------------\n" );
  printf( "%-28s  %18d  %15.3f  %12.6f  %15.3f  %19d\n", "Total",   $total{number},
                                                                    $total{area},
                                                                    $total{leakage} * 1000000,
                                                                    $total{area} / $lib{SC}->{Info}{$NAND_NAME}{area} / 1000000.000,
                                                                    $total{mem_bits}
  );
  printf( "Port Number: $port_number\n\n" );
  printf( "-----------------------------------------------------------------------------------------------------------------------------\n" );
  printf ("%28s  %19s  %6s\n", "Type          ", "Value   ", "  Ratio");
  printf( "-------------------------------  ------------------  ---------\n" );
  printf ("%-29s  %19d  %6s\n", "#Combinational", $area{$TOP}{non_seq_number}, "" );
  printf ("%-29s      %15.3f  %6s\n", "Combinational_area", $area{$TOP}{non_seq_area}, "" );
#  printf ("%-29s  %19d     %3.2f%%\n", "#HighInput_Combinational", $area{$TOP}{non_seq_highinput_number}, $area{$TOP}{non_seq_highinput_number} / $area{$TOP}{non_seq_number} * 100 );
#  printf ("%-29s      %15.3f     %3.2f%%\n", "HighInput_Combinational_area", $area{$TOP}{non_seq_highinput_area},  $area{$TOP}{non_seq_highinput_area} / $area{$TOP}{non_seq_area} * 100 );
  printf( "-----------------------------------------------------------------------------------------------------------------------------\n" );

}
