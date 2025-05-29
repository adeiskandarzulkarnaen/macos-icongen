#! /bin/bash
set -e

generate_icon() {
    local image="$1"        # arg[1] -> image file location
    local icon_name="$2"    # arg[2] -> output icon name
    local iconset_dir="${icon_name}.iconset"


    if [ ! -f "$image" ]; then
        echo "❌ File '${image}' tidak ditemukan!" >&2
        return 1
    fi

    if [ -z "$icon_name" ]; then
        echo "❌ Nama icon tidak boleh kosong!" >&2
        return 1
    fi

    mkdir -p "$iconset_dir"                     # create dir
    local -a sizes=(16 32 128 256 512)          # required sizes


    # Scaling process for each size
    for size in "${sizes[@]}"; do
        double=$(( size * 2 ))
        echo "🔧 Membuat icon ukuran ${size}x${size} dan ${double}x${double}..."

        sips -z "$size" "$size" "$image" --out "$iconset_dir/icon_${size}x${size}.png" > /dev/null
        
        if [ "$double" -eq 512 ]; then 
            # Copy the original 1024x1024 file as a 512x512@2x icon
            cp "$image" "$iconset_dir/icon_512x512@2x.png"
        else
            sips -z "$double" "$double" "$image" --out "$iconset_dir/icon_${size}x${size}@2x.png" > /dev/null
        fi
    done


    # create .icns file
    echo "📦 Membuat file .icns: output/${icon_name}.icns"

    mkdir -p ./output
    iconutil -c icns "$iconset_dir" -o "output/${icon_name}.icns"

    # delete iconset folder
    rm -R "$iconset_dir"

    printf "✅ File ${icon_name}.icns berhasil dibuat!\n"
}



# ======================================================================== #
# ============================[ Main Program ]============================ #
# ======================================================================== #


raw_icon_dir="./raw_icons"

# check folder
if [ ! -d "$raw_icon_dir" ]; then
    echo "❌ folder tidak tersedia!" >&2
    exit 1
fi


shopt -s nullglob 
images=("$raw_icon_dir"/*.{png,jpg,jpeg})
shopt -u nullglob 

if [ "${#images[@]}" -eq 0 ]; then
    echo "❌ tidak ada file gambar (png, jpg, jpeg) di $raw_icon_dir" >&2
    exit 1
fi


echo "📸 Pilih gambar untuk dibuat menjadi icon:"
IFS=$'\n' 
select image in "${images[@]}" "exit"; do
    case "$image" in
    "exit")
        echo "👋 Keluar dari program."
        exit 0
        ;;
    "")
        echo "❌ Pilihan tidak valid. Coba lagi."
        ;;
    *)
        echo "📸 Gambar dipilih: $image"
        read -p "🔖 Masukkan nama icon (tanpa ekstensi): " icon_name

        if [ -z "$icon_name" ]; then
            echo "❌ icon name tidak boleh kosong!" >&2
            exit 1
        fi

        generate_icon "$image" "$icon_name"
        exit 0
        ;;
    esac
done
