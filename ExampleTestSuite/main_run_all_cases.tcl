package require OurTest
namespace import OurTest::*
set OurTest::log_file_id [open log.txt w]

run_test

close $OurTest::log_file_id
