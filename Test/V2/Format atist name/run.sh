file_artist_name() {
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
artist_name=$(file_artist_name "Time (Alan Walker Remix) [BDYkziFXGZU].description")
echo "$artist_name"
