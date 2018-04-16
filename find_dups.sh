#! /bin/bash

read -n 1 -p "Are you sure  to start  (y/[a]): " AMSURE 
[ "$AMSURE" = "y" ] || exit 
echo "" 1>&2
if [[ $# = 0 ]]
then
    echo "No arguments"
else
    
    ##    default equals of arg
    DIR="."
    script_name="rm_dups.sh"
    mode="name"

    
    while [ $# -gt 0 ] 
    do      
	case $1 in
	    cont|name)	    
		mode=$1; shift  ;;
	    *.sh)	   
		script_name=$1; shift  ;;
	    */*|.)
		DIR=$1; shift  ;;
	esac  

    done

    echo '#! /bin/bash' > $script_name
    case "$mode" in
	"name")
	    
	    find $DIR -type f -printf "%f\n" | sort | uniq  -d |
		while  read line
		do
		    echo "####----------|${line}|-------" >> $script_name
		    find $DIR -type f  -name "*$line" -printf "#rm %p\n" |
			sed -e 's/ /\\ /g' -e 's/\\ / /1' >> $script_name	 
		done 
	    ;;
	"cont")
	    find $DIR -type f -printf "%p\n" |
		while read line
		do
		    md5sum  "${line}" >> hash_sum
		done
	    cat hash_sum |awk '{print $1}' | sort | uniq -d  |
		while read line
		do
		    echo "####----------|$line|-------" >> $script_name 
		    grep $line hash_sum | awk -F\ \ ./ '{print $2}' |  
			while read line2
			do			
			    echo "#rm /$line2"   | sed -e 's/ /\\ /g' -e 's/\\ / /1' >> $script_name
			done		
		done
	    ;;
    esac
fi 
