#!/bin/bash

# CALL VARIABLES

BLACK='\033[0;30m'
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[0;37m'
NC='\033[0m' # No Color

log_info() { echo -e "${CYAN}[ INFO ]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[ WARN ]${NC} $1"; }
log_crit() { echo -e "${RED}[ CRIT ]${NC} $1"; }
log_succ() { echo -e "${GREEN}[ DONE ]${NC} $1"; }

echo -e "${PURPLE}
  __  __  _____ 
 |  \/  || ____|
 | |\/| ||___ \ 
 | |  | | ___) |
 |_|  |_||____/  v1.8 // CLEAR WINNER PROTOCOL
${NC}"

SOURCE_URL="$1"
TYPE="$2"
FINAL_DIR="$3"
lineFour="$4"
lineFive="$5"
lineSix="$6"
CHECKCOUNT=""
openDirAfter=0

# CONFIG lOCATION

# will ask if you want to double-check input
# input values below are "0"-false or "1"-true
comformationPrompt=0

# set default output format | empty to write in cmd
audioFormat=""

# directory where your reCoverArt is located
reCoverArtLocation="$HOME/.local/bin/reCoverArt"

# directory where addURLTag is located
# exanple dir: "/usr/bin/addURLTag"
addURLTagLocation="$HOME/.local/bin/addURLTag"

# directory where you want to put the final created folder
# example dir: "/home/user/Music/"
getUser=$(whoami)
dirLocation="/home/$getUser/Music/"

# echo "please administrate us!"
# sudo -v
# echo "thanks for administring us!"

if [[ ":$PATH:" != *":$HOME/.local/bin:"* ]]; then
    echo "------------------------------"
    echo
    echo "WARN -- '$HOME/.local/bin' is not in your \$PATH var."
    echo "Add this specifically to your shell configuration (~/.bashrc, ~/.zshrc, etc.):"
    echo
    echo "this is the best place to put custom scripts and keep em neat!"
    echo
    echo 'export PATH="$HOME/.local/bin:$PATH"'
    echo
    echo "short explanation: this folder works right along side your /usr/bin folder and"
    echo "by adding this path to your (~/.bashrc, ~/.zshrc, etc.), this just keeps \"original\" (package manager installed)"
    echo "scripts in your /usr/bin folder from mixing up with your custom awesome and unique scripts!"
    exit
fi

if ! command -v yt-dlp &>/dev/null; then
    echo "Error: yt-dlp is not installed. visit https://github.com/yt-dlp/yt-dlp ✕"
    echo "nudge: i recommend downloading the binary and putting it in /usr/bin and checking with 'yt-dlp -U'"
    exit 1
else
    echo "-- yt-dlp verified installed ✓"
fi

if ! command -v deno &>/dev/null; then
    echo "Error: script will fail, please install deno ✕"
    echo "nudge: read this page: https://docs.deno.com/runtime/getting_started/installation/"
    exit 1
else
    echo "-- deno verified installed ✓"
fi

if [[ -z "$dirLocation" ]]; then
    echo "Error: save directory does not exist or is not writeable. current is: '$dirLocation' ✕"
    echo "nudge: make sure your \$dirLocation variable is set to a REAL folder in THIS script."
    exit 1
fi

echo "-- dependencies verified installed ✓"

if [ -f "$addURLTagLocation" ]; then
    echo "-- addURLTag script verified installed ✓"
else
    echo "Error: addURLTag script not found! "
    echo "-- downloading and installing addURLTag to '$addURLTagLocation'"
    wget "https://raw.githubusercontent.com/fennboii/fennboii/main/M5/addURLTag" -O "$HOME/.local/bin/addURLTag" >/dev/null 2>&1
    chmod +x "$HOME/.local/bin/addURLTag"
    echo "-- addURLTag script installed! rerun your last command!"
    exit
fi

if [ -f "$reCoverArtLocation" ]; then
    echo "-- reCoverArt script verified installed ✓"
