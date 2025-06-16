#!/bin/bash/expect -f

set password "local_pass"
set username "local_username"

pawn passwd $username

expect "New password: "
send "$password\r"

expect "Retype new password: "
send "$password\r"

expect eof
