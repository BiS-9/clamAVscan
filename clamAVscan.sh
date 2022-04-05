#!/usr/bin/env bash
#			 ___  _
#			| . ><_> ||_
#			| . \| |<_-<
#			|___/|_|/__/
#				 	 ||
#
#---------------------------------------------------------------------------------
# Script     : clamAVscan.sh
# Description: Scan virus from Thunar
# Version    : 0.1
# Author     : Bi$ - https://github.com/BiS-9
# Date       : 2022-04-03
# License    : GNU/GPL v3.0
#---------------------------------------------------------------------------------
# Use        : ./clamAVscan.sh or ./PATH/clamAVscan.sh
#---------------------------------------------------------------------------------

set -o errexit      # The script ends if a command fails
set -o nounset      # The script ends if it uses an undeclared variable
# set -o pipefail     # The script ends if a command fails in a pipe
# set -o xtrace     # If you want to debug
#---------------------------------------------------------------------------------

TITLE="ClamAV Scan"
SCANUSER=$(whoami)
LOGDATE=$(date +"%Y-%m-%d %T")
LOGDATEFNAME=$(date +"%Y%m%d.%H%M%S")
LOGFILE="/tmp/clamavscan-$SCANUSER-$LOGDATEFNAME.log"
REPORTE="\n------- REPORTE GUARDADO EN: -------\n"
SCANDATA="\n-------- DATO/S ESCANEADO/S: -------\n"

zenity --notification --window-icon=clamav --text "Empezando escaneo!"

{
  echo "ClamAV Scan Log $LOGDATE" > "$LOGFILE"
  echo -e "$REPORTE"
  echo "$LOGFILE"
  echo -e "$SCANDATA"
} >> "$LOGFILE"

chmod 600 "$LOGFILE"

clamscan -r "$1" | tee >(zenity --progress --pulsate --title "clamAV Scan" --text "Escaneando..." --auto-kill --auto-close) >> "$LOGFILE"

WHAT=$(awk '/^Infected/ {print $NF}' "$LOGFILE")

if [[ $WHAT -eq 0 ]]
then
	zenity --notification --window-icon=clamav --text "Sin virus!"
else
	zenity --title "$TITLE $LOGDATE" --error --width 400 --text="Atención, virus encontrado/s!"
fi

zenity --title "$TITLE $LOGDATE" --text-info --width 500 --height 400 --filename="$LOGFILE"

case $? in
  0)
    zenity --notification --window-icon=clamav --text "Terminado!";;
  1)
    xdg-open "$LOGFILE";;
  255)
    zenity --notification --window-icon=clamav --text "Cerrando!";;
esac
