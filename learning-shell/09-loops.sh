#for loop

for fruit in apple banana orange ; do
  echo Fruit Name = $fruit
  sleep 10
done

#while loop 

a=10
while [ $a -gt 5 ]; do

echo $a
a=$((a-1))
sleep 2
done