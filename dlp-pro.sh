#!/bin/bash

# Check if a filename is provided as an argument
if [ $# -eq 0 ]; then
    echo "Usage: $0 <filename>"
    exit 1
fi

filename="$1"
location=~/AKI

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


# album_image=$(cat $filename | grep -oP '(?<=album_image=").*?(?=")')
album_image=$(grep -m 1 -oP '(?<=album_image=").*?(?=")' "$filename")
album_name=$(grep -m 1 -oP '(?<=album=").*?(?=")' "$filename")
wget -O "$location/$album_name.jpg" "$album_image" > /dev/null 2>&1

echo "Downloaded successfully: Album cover art"
echo "----------------------------------------"


# Loop over each line in the file
while IFS= read -r line; do
    index=$(echo "$line" | grep -oP '(?<=song_index=)\d+')
    # album=$(echo "$line" | grep -oP '(?<=album=").*?(?=")')
    # album_img=$(echo "$line" | grep -oP '(?<=album_image=").*?(?=")')
    name=$(echo "$line" | grep -oP '(?<=song_name=").*?(?=")')
    song_url=$(echo "$line" | grep -oP '(?<=song_link=").*?(?=")')
    artist_name=$(echo "$line" | grep -oP '(?<=artist_name=").*?(?=")')
    year=$(echo "$line" | grep -oP '(?<=year=")\d*?(?=")')
    
    # echo "Song: $index"
    # echo "album: $album_name"
    # echo "Album image: $album_image"
    # echo "Song: $name"
    # echo "Song url: $song_url"
    # echo $location
    
    cd "$location"
    song_file_name=$( yt-dlp -x -f 'bestaudio[ext=m4a]' --add-metadata --embed-thumbnail $song_url | grep -oP '(?<=Adding metadata to ").+\.m4a' )
    # echo "Song file name: $song_file_name"
    AtomicParsley "$song_file_name" --artwork REMOVE_ALL --overWrite > /dev/null 2>&1
    AtomicParsley "$song_file_name" --artwork "$album_name.jpg" --title "$name" --artist "$artist_name" --album "$album_name" --year $year --tracknum $index --overWrite > /dev/null 2>&1
    mv "$song_file_name" "$name.m4a"
    echo "🗹 ($index). $name"
    cd ~
    # exit
    
done < "$filename"


    echo "----------------------------------------"
    echo "➤ Download complete!"