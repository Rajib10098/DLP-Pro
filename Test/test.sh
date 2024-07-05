#!/bin/bash

# Define the characters for the animation
chars="/-\|"

# Define the number of characters
n=${#chars}

# Function to clear the previous line
clear_line() {
    printf "\r"
    printf " "
    printf "\r"
}

# Loop for animation
i=0
while true; do
    # Get the character at position i
    char="${chars:i%n:1}"

    # Print the character without newline
    echo -n "$char"

    # Wait for a short interval (e.g., 0.1 seconds)
    sleep 0.1

    # Clear the previous line
    clear_line

    # Move to the next character
    ((i++))
done
