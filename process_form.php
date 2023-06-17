<?php
if ($_SERVER["REQUEST_METHOD"] == "POST") {
    // Menerima data form dari input POST
    $LINK_GIT = $_POST["LINK_GIT"];
    $NAMA_DATABASE = $_POST["NAMA_DATABASE"];
    $PORT_AKSES = $_POST["PORT_AKSES"];

    // Menjalankan shell script untuk memproses data
    $output = shell_exec("bash /home/richi/Desktop/meja kerja pa/7_aplikasi_full_desain/pendocker.sh '$LINK_GIT' '$NAMA_DATABASE' '$PORT_AKSES'");

    // Menampilkan hasil output dari shell script
    echo "<h1>Hasil Form</h1>";
    echo $output;
}
?>
