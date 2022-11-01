
echo "Mongo script to install"
COMPONENT=mongodb
LOG=/tmp/${COMPONENT}
source ./common.sh

echo "Configure YUM Repos"
curl -s -o /etc/yum.repos.d/mongodb.repo https://raw.githubusercontent.com/roboshop-devops-project/mongodb/main/mongo.repo &>>${LOG}
StatusCheck $?

echo "Install MongoDB"
yum install -y -nogpgcheck mongodb-org &>>${LOG}
StatusCheck $?

echo "Configure MongoDB Service"
sed -i -e 's/127.0.0.1/0.0.0.0/' /etc/mongod.conf
StatusCheck $?

echo "Start MonogDB"
systemctl enable mongod &>>${LOG}  && systemctl restart mongod &>>${LOG}
StatusCheck $?


echo "Download Schema"
curl -s -L -o /tmp/mongodb.zip "https://github.com/roboshop-devops-project/mongodb/archive/main.zip" &>>${LOG}
StatusCheck $?

echo "Load Schema"
cd /tmp && unzip -o mongodb.zip &>>${LOG}  && cd mongodb-main && mongo < catalogue.js &>>${LOG}  && mongo < users.js &>>${LOG}
StatusCheck $?