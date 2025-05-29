#! /bin/bash

read -p "📸 Masukan Lokasi ImageFile : $image" IMAGE_FILE
read -p "🔖 Masukkan nama icon (tanpa ekstensi): " ICON_NAME

ICONSET_DIR="${ICON_NAME}.iconset"
OUTPUT_DIR="./output"


if [ ! -f "$IMAGE_FILE" ]; then
    echo "❌ File '${IMAGE_FILE}' tidak ditemukan!"
    exit 1
fi

if [ -z "$ICON_NAME" ]; then
    echo "❌ Nama icon tidak boleh kosong!"
    exit 1
fi

mkdir -p "$ICONSET_DIR"                     # create dir
declare -a SIZES=(16 32 128 256 512)        # required sizes


# Scaling process for each size
for SIZE in "${SIZES[@]}"; do
    DOUBLE=$(( SIZE * 2 ))
    echo "🔧 Membuat icon ukuran ${SIZE}x${SIZE} dan ${DOUBLE}x${DOUBLE}..."

    sips -z "$SIZE" "$SIZE" "$IMAGE_FILE" --out "$ICONSET_DIR/icon_${SIZE}x${SIZE}.png" > /dev/null
    
    if [ "$DOUBLE" -eq 512 ]; then 
        # Copy the original 1024x1024 file as a 512x512@2x icon
        cp "$IMAGE_FILE" "$ICONSET_DIR/icon_512x512@2x.png"
    else
        sips -z "$DOUBLE" "$DOUBLE" "$IMAGE_FILE" --out "$ICONSET_DIR/icon_${SIZE}x${SIZE}@2x.png" > /dev/null
    fi
done


# create .icns file
echo "📦 Membuat file .icns: output/${ICON_NAME}.icns"

mkdir -p "$OUTPUT_DIR"
iconutil -c icns "$ICONSET_DIR" -o "$OUTPUT_DIR/${ICON_NAME}.icns"

# delete iconset folder
rm -R "$ICONSET_DIR"

printf "✅ File ${icon_name}.icns berhasil dibuat!\n"