#!/bin/sh
# /root/drill.sh - Skrip Otomatisasi Uji Kebakaran Geofront (Soal 20)
# Penggunaan: sh /root/drill.sh [nama_node]

NODE="${1:-$(hostname)}"
RULES_FILE="/root/${NODE}.rules"
SCRIPT_FILE="/root/${NODE}.sh"

echo "=== MEMULAI UJI KEBAKARAN GEOFRONT PADA NODE: $NODE ==="

# 1. Simpan konfigurasi aktif
echo "[1] Menyimpan rule aktif ke $RULES_FILE..."
iptables-save > "$RULES_FILE"

# 2. Hancurkan konfigurasi iptables dan routing kustom
echo "[2] Menghapus semua rule iptables (filter & nat)..."
iptables -P INPUT ACCEPT
iptables -P FORWARD ACCEPT
iptables -P OUTPUT ACCEPT
iptables -F
iptables -X
iptables -t nat -F
iptables -t nat -X

# 3. Pemulihan Pertama
echo "[3] Melakukan pemulihan ke-1..."
iptables-restore < "$RULES_FILE"
if [ -f "$SCRIPT_FILE" ]; then
    sh "$SCRIPT_FILE"
fi

L_FILT_1=$(iptables -S | wc -l)
L_NAT_1=$(iptables -t nat -S | wc -l)
ROUTES_1=$(ip route | wc -l)
echo "    Hasil Restore 1: Filter=$L_FILT_1 baris, NAT=$L_NAT_1 baris, Routes=$ROUTES_1 entri"

# 4. Pemulihan Kedua berturut-turut
echo "[4] Melakukan pemulihan ke-2 berturut-turut..."
iptables-restore < "$RULES_FILE"
if [ -f "$SCRIPT_FILE" ]; then
    sh "$SCRIPT_FILE"
fi

L_FILT_2=$(iptables -S | wc -l)
L_NAT_2=$(iptables -t nat -S | wc -l)
ROUTES_2=$(ip route | wc -l)
echo "    Hasil Restore 2: Filter=$L_FILT_2 baris, NAT=$L_NAT_2 baris, Routes=$ROUTES_2 entri"

# 5. Verifikasi
echo "[5] Kesimpulan Pengujian:"
if [ "$L_FILT_1" -eq "$L_FILT_2" ] && [ "$L_NAT_1" -eq "$L_NAT_2" ] && [ "$ROUTES_1" -eq "$ROUTES_2" ]; then
    echo ">>> SUKSES: Jumlah baris iptables dan tabel rute TIDAK BERUBAH / TIDAK DOBEL! <<<"
else
    echo ">>> GAGAL: Terjadi perubahan jumlah rule atau rute setelah restore kedua! <<<"
fi
