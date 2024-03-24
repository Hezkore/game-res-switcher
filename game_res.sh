#!/bin/bash
# Game Resolution Switcher

SCRIPT_NAME="Game Resolution Switcher"

# Log file
SCRIPT_LOG_PATH="$HOME/.log/game resolution switcher"
SCRIPT_LOG_FILE="game_res.log"
SCRIPT_LOG_FULL_PATH="$SCRIPT_LOG_PATH/$SCRIPT_LOG_FILE"
mkdir -p "$SCRIPT_LOG_PATH"

# Set our own PWD variable if it's not already set
if [ -z "${GAME_PATH}" ]; then
	GAME_PATH="$(pwd)"
fi
echo "PWD is $GAME_PATH" > "$SCRIPT_LOG_FULL_PATH"

# Check if zenity is available
if command -v zenity >/dev/null 2>&1; then
	ZENITY=$(command -v zenity)
elif [ -n "${SYSTEM_ZENITY}" ] && command -v ${SYSTEM_ZENITY} >/dev/null 2>&1; then
	ZENITY="${SYSTEM_ZENITY}"
elif [ -n "${STEAM_ZENITY}" ] && command -v ${STEAM_ZENITY} >/dev/null 2>&1; then
	ZENITY="${STEAM_ZENITY}"
else
	echo "Zenity was not found" >> "$SCRIPT_LOG_FULL_PATH"
	ZENITY=""
fi

# Helper function for error messages
show_error() {
	echo -e "$1" >> "$SCRIPT_LOG_FULL_PATH"
	if [ -n "${ZENITY}" ]; then
		"${ZENITY}" --error --text="$1"
	fi
}

# Warn about working directories
if [ "$GAME_PATH" == "/" ] || [ "$GAME_PATH" == "$HOME" ]; then
	show_error "$SCRIPT_NAME is running from $GAME_PATH.\nThis is likely not the correct directory."
	exit 1
fi

# Check if any arguments were passed
if [ $# -eq 0 ]; then
	# TODO: show available resolutions
	show_error "$SCRIPT_NAME must be called with at least one argument.\nFor example: -s 1920x1080"
	exit 1
fi

# Store the current mode of all connected displays
declare -a restore_commands
while IFS= read -r line; do
	display=$(echo $line | awk '{print $1}')
	resolution=$(echo $line | awk '{print $3}' | cut -d'+' -f1)
	restore_commands+=("xrandr --output $display --mode $resolution")
done < <(xrandr --current | awk '/ connected/')

# Save the entire list of restore commands to the debug file
printf "%s\n" "${restore_commands[@]}" >> "$SCRIPT_LOG_FULL_PATH"

# Execute the xrandr command passed as arguments and capture the output
echo "Calling: xrandr $@" >> "$SCRIPT_LOG_FULL_PATH"
output=$(xrandr "$@" 2>&1)

# If the xrandr command failed
if [ $? -ne 0 ]; then
	show_error "$SCRIPT_NAME failed to execute the xrandr command.\n$output"
	exit 1
fi

# Start a subshell in the background
(
	sleep 5
	echo "Looking for processes in the working directory $GAME_PATH" >> "$SCRIPT_LOG_FULL_PATH"
	while true; do
		# Check if a process with the working directory in its command line is still running
		if ! pgrep -af "$GAME_PATH" > /dev/null; then
			# If no such process is running, restore the original mode for all displays and exit the loop
			echo "No active processes found in the working directory $GAME_PATH" >> "$SCRIPT_LOG_FULL_PATH"
			for command in "${restore_commands[@]}"; do
				eval "$command"
				echo "Calling: $command" >> "$SCRIPT_LOG_FULL_PATH"
			done
			exit 0
		fi
		sleep 2
	done
) &
exit 0