else
    echo "Error: reCoverArt script not found! ✕"
    echo "-- downloading and installing reCoverArt to '$reCoverArtLocation'"
    wget "https://raw.githubusercontent.com/fennboii/fennboii/main/M5/reCoverArt" -O "$HOME/.local/bin/reCoverArt" >/dev/null 2>&1
    chmod +x "$HOME/.local/bin/reCoverArt"
    echo "-- reCoverArt script installed! rerun your last command!"
    exit
fi

# checking complete! continue~!

if [[ "$lineFour" == "-t" ]]; then
    audioFormat="$5"
fi

if [[ "$lineFive" == "-t" ]]; then
    audioFormat="$6"
fi

if [[ "$lineSix" == "-t" ]]; then
    audioFormat="$7"
fi

if [[ "$lineFour" == "-o" ]]; then
    openDirAfter=1
    echo "[Extra] will open directory when finished"
fi

if [[ "$lineFive" == "-o" ]]; then
    openDirAfter=1
    echo "[Extra] will open directory when finished"
fi

if [[ "$lineSix" == "-o" ]]; then
    openDirAfter=1
    echo "[Extra] will open directory when finished"
fi

if [[ "$TYPE" =~ ^(-h|--help|help)$ ]] || [[ -z "$TYPE" || -z "$SOURCE_URL" || -z "$FINAL_DIR" ]]; then
    cat <<EOF

-- syntax error! read below

  M5 Usage:  M5 "<url>" "<artist>" <release_type> -t <format> [options]

  ARGUMENTS:
    <url>           YouTube Music link (Must be in "quotes")
    <artist>        Artist name (Use "quotes" for names with spaces)
    <release_type>  Category: Single, EP, or Album

  OPTIONS:
    -t <format>     REQUIRED: flac, mp3, etc. 
    -o              Open destination folder when finished
    -h, --help      Show this help screen

  EXAMPLES:
    M5 "https://music.youtube.com/..." "keshi" Single -t mp3
    M5 "https://music.youtube.com/..." "nothing,nowhere." Album -t flac -o

  Note: Ensure all positional arguments are provided before flags.
EOF
    exit 0
fi

# OLD VERSION
# if [[ "$TYPE" == "help" || "$TYPE" == "-help" || "$TYPE" == "--help" ]] \
#    || [[ -z "$TYPE" || -z "$SOURCE_URL" || -z "$FINAL_DIR" ]]; then
#     cat << EOF

# -- syntax error! read below

# Usage: M5 <url> <type> <artist> <-t <TYPE>> [options]

# ARGUMENTS:
#   <url>      YouTube Music link (Wrap in "quotes")
#   <type>     Type of release: Single, EP, or Album
#   <artist>   Artist name (Wrap in "quotes" if it has spaces)

# OPTIONS:
#   -t <ext>   REQUIRED: Specify file format (flac, mp3, etc.)
#              (To set a permanent default, edit the M5 script)
#   -o         Open the destination folder after download

# EXAMPLES:
#   M5 "https://music.youtube.com..." Album "nothing, nowhere"
#   M5 "https://music.youtube.com..." Single keshi -t mp3 -o

# Note: Options -t and -o can be used in any order at the end.
# EOF
#     exit 0
# fi

if [[ -z "$TYPE" ]]; then
    echo "-- ERROR - ALBUM TYPES: 'Album | Single | EP' --"
    exit
fi

if [[ -z "$FINAL_DIR" ]]; then
    echo "-- ERROR - FINAL_DIR UNDEFINED --"
    exit
fi

case "$TYPE" in
Album | Single | EP) ;;
*)
    echo "-- ERROR - INVALID ALBUM TYPE: '$TYPE'. PLEASE USE: 'Album | Single | EP' --"
    exit
    ;;
esac

