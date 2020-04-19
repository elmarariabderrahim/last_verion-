
#!/bin/bash
export username=$1
export password=$2
str=$(docker port test-mysql)
IFS=':'
read -ra ADDR <<< "$str"
docker_mysql_port=${ADDR[1]}
echo ${docker_mysql_port}
#acces to docker image 'test-mysql'
 

path=$(pwd)

# import database schema 
input="$path/output.sql"
var=""
while IFS= read -r line
do
var="${var}$line"
done < "$input"
mysql -P $docker_mysql_port --protocol=tcp -u$username -p$password -Bse "$var"
