
# Imagen de docker: Central telefonica creada por Netlife usando Asterisk y Freepbx. V1.1 - ENERO 2018

# Esta imagen fue creada para correrla en una instancia EC2 de AWS usando docker y ECS

### PASOS PREVIOS:

#Para correr ersta imagen debes crear una instancia (linux) en EC2, instalar docker y recomendamos tambien instalar Amazon-cli para usae el registro ECS.
#para ver más: https://docs.aws.amazon.com/AmazonECR/latest/userguide/get-set-up-for-amazon-ecr.html

#Instalar tambien docker compose.

###CONTENIDO

La imagen incluye:

    Debian 8
    Apache2
    mysq
    php
    Asterisk 13
    FreePBX 13

### INSTALACION

Para correr la central:

La primera vez:

cd /home/
mkdir netlife-pbx
cd netlife-pbx
wget https://raw.githubusercontent.com/netlife-tel/PBX/master/docker-compose.yml

# Correr en segundo plano
docker-compose up -d

# Correr en primer plano
docker-compose up

###PASOS DESPUES DE LA INSTALACIÓN

En la consola de AWS, entrar a EC2, luego a security groups y verificar que el puerto 8082 este abierto para conexiones entrantes (Inbound TCP 8082)


Entrar a  http://<Dir-IP-publica>:8082 para entrar a la GUI de FreePBX


*Comandos para gestionar la central:

docker start freepbx

shutdown

docker stop freepbx

Remove

docker-compose down

O tambien: 

docker rm freepbx



#Dockerhub

Esta imagen esta disponible en dockerhub: docker pull netlife/pbx


Si quieres usar, reusar o contribuir a esta imagen sientete libre de hacerlo


 https://github.com/netlife-tel/PBX.git

