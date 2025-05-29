#! /bin/bash

# =======================[ mendapatkan daftar file di dalam folder ]======================= #
folder="./raw_icons"

shopt -s nullglob                   # set null blob -> agar array bernilai kosong jika folder kosong
files=("$folder"/*.{png,jpg,jpeg})

for file in "${files[@]}"; do
    echo "${file}";
done
shopt -u nullglob                   # unset null blob



