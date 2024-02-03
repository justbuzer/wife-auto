#!/bin/bash

log_directory="/home/melina/PakBus Stuff/Gdrive Ocamlfuse/Log"

# Create log directory if it doesn't exist
mkdir -p "$log_directory"

# Redirect output to a log file with timestamps
exec > >(while read line; do echo "$(date '+%Y-%m-%d %H:%M:%S') $line"; done | tee -a "$log_directory/logfile.txt") 2>&1

# Function to show notification
show_notification() {
    notify-send "$1" "$2"$'\n'"$3"
}

# Initialize variables
loop_count=0
mounted_notification_shown=false
connection_lost_notification_shown=false
mount_success_notification_shown=false

# Define the mount point
mount_point="/home/melina/GDrive/Google Drive"

# Set the cooldown period (in seconds) for the "Connection Lost!" notification
cooldown_period=300  # 5 minutes

# Set the maximum loop count before executing the killswitch
max_loop_count=60


while [ $loop_count -lt $max_loop_count ]; do
    # Increment the loop count
    ((loop_count++))

    # Check internet connection
    if ping -q -c 1 google.com &>/dev/null; then
        # Internet connection is available
        if grep -qs "$mount_point" /proc/mounts; then
            # Show the notification only if it hasn't been shown before
            if [ "$mounted_notification_shown" = false ]; then
                show_notification "Google Drive already mounted" "Pencet F5 buat refresh Explorer Bu Mell."
                mounted_notification_shown=true
            fi
            
            # Reset loop counter since the internet is restored and drive is mounted
            loop_count=0

            # Reset the "Connection Lost" notification flag
            connection_lost_notification_shown=false
        else
            # Reset the notification flag when the drive is not mounted
            mounted_notification_shown=false

            # Attempt to mount Google Drive
            if google-drive-ocamlfuse "$mount_point"; then
                # Mount was successful
                if [ "$mount_success_notification_shown" = false ]; then
                show_notification "Google Drive mounted" "Udah bisa dipake" "Pencet F5 buat refresh Explorer Bu Mell."
                mount_success_notification_shown=true
            fi
                
                # Reset loop counter since the internet is restored and drive is mounted
                loop_count=0

                # Reset the "Connection Lost" notification flag
                connection_lost_notification_shown=false
            else
                # Mount failed
                show_notification "Mounting Error" "Coba diulang." "Kalo masih gagal hubungi Pak Bus"
                
                #Terminate the script if mounting failed
                exit 1
            fi
        fi
    else
        # Internet connection is lost
        if [ "$connection_lost_notification_shown" = false ]; then
            show_notification "Connection Lost!" "Internet connection is lost." "Unmounting Google Drive"
            connection_lost_notification_shown=true
            # Unmount Google Drive
            fusermount -u "$mount_point"
        fi
    fi

    # Sleep for 5 seconds before checking again
    sleep 5

    # Check if the break condition is met
    if [ $loop_count -ge $max_loop_count ]; then
        break
    fi
done
