# Ustawienie zmiennej z wersją FRP
FRP_VERSION="frp_0.55.1"

# Wykrywanie systemu operacyjnego
OS="$(uname -s | tr '[:upper:]' '[:lower:]')"

# Wykrywanie architektury procesora
ARCH="$(uname -m)"
case $ARCH in
    x86_64) ARCH="amd64" ;;
    armv6l | armv7l) ARCH="arm" ;;
    aarch64) ARCH="arm64" ;;
    mips) ARCH="mips" ;;
    mips64) ARCH="mips64" ;;
    mipsel) ARCH="mipsle" ;;
    mips64el) ARCH="mips64le" ;;
    riscv64) ARCH="riscv64" ;;
    *) echo "Nieobsługiwana architektura: $ARCH" ; exit 1 ;;
esac

# Ustalenie nazwy pliku na podstawie systemu i architektury
FILENAME="${FRP_VERSION}_${OS}_${ARCH}.tar.gz"
if [ "$OS" = "windows_nt" ]; then
    OS="windows"
    FILENAME="${FRP_VERSION}_${OS}_${ARCH}.zip"
elif [ "$OS" != "linux" ] && [ "$OS" != "darwin" ] && [ "$OS" != "freebsd" ]; then
    echo "Nieobsługiwany system operacyjny: $OS"
    exit 2
fi

# Pobieranie i rozpakowywanie pliku
URL="https://github.com/fatedier/frp/releases/download/v0.55.1/$FILENAME"
echo "Pobieranie $URL..."
curl -L $URL -o $FILENAME
echo "Rozpakowywanie $FILENAME..."
if [ "${FILENAME: -4}" == ".zip" ]; then
    unzip $FILENAME
    ORIGINAL_FOLDER=$(unzip -l $FILENAME | sed -n 5p | awk '{print $4}' | cut -d'/' -f1)
else
    tar -xzf $FILENAME
    ORIGINAL_FOLDER=$(tar tzf $FILENAME | head -1 | cut -f1 -d"/")
fi

# Zmiana nazwy folderu na 'frp'
if [ -d "$ORIGINAL_FOLDER" ]; then
    mv "$ORIGINAL_FOLDER" "frp"
    echo "Folder zmieniony na 'frp'."
else
    echo "Nie można znaleźć folderu: $ORIGINAL_FOLDER"
    exit 3
fi

# Wczytanie konfiguracji add-onu Home Assistant
SERVER_ADDRESS=$(jq --raw-output '.server' /data/options.json)
AUTH_TOKEN=$(jq --raw-output '.token' /data/options.json)
SUBDOMAIN=$(jq --raw-output '.subdomain' /data/options.json)
PROXY_NAME=$(jq --raw-output '.proxy_name' /data/options.json)

# Ścieżka do pliku konfiguracyjnego FRP
FRP_CONFIG_PATH="./frpc.toml"

# Sprawdzenie istnienia pliku konfiguracyjnego FRP
if [ ! -f "$FRP_CONFIG_PATH" ]; then
    echo "Plik konfiguracyjny FRP nie istnieje: $FRP_CONFIG_PATH"
    exit 1
fi

# Aktualizacja konfiguracji FRP na podstawie danych z Home Assistant
sed -i "s|__arg_server_address__|$SERVER_ADDRESS|g" $FRP_CONFIG_PATH
sed -i "s|__arg_auth_token__|$AUTH_TOKEN|g" $FRP_CONFIG_PATH
sed -i "s|__arg_subdomain__|$SUBDOMAIN|g" $FRP_CONFIG_PATH
sed -i "s|__arg_proxy_name__|$PROXY_NAME|g" $FRP_CONFIG_PATH

# Uruchomienie klienta FRP
echo "Uruchamianie klienta FRP..."
./frp/frpc -c $FRP_CONFIG_PATH
