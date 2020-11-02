#!/bin/bash
echo " ";
if [ -z "$1" ]; then
	#if there is any parameter like the Job Name, let's find the 
	#highest CPU-time and it will be reported with the Job Name.
	MCPUt="";
	theFile=" ";
	time1=0;
	time2=0;
	theFiles=`grep -l "Job Name" *`;
	arrayOfFiles=($theFiles);
	for nameFile in "${arrayOfFiles[@]}"
		#nameFile is the name of the file that we are looking for the cput
		do
			theCPUT=`grep -oh 'cput='..:..:.. $nameFile`;
			#we get an string like cput=00:00:00
			#so now we take off the "cput="
			IFS='cput=' read -a arrayWithTime <<< $theCPUT;
			#now we have something like 00:00:00
			#so now we take off the ":" and make it array
			IFS=':' read -a arrayOnlyTime <<< ${arrayWithTime[@]};
			#with an array we have the values like this 00 00 00
			#so we can make it a unique number to compare
			time1=$((10#${arrayOnlyTime[0]}*3600 + (10#${arrayOnlyTime[1]}*60) + (10#${arrayOnlyTime[2]})))
			#the 10# is to forced to based 10 becase I was having an error with the interpretation of the language
			# you can see more here https://stackoverflow.com/questions/24777597/value-too-great-for-base-error-token-is-08

			if [ $(($time1)) = $(($time2)) ]; then
				theFile=$theFile;
			else
				if [ $(($time1)) -gt $(($time2)) ]; then
			 		theFile="$nameFile";
					MCPUt=$(echo "${arrayWithTime[@]}" | tr -d '[[:space:]]')
					time2=$time1;
				fi
			fi
	done

	theJobName=`grep -oh 'Job Name:'.* $theFile`;
	IFS='Job Name: ' read -a arrayJob <<< $theJobName;
	JobName=$(echo "${arrayJob[@]}" | tr -d '[[:space:]]')
	echo "Maximun CPU time of $MCPUt for job $JobName"

else
#if there is a parameter, let's see if it is a rigth one
	echo '';
	MCPUt="";
	theFile=" ";
	time1=0;
	time2=0;
	theFiles=`grep "Job Name: $1" *`;
	theFiles=`grep -oh "^stdout.*.be"<<< $theFiles`;
	theFiles=`grep -oh "^stdout.*.be" <<< $theFiles`;
	arrayOfFiles=($theFiles);
	for nameFile in "${arrayOfFiles[@]}"
		do
		theCPUT=`grep -oh 'cput='..:..:.. $nameFile`;
		IFS='cput=' read -a arrayWithTime <<< $theCPUT;
		IFS=':' read -a arrayOnlyTime <<< ${arrayWithTime[@]};
		time1=$((10#${arrayOnlyTime[0]}*3600 + 10#${arrayOnlyTime[1]}*60 + 10#${arrayOnlyTime[2]}));
		if [ $(($time1)) = $(($time2)) ]; then
				theFile=$theFile;
		else
			if [ $(($time1)) -gt $(($time2)) ]; then
				theFile="$nameFile";
				MCPUt=$(echo "${arrayWithTime[@]}" | tr -d '[[:space:]]');
				time2=$time1;
			fi
		fi

		
	done
	echo "CPU time of $MCPUt for job $1"
fi
