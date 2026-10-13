#!/usr/bin/env bash

# use this to catch EVERYTHING that could break lol
set -Eeuo pipefail


# change ur hostname user here OR just use $USER
user=$(echo $USER)

# basically, this DB file is what checks your current 'last vid' ID from the 'newest' one.
DB_FILE="/home/$user/Documents/critical/rssChecker/feed.db"

# make sure NOTHING ELSE can edit this file while this script is running to (hopefully) stop corruption
LOCK_FILE="${DB_FILE}.lock"

# location to download newest video
DOWNLOAD_DIR="/home/$user/Videos/new"

# this is to make sure u dont have NO space and you can set your minimum system size to check before trying to download anything.format should be in kilobytes (KB) (default ive set is 50MB)
MIN_FREE_KB=50000


# ohkay, now lets make sure the DB file exists, so basically some setup and checks.

mkdir -p "$(dirname "$DB_FILE")"
mkdir -p "$DOWNLOAD_DIR"

touch "$DB_FILE"

releaseCounter=0
DOWNLOAD=1

# Usage:
# ./checkNewReleasesRSS.sh           -> download + update DB
# ./checkNewReleasesRSS.sh --nodl    -> update DB only

if [[ "${1:-}" == "--nodl" ]]; then
    DOWNLOAD=0
    echo "downloading disabled, updating db"
fi

# ohkay here is where we truly LOCK the file. if it IS in use, stop everything.

exec 9>"$LOCK_FILE"

if ! flock -n 9; then
    echo "[!] Another instance is already running."
    exit 1
fi

# lets check if you have space goober *sniffs your disk*

check_disk_space() {
    local available_kb

    available_kb=$(df "$(dirname "$DB_FILE")" | awk 'NR==2 {print $4}')

    if (( available_kb < MIN_FREE_KB )); then
        echo "[FATAL] Low disk space."
        echo "[FATAL] Refusing to modify database."
        exit 1
    fi
}


# ohkay, now here is the fun part! we use our control of the file to finally write to the file. HERE we also check how much space you have left JUST to make sure we dont write to a full disk and then the file gets corrupted or erased.

update_db() {
    local name="$1"
    local latest_id="$2"

    check_disk_space

    local tmpfile
    tmpfile=$(mktemp)

    # remove an old entry
    grep -vF -- "${name}|" "$DB_FILE" > "$tmpfile" || true

    # add a new entry
    echo "${name}|${latest_id}" >> "$tmpfile"

    # if we cant write to the tmp file, we quit. this should never happen because tmp doesnt usually require premissions to write in the dir.
    if [[ ! -s "$tmpfile" ]]; then
        echo "[FATAL] Temporary DB file is empty."
        rm -f "$tmpfile"
        exit 1
    fi

    mv "$tmpfile" "$DB_FILE"
}

# aaaye lets check ur youtuber's last video!

fetch_youtube_latest() {
    local url="$1"

    yt-dlp \
        --get-id \
        --playlist-items 1 \
        --flat-playlist \
        --socket-timeout 15 \
        "$url" 2>/dev/null | head -n 1
}

fetch_rss_latest() {
    local url="$1"

    curl -fsSL \
        --compressed \
        --connect-timeout 10 \
        --max-time 20 \
        "$url" 2>/dev/null |
    sed 's/>/>\n/g' |
    sed -n '/<item>/,$p' |
    grep -m 1 -E '<guid|<id' |
    sed -E 's/.*>([^<]+)<.*/\1/' |
    tr -d '[:space:]'
}

# ohkay, so u can disable the thing where we download the newest video. you can just comment out the video function on line 247 or somewhere there.

download_video() {
    local video_id="$1"

    (
        cd "$DOWNLOAD_DIR" || exit 1

        yt-dlp \
            -q \
            --write-auto-subs \
            --sub-langs "en" \
            --convert-subs srt \
            --embed-subs \
            --cookies-from-browser firefox \
            --js-runtimes deno \
            -f "bv*+ba" \
            -t mp4 \
            "https://www.youtube.com/watch?v=${video_id}"
    )
}

# EEEEE now we've come to the fun part. defining your youtuber's streams! add them as you please.

declare -A FEEDS

# for podcasts
FEEDS["Detective_Perspective"]="https://audioboom.com/channels/5108029.rss"
FEEDS["Scary___A_Paranormal_Podcast"]="https://feeds.acast.com/public/shows/6212aa30da90cc0012177abb"
FEEDS["Be__Scared"]="https://feeds.megaphone.fm/STU6307201575"
FEEDS["Danny_Jones_Podcast"]="https://feeds.megaphone.fm/QCD2752074976"
FEEDS["Crime_Weekly"]="https://audioboom.com/channels/5038514.rss"

