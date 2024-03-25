# Game Resolution Switcher

This is a Linux Bash script for switching resolution and refresh rate when a game is launched, then switching back when the game is closed.\
It is intended to be used with game launchers such as Steam.

## Why this is useful
Some Linux games don't always adjust the monitor resolution, even when the 'Fullscreen' option is selected. This can cause problems, particularly when the game is played on an ultra-wide monitor but doesn't natively support ultra-wide resolutions. These issues can be resolved by changing the resolution before starting the game.

Another scenario where this can be useful is when you need to enable, disable or change the primary monitor, or adjust the refresh rate before starting a game.

## How It Works
* This script operates alongside a game launcher, like Steam, and passes the provided arguments
 to [XRandR](https://www.x.org/wiki/Projects/XRandR/).

* The script uses the current working directory _(which is automatically set by Steam)_ to check if any game executables are running.
	* _Can be overridden by setting the `GAME_PATH` environment variable._

* Once the script detects that no game executables are running from the working directory, it will restore the screen resolution to its original setting and then exit.

## Installation

To get going quickly, you can run the following command:

```bash
curl -sS https://raw.githubusercontent.com/hezkore/game-res-switcher/main/install.sh | bash
```

> [!WARNING]
> Never run unknown scripts without reviewing them for safety. Read the install script [here](https://raw.githubusercontent.com/hezkore/game-res-switcher/main/install.sh).

<details>
<summary><b>Manual Installation</b></summary>

1. Clone or download the repository:
	```bash
	git clone https://github.com/hezkore/game-res-switcher.git
	```

2. Make the script executable:
	```bash
	chmod +x game_res.sh
	```

3. Move or symlink `game_res.sh` to `/usr/local/bin` as `game_res`
</details>

## Usage
### Steam
* Right click any game in your library, then click 'Properties...'
* Change 'Launch Options' to `game_res` followed by any XRandR arguments, end with `; %command%`
	* _For example: `game_res -s 1920x1080; %command%`_

Any arguments passed to the game must be placed after `%command%`
> [!NOTE]
> Remember to always end with `;` followed by `%command%`

### Steam Heroic Games Launcher Shortcuts
Heroic Games Launcher has the ability to add game shortcuts to Steam. However, these shortcuts do not have the correct working directory set.\
To fix this, you can use the `GAME_PATH` environment variable to set the correct working directory.

For example, in Steam change the games 'Launch Options' to:\
`GAME_PATH="/home/your username/Games/Heroic/Some Game/" game_res -s 1920x1080; %command%`

### Generic examples
* Change primary monitor to 800x600:\
`game_res -s 800x600`

* Change monitor at HDMI 1 to 1920x1080:\
`game_res --output HDMI-1 --mode 1920x1080`

* Change monitor at DisplayPort 0 to 1920x1080 120 Hz:\
`game_res --output DP-0 --mode 1920x1080 --rate 120`

## Requirements
* [XRandR](https://www.x.org/wiki/Projects/XRandR/)
* zenity _(optional)_

## Limitations
* The script must be run from the directory of the game you want to change the resolution for.
* The script does not list available resolutions. You must know the correct xrandr arguments to pass.