# OurTest
A tcl test framework. ExampleTestSuite in the code is a representative example of common test suite.
# How to use it?
## Create directory structure as following:
```
ExampleTestSuite-----------------------------------------------top directory
        SuiteSetup.tcl-----------------------------------------setup for dir suite
        SuiteTeardown.tcl--------------------------------------teardown for dir suite
        DhcpFunction-------------------------------------------sub directory for sub dir suite
                SuiteSetup.tcl
                dhcp_test_suite_1.test.tcl
                dhcp_test_suite_2.test.tcl
                dhcp_test_suite_3.test.tcl
                SuiteTeardown.tcl
        PppoeFuntion-------------------------------------------sub directory for sub dir suite
                SuiteSetup.tcl
                pppoe_test_suite_1.test.tcl
                pppoe_test_suite_2.test.tcl
                SuiteTeardown.tcl
```
This is the directory structure of the exmaple already in the repo.
When the suite is running, the running order as following:
```
ExampleTestSuite/SuiteSetup.tcl
ExampleTestSuite/DhcpFunction/SuiteSetup.tcl
ExampleTestSuite/DhcpFunction/dhcp_test_suite_1.test.tcl
ExampleTestSuite/DhcpFunction/dhcp_test_suite_2.test.tcl
ExampleTestSuite/DhcpFunction/dhcp_test_suite_3.test.tcl
ExampleTestSuite/DhcpFunction/SuiteTeardown.tcl
ExampleTestSuite/PppoeFuntion/SuiteSetup.tcl
ExampleTestSuite/PppoeFuntion/pppoe_test_suite_1.test.tcl
ExampleTestSuite/PppoeFuntion/pppoe_test_suite_2.test.tcl
ExampleTestSuite/PppoeFuntion/SuiteTeardown.tcl
ExampleTestSuite/SuiteTeardown.tcl
```
## How to write SuiteTeardown.tcl
The content of SuiteTeardown.tcl is be executed line by line, all lines will be executed even exception happens to ensure the clearance.
When write the SuiteTeardown.tcl, you must guarantee **keep one sentence in one line**. If need cross line, you must add \ to the line end.
## How to run the test suite
### Run all the scripts.
If you already has the exmaple test suite, you can create a tcl file in the top dir (ExampleTestSuite) like following, and run it.
```
package require OurTest-----------------------------------------------import the package
namespace import OurTest::*

set OurTest::log_file_id [open log.txt w]-----------------------------the log will be recorded in the corresponding file.

run_test--------------------------------------------------------------It will get all the file in current dir and its sub dir to run

close $OurTest::log_file_id
```
The content is already in the example with file name main_run_all_cases.tcl, you can use any legal name you like. 
### Just run one test.
If you want just run one test file, execute the file drectly by tclsh, it will run all the setup in the parent directories and current directory, and then run the script itself, at last it will run all the teardown in current directory and all the parent directories.
## How to write test file.
### Create a file with name ending .test.tcl or _test.tcl
If you want to use other names that not ending .test.tcl or _test.tcl, you should call run_test with pattern parameter of yourself. For example, if you name it as mytestcase-test.tcl, you should call run_test like this:
`
run_test . *-test.tcl
`
### Create test element in the file
```
package require OurTest
namespace import OurTest::*

######################################################################################
#setup
######################################################################################

SuiteSetup {
	puts "suite setup of dhcp_test_suite_1."
}


######################################################################################
#Test procedure
######################################################################################

testcase {
  test_case_1 ----------------------------------------------test case id
} {
  always----------------------------------------------------run condithion, now only always or norun could work.
} {
  test_case_1 of dhcp_test_suite_1.-------------------------test case description
} {
	puts "setup of test_case_1 in dhcp_test_suite_1"----------test setup
} {


	checking "Marking test result step 1"---------------------Description for the current checkpoint
	expect 1 eq 1---------------------------------------------check if 1 eq 1, it not, it will fail
	
	checking "Marking test result step 2"
	expect 1 ne 2---------------------------------------------check if 1 ne 2
	
	checking "Marking test result step 3"
	expect "results string" rmatch .*stri.*-------------------check if "results string" regexp match .*stri.*
	
	checking "Marking test result step 4"
	expect "results string" match *stri*----------------------check if "results string" match *stri*
	
} {
	puts "teardown of test_case_1 in dhcp_test_suite_1"
}

testcase test_case_2 always {test_case_2 of dhcp_test_suite_2.} {
	puts "setup of test_case_2 in dhcp_test_suite_1"
} {


	checking "Marking test result step 1"
	expect 1 eq 1
	
	checking "Marking test result step 2"
	expect 1 ne 2
	
	checking "Marking test result step 3"
	expect "results string" rmatch .*stri.*
	
	checking "Marking test result step 4"
	expect "results string" match *stri*
	
} {
	puts "teardown of test_case_2 in dhcp_test_suite_1"
}

testcase test_case_3 always {test_case_3 of dhcp_test_suite_3.} {
	puts "setup of test_case_3 in dhcp_test_suite_1"
} {


	checking "Marking test result step 1"
	expect 1 eq 1
	
	checking "Marking test result step 2"
	expect 1 ne 2
	
	checking "Marking test result step 3"
	expect "results string" rmatch .*stri.*
	
	checking "Marking test result step 4"
	expect "results string" match *stri*
	
} {
	puts "teardown of test_case_3 in dhcp_test_suite_1"---------test teardown.
}

######################################################################################
#Test teardown
######################################################################################

SuiteTeardown {
	puts "suite teardown of dhcp_test_suite_1."
}
```
# Function Introduction
## run_test
### Function prototype
`
run_test { {dir_list ""} {pattern {*.test.tcl *_test.tcl}}}
`
### Parameter inctroduction
dir_list: dir list that contain test file
pattern:  the file in the dir_list that match the pattern will be executed as test file.
## testcase
### Function prototype
`
testcase {ourtest__caseid ourtest__condition ourtest__description ourtest__setup_script ourtest__body_script ourtest__teardown_script} 
`
### Parameter inctroduction
ourtest__caseid:          case id
ourtest__condition:       condition if run or not, the current support value is always or norun
ourtest__description:     To describe what the case is
ourtest__setup_script:    setup for the case
ourtest__body_script:     script body
ourtest__teardown_script: teardown for the case
## expect
### Function prototype
`
expect {cnt {opt expression} {ptn 1}}
`
### Parameter inctroduction
cnt: any string
opt:  enum value, could only one of [eq ne rmatch match]
ptn: any string

To check if cnt is eq or ne or rmatch or match patn. It chould be used only in testcase body.
