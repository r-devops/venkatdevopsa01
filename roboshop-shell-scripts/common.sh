ID=$(id -u)

if [ $ID -ne 0 ]; then 
   echo you are not running as root, So it will not work 
   exit 1
fi 


StatusCheck() { 
    if [ $1 -eq 0 ]; then 
    echo -e status  = "\e[32mSUCCESS\e[0m"
    else 
    echo -e status  = "\e[31mFAILED\e[0m"
    exit 1
    fi 

}


APP_PREREQ() {
    id roboshop &>>${LOG_FILE}

    if [ $? -ne 0 ]; then 
    echo " Add Roboshop user"
    useradd roboshop &>>${LOG_FILE}
    StatusCheck $?
    fi 
    
    yum install -y --nogpgcheck unzip 

    echo "Download ${COMPONENT} Application code "
    curl -s -L -o /tmp/${COMPONENT}.zip "https://github.com/roboshop-devops-project/${COMPONENT}/archive/main.zip" &>>${LOG_FILE}
    StatusCheck $?

    echo " Clean old content - making the script comptable for rerun/re-install"
    cd /home/roboshop && rm -rf ${COMPONENT} &>>${LOG_FILE}
    StatusCheck $?

    echo " extracting the component"
    unzip /tmp/${COMPONENT}.zip &>>${LOG_FILE}
    StatusCheck $?

    mv ${COMPONENT}-main ${COMPONENT} && cd /home/roboshop/${COMPONENT}

}

SYSTEMD_SETUP() { 

    echo "Update SystemD Service File"
    sed -i -e 's/REDIS_ENDPOINT/redis.roboshop.internal/' -e 's/MONGO_ENDPOINT/mongodb.roboshop.internal/' -e 's/CATALOGUE_ENDPOINT/catalogue.roboshop.internal/' -e 's/MONGO_DNSNAME/mongodb.roboshop.internal/' -e 's/CARTENDPOINT/cart.roboshop.internal/' -e 's/DBHOST/mysql.roboshop.internal/' -e 's/CARTHOST/cart.roboshop.internal/' -e 's/USERHOST/user.roboshop.internal/' -e  's/AMQPHOST/rabbitmq.roboshop.internal/' /home/roboshop/${COMPONENT}/systemd.service
    StatusCheck $?

    echo " setting up the service"
    mv /home/roboshop/${COMPONENT}/systemd.service /etc/systemd/system/${COMPONENT}.service &>>${LOG_FILE}
    StatusCheck $?

    systemctl daemon-reload &>>${LOG_FILE}
    systemctl enable ${COMPONENT}  &>>${LOG_FILE}
    StatusCheck $?

    echo " Starting the ${COMPONENT} service"
    systemctl start ${COMPONENT}  &>>${LOG_FILE}
    StatusCheck $?

}

NODEJS() {
    
    echo "Setup Nodejs on VM"
    curl -sL https://rpm.nodesource.com/setup_lts.x | bash  &>>${LOG_FILE}
    StatusCheck $?

    echo "Installing NodeJS"
    yum install nodejs --nogpgcheck -y &>>${LOG_FILE}
    StatusCheck $?

    APP_PREREQ

    echo " Install NodeJs dependencies "
    npm install &>>${LOG_FILE}
    StatusCheck $?

    SYSTEMD_SETUP
}

JAVA() {

    echo "Install Maven "
    yum install maven --nogpgcheck -y &>>${LOG_FILE}
    StatusCheck $?

    APP_PREREQ

    echo " Make mvn package"     
    mvn clean package &>>${LOG_FILE}
    mv target/${COMPONENT}-1.0.jar ${COMPONENT}.jar &>>${LOG_FILE}
    StatusCheck $?

    SYSTEMD_SETUP

} 



PYTHON() {

    echo "Install Python 3"
    yum install python36 gcc python3-devel -y --nogpgcheck &>>${LOG_FILE}
    StatusCheck $?

    APP_PREREQ

    cd /home/roboshop/${COMPONENT}

    echo " Install dependencies " 
    pip3 install -r requirements.txt &>>${LOG_FILE}
    StatusCheck $?
 
    APP_UID=$(id -u roboshop)
    APP_GID=$(id -g roboshop)

    echo "Update Payment Configuration file"
    sed -i -e "/uid/ c uid = ${APP_UID}" -e "/gid/ c gid = ${APP_GID}" /home/roboshop/${COMPONENT}/${COMPONENT}.ini &>>${LOG_FILE}    

    SYSTEMD_SETUP

}


GOLANG() {

    yum install golang -y --nogpgcheck &>>${LOG_FILE}
    StatusCheck $?

    APP_PREREQ

    go mod init dispatch &>>${LOG_FILE}
    go get &>>${LOG_FILE}
    go build &>>${LOG_FILE}  
    
    SYSTEMD_SETUP


}