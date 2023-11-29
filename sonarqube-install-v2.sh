## Update Package Repository and Upgrade Packages¶
sudo apt update -y
sudo apt upgrade -y

## Add PostgresSQL repository
sudo sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list'
wget -qO- https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo tee /etc/apt/trusted.gpg.d/pgdg.asc &>/dev/null

## Install PostgreSQL
sudo apt update -y
sudo apt-get -y install postgresql postgresql-contrib
sudo systemctl enable postgresql
psql --version

## Create Database for Sonarqube

## Set password for postgres user (Password `postgres`)
sudo passwd postgres

## Change to the postgres user
su - postgres

## Create database user postgres
createuser sonar

## Switch to the PostGreSQL Database by running `psql`
psql

## Set password and grant privileges
ALTER USER sonar WITH ENCRYPTED password 'sonar';
CREATE DATABASE sonarqube OWNER sonar;
GRANT all privileges on DATABASE sonarqube to sonar;

## Exit the Database by running 
exit

## Exit Again back to normal or root user
exit

#Adoptium Java 17¶
## Switch to root user
sudo bash
wget -O - https://packages.adoptium.net/artifactory/api/gpg/key/public | tee /etc/apt/keyrings/adoptium.asc
echo "deb [signed-by=/etc/apt/keyrings/adoptium.asc] https://packages.adoptium.net/artifactory/deb $(awk -F= '/^VERSION_CODENAME/{print$2}' /etc/os-release) main" | tee /etc/apt/sources.list.d/adoptium.list

## Install Java 17¶
apt update -y
apt install temurin-17-jdk -y
update-alternatives --config java
/usr/bin/java --version

## Exit back to your normal user
exit 

#Linux Kernel Tuning¶
## Increase Limits¶
sudo vi /etc/security/limits.conf
```bash
sonarqube   -   nofile   65536
sonarqube   -   nproc    4096
```

##Increase Mapped Memory Regions
### Paste the below values at the bottom of the file
sudo vi /etc/sysctl.conf
```bash
vm.max_map_count = 262144
```

## Download, Extract and Install SonarQube
sudo wget https://binaries.sonarsource.com/Distribution/sonarqube/sonarqube-9.9.0.65466.zip
sudo apt install unzip -y
sudo unzip sonarqube-9.9.0.65466.zip -d /opt
sudo mv /opt/sonarqube-9.9.0.65466 /opt/sonarqube

## Create user and set permissions
sudo groupadd sonar
sudo useradd -c "user to run SonarQube" -d /opt/sonarqube -g sonar sonar
sudo chown sonar:sonar /opt/sonarqube -R

## Update Sonarqube properties with DB credentials
sudo vi /opt/sonarqube/conf/sonar.properties
```bash
sonar.jdbc.username=sonar
sonar.jdbc.password=sonar
sonar.jdbc.url=jdbc:postgresql://localhost:5432/sonarqube
```

## Create service for Sonarqube
sudo vi /etc/systemd/system/sonar.service
```bash
[Unit]
Description=SonarQube service
After=syslog.target network.target

[Service]
Type=forking

ExecStart=/opt/sonarqube/bin/linux-x86-64/sonar.sh start
ExecStop=/opt/sonarqube/bin/linux-x86-64/sonar.sh stop

User=sonar
Group=sonar
Restart=always

LimitNOFILE=65536
LimitNPROC=4096

[Install]
WantedBy=multi-user.target
```

## Start Sonarqube and Enable service
sudo systemctl start sonar
sudo systemctl enable sonar
sudo systemctl status sonar

## Watch log files and monitor for startup
sudo tail -f /opt/sonarqube/logs/sonar.log


## VM Instaructions
# Image: Ubuntu 22.04
# Instance type: 2CPU and 4 or 8+RAM