if [[ -z "$audioFormat" ]]; then
    echo "please set an audioFormat!"
    echo "if you'd like to set a default, find this line and comment out the bottom line in this script. (look for "case \"\$audioFormat\" in")"
    echo ""
    echo "how to set example:"
    echo "-t \"mp3\" OR -t \"flac\""
    echo ""
    echo "in a full example:"
    echo "M5 \"https://music.youtube.com/playlist?list=OLAK5uy_njhMKBnoa0tKJC2-t25rwuv1UZdD7Y7z0&si=7LjwUIqO8smRG77U\" Album \"nothing, nowhere\" -t mp3"
    echo "simpler:"
    echo "M5 [url] [Album/Single/EP] [aritst] [options: -t mp3/flac/etc.. || -o]"
    exit
fi

echo "[Song Information] Artist: $FINAL_DIR"
echo "[Song Information] Type: $TYPE"
echo "[Song Information] saveDirectory: '$dirLocation$FINAL_DIR'"
echo "[Song Information] audioFormat: .$audioFormat"
echo "this looks okay right? right?! good :>"

if [[ "$comformationPrompt" = 1 ]]; then

    read -r -p "does this look correct? (y/Y)-(n/N):" inputDir

    if [[ "$inputDir" == "Y" || "$inputDir" == "y" ]]; then
        echo "[valid input] Continuing service"
    else
        echo "[invalid input] Stopping service"
        echo "(you can disable this check)"
        exit
    fi
fi

# ensure target directory exists
mkdir -p "$dirLocation$FINAL_DIR" || {
    echo "Failed to create directory"
    return 1
}
cd "$dirLocation$FINAL_DIR" || {
    echo "Failed to cd into directory"
    return 1
}

# seperation -----

echo "-- fetching the album name"
PLAYLIST_DIR=$(yt-dlp --cookies-from-browser firefox --get-filename -o "%(playlist_title)s" --playlist-items 1 "$SOURCE_URL" | head -n 1)
echo "-- name fetched, continuing"

TOTAL_TRACKS=$(yt-dlp --flat-playlist --get-id "$SOURCE_URL" | wc -l)
declare -A URLMAP

while IFS= read -r line; do
    if [[ "$line" =~ "Destination: " ]]; then
        FILE=$(echo "$line" | sed 's/.*Destination: //')
        FILE=$(basename "$FILE")
        URLMAP["$FILE"]="$LAST_URL"
    fi
    if [[ "$line" =~ "https://www.youtube.com/watch" ]]; then
        LAST_URL="$line"
    fi
    echo "$line"
done < <(
    yt-dlp -f "bestaudio" \
        --cookies-from-browser firefox \
        --write-thumbnail \
        --yes-playlist \
        --write-playlist-metafiles \
        --extract-audio \
        --audio-format "$audioFormat" \
        --audio-quality 0 \
        --embed-metadata \
        --embed-thumbnail \
        -o "%(playlist_title)s/%(playlist_index)02d - %(title)s.%(ext)s" \
        "$SOURCE_URL"
)

CLEAN_PLAYLIST_DIR=$(echo "$PLAYLIST_DIR" | sed -E 's/^(Album|Single|EP) - //')
NEW_DIR="${TYPE} - ${CLEAN_PLAYLIST_DIR}"

if [[ "$PLAYLIST_DIR" != "$NEW_DIR" ]]; then
    mv "$PLAYLIST_DIR" "$NEW_DIR"
fi
PLAYLIST_DIR="$NEW_DIR"

((CHECKCOUNT++))

case "$audioFormat" in
mp3)
    FF_CODEC="-acodec libmp3lame -aq 0"
    FF_TAGS="-id3v2_version 3 -write_id3v1 1"
    ;;
flac)
    FF_CODEC="-c:a flac"
    FF_TAGS="-map_metadata 0"
    ;;
opus)
    FF_CODEC="-c:a libopus -b:a 192k"
    FF_TAGS="-map_metadata 0"
    ;;
aac | m4a)
    FF_CODEC="-c:a aac -b:a 256k"
    FF_TAGS="-map_metadata 0"
    ;;
*)
    echo "Unsupported audio format: $audioFormat"
    exit 1
    ;;
esac

