
input_file="$1"
# dlp_song_des='hello.md'
totall_song=1
destination=~/ProDLP

# Song destination Folder
if [[ ! -e "$destination" ]]; then
    mkdir "$destination"
fi



if [[ -e "$input_file" ]]; then
    alnum_image_url=$(grep -m 1 -oP '(?<=album_image=").*?(?=")' "$input_file")
    album_name=$(grep -m 1 -oP '(?<=album=").*?(?=")' "$input_file")
    
    # echo $alnum_image_url
    song_destination="$destination/$album_name"
    song_temp=$destination/$album_name/temp
    
    # Creating Song Folder
    if [[ -e "$song_destination" ]]; then
        echo "➣ Song Folder: '$song_destination'"
    else
        mkdir "$song_destination"
        echo "➣ Song Folder: '$song_destination' (created)"
        
    fi
    
    # Creating temp Folder
    if [[ ! -e "$song_temp" ]]; then
        mkdir "$song_temp"
    fi
    album_image_path="$song_temp/$album_name.png"
    # echo "$album_image_path"
    
    # Downloading album image
    if [[ ! -e "$album_image_path" ]]; then
        wget -O "$album_image_path" "$alnum_image_url" > /dev/null 2>&1
        echo "➣ Album Cover Art (downloaded)"
        
    fi
    
    
    # Calculate how many song are there
    while read -r line; do
        ((totall_song++))
    done < "$input_file"
    
    
    format_totall_song=$(printf "%02d" "$totall_song")
    
    # Print the number of song
    
    if (( "$totall_song" != "1" )); then
        echo "➣ [$format_totall_song]: Track"
    fi
    echo "-----------------------------------------------"
    while read -r line; do
        song_index=$(echo "$line" | grep -oP '(?<=song_index=)\d+')
        formatted_track_index=$(printf "%02d" "$song_index")
        song_name=$(echo "$line" | grep -oP '(?<=song_name=").*?(?=")')
        song_path="$song_destination/$song_name.m4a"
        song_url=$(echo "$line" | grep -oP '(?<=song_link=").*?(?=")')
        # artist_name=$(echo "$line" | grep -oP '(?<=artist_name=").*?(?=")')
        release_year=$(echo "$line" | grep -oP '(?<=year=")\d*?(?=")')
        # echo "$song_path"
        
        
        cd "$song_destination"
        
        
        
        
        # See the song is all ready downloaded
        if [[ -e "$song_path" ]]; then
            
            #AtomicParsley "$song_path" --title "$song_name" --overWrite > /dev/null 2>&1
            echo "🗹 ($formatted_track_index): $song_name"
            
        else
            # Download the song
            song_file_name=$( yt-dlp -x -f 'bestaudio[ext=m4a]' --write-description --add-metadata --embed-thumbnail $song_url | grep -oP '(?<=Adding metadata to ").+\.m4a' )
            
            # Song artist name form .decription file
            song_decription="${song_file_name%.*}.description"
            artist_name=$(cat "$song_decription" | grep -oP '·\s\K.+')
            
            # Rename song file
            mv "$song_file_name" "$song_name.m4a"
            # Remove song's art-cover
            AtomicParsley "$song_path" --artwork REMOVE_ALL --overWrite > /dev/null 2>&1
            AtomicParsley "$song_path" --artwork "$album_image_path" --artist "$artist_name" --album "$album_name" --year $release_year --tracknum $song_index --overWrite > /dev/null 2>&1
            # echo "song name: $song_name"
            # echo "Album name: $album_name"
            # echo "Track: $song_index"
            # echo "Release: $release_year"
            # Delete Description file
            rm -rf "$song_decription"
            echo "🗹 ($formatted_track_index): $song_name"
            
            # echo $artist_name
        fi
        cd ~
        
        # exit
        
        
        
    done < "$input_file"
    
    echo "-----------------------------------------------"
    echo "Download complate!"
    
else
    echo "ALERT: Invalid peramiter"
    
fi

