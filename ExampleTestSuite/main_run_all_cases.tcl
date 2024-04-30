package require OurTest
namespace import OurTest::*

config_log_file_id [open log.txt w]
config_report_file_id [open report.csv w]

run_test

make_clear
