set ___chars_of_line 100

namespace eval OurTest {
	
	variable ___mVersion 1.0
	variable ___mTestResults [list]
	variable ___mRunCondition
	variable ___mSuiteSetupExp 0
	variable runer_script_list ""
	variable runner_next_script ""
	variable test_results ""
	variable setup_num 0
	variable log_file_id ""
	variable sep1 [string repeat - $::___chars_of_line]
	variable sep2 [string repeat = $::___chars_of_line]
	
	set ___mRunCondition(always) {expr 1}
	set ___mRunCondition(norun) {expr 0}
	
	namespace eval ___test {
		
		variable description ""
		variable content ""
		variable pattern 1
		variable operation equal
		variable result ""
		variable results ""
		variable step 1
		
	}

	proc our_puts { data } {
		
		variable log_file_id
		variable sep1
		variable sep2
		
		if {$data ne "" && $data ne $sep1 && $data ne $sep2} {
			set data "OurTest [clock format [clock seconds]]: $data"
		}
		
		if {$log_file_id ne ""} {
			puts $log_file_id $data
			flush $log_file_id
		}
		
		puts $data
	}
	
	proc get_file_dir {} {
		
		set script_file_name [file normalize [info script]]
		return [file dirname $script_file_name]
	}
	
	proc read_script_content { filename } {
		
		if {[catch {
        		set fileid [open $filename]
        		set content [read $fileid]
		} msg]} {
			our_puts $msg
			catch {close $fileid}
			
			return ""
		}
		
		return $content
	}
	
	namespace export run_test
	proc run_test { {dir_list ""} {pattern {*.test.tcl *_test.tcl}}} {
		
		variable runer_script_list
		variable test_results
		variable sep1
		variable sep2
		
		set test_results ""
		set runer_script_list ""
		
		if {$dir_list eq ""} {
			set dirs [get_file_dir]
		} else {
			
			set dirs [list]
			foreach dir $dir_list {
				lappend dirs [string trimright $dir /]
				
			}
		}
		
		get_all_tcl_scripts $dirs $pattern
		
		our_puts $sep2
		our_puts "Following scripts will be executed."
		our_puts $sep1
		foreach s $runer_script_list { our_puts $s}
		our_puts $sep2
		our_puts ""
		
		run_suite_script
		
		our_puts ""
		our_puts ""
		our_puts "Test results:"
		our_puts $sep2
		foreach {script results} $test_results {
			our_puts "$script:"
			foreach result $results {
				our_puts  $result
			}
			our_puts $sep1
		}
		
		set runer_script_list ""
		
		return 0
		
	}
	
	proc get_all_tcl_scripts {dirs pattern} {
		
		variable runer_script_list
		variable setup_num
		
		foreach dir $dirs {
			
			set tcl_files [list]
			if { [catch "glob -directory $dir $pattern" tcl_files] } {
				set tcl_files ""
			}
			
			set tcl_file_list [list]
			foreach tcl_file $tcl_files {
				
				if {[string match *SuiteSetup.tcl $tcl_file]} {continue}
				if {[string match *SuiteTeardown.tcl $tcl_file]} {continue}
				lappend tcl_file_list $tcl_file
			}
	
			set tcl_setup ""
			if {[file exists "$dir/SuiteSetup.tcl"]} {
				set tcl_setup "$dir/SuiteSetup.tcl"
			}	
			set tcl_teardown ""
			if {[file exists "$dir/SuiteTeardown.tcl"]} {
				set tcl_teardown "$dir/SuiteTeardown.tcl"
			}
			
			if { [catch "glob -directory $dir -types d *" msg] } {
				set tcl_dirs ""
			} else {
				set tcl_dirs $msg
			}
			
			if {$tcl_setup ne ""} {
				set runer_script_list [linsert $runer_script_list $setup_num $tcl_setup]
				incr setup_num
			}
			
			if {$tcl_dirs ne ""} {
				get_all_tcl_scripts $tcl_dirs $pattern
			}
			
			
			foreach tcl $tcl_file_list {
				set runer_script_list [linsert $runer_script_list $setup_num $tcl]
				incr setup_num
			}

			if {$tcl_teardown ne ""} {
				set runer_script_list [linsert $runer_script_list $setup_num $tcl_teardown]
				incr setup_num
			}
			
		}
		
		return 0
	}
	
