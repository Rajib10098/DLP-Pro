
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
    echo "➣ [$format_totall_song]: Totall Song"
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
            file_to_artist_name() {
                local description_path="$1"  # Store the path to the description file
                local row_text="raw-artist7867.txt"  # Temporary file to store unformatted artist names
                local row_text2="raw-artist7686.txt"  # Temporary file to store formatted artist names
                local artist_txt="artist-name.txt"   # Final file to store the processed artist names
                
                # Extract unformatted artist name from description file
                unformatted_artist_name=$(cat "$description_path" | grep -oP '·\s\K.+$')
                
                # Save unformatted artist name to file
                echo "$unformatted_artist_name" > "$row_text"
                
                # Replace ' · ' with newline character
                sed -i 's/\s·\s/\n/g' "$row_text"
                
                total_artist=0    # Initialize counter for total artists
                artist_index=0    # Initialize index for iterating over artists
                
                # Count artists
                while IFS= read -r line; do
                    ((total_artist++))   # Increment total artist count
                done < "$row_text"
                
                # Format artist names
                while IFS= read -r line; do
                    ((artist_index++))   # Increment artist index
                    
                    if [ "$total_artist" = "1" ]; then   # If there is only one artist
                        echo -n "$line" > "$row_text2"   # Write the artist name to row_text2
                    else
                        if [ $artist_index = "1" ]; then   # For the first artist
                            echo -n "$line" > "$row_text2"   # Write the artist name to row_text2
                        else
                            if [ $total_artist = $artist_index ]; then   # If it's the last artist
                                echo -n " & $line" >> "$row_text2"   # Append with ' & ' separator
                            else
                                echo -n ", $line" >> "$row_text2"   # Append with ', ' separator
                            fi
                        fi
                    fi
                    
                done < "$row_text"
                
                rm -rf "$row_text"   # Remove the temporary unformatted artist names file
                
                # Remove newline characters from final output
                tr -d '\n' < "$row_text2" > "$artist_txt"   # Remove newlines and save to artist_txt
                rm -rf "$row_text2"   # Remove the temporary formatted artist names file
                
                artist_name=$(cat "$artist_txt")   # Read the final artist names from artist_txt
                echo "$artist_name"   # Output the final artist names
            }
            
            # Example usage
            artist_name=$(file_to_artist_name "$song_decription")

            
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

