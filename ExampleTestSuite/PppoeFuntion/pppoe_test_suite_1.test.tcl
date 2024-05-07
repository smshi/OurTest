package require OurTest
namespace import OurTest::*

######################################################################################
#setup
######################################################################################

SuiteSetup {
	puts "suite setup of pppoe_test_suite_1."
}


######################################################################################
#Test procedure
######################################################################################

testcase test_case_1 always {test_case_1 of pppoe_test_suite_1.} {
	puts "setup of test_case_1 in pppoe_test_suite_1"
} {
	
	checking "Marking test result step 1 for contain"
	expect 112 contain 1

	checking "Marking test result step 2"
	expect 1 eq 1
	
	checking "Marking test result step 3"
	expect 1 ne 2
	
	checking "Marking test result step 4"
	expect "results string" rmatch .*stri.*
	
	checking "Marking test result step 5"
	expect "results string" match *stri*
	
} {
	puts "teardown of test_case_1 in pppoe_test_suite_1"
}

testcase test_case_2 always {test_case_2 of pppoe_test_suite_2.} {
	puts "setup of test_case_2 in pppoe_test_suite_1"
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
	puts "teardown of test_case_2 in pppoe_test_suite_1"
}

testcase test_case_3 always {test_case_3 of pppoe_test_suite_3.} {
	puts "setup of test_case_3 in pppoe_test_suite_1"
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
	puts "teardown of test_case_3 in pppoe_test_suite_1"
}

######################################################################################
#Test teardown
######################################################################################

SuiteTeardown {
	puts "suite teardown of pppoe_test_suite_1."
}
