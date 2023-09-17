#!/bin/bash

# must set myargs = ( '' '' '' ) before sourcing this module

# each arg is defined like 'shorthand|name|help|runthistext -t "$val"'
# arguments value is accessed via $val

# positionals are defined by an empty shorthand

# all positionals (defined or not) are exported to POSARGS array in recieved order
# all defined positionals become required components

# executes argument commands
# exports POSARGS (positionals array)

args=( "$@" )

function showhelp() {
	echo "${script_example:-${script_name:-$0}}"
	echo "-----------------------------------"
	echo "${script_description:-"Define a Description"}"
	echo "-----------------------------------"
	for x in $(seq 1 ${#myargs[@]});do
			argument="${myargs[$((x-1))]}"
			argshort="$(echo "$argument"|cut -d '|' -f 1)"
			argname="$(echo "$argument"|cut -d '|' -f 2)"
			arghelp="$(echo "$argument"|cut -d '|' -f 3)"
						d='-'
			argtype="$(
					if [ ! "$argshort" ];then
						echo "positional"
					elif [[ "$(echo "$argument"|cut -d '|' -f 4-)" =~ '$val' ]];then
						echo "value"
					else
						echo "toggle"
					fi
				)"
			[ "$argtype" == 'positional' ] && unset d
			echo "${d}$argshort ${d}${d}$argname	$argtype	$arghelp"
	done|sort -h
	exit
}

x=0
POSARGS=( )
while [ $x -lt ${#args[@]} ];do
	if ( echo "${args[$x]}"|grep ^- >/dev/null );then
		argval=1
		arg="${args[$x]//-/}"
		val="${args[$((x+1))]}"
		( [ "$arg" == "h" ] || [ "$arg" == "help" ] ) && showhelp

		unset found
		for i in $(seq 1 ${#myargs[@]});do
			argument="${myargs[$((i-1))]}"
			argshort="$(echo "$argument"|cut -d '|' -f 1)"
			argname="$(echo "$argument"|cut -d '|' -f 2)"
			arghelp="$(echo "$argument"|cut -d '|' -f 3)"
			argcmd="$(echo "$argument"|cut -d '|' -f 4-)"

			if ( [ "$arg" == "$argshort" ] || [ "$arg" == "$argname" ] );then
				found=yes
				source <(echo "${argcmd}") || exit $?
			fi
		done
		[ ! "$found" ] && echo "Unknown Argument: $arg" && exit 1
		#this is an argument name
	elif [ "$argval" ];then
		#this is an arguments value
		unset argval
	else
		#this is a positional
		#add to positionals array
		POSARGS+=(${args[$x]})
	fi
	x=$((x+1))
done


p=0
# check our defined arguments
# handle defined positionals
for i in $(seq 1 ${#myargs[@]});do
	argument="${myargs[$((i-1))]}"
	argshort="$(echo "$argument"|cut -d '|' -f 1)"
	if [ ! "$argshort" ];then
		argname="$(echo "$argument"|cut -d '|' -f 2)"
		arghelp="$(echo "$argument"|cut -d '|' -f 3)"
		argcmd="$(echo "$argument"|cut -d '|' -f 4-)"
		val="${POSARGS[$p]}"
		[ ! "$val" ] && echo "Undefined Positional: $argname" && exit 1
		source <(echo "${argcmd}") || exit $?
		p=$((p+1))
	fi
done



