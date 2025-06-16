#!/bin/bash

# Global variables for date and formatting
CURRENT_DATE=$(date "+[%Y-%m-%d %H-%M-%S]")
HEADER="======================================================================="
FOOTER="-----------------------------------------------------------------------"

# Helper function for output format
output_format() {
    local MESSAGE="$1"
    echo "$HEADER"
    echo "$CURRENT_DATE INFO - $MESSAGE"
    echo "$FOOTER"
    sleep 2
}

# Function for creating log_files directory
create_log_files_directory() {
    output_format "Creating log_files directory."
    mkdir log_files
    echo "mkdir: created directory 'log_files'"
}

# Function for moving log files from /var/log to the locally created log_files
moving_log_files() {
    output_format "Collecting log files from /var/log ..."

    find /var/log -type f -name "*.log" -exec 

    LOG_FILES=$(find /var/log -type f -name "*.log")
    for log_file in $LOG_FILES; do
        filename=$(basename "$log_file")
        cp "$log_file" "log_files/$filename"
        echo "$log_file -> log_files/$filename"
    done
}

# Function for modifying file permissions
modify_file_permissions() {
    output_format "Updating permissions for global reading ..."

    for log_file in $LOG_FILES; do
        filename=$(basename "$log_file")
        copied_file="log_files/$filename"
        PERMISSION=$(stat -c "%A" "$copied_file" | cut -c 2-)
        VALUE_EQUIVALENT="0000"
    
        if [[ "$PERMISSION" == "rwxrwxrwx" ]]; then
            VALUE_EQUIVALENT="777 (rwxrwxrwx)"
        elif [[ "$PERMISSION" == "rwxr-xr-x" ]]; then
            VALUE_EQUIVALENT="755 (rwxr-xr-x)"
        elif [[ "$PERMISSION" == "r--r--r--" ]]; then
            VALUE_EQUIVALENT="444 (r--r--r--)"
        elif [[ "$PERMISSION" == "rw-rw-rw-" ]]; then
            VALUE_EQUIVALENT="666 (rw-rw-rw-)"
        elif [[ "$PERMISSION" == "--x--x--x" ]]; then
            VALUE_EQUIVALENT="111 (--x--x--x)"
        elif [[ "$PERMISSION" == "---------" ]]; then
            VALUE_EQUIVALENT="000 (---------)"
        elif [[ "$PERMISSION" == "r--r-----" ]]; then
            VALUE_EQUIVALENT="440 (r--r-----)"
        elif [[ "$PERMISSION" == "r-xr-xr-x" ]]; then
            VALUE_EQUIVALENT="555 (r-xr-xr-x)"
        elif [[ "$PERMISSION" == "rwx------" ]]; then
            VALUE_EQUIVALENT="700 (rwx------)"
        elif [[ "$PERMISSION" == "rwxr-----" ]]; then
            VALUE_EQUIVALENT="740 (rwxr-----)"
        elif [[ "$PERMISSION" == "rw-r--r--" ]]; then
            VALUE_EQUIVALENT="644 (rw-r--r--)"
        elif [[ "$PERMISSION" == "rw-r-----" ]]; then
            VALUE_EQUIVALENT="640 (rw-r-----)"
        else
            VALUE_EQUIVALENT="unknown"

        fi
    
        if [[ "$(grep -o 'r' <<< "$PERMISSION" | wc -l)" -ne 3 ]]; then
            echo "mode of '$copied_file' changed from $VALUE_EQUIVALENT to 644 (rw-r--r--)"
            chmod 644 "$copied_file"
        else
            echo "mode of '$copied_file' retained as $VALUE_EQUIVALENT"
        fi
    done
}

# Function for creating a .txt file containing line and size summary of each files
create_files_summary() {
    output_format "Calculating line count summary ..."
    output_format "Calculating file size summary ..."

    touch log_summary.txt
    LOG_FILES_PATH="log_files/log_summary.txt"

    echo "$HEADER" >> $LOG_FILES_PATH
    echo "Log Summary" >> $LOG_FILES_PATH
    echo "$FOOTER" >> $LOG_FILES_PATH

    echo "$HEADER" >> $LOG_FILES_PATH
    echo "Line count summary" >> $LOG_FILES_PATH
    echo "$FOOTER" >> $LOG_FILES_PATH

    find log_files -type f -name "*.log" -exec wc -l {} \; | sort -n >> $LOG_FILES_PATH

    echo "$HEADER" >> $LOG_FILES_PATH
    echo "File size summary" >> $LOG_FILES_PATH
    echo "$FOOTER" >> $LOG_FILES_PATH

    du -ah log_files | sort -nr >> $LOG_FILES_PATH
    TOTAL_NUMBER_OF_LINES=$(cat log_files/* | wc -l)
}

# Function for zipping the content of log_files then moving it on /opt
zip_directory() {
    output_format "Compressing log archive to /opt/log_files-$TOTAL_NUMBER_OF_LINES.zip"
    output_format "Creating ZIP archive in /opt/ ..."
    ZIP_PATH="/opt/log_files-$TOTAL_NUMBER_OF_LINES.zip"

    sudo mkdir -p /opt
    sudo zip -r "$ZIP_PATH" log_files/ > /dev/null
    sudo chmod 755 "$ZIP_PATH"
}

# Main function or entry function
main() {
    output_format "Begin archiving log files."
    create_log_files_directory
    moving_log_files
    modify_file_permissions
    create_files_summary
    zip_directory
    output_format "Done."
}

main