#!/usr/bin/env expect
log_file password.output

spawn bash -c "[lindex $argv]"
expect "Enter password"
send "secretme\n"
expect eof
