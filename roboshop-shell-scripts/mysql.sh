LOG_FILE=/tmp/mysql
source common.sh

if [ -z "${ROBOSHOP_MYSQL_PASSWORD}" ]; then
  echo -e "\e[31m ROBOSHOP_MYSQL_PASSWORD env variable is needed\e[0m"
  exit 1
fi

echo "Setting Up MySQL Repo"
curl -s -L -o /etc/yum.repos.d/mysql.repo https://raw.githubusercontent.com/roboshop-devops-project/mysql/main/mysql.repo &>>$LOG_FILE
StatusCheck $?

echo "Disable MySQL Default Module to Enable 5.7 MySQL"
dnf module disable mysql -y &>>$LOG_FILE
StatusCheck $?

echo "Install MySQL"
yum install mysql-community-server -y &>>$LOG_FILE
StatusCheck $?


echo "Start MySQL Service"
systemctl enable mysqld &>>$LOG_FILE
systemctl restart mysqld &>>$LOG_FILE
StatusCheck $?


DEFAULT_PASSWORD=$(grep 'A temporary password' /var/log/mysqld.log | awk '{print $NF}')

echo "SET PASSWORD FOR 'root'@'localhost' = PASSWORD('${ROBOSHOP_MYSQL_PASSWORD}');
FLUSH PRIVILEGES;" >/tmp/root-pass.sql

echo "show databases;" |mysql -uroot -p${ROBOSHOP_MYSQL_PASSWORD} &>>$LOG_FILE
if [ $? -ne 0 ]; then
  echo "Change the default root password"
  mysql --connect-expired-password -uroot -p"${DEFAULT_PASSWORD}" </tmp/root-pass.sql &>>$LOG_FILE
  StatusCheck $?
fi

echo 'show plugins'| mysql -uroot -p${ROBOSHOP_MYSQL_PASSWORD} 2>/dev/null | grep validate_password &>>$LOG_FILE
if [ $? -eq 0 ]; then
  echo "Uninstall Password Validation Plugin"
  echo "uninstall plugin validate_password;" | mysql -uroot -p${ROBOSHOP_MYSQL_PASSWORD} &>>$LOG_FILE
  StatusCheck $?
fi

echo "Download Schema"
curl -s -L -o /tmp/mysql.zip "https://github.com/roboshop-devops-project/mysql/archive/main.zip" &>>$LOG_FILE
StatusCheck $?

echo "Extract Schema"
cd /tmp
unzip -o mysql.zip &>>$LOG_FILE
StatusCheck $?

echo "Load Schema"
cd mysql-main
mysql -u root -p${ROBOSHOP_MYSQL_PASSWORD} <shipping.sql &>>$LOG_FILE
StatusCheck $?