	proc run_suite_script {} {
		
		variable runner_next_script
		variable runer_script_list
		variable test_results
		variable sep1
		variable sep2
		
		set current_resuts ""
		
		interp create runner
		interp alias runner append_suite_result {} set current_resuts
		runner eval "set ::___ourtest_is_run_by_runner 1"
		
		set script_num [llength $runer_script_list]
		
		foreach cur_script $runer_script_list {
			
			set current_resuts ""
			if {$runner_next_script ne ""} {
				if {"$cur_script" eq "$runner_next_script"} {
					set runner_next_script ""
				} else {
					set current_resuts {{Dir setup exception.}}
					lappend test_results $cur_script
					lappend test_results $current_resuts
					set current_resuts ""
					continue
				}
			}
			
			if {![string match -nocase *SuiteTeardown.tcl $cur_script] && \
				![string match -nocase *SuiteSetup.tcl $cur_script]} {
				our_puts ""
				our_puts $sep2
        			our_puts "Begin to run test suite in file $cur_script"
			}
			
			set script_content  [read_script_content $cur_script]
			runner eval "set ::___current_script_name $cur_script"
			
			if {[string match -nocase *SuiteTeardown.tcl $cur_script]} {
				
				set script_content [subst -nocommands -novariables $script_content]
				
				foreach line [split $script_content "\r\n"] {
					
					if {[catch {runner eval $line} msg]} {
						
						our_puts "Exception happened in $cur_script"
						our_puts $msg
						lappend current_resuts "$msg"
					}
				}
				
			} else {
				
        			if {[catch {runner eval $script_content} msg]} {
        				
        				our_puts "Exception happened in $cur_script"
        				our_puts $msg
        				
        				if {[string match *SuiteSetup.tcl $cur_script]} {
        
        					set teardown_file "[file dirname $cur_script]/SuiteTeardown.tcl"
        					if { [file exists $teardown_file] } {
        						set runner_next_script $teardown_file
        					} else {
        						set last_script [lindex [ \
        						lsearch -glob -all $runer_script_list [ \
							file dirname $cur_script]/*.tcl ] end]
        						
        						if {$script_num > [expr $last_script + 1] } {
        							set runner_next_script [\
								lindex $runer_script_list $last_script+1]
        						} else {
								set runner_next_script unavailable_script_in_runner
        						}
        					}
						
						lappend current_resuts "$msg"
        					
        				} 
        			}
			}
			
			if {![string match -nocase *SuiteTeardown.tcl $cur_script] && \
				![string match -nocase *SuiteSetup.tcl $cur_script]} {
				our_puts "end to run test suite in file $cur_script"
				our_puts $sep2
				our_puts ""
			}
			
			lappend test_results $cur_script
			lappend test_results $current_resuts
			set current_resuts ""
		}
		
		interp delete runner
		set runner_next_script ""
	}
	
	namespace export SuiteSetup
	proc SuiteSetup { {setup_script ""} } {
		
		variable ___mSuiteSetupExp
		variable ___mTestResults
		
		set ___mTestResults [list]
		set ___mSuiteSetupExp 0
		set setup_list [list]
		
		if {[info exists ::___ourtest_is_run_by_runner]} {
			set current_dir [get_file_dir]
			while {[file exists "$current_dir/SuiteSetup.tcl"]} {
				lappend setup_list "$current_dir/SuiteSetup.tcl"
				set current_dir [file dirname $current_dir]
			}
		}
		
		if {[catch {
			
        		set setup_list [lreverse $setup_list]
        		foreach setup $setup_list {
        			set script [subst "source $setup"]
        			uplevel $script
        		}
        		
        		uplevel $setup_script
			
		} msg]} {
			our_puts "Exception happened in SuiteSetup."
			our_puts $msg
			set ___mSuiteSetupExp 1
				
        	}
	}
	
	namespace export SuiteTeardown
	proc SuiteTeardown { {teardown_script ""} } {
		
		variable ___mSuiteSetupExp
		variable ___mTestResults
		if {[info exists ::___ourtest_is_run_by_runner]} {
			append_suite_result $___mTestResults
		}
		
		set teardown_script [subst -nocommands -novariables $teardown_script]
		foreach funcall [split $teardown_script "\r\n"] {
			
			set funcall [string trim $funcall]
			
			if {[string index [string trim $funcall] 0] == "#"} { continue }
			
			if {[catch {uplevel $funcall} msg]} {
				our_puts "Execption happened in suite teardown code ==\{$funcall\}==."
				our_puts $msg
			} 
		}
		
		set teardown_list [list]
		
		if {![info exists ::___ourtest_is_run_by_runner]} {
			set current_dir [get_file_dir]
			while {[file exists "$current_dir/SuiteTeardown.tcl"]} {
				lappend teardown_list "$current_dir/SuiteTeardown.tcl"
				set current_dir [file dirname $current_dir]
			}
		}

		foreach teardown $teardown_list {
			
			set current_teardown_content [read_script_content $teardown]
			set current_teardown_content [subst -nocommands -novariables $current_teardown_content]
			
			foreach funcall [split $current_teardown_content "\r\n"] {
						
				set funcall [string trim $funcall]
				
				if {[string index [string trim $funcall] 0] == "#"} { continue }
				
				if {[catch {uplevel $funcall} msg]} {
					our_puts "Execption happened in suite teardown file ==\{$teardown\}==."
					our_puts $msg
				} 
			}
		}
		
		set ___mSuiteSetupExp 0
		
		if {[info exists ::___current_script_name]} {
			set script_name $::___current_script_name
		} else {
			set script_name [info script]
		}
		
		our_puts [string repeat - 100]
		our_puts "Test results for $script_name"
		foreach case_result $___mTestResults {
			our_puts $case_result
		}
	}
	
	proc checking {desc} {
		
		set ___test::description $desc
	}
	
	proc expect {cnt {opt expression} {ptn 1}} {
		
		set ___test::content $cnt
		set ___test::pattern $ptn
		set ___test::operation $opt
		set ___test::result ""
		
		set msg "Step_$___test::step: checking $cnt $opt $ptn when $___test::description;\n"
		set res [list]
		switch -glob -nocase -- $opt {
			
			eq* {
				if {"$cnt" ne "$ptn"} {
					set ___test::result "failed $msg"
					error $___test::result "failed" failed_error
				} 
				
				set ___test::result pass
			}
			ne* {
				if {"$cnt" eq "$ptn"} {
					set ___test::result "failed $msg"
					error $___test::result "failed" failed_error
				} 
				
				set ___test::result pass
			}
			rmatch -
			reg* {
				if {![regexp -- $ptn $cnt]} {
					set ___test::result "failed $msg"
					error $___test::result "failed" failed_error
				} 
				
				set ___test::result pass
			}
			match* {
				if {![string match -nocase $ptn $cnt]} {
					set ___test::result "failed $msg"
					error $___test::result "failed" failed_error
				} 
				
				set ___test::result pass
			}
			
			default {
				error "Step_$___test::step: The operation:$opt is not available when $___test::description;\n"\
				"error" noerror
			}
			
		}
		
		lappend res $___test::result
		lappend res $msg
		
		lappend ___test::results $res
		
		incr ___test::step
		
		
	}
	
	namespace export testcase
	proc testcase {ourtest__caseid ourtest__condition ourtest__description ourtest__setup_script ourtest__body_script ourtest__teardown_script} {

		variable ___mTestResults
		variable ___mRunCondition
		variable ___mSuiteSetupExp
		
		set ___test::result ""
		set ___test::results ""
		set ___test::description ""
		set ___test::content ""
		set ___test::pattern 1
		set ___test::operation equal
		set ___test::step 1
		
		foreach ourtest__uplevel_variable [uplevel {info vars}] {
			upvar $ourtest__uplevel_variable $ourtest__uplevel_variable
		}
		
	###############################################################
	set ourtest__iserror [catch {
	###############################################################
		
		set ___test_result [list $ourtest__caseid [string trim $ourtest__description] ]
		
		if {$___mSuiteSetupExp == 1} {
			error "Exception happens in suite setup."
		}
		
		if {[info exists ___mRunCondition($ourtest__condition)]} {
			set ourtest__condition_satisfied [eval $___mRunCondition($ourtest__condition)]
		} {
			error "No condition:$ourtest__condition available." "error" noerror
		}
		
		if {$ourtest__condition_satisfied == 0} {
			error "The condition:$ourtest__condition is not satified!" "skip" noerror
		}
		
		set ourtest__cur_error_msg ""
		if {[catch {eval $ourtest__setup_script} ourtest__msg ourtest__option]} {
			
			set ourtest__cur_error_msg "Execption happened in test setup.\n$ourtest__msg"
			
		} elseif {[catch {eval $ourtest__body_script} ourtest__msg ourtest__option]} {
			
			array set ourtest__result_msg $ourtest__option
			if {"$ourtest__result_msg(-errorcode)" eq "failed_error"} {
				error $___test::result failed noerror
				
			}		
        		set ourtest__cur_error_msg "Execption happened in test body.\n$ourtest__msg"	
        	}
		
		
		
		set ourtest__teardown_script [subst -nocommands -novariables $ourtest__teardown_script]
		foreach ourtest__funcall [split $ourtest__teardown_script "\r\n"] {
			
			set ourtest__funcall [string trim $ourtest__funcall]
			if {[string index [string trim $ourtest__funcall] 0] == "#"} { continue }
			if {[catch {eval $ourtest__funcall} ourtest__msg ourtest__option]} {
				if {$ourtest__cur_error_msg ne ""} {append ourtest__cur_error_msg "\n"}
				append ourtest__cur_error_msg "Execption happened in test teardown code ==\{$ourtest__funcall\}==."
			} 
		}
		
		if {$ourtest__cur_error_msg ne ""} {
			error $ourtest__cur_error_msg
		}
		
		
		
		
		
	###############################################################
	} ourtest__msg ourtest__option]
	###############################################################
		
		if {$ourtest__iserror == 1} {
			
			array set ourtest__result_msg $ourtest__option
			if {"$ourtest__result_msg(-errorcode)" eq "noerror"} {
				lappend ___test_result $ourtest__result_msg(-errorinfo)
				
			} else {
        			lappend ___test_result exception
			}	
		} else {
			set ourtest__msg ""
			lappend ___test_result pass
		}
		
		if {$___test::results ne ""} {
			
			set OurTest__last_msg ""
			foreach OurTest__cur_res $___test::results {
				append OurTest__last_msg [join $OurTest__cur_res]
			}
			set ourtest__msg [string trim $OurTest__last_msg$ourtest__msg \n]
		}
		
		lappend ___test_result $ourtest__msg
		
		our_puts $___test_result
		lappend ___mTestResults $___test_result
	}
	
}

package provide OurTest $OurTest::___mVersion