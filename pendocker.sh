#!/bin/sh

# Menerima data form dari input POST
read -r LINK_GIT
read -r NAMA_DATABASE
read -r PORT_AKSES



PORT_BACKEND=$((PORT_AKSES + 1))
PORT_DATABASE=$((PORT_AKSES + 2))

echo $PORT_BACKEND
echo $PORT_DATABASE
# sekedar info
# PORT_AKSES adalaha port fronend
# PORT_BACKEND adalaha port backend
# PORT_DATABASE adalaha port database

# Mendapatkan file dari git
repo_url=$LINK_GIT
repo_name=$(basename $repo_url .git)

# Clone repositori dengan nama folder yang baru
clear
output=$(sudo git clone $repo_url $repo_name)
echo "$PORT_AKSES-$PORT_BACKEND-$PORT_DATABASE-$repo_name" >> list_port.txt
cd $repo_name
echo "Berhasil mengekstrak aplikasi dari git"


# buat dockerfile frontend
cd frontend
echo "FROM node:18.16.0" > dockerfile-frontend
echo "WORKDIR /app" >> dockerfile-frontend
echo "COPY package*.json ./" >> dockerfile-frontend
echo "RUN npm install" >> dockerfile-frontend
echo "COPY . ." >> dockerfile-frontend
echo "EXPOSE 3000" >> dockerfile-frontend
echo "CMD [\"npm\", \"start\"]" >> dockerfile-frontend
echo "Dockerfile frontend telah dibuat!"

# buat dockerfile backend
cd ../backend
echo "FROM node:18.16.0" > dockerfile-backend
echo "WORKDIR /app" >> dockerfile-backend
echo "COPY package*.json ./" >> dockerfile-backend
echo "RUN npm install -g nodemon" >> dockerfile-backend
echo "RUN npm install" >> dockerfile-backend
echo "COPY . ." >> dockerfile-backend
echo "EXPOSE 5000" >> dockerfile-backend
echo "CMD [\"nodemon\", \"index\"]" >> dockerfile-backend
echo "Dockerfile backend telah dibuat!"

# buat docker-compose.yml
cd ..
echo "version: '3.8'" > docker-compose.yml
echo "services:" >> docker-compose.yml
echo "  frontend-$PORT_AKSES:" >> docker-compose.yml
echo "    build:" >> docker-compose.yml
echo "      context: ./frontend" >> docker-compose.yml
echo "      dockerfile: dockerfile-frontend" >> docker-compose.yml
echo "    restart: on-failure:3" >> docker-compose.yml
echo "    expose:" >> docker-compose.yml
echo "      - 3000" >> docker-compose.yml
echo "    ports:" >> docker-compose.yml
echo "      - \"$PORT_AKSES:3000\"" >> docker-compose.yml
echo "    networks:" >> docker-compose.yml
echo "      - link-$PORT_AKSES-$PORT_BACKEND-$PORT_DATABASE" >> docker-compose.yml
echo "    depends_on:" >> docker-compose.yml
echo "      - backend-$PORT_BACKEND" >> docker-compose.yml
echo "      - db-$PORT_DATABASE" >> docker-compose.yml
echo "  backend-$PORT_BACKEND:" >> docker-compose.yml
echo "    build:" >> docker-compose.yml
echo "      context: ./backend" >> docker-compose.yml
echo "      dockerfile: dockerfile-backend" >> docker-compose.yml
echo "    restart: on-failure:3" >> docker-compose.yml
echo "    expose:" >> docker-compose.yml
echo "      - 5000" >> docker-compose.yml
echo "    ports:" >> docker-compose.yml
echo "      - \"$PORT_BACKEND:5000\"" >> docker-compose.yml
echo "    networks:" >> docker-compose.yml
echo "      - link-$PORT_AKSES-$PORT_BACKEND-$PORT_DATABASE" >> docker-compose.yml
echo "    depends_on:" >> docker-compose.yml
echo "      - db-$PORT_DATABASE" >> docker-compose.yml
echo "  db-$PORT_DATABASE:" >> docker-compose.yml
echo "    image: mariadb:10.6" >> docker-compose.yml
echo "    environment:" >> docker-compose.yml
echo "      - MYSQL_ROOT_PASSWORD=root" >> docker-compose.yml
echo "      - MYSQL_DATABASE=$NAMA_DATABASE" >> docker-compose.yml
echo "      - MYSQL_USER=$PORT_DATABASE" >> docker-compose.yml
echo "      - MYSQL_PASSWORD=$PORT_DATABASE" >> docker-compose.yml
echo "    restart: on-failure:3" >> docker-compose.yml
echo "    ports:" >> docker-compose.yml
echo "      - \"$PORT_DATABASE:3306\"" >> docker-compose.yml
echo "    volumes:" >> docker-compose.yml
echo "      - ./$NAMA_DATABASE.sql:/docker-entrypoint-initdb.d/$NAMA_DATABASE.sql" >> docker-compose.yml
echo "    networks:" >> docker-compose.yml
echo "      - link-$PORT_AKSES-$PORT_BACKEND-$PORT_DATABASE" >> docker-compose.yml
echo "networks:" >> docker-compose.yml
echo "  link-$PORT_AKSES-$PORT_BACKEND-$PORT_DATABASE:" >> docker-compose.yml


echo "Docker Compose telah dibuat!"

# echo "mengisntall hapi"
# npm install @hapi/hapi
echo "membuat image docker"
output=$(docker-compose up --build -d)
echo "berhasil membuat image"
echo "berhasil membuat docker"
echo "tunggu beberapat saat agar sistemnya berjalan dan anda bisa menggunakannya"
sleep 5
cd ..