for FILE in "$PLAYLIST_DIR"/*.${audioFormat}; do
    BASENAME=$(basename "$FILE")
    TRACKNUM=$(echo "$BASENAME" | cut -d'-' -f1 | tr -d ' ')
    TRACK_URL="${URLMAP[$BASENAME]}"
    [[ -z "$TRACK_URL" ]] && TRACK_URL="$SOURCE_URL"

    ffmpeg -i "$FILE" \
        $FF_CODEC \
        -metadata track="$TRACKNUM/$TOTAL_TRACKS" \
        -metadata comment="$TRACK_URL" \
        -metadata purl="$TRACK_URL" \
        $FF_TAGS \
        "${FILE%.${audioFormat}}_tmp.${audioFormat}" &&
        mv "${FILE%.${audioFormat}}_tmp.${audioFormat}" "$FILE"
done

# this make sure no symbols are in the filename.
for FILE in "$PLAYLIST_DIR"/*; do
    BASE=$(basename "$FILE")
    NEW=$(echo "$BASE" | sed -E 's/^[0-9]{2} - //')
    [[ "$NEW" != "$BASE" ]] && mv "$FILE" "$PLAYLIST_DIR/$NEW"
done

# writing the json file. SUPER USEFUL.
JSON_FILE="$PLAYLIST_DIR/playlist_metadata.json"
echo "[" >"$JSON_FILE"

FIRST=true
for FILE in "$PLAYLIST_DIR"/*.${audioFormat}; do
    BASENAME=$(basename "$FILE")
    TRACKNUM=$(echo "$BASENAME" | cut -d'-' -f1 | tr -d ' ')
    TRACK_URL="${URLMAP[$BASENAME]}"
    [[ -z "$TRACK_URL" ]] && TRACK_URL="$SOURCE_URL"

    METADATA=$(ffprobe -v quiet -print_format json -show_format "$FILE" | jq '.format.tags')

    [[ "$FIRST" == true ]] && FIRST=false || echo "," >>"$JSON_FILE"

    jq -n \
        --arg file "$BASENAME" \
        --arg track "$TRACKNUM/$TOTAL_TRACKS" \
        --arg url "$SOURCE_URL" \
        --argjson ffmetadata "$METADATA" \
        '{file: $file, track: $track, url: $url, ffmetadata: $ffmetadata}' >>"$JSON_FILE"
done
echo "]" >>"$JSON_FILE"

cd "$PLAYLIST_DIR" || exit
bash "$addURLTagLocation"
cd ..

if [[ -n "$FINAL_DIR" ]]; then
    mkdir -p "$dirLocation$FINAL_DIR"
    mv "$PLAYLIST_DIR" "$dirLocation$FINAL_DIR"

    cd "$dirLocation$FINAL_DIR/$PLAYLIST_DIR"

    # echo "fixing images: "$finalImage" + "$audioFormat""
    # echo "fixing images in dir"

    # echo "$(pwd)"

    finalImage=$(ls | grep *.png || ls | grep *.jpg)
    reCoverArt "$finalImage" -t "$audioFormat"

    cd "$dirLocation$FINAL_DIR/$PLAYLIST_DIR" # RUN THIS TO CHANGE ALL SONGS IN CURRENT DIR = [ ALBUM / EP / SINGLE ] HERE

    # cd "$dirLocation$FINAL_DIR" # RUN THIS TO CHANGE ALL SONGS IN DIR = [ ARTIST ] ALL CHILDREN

    echo "running in "$dirLocation$FINAL_DIR/$PLAYLIST_DIR""

    setAlbumArtist mp3 "$FINAL_DIR" .

    echo "ran 'setAlbumArtist' in "$(pwd)""

    echo "Moved $PLAYLIST_DIR to $FINAL_DIR/"

    cd /home/$getUser/Music/
fi

if [[ "$openDirAfter" == "1" || "$openDirAfter" == 1 ]]; then
    xdg-open "$dirLocation$FINAL_DIR"
    echo "----------------------------------------"
    echo "opened folder for u! thanks for using M5!"
else
    echo "----------------------------------------"
    echo "thanks for using M5!"
fi
