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