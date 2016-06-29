#!/bin/bash
# UNISTD_64= # ex: /usr/include/asm/unistd_64.h

register=(rax rdi rsi rdx r10 r8 r9)

syscall_name_clean(){
	var="$1"
	[ "${var::3}" == "rt_" ] && var="${var:3:${#var}}"
	echo "${var%*_old}"
}

print_table_line(){
	args=("$@")

	echo -n "+"
	for((i=0;i<${#args[@]};i++));do
		for((j=0;j<$((${#args[i]}+2));j++));do
			echo -n '-'
		done
		echo -n +
	done
}

create_table(){
	fp="$1"

	f=()

	index=0

	for((i=0;i<${#fp};i++));do
		char="${fp:i:1}"

		if [ "${char}" == " " ] && [ -z "$start_word" ];then
			continue
		elif [[ "${char}" =~ \(|, ]];then
			((index++))
			start_word=''
			continue
		elif [[ "${char}" == ")" ]];then
			break;
		else
			start_word=1
			f[${index}]="${f[index]}${char}"
		fi
	done

	start_word=''
	line_len=0

	[ "${f[1]}" == "void" ] && unset f[1]

	for((i=0;i<${#f[@]};i++));do
		line_len=$((line_len+${#f[i]}))
	done

	line_len=$((2*${#f[@]} + 1*${#f[@]} + 1 + $line_len))

	print_table_line "${f[@]}"

	echo
	echo  -n "|"
	for((i=0;i<${#f[@]};i++));do
		echo -n " ${register[i]} "
		for((j=0;j<$((${#f[i]}-${#register[i]}));j++));do
			echo -n ' '
		done
		echo -n '|'
	done

	echo
	print_table_line "${f[@]}"

	echo
	echo  -n "|"
	for((i=0;i<${#f[@]};i++));do
		echo -n " ${f[i]} |"
	done

	echo
	print_table_line "${f[@]}"

	echo
	echo

}

check_unistd64(){
	if [ -z "$UNISTD_64" ];then
		echo "searching unistd_64.h ..."
		export UNISTD_64=$(find /usr/include -type f -name "unistd_64.h" 2> /dev/null)

		if [ $? != "0" ];then
			echo "unistd_64.h not found"
			return 1
		else
			echo "found: $UNISTD_64"
		fi
	else
		if [ ! -f "$UNISTD_64" ];then
			echo "File $UNISTD_64 doens't exist"
			return 1
		fi
	fi

	return 0
}


syscall64ref(){

	syscalls=("$@")

	for i in "${syscalls[@]}";do

	if [[ "$i" =~ ^[0-9]+$ ]];then
		regex="__NR_(.+)\ (${i})\$"
	else
		regex="__NR_(${i})\ ([0-9]+)\$"
	fi

	OLD_IFS="${IFS}"
	IFS=''

	while read line;do
		if [[ "$line" =~ $regex ]];then
			syscall_name="${BASH_REMATCH[1]}"
			syscall_number="${BASH_REMATCH[2]}"

			echo "syscall_number -> ${syscall_number} | syscall_name -> ${syscall_name}";
			echo

			while read man_line;do

				if [[ "$man_line" == "SYNOPSIS" ]];then
					start_match=1;
					continue;
				fi

				if [[ "$rest_of_function" == 1 ]];then
					echo "${man_line}"
					function_prototype="${function_prototype}${man_line}"
					if [[ "${man_line}" =~ \) ]];then
						echo
						create_table "${function_prototype}"
						break
					else
						continue
					fi
				fi


				if [[ "$start_match" == 1 ]];then
					man_line="${man_line///\**\*\//}" # remove comments

					if [[ "$man_line" =~ ^[^\ ] ]];then # detect end of SYNOPSIS
						break;
					elif [[ "$man_line" =~ Unimplemented\ system\ calls ]];then
						echo "${man_line}"
						echo
						break
					elif [[ -z "$man_line" ]] || [[ "$man_line" =~ : ]];then
						continue
					elif [[ "$man_line" =~ \#include ]];then
						echo "$man_line"
					elif [[ "$man_line" =~ \ _?\*?"${syscall_name}"\( ]];then
						echo
						echo "${man_line}"
						function_prototype="${man_line}"
						if [[ ! "${man_line}" =~ \) ]];then
							rest_of_function=1
						else
							echo
							create_table "${function_prototype}"
							break;
						fi
					fi


				fi

			done < <(man 2 "${syscall_name}")

		start_match=0
		rest_of_function=0
		function_prototype=""

		fi
	done < "$UNISTD_64"

	done

	IFS="${OLD_IFS}"

}


if [[ "$0" != "bash" ]]
then
	if [[ $# == 0 ]];then
		echo "syscallref64 [syscall_name|syscall_number] ..."
		exit
	fi

	check_unistd64
	[[ "$?" == 1 ]] && exit

	syscall64ref "$@"

else
	check_unistd64
fi
