#!/data/data/com.termux/files/usr/bin/bash

clear
echo "🔥 INSTALLING PISO WIFI SYSTEM..."

pkg update -y
pkg upgrade -y

pkg install php git tmux termux-api termux-services -y

echo "📂 Setting storage..."
termux-setup-storage

sleep 3

# USE HOME INSTEAD OF SDCARD (NO PERMISSION ISSUE)
mkdir -p ~/htdocs

echo "📥 Cloning project..."
rm -rf ~/htdocs
git clone https://github.com/alpisowifi-ops/voucher_via_gcash.git ~/htdocs

cd ~/htdocs

# 🔐 GENERATE RANDOM API NAME + KEY
API_NAME=$(tr -dc a-z0-9 </dev/urandom | head -c 6)
SECRET_KEY=$(tr -dc a-z0-9 </dev/urandom | head -c 10)

mv api.php ${API_NAME}.php

# 🔐 PATCH API (ADD SECRET KEY CHECK)
sed -i "1i<?php if(!isset(\$_GET['key']) || \$_GET['key'] !== '$SECRET_KEY'){ die(json_encode(['status'=>'error','msg'=>'Unauthorized'])); } ?>" ${API_NAME}.php

echo "⚙️ Setting auto-start..."

mkdir -p ~/.termux/boot

cat > ~/.termux/boot/start.sh << EOF
#!/data/data/com.termux/files/usr/bin/sh

termux-wake-lock
cd ~/htdocs
tmux new-session -d "php -S 0.0.0.0:8080"
EOF

chmod +x ~/.termux/boot/start.sh

# 🚀 START SERVER NOW
tmux new-session -d "php -S 0.0.0.0:8080"

# GET IP (FIX NO IP COMMAND ERROR)
IP=$(ifconfig 2>/dev/null | grep -oE 'inet (192\.168\.[0-9]+\.[0-9]+)' | awk '{print $2}' | head -n1)

if [ -z "$IP" ]; then
IP="localhost"
fi

clear

echo "✅ INSTALL COMPLETE!"
echo ""
echo "🌐 OPEN:"
echo "👉 http://$IP:8080"
echo ""
echo "🔐 ADMIN:"
echo "👉 http://$IP:8080/admin.php"
echo "👉 Password: admin123"
echo ""

echo "📲 USE THIS CODE FOR MACRODROID 👇"
echo "===================================="
echo "URL:"
echo "http://$IP:8080/${API_NAME}.php?amount=10&key=$SECRET_KEY"
echo ""
echo "Method: GET"
echo "===================================="

echo ""
echo "⚡ SERVER RUNNING (BACKGROUND)"
echo "⚡ AUTO START ON REBOOT ENABLED"
echo ""
echo "⚠️ DO NOT SHARE API LINK!"
