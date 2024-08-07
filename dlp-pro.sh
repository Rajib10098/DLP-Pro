input_file="$1"
total_song=0
destination=~/Music/DLP-PRO
source_path=$(pwd)

# Track destination Folder
if [[ ! -e "$destination" ]]; then
    mkdir "$destination"
fi

# Ping Google to check for internet connectivity
is_internet_available() {
    local message=$1
    if ping -c 1 google.com &>/dev/null; then
        INTERNET_AVAILABLE=true
    else
        INTERNET_AVAILABLE=false

    fi

    if [ "$INTERNET_AVAILABLE" = false ]; then
        echo "$message"
        echo ""
        echo "-----------------------------------------------"
        echo -e "\033[1m\033[31mDownload incomplete\033[0m, please try again when internet is available."
        echo ""
        exit
    fi
}

if [[ -e "$input_file" ]]; then
    #Extracting variable
    alnum_image_url=$(grep -m 1 -oP '(?<=album_image=").*?(?=")' "$input_file")
    album_name=$(grep -m 1 -oP '(?<=album=").*?(?=")' "$input_file")
    track_destination="$destination/$(python3 find_and_replace.py "$album_name")"
    album_cover_art_folder="$destination/$(python3 find_and_replace.py "$album_name")/Album Cover"

    # Creating track folder
    if [[ -e "$track_destination" ]]; then
        echo "🗹 Track Folder: '$track_destination' (Already exist)"
    else
        mkdir "$track_destination"
        echo "🗹 Track Folder: '$track_destination'"

    fi

    # Creating album cover art folder if it doesn't exist
    if [[ ! -e "$album_cover_art_folder" ]]; then
        mkdir "$album_cover_art_folder"
    fi

    # Album image path variable
    album_image_path="$album_cover_art_folder/$(python3 find_and_replace.py "$album_name").png"


    # Downloading the album art cover
    if [[ ! -e "$album_image_path" ]]; then
        is_internet_available "🗷 No internet: unable to download ablum art cover"
        wget -O "$album_image_path" "$alnum_image_url" >/dev/null 2>&1
        echo "🗹 Album cover art is downloaded"
    else
        echo "🗹 Album cover art already exist"

    fi

    # Calculate, how many traks are in input_file text (.txt) file
    while read -r line; do
        ((total_song++))
    done <"$input_file"

    format_total_song=$(printf "%02d" "$total_song")

    # Print the number of song

    if [[ "$total_song" == "1" ]]; then
        echo "🗹 ($format_total_song): Track"
    else
        echo "🗹 ($format_total_song): Tracks"
    fi
    echo "-----------------------------------------------"

    # Loop over the "input_file" text (.txt) file variable line by line
    while read -r line; do
        song_index=$(echo "$line" | grep -oP '(?<=song_index=)\d+')
        formatted_track_index=$(printf "%02d" "$song_index")
        cd "$source_path"
        # song_name=$(echo "$line" | grep -oP '(?<=song_name=").*?(?=")')
        song_name=$(python3 fix_html_perse_error.py "$(echo "$line" | grep -oP '(?<=song_name=").*?(?=")')")

        # echo $source_path
        # song_path="$track_destination/$song_name.m4a"
        song_path="$track_destination/$(python3 find_and_replace.py "$song_name").m4a"

        song_url=$(echo "$line" | grep -oP '(?<=song_link=").*?(?=")')
        # artist_name=$(echo "$line" | grep -oP '(?<=artist_name=").*?(?=")')
        release_year=$(echo "$line" | grep -oP '(?<=year=")\d*?(?=")')

        cd "$track_destination"

        # See the song is all ready downloaded
        if [[ -e "$song_path" ]]; then

            #AtomicParsley "$song_path" --title "$song_name" --overWrite > /dev/null 2>&1
            echo "🗹 ($formatted_track_index): $song_name"

        else
            # is_internet_available "🗷 ($formatted_track_index): $song_name (No internet, unable to download)"
            # Download the song
            song_file_name=$(yt-dlp -x -f 'bestaudio[ext=m4a]' --write-description --add-metadata --embed-thumbnail $song_url | grep -oP '(?<=Adding metadata to ").+\.m4a')

            # Song artist name form .decription file
            song_decription="${song_file_name%.*}.description"
            file_to_artist_name() {
                local description_path="$1"          # Store the path to the description file
                local row_text="raw-artist7867.txt"  # Temporary file to store unformatted artist names
                local row_text2="raw-artist7686.txt" # Temporary file to store formatted artist names
                local artist_txt="artist-name.txt"   # Final file to store the processed artist names

                # Extract unformatted artist name from description file
                unformatted_artist_name=$(cat "$description_path" | grep -oP '·\s\K.+$')

                # Save unformatted artist name to file
                echo "$unformatted_artist_name" >"$row_text"

                # Replace ' · ' with newline character
                sed -i 's/\s·\s/\n/g' "$row_text"

                total_artist=0 # Initialize counter for total artists
                artist_index=0 # Initialize index for iterating over artists

                # Count artists
                while IFS= read -r line; do
                    ((total_artist++)) # Increment total artist count
                done <"$row_text"

                # Format artist names
                while IFS= read -r line; do
                    ((artist_index++)) # Increment artist index

                    if [ "$total_artist" = "1" ]; then # If there is only one artist
                        echo -n "$line" >"$row_text2"  # Write the artist name to row_text2
                    else
                        if [ $artist_index = "1" ]; then  # For the first artist
                            echo -n "$line" >"$row_text2" # Write the artist name to row_text2
                        else
                            if [ $total_artist = $artist_index ]; then # If it's the last artist
                                echo -n " & $line" >>"$row_text2"      # Append with ' & ' separator
                            else
                                echo -n ", $line" >>"$row_text2" # Append with ', ' separator
                            fi
                        fi
                    fi

                done <"$row_text"

                rm -rf "$row_text" # Remove the temporary unformatted artist names file

                # Remove newline characters from final output
                tr -d '\n' <"$row_text2" >"$artist_txt" # Remove newlines and save to artist_txt
                rm -rf "$row_text2"                     # Remove the temporary formatted artist names file

                artist_name=$(cat "$artist_txt") # Read the final artist names from artist_txt
                echo "$artist_name"              # Output the final artist names
                rm -rf "$artist_txt"             # Remove artist_txt file
            }

            # Example usage
            artist_name=$(file_to_artist_name "$song_decription")

            # Rename the track's name to song_name
            mv "$song_file_name" "$song_path"

            # Removing track's album cover art
            AtomicParsley "$song_path" --artwork REMOVE_ALL --overWrite >/dev/null 2>&1

            #Add new album art cover, track artist name, album name, release year and track index
            AtomicParsley "$song_path" --artwork "$album_image_path" --artist "$artist_name" --album "$album_name" --year $release_year --tracknum "$song_index/$total_song" --overWrite >/dev/null 2>&1

            rm -rf "$song_decription"
            echo "🗹 ($formatted_track_index): $song_name"

        fi

        cd ~

        # exit

    done \
        < \
        "$input_file"
    echo ""
    echo "-----------------------------------------------"
    echo -e "\033[1mDownload complete!\033[0m"
    echo ""

else
    echo -e "\033[1m! ALERT\033[0m: PATH is not valid"
    echo ""
    echo "Valid example:"
    echo "(✔): dlp-pro 'Album name.txt'"
    echo ""
    echo "Unvalid Example:"
    echo "(✗): dlp-pro Album name.txt"
    echo ""

fi
