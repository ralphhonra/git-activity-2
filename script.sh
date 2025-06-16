#!/bin/bash

#this is my first comment
echo "Hello world from script!"


x="testing"
y="testing"

if [ "$x" = "$y" ]; then
	echo "Truee"
else
	echo "Falsee"
fi

for i in 1 2 3 4 5
do
	touch samplefile-$i.txt
	echo "Done creating samplefile-$1.txt"
done

INPUTTED_STRING="sample"

while true; do
	echo "Type the exit command"
	read INPUTTED_STRING
	if [ "$INPUTTED_STRING" = "done" ]; then
		break
	else
		echo "exit command not found"
	fi
done

