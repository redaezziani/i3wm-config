#!/bin/bash

# Tailwind theme colors
bg="#121b1a"       # Hooker's green darker shade
fg="#D5CDC2"       # Timberwolf
blue="#65988A"     # Zomp
red="#9C594A"      # Redwood
magenta="#5B8582"  # Hooker's green
green="#5B8582"    # Hooker's green
yellow="#D5CDC2"   # Timberwolf

# Create a temporary directory for the lock screen
TMPDIR=$(mktemp -d)
LOCK_IMAGE="$TMPDIR/lock.png"
LOCK_GIF="$HOME/Pictures/lock.gif"

# Take a screenshot
scrot "$LOCK_IMAGE"

# Apply blur and Tailwind theme to the screenshot
convert "$LOCK_IMAGE" -blur 0x12 -brightness-contrast -10x5 \
    -fill "$bg" -colorize 20% "$LOCK_IMAGE"

# Add date and time in the top-left corner
convert "$LOCK_IMAGE" \
    -gravity northwest -pointsize 42 -fill "$fg" \
    -font "DejaVu-Sans-Mono-Bold" \
    -annotate +30+50 "$(date +"%H:%M:%S")" \
    -gravity northwest -pointsize 22 -fill "$blue" \
    -annotate +30+100 "$(date +"%A, %B %d")" \
    "$LOCK_IMAGE"

# Add a stylish password input prompt to the center of the image
convert "$LOCK_IMAGE" \
    -gravity center -pointsize 18 \
    -fill "$blue" \
    -annotate +0-10 "PASSWORD" \
    -gravity center -pointsize 14 \
    -fill "$fg" \
    -annotate +0+30 "[enter to unlock]" \
    "$LOCK_IMAGE"

# Process the GIF for display in the bottom-right corner (static only)
if [ -f "$LOCK_GIF" ]; then
    # Calculate suitable GIF size (making it small)
    GIF_WIDTH=100
    GIF_HEIGHT=100
    
    # Calculate bottom-right position with padding
    X_OFFSET=30
    Y_OFFSET=30
    
    # Create a scaled version of the GIF's first frame
    convert "$LOCK_GIF[0]" -resize ${GIF_WIDTH}x${GIF_HEIGHT} "$TMPDIR/gif_first_frame.png"
    
    # Overlay the first GIF frame on the lock image
    convert "$LOCK_IMAGE" "$TMPDIR/gif_first_frame.png" \
        -gravity southeast -geometry +${X_OFFSET}+${Y_OFFSET} -composite "$LOCK_IMAGE"
fi

# Add username to the bottom
convert "$LOCK_IMAGE" \
    -gravity south -pointsize 26 \
    -fill "$blue" \
    -annotate +0+50 "Klaus The Hunter" \
    "$LOCK_IMAGE"

# Try checking if i3lock-color is installed and available first
if command -v i3lock-color &> /dev/null; then
    # Use i3lock-color with no indicator
    i3lock-color -n -i "$LOCK_IMAGE" \
        --indicator \
        --radius=0 \
        --ring-width=0 \
        --inside-color="00000000" \
        --ring-color="00000000" \
        --insidever-color="00000000" \
        --ringver-color="00000000" \
        --insidewrong-color="00000000" \
        --ringwrong-color="00000000" \
        --line-color="00000000" \
        --separator-color="00000000" \
        --verif-color=$blue \
        --wrong-color=$red \
        --modif-color=$green \
        --layout-color=$fg \
        --time-color="00000000" \
        --date-color="00000000" \
        --greeter-color="00000000" \
        --verif-text="VERIFYING..." \
        --wrong-text="INCORRECT!" \
        --noinput-text="TYPE PASSWORD" \
        --lock-text="LOCKING..." \
        --lockfailed-text="LOCK FAILED!"
else
    # Use standard i3lock with our image
    i3lock -n -i "$LOCK_IMAGE"
fi

# Clean up temporary files
rm -rf "$TMPDIR"