# for music
FEEDS["shteppi"]="https://www.youtube.com/@shteppi"
FEEDS["ISSBROKIE"]="https://www.youtube.com/@ISSBROKIE"
FEEDS["ajackal"]="https://www.youtube.com/@jackalart"
FEEDS["SPARKLEWOLF_RADIO"]="https://www.youtube.com/@sparklewolfradio"
FEEDS["Electronic_Gems"]="https://www.youtube.com/@ElectronicGems"
FEEDS["Jeris_Johnson"]="https://www.youtube.com/@JerisJohnson"
FEEDS["Frizk"]="https://www.youtube.com/@frizkmusic"
FEEDS["Sunday_Cruise"]="https://www.youtube.com/@sundaycruise5653"
FEEDS["Lauv"]="https://www.youtube.com/@lauvsongs"
FEEDS["I_Prevail"]="https://www.youtube.com/@IPrevailBand"
FEEDS["Chase_Atlantic"]="https://www.youtube.com/@chaseatlantic"
FEEDS["bonjr"]="https://www.youtube.com/@bonjr2854"
FEEDS["heylog"]="https://www.youtube.com/@byelog" # heylog
FEEDS["logan"]="https://www.youtube.com/@logan10942" # byelog
FEEDS["blackbear"]="https://www.youtube.com/@blackbeardiaries"
FEEDS["Now__Now"]="https://www.youtube.com/channel/UCXIClNK5na27EXgnOX9GFbQ"
FEEDS["prkr_blu"]="https://www.youtube.com/channel/UCw90gvxVxHmR1abZOqow_PA"
FEEDS["keshi"]="https://www.youtube.com/@keshibeats"
FEEDS["Dead_By_April"]="https://www.youtube.com/channel/UCvZZS9q9SfLcFUVPwNyyXtA"
FEEDS["bbno$"]="https://www.youtube.com/@bbnomoney"
FEEDS["Lund"]="https://www.youtube.com/@lundbeatz"
FEEDS["Good_Kid"]="https://www.youtube.com/@GoodKidband"
FEEDS["Jeremy_Zucker"]="https://www.youtube.com/channel/UCNwwzAlMbHAJUNoJe0h3nBw"
FEEDS["EDEN"]="https://www.youtube.com/@iameden"
FEEDS["Joji"]="https://www.youtube.com/@joji"
FEEDS["Verplex"]="https://www.youtube.com/@Verplex321"
FEEDS["YOUTH_83"]="https://www.youtube.com/@youth83"
FEEDS["GOJII"]="https://www.youtube.com/@GOJIIMUSIC"
FEEDS["Far_Caspian"]="https://www.youtube.com/@FarCaspian"

# for videos
FEEDS["MuYe"]="https://www.youtube.com/@MuYe"
FEEDS["MuYeLive"]="https://www.youtube.com/@MuYeLive"
FEEDS["Shiey"]="https://www.youtube.com/@shiey"
FEEDS["Dream"]="https://www.youtube.com/@dream"
FEEDS["DreamXD"]="https://www.youtube.com/@DreamXD"
FEEDS["CHRISTIAN"]="https://www.youtube.com/@CHRIST14N"
FEEDS["Hater_s_Garage"]="https://www.youtube.com/@HatersGarage"
FEEDS["Low_Level"]="https://www.youtube.com/@LowLevelTV"
FEEDS["Insym"]="https://www.youtube.com/@Insym"
FEEDS["UDY"]="https://www.youtube.com/@UDY"
FEEDS["Markiplier"]="https://www.youtube.com/@markiplier"
FEEDS["JedediahDaFox"]="https://www.youtube.com/@jedediahdafox"
FEEDS["Raych_VODs"]="https://www.youtube.com/@RaychVODs/videos"


echo "checking feeds --"
echo ""

for name in "${!FEEDS[@]}"; do

    url="${FEEDS[$name]}"
    latest_id=""

    echo ""
    echo "-------------------------"
    echo "[*] checking '$name'"


    if [[ "$url" == *"youtube.com"* ]]; then
        latest_id=$(fetch_youtube_latest "$url")
    else
        latest_id=$(fetch_rss_latest "$url")
    fi


    if [[ -z "$latest_id" ]]; then
        echo "[!] failed to fetch the latest release"
        continue
    fi

    if grep -qF -- "${name}|${latest_id}" "$DB_FILE"; then
        echo "[ ] no new updates"
        continue
    fi


    echo "[NEW] release found!"

    if [[ "$url" == *"youtube.com"* ]]; then
        echo "      https://www.youtube.com/watch?v=${latest_id}"
    else
        echo "      ID: ${latest_id}"
    fi

    if (( DOWNLOAD == 1 )); then

        if [[ "$url" == *"youtube.com"* ]]; then
            echo "[*] downloading..."

            if download_video "$latest_id"; then
                echo "[✓] download complete"
            else
                echo "[!] download failed"
            fi
        fi

    else
        echo "[*] download disabled (--nodl)"
    fi


    if update_db "$name" "$latest_id"; then
        echo "[✓] database updated safely"
        continue
    else
        echo "[!] failed to update database"
        continue
    fi

    ((releaseCounter++))

done

echo ""
echo "========================================"

if (( releaseCounter > 0 )); then
    echo "total new releases '$releaseCounter'"
else
    echo "no new releases."
fi

echo "========================================"