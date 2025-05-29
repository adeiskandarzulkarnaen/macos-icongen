#! /bin/bash
set -e  # Skrip akan berhenti jika ada error


print_images_in_folder() {
    local IMG_DIR="$1"

    # check folder
    if [ ! -d "$IMG_DIR" ]; then
        echo "❌ folder tidak tersedia!" >&2
        return 1
    fi


    shopt -s nullglob 
    images=("$IMG_DIR"/*.{png,jpg,jpeg})
    shopt -u nullglob 

    if [ "${#images[@]}" -eq 0 ]; then
        echo "❌ tidak ada file gambar (png, jpg, jpeg) di $IMG_DIR" >&2
        return 1
    fi

    # echo ${images[@]}
    printf "%s\n" "${images[@]}"
}


generate_icon() {
    local INPUT_FILE="$1"       # arg[1] -> file location
    local OUTPUT_NAME="$2"      # arg[2] -> icon name
    local ICONSET_DIR="${OUTPUT_NAME}.iconset"


    if [ ! -f "$INPUT_FILE" ]; then
        echo "❌ File '${INPUT_FILE}' tidak ditemukan!" >&2
        return 1
    fi


    if [ -z "$OUTPUT_NAME" ]; then
        echo "❌ Nama icon tidak boleh kosong!" >&2
        return 1
    fi

    mkdir -p "$ICONSET_DIR"                     # create dir
    local -a SIZES=(16 32 128 256 512)          # required sizes


    # Scaling process for each size
    for SIZE in "${SIZES[@]}"; do
        DOUBLE=$(( SIZE * 2 ))
        echo "🔧 Membuat icon ukuran ${SIZE}x${SIZE} dan ${DOUBLE}x${DOUBLE}..."

        sips -z "$SIZE" "$SIZE" "$INPUT_FILE" --out "$ICONSET_DIR/icon_${SIZE}x${SIZE}.png" > /dev/null
        
        if [ "$DOUBLE" -eq 512 ]; then 
            # Copy the original 1024x1024 file as a 512x512@2x icon
            cp "$INPUT_FILE" "$ICONSET_DIR/icon_512x512@2x.png"
        else
            sips -z "$DOUBLE" "$DOUBLE" "$INPUT_FILE" --out "$ICONSET_DIR/icon_${SIZE}x${SIZE}@2x.png" > /dev/null
        fi
    done


    # create .icns file
    echo "📦 Membuat file .icns"
    mkdir -p output
    iconutil -c icns "$ICONSET_DIR" -o "output/${OUTPUT_NAME}.icns"

    # delete iconset folder
    rm -R "$ICONSET_DIR"

    printf "✅ File ${OUTPUT_NAME}.icns berhasil dibuat!"
}



# ============================[ Main Program ]============================ #
RAW_ICON_DIR="./raw_icons"

# Simpan hasil fungsi ke variabel
if ! raw_img_list=$(print_images_in_folder "$RAW_ICON_DIR"); then
    echo "🚨 Terjadi kesalahan saat membaca gambar dari folder $RAW_ICON_DIR"
    exit 1
fi


# Menyimpan hasil print_images_in_folder ke array
image_array=()
while IFS= read -r line; do
    image_array+=("$line")
done <<< "$raw_img_list"

echo "📸 Pilih gambar untuk dibuat menjadi icon:"
select selected_image in "${image_array[@]}" "Keluar"; do
    case "$selected_image" in
        "Keluar")
            echo "👋 Keluar dari program."
            exit 0
            ;;
        "")
            echo "❌ Pilihan tidak valid. Coba lagi."
            ;;
        *)
            echo "🖼️  Gambar dipilih: $selected_image"
            read -p "Masukkan nama icon (tanpa ekstensi): " icon_name

            if [ -z "$icon_name" ]; then
                echo "❌ Nama icon tidak boleh kosong!"
                exit 1
            fi

            generate_icon "$selected_image" "$icon_name"
            exit 0
            ;;
    esac
done
