#!/bin/bash

DEST="/tmp/arduino-ide"
if [ ! -d "$DEST" ]
then
	echo "Creating temporary directory"
	mkdir "$DEST"
	if [ $? -ne 0 ] || [ ! -d "$DEST" ]
	then
		echo "Error: error creating '$DEST'"
		exit 1
	fi
fi

URL="https://downloads.arduino.cc/arduino-ide/arduino-ide_2.0.3_Linux_64bit.zip"
FILENAME=$(basename "$URL" .zip)

if [ -f "$DEST/$FILENAME.zip" ]
then
	echo "Resuming download"
	curl --output "$DEST/$FILENAME.zip" --continue-at - "$URL"
else
	echo "Downloading"
	curl --output "$DEST/$FILENAME.zip" "$URL"
fi

if [ ! -f "$DEST/$FILENAME.zip" ]
then
	echo "Error: file '$DEST/$FILENAME.zip' does not exists"
	exit 1
fi

# -n: NO, -o: YES
OVERWRITE="-n"
echo "Uncompress"
sudo unzip $OVERWRITE "$DEST/$FILENAME.zip" -d "/opt"

if [ ! -d "/opt/${FILENAME}" ]
then
	echo "Error: directory '/opt/${FILENAME}' does not exists"
	exit 1
fi

if [ ! -h "/opt/arduino-ide" ]
then
	echo "Creating symbolic link"
	sudo ln -s "/opt/${FILENAME}" "/opt/arduino-ide"
	if [ $? -ne 0 ] || [ ! -h "/opt/arduino-ide" ]
	then
		echo "Error: creating symbolic link"
		exit 1
	fi
fi

echo "Creating menu entry"
DESKTOP="/usr/share/applications/arduino-ide.desktop"
sudo tee "$DESKTOP" > /dev/null <<EOF
[Desktop Entry]
Name=Arduino IDE
Exec=/opt/arduino-ide/arduino-ide %F
Icon=$(find /opt/arduino-ide/resources/app/lib/ -name '*.png' | head -n 1)
comment=Arduino IDE
comment[es]=Entorno de desarrollo de placas Arduino
Type=Application
Terminal=false
Encoding=UTF-8
Categories=Utility;TextEditor;Development;IDE;
Keywords=vscode;ide;esp32;arduino;
MimeType=text/plain;inode/directory;
EOF
if [ $? -ne 0 ] || [ ! -f "$DESKTOP" ]
then
	echo "Error: can't create desktop file '$DESKTOP'"
	exit 1
fi

echo "Removing temporary directory"
rm -Rf "$DEST"

