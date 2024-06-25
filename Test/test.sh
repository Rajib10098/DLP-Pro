#!/bin/bash

# Check if a filename is provided as an argument
if [ $# -eq 0 ]; then
    echo "Usage: $0 <filename>"
    exit 1
fi

filename="$1"
location=~/DLP-Pro
song_count_from_zero=$(wc -l < "$filename")
song_count=$((song_count_from_zero + 1))

if [ ! -d "$location" ]; then
    # If it doesn't exist, create it
    mkdir "$location"
    echo "Destination folder '$location' created."
else
    echo "Destination '$location'"
fi

# Check if the file exists
if [ ! -f "$filename" ]; then
    echo "File $filename not found."
    exit 1
fi



album_image=$(grep -m 1 -oP '(?<=album_image=").*?(?=")' "$filename")
album_name=$(grep -m 1 -oP '(?<=album=").*?(?=")' "$filename")
album_location=$location/$album_name
# echo $album_location

if [ ! -d "$album_location" ]; then
    # If it doesn't exist, create it
    mkdir "$album_location"
    echo "Song Destination folder '$album_location' created."
else
    echo "Song Destination '$album_location'"
fi

# check if cover art is already downloaded
if [ -f "$album_location/$album_name.jpg" ]; then
    echo "➣ Cover art: $album_name.jpg [already exist]"
else
    wget -O "$album_location/$album_name.jpg" "$album_image" > /dev/null 2>&1
    echo "➣ Cover art: $album_name.jpg [downloaded]"
fi

# Print output in console

echo "➣ Total Song: $song_count"
echo "----------------------------------------"

# Run if input file has one song's info
if [ $song_count_from_zero -eq 0 ]; then
    index=$(grep -m 1 -oP '(?<=song_index=)\d+' "$filename")
    name_un_fix=$(echo "$line" | grep -oP '(?<=song_name=").*?(?=")')
    name="${name_un_fix//&quot;/\"}"
    song_url=$(grep -m 1 -oP '(?<=song_link=").*?(?=")' "$filename")
    artist_name=$(grep -m 1 -oP '(?<=artist_name=").*?(?=")' "$filename")
    year=$(grep -m 1 -oP '(?<=year=")\d*?(?=")' "$filename")
    
    # echo $name
    # echo $name
    # echo $song_url
    # echo $artist_name
    # echo $year
    
    cd "$album_location"
    
    if [ -f "$name.m4a" ]; then
        # echo "🖙 ($index). $name [already exist]"
        :
    else
        
        # Download the song with YouTube-dlp
        song_file_name=$( yt-dlp -x -f 'bestaudio[ext=m4a]' --add-metadata --embed-thumbnail $song_url | grep -oP '(?<=Adding metadata to ").+\.m4a' )
    fi
    
    # Remove song's art-cover
    AtomicParsley "$song_file_name" --artwork REMOVE_ALL --overWrite > /dev/null 2>&1
    
    # Change album cover, song name, artist name, album name, year and Track number
    AtomicParsley "$song_file_name" --artwork "$album_name.jpg" --title "$name" --artist "$artist_name" --album "$album_name" --year $year --tracknum $index --overWrite > /dev/null 2>&1
    
    if [ -f "$name.m4a" ]; then
        # echo "🖙 ($index). $name [already exist]"
        :
    else
        # Rename the downloaded file
        mv "$song_file_name" "$name.m4a"
    fi
    
    
    
    # Print output in console
    echo "🗹 ($index). $name"
    
    cd ~
fi

# if not 0 song then go ahead
if [ $song_count_from_zero -ne 0 ]; then
    
    # Loop over each line in the file
    
    while IFS= read -r line; do
        
        # Varrible inside loop
        index=$(echo "$line" | grep -oP '(?<=song_index=)\d+')
        name_un_fix=$(echo "$line" | grep -oP '(?<=song_name=").*?(?=")')
        name="${name_un_fix//&quot;/\"}"
        song_url=$(echo "$line" | grep -oP '(?<=song_link=").*?(?=")')
        artist_name=$(echo "$line" | grep -oP '(?<=artist_name=").*?(?=")')
        year=$(echo "$line" | grep -oP '(?<=year=")\d*?(?=")')
        
        
        
        cd "$album_location"
        
        if [ -f "$name.m4a" ]; then
            # echo "🖙 ($index). $name [already exist]"
            :
        else
            
            # echo "➣ Cover art: $album_name.jpg [downloaded]"
            
            # Download the song with YouTube-dlp
            song_file_name=$( yt-dlp -x -f 'bestaudio[ext=m4a]' --add-metadata --embed-thumbnail $song_url | grep -oP '(?<=Adding metadata to ").+\.m4a' )
        fi
        
        # Remove song's art-cover
        AtomicParsley "$song_file_name" --artwork REMOVE_ALL --overWrite > /dev/null 2>&1
        
        # Change album cover, song name, artist name, album name, year and Track number
        AtomicParsley "$song_file_name" --artwork "$album_name.jpg" --title "$name" --artist "$artist_name" --album "$album_name" --year $year --tracknum $index --overWrite > /dev/null 2>&1
        
        
        if [ -f "$name.m4a" ]; then
            # echo "🖙 ($index). $name [already exist]"
            :
        else
            # Rename the downloaded file
            mv "$song_file_name" "$name.m4a"
        fi
        
        
        
        # Print output in console
        echo "🗹 ($index). $name"
        
        cd ~
        
        
    done < "$filename"
fi



echo "----------------------------------------"
echo "➤ Download complete!"