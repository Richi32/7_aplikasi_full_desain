#!/bin/sh

# -----------------------------------------------------------------------------------------------

# pilihan menu
# Fungsi untuk menampilkan menu
show_menu() {
    clear
    echo "=============================================="
    echo "           MY DOCKER APPLICATION              "
    echo "=============================================="
    sleep 1
    echo ""
    echo "Pilihan Menu:"
    sleep 0.1
    echo "1. Tambah Aplikasi"
    sleep 0.1
    echo "2. Lihat aplikasi yang berjalan"
    sleep 0.1
    echo "3. Lihat aplikasi baik berjalan maupun yang berhenti"
    sleep 0.1
    echo "4. jalankan aplikasi"
    sleep 0.1
    echo "5. Hentikan/stop aplikasi"
    sleep 0.1
    echo "6. Hapus aplikasi"
    sleep 0.1
    echo "9. Jika aplikasi bermasalah(restart)"
    sleep 0.1
    echo "0. Keluar"
}


tambah_aplikasi() {
# echo "masukkan nama aplikasi"
# read APP_NAME

# echo "maskkan teknologi/ framwork berserta versinya"
# echo "contoh: \"node:16.19\" atau \"node:14\""
# read TEKNOLOGI
clear
echo "=============================================="
echo "           MY DOCKER APPLICATION              "
echo "=============================================="
echo "*catatan: "
echo "untuk file di git berisikan file frontend, backend, dan hasil export database"
echo "nama folder git harus sesuai dengan 'nrp_nama aplikasi'"
echo "untuk sekarang kofigurasi masih menggunakna node 18.16.0 dan database:mariadb/mysql"
echo "untuk kedepannya akan ada update"
echo "=============================================="
echo "masukkan link git:"
read LINK_GIT

#nama database
clear
echo "=============================================="
echo "           MY DOCKER APPLICATION              "
echo "=============================================="
echo "masukkan nama database contoh= yukimaga_db" 
echo "nama_database=sesuai dengan hasil export(contoh jika nama database=yukimaga_db maka hasil export harus yukimaga_db.sql"
echo "=============================================="
read NAMA_DATABASE

# echo "masukkan port aplikasi asli"
# read PORT_ASLI
clear
echo "=============================================="
echo "           MY DOCKER APPLICATION              "
echo "=============================================="
echo "penggunaan port di kisaran 49152-65535"
echo "jika port masih kosong mulai gunakan dari port ini 49152 dulu"
echo "harap port di aplikasi yang ingin dihosting dirubah juga sesuai dengan port yang kosong di list"
echo "untuk konfigurasi port seperti berikut jika frontend (49152) maka backend (49153) dan database (49154) dan seterusnya +1 dan +2"
echo "berikut list port"
cat list_port.txt
echo "masukkan port yang digunakan untuk akses aplikasi"
echo "=============================================="
read PORT_AKSES

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
git clone $repo_url $repo_name
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
docker-compose up --build -d
echo "berhasil membuat image"
echo "berhasil membuat docker"
echo "tunggu beberapat saat agar sistemnya berjalan dan anda bisa menggunakannya"
sleep 5
cd ..
}


lihat_aplikasi() {
    docker container ls
    sleep 10
}


lihat_all_aplikasi() {
    docker container ls -a
    sleep 10
}

jalankan_aplikasi() {
    docker start $(docker ps -a -q)
    sleep 10
}

stop_aplikasi() {
    echo "sedang mengehentikan aplikasi"
    docker stop $(docker ps -a -q)
}


hapus_aplikasi() {
    echo "sedang menghapus aplikasi"
    docker rm $(docker ps -a -q)
}


restart_aplikasi() {
    echo "sedang merestart aplikasi"
    docker restart $(docker ps -a -q)
}

# Tampilkan menu dan terus ulang hingga pengguna memilih untuk keluar
while true; do
    show_menu

    read -p "Masukkan pilihan (angka): " choice

    case $choice in
        1)
            tambah_aplikasi
            ;;
        2)
            lihat_aplikasi
            ;;
        3)
            lihat_all_aplikasi
            ;;
        4)
            jalankan_aplikasi
            ;;            
        5)
            stop_aplikasi
            ;;
        6)
            hapus_aplikasi
            ;;
        9)
            restart_aplikasi
            ;;
        0)
            clear
            echo "Terima kasih, program berakhir."
            sleep 1
            clear
            exit
            ;;
        *)
            echo "Pilihan tidak valid. Silakan masukkan pilihan yang benar."
            ;;
    esac

    echo
done
