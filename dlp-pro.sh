#!/bin/bash

# Check if a filename is provided as an argument
if [ $# -eq 0 ]; then
    echo "Usage: $0 <filename>"
    exit 1
fi

filename="$1"
location=~/DLP-Pro

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

# Download Song art-cover
wget -O "$location/$album_name.jpg" "$album_image" > /dev/null 2>&1
# Print output in console
echo "Downloaded successfully: Album cover art"
echo "----------------------------------------"


# Loop over each line in the file
while IFS= read -r line; do
    
    # Varrible inside loop
    index=$(echo "$line" | grep -oP '(?<=song_index=)\d+')
    name=$(echo "$line" | grep -oP '(?<=song_name=").*?(?=")')
    song_url=$(echo "$line" | grep -oP '(?<=song_link=").*?(?=")')
    artist_name=$(echo "$line" | grep -oP '(?<=artist_name=").*?(?=")')
    year=$(echo "$line" | grep -oP '(?<=year=")\d*?(?=")')
    
    
    
    cd "$location"
    
    # Download the song with YouTube-dlp
    song_file_name=$( yt-dlp -x -f 'bestaudio[ext=m4a]' --add-metadata --embed-thumbnail $song_url | grep -oP '(?<=Adding metadata to ").+\.m4a' )
    
    # Remove song's art-cover
    AtomicParsley "$song_file_name" --artwork REMOVE_ALL --overWrite > /dev/null 2>&1
    
    # Change album cover, song name, artist name, album name, year and Track number
    AtomicParsley "$song_file_name" --artwork "$album_name.jpg" --title "$name" --artist "$artist_name" --album "$album_name" --year $year --tracknum $index --overWrite > /dev/null 2>&1
    
    # Rename the downloaded file
    mv "$song_file_name" "$name.m4a"
    
    # Print output in console
    echo "🗹 ($index). $name"
    
    cd ~
    
    
done < "$filename"


echo "----------------------------------------"
echo "➤ Download complete!"