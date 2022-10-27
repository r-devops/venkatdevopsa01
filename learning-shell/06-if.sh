declare -i a
a=11

if [ $a -gt 10 ]
then 
echo $a is greather than 10 
else 
echo $a is less than 10 
fi 

x="abc"

if [ $x == "abc" ]; then
  echo Yes both are equal
fi


file=/tmp/new

if [ -f $file ]; then
  echo File Exists
else
  echo File does not exist
fi