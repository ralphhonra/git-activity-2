#!/bin/bash
echo "Input number of users: "
read user_num
echo "========================"

for i in $(seq $user_num); do
	echo "Input user name: "
	read user_name
	echo "====================="
	useradd -m -c /bin/bash "$user_name"

	echo "Input user password: "
	echo "===================="
	passwd $user_name

	echo "Congratulations, user $user_name with password is now created."
done

