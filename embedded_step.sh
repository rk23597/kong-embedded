sudo yum update -y
sudo yum install wget -y
sudo yum install perl -y


# install the kong
curl -Lo kong-enterprise-edition-3.1.1.3.rpm $( rpm --eval "https://download.konghq.com/gateway-3.x-rhel-%{rhel}/Packages/k/kong-enterprise-edition-3.1.1.3.rhel%{rhel}.amd64.rpm")

sudo yum install kong-enterprise-edition-3.1.1.3.rpm -y


# postgres installation
# Install the repository RPM:
sudo dnf install -y https://download.postgresql.org/pub/repos/yum/reporpms/EL-8-x86_64/pgdg-redhat-repo-latest.noarch.rpm
sudo dnf -qy module disable postgresql
sudo dnf install -y postgresql15-server
sudo /usr/pgsql-15/bin/postgresql-15-setup initdb
sudo systemctl enable postgresql-15
sudo systemctl start postgresql-15

sudo -i -u postgres

psql

CREATE USER kong; CREATE DATABASE kong OWNER kong; ALTER USER kong WITH password 'password';

exit
exit

#Save a copy of the default Kong conf file that ships with the installation before making modifications: 

sudo cp /etc/kong/kong.conf.default  /etc/kong/kong.conf 


#Update the following variables with your environment specific values: 
#database = postgres  
sudo sed -i "/#database = postgres/s/^#//g"  /etc/kong/kong.conf     
#pg_host = <Kong-Enterprise-VM-IP> 
sudo sed -i "/#pg_host = 127.0.0.1/s/^#//g" /etc/kong/kong.conf
#pg_port = 5432         
sudo sed -i "/#pg_port = 5432/s/^#//g" /etc/kong/kong.conf         
#pg_timeout = 5000               
sudo sed -i "/#pg_timeout = 5000/s/^#//g" /etc/kong/kong.conf    
#pg_user = kong  
sudo sed -i "/#pg_user = kong/s/^#//g" /etc/kong/kong.conf                
#pg_password = password  
sudo sed -i "s/#pg_password = /pg_password = password/g"  /etc/kong/kong.conf                   
#pg_database = kong   
sudo sed -i "/#pg_database = kong/s/^#//g" /etc/kong/kong.conf            
#admin_listen = 0.0.0.0:8001, 0.0.0.0:8444 ssl 
sudo sed -i "s/#admin_listen = 127.0.0.1:8001 reuseport backlog=16384, 127.0.0.1:8444/admin_listen = 0.0.0.0:8001 reuseport backlog=16384, 0.0.0.0:8444/g" /etc/kong/kong.conf
# The KONG_PASSWORD environment variable needs to be exported before running the database migration and bootstrap processes. The password defined in this variable will be used to log in to the Kong Enterprise console once it is set up: 


sudo su - 

export KONG_PASSWORD=password 

kong migrations bootstrap -c /etc/kong/kong.conf -vv 

kong start -c /etc/kong/kong.conf 

systemctl enable  kong
kong stop
systemctl restart  kong
systemctl status  kong


#Run a test against the local service to make sure Kong is up and running: 

curl -i -X GET --url http://localhost:8001/staus
curl -i -X GET --url http://localhost:8002
curl -i -X GET --url http://localhost:8000
