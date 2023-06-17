function processForm() {
    var form = document.getElementById("myForm");
    var formData = new FormData(form);
    var xhr = new XMLHttpRequest();

    xhr.open("POST", "process_form.php", true);
    xhr.onload = function () {
        if (xhr.status === 200) {
            document.getElementById("result").innerHTML = xhr.responseText;
        }
    };
    xhr.send(formData);
}

