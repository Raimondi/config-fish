# Path to your oh-my-fish.
#set fish_path $HOME/.oh-my-fish

# Path to your custom folder (default path is ~/.oh-my-fish/custom)
#set fish_custom $HOME/dotfiles/oh-my-fish

# Load oh-my-fish configuration.
#source $fish_path/oh-my-fish.fish

# Custom plugins and themes may be added to ~/.oh-my-fish/custom
# Plugins and themes can be found at https://github.com/oh-my-fish/
#Theme 'robbyrussell'

umask 0027

set -xg EDITOR vim
set -xg VISUAL vim
set -xg PAGER "less -X"
set -xg fish_user_paths ~/bin
set -xg VIDIR_EDITOR_ARGS '-c :set nolist | :set ft=vidir-ls'
set -xg CDPATH . ~
if test -d ~/Documents/Source
  set CDPATH $CDPATH ~/Documents/Source
end
if set -q -U fish_user_abbreviations
  set -e -U fish_user_abbreviations
end
if not set -q -g fish_user_abbreviations
  set -gx fish_user_abbreviations
end

# XQuartz libs are not in the usual place.
set -xg CPLUS_INCLUDE_PATH /usr/X11R6/include

if type -f gshuf 1>/dev/null 2>/dev/null
  function random_line
    gshuf -n 1 -
  end
end
if begin
    not functions -q random_line
    and echo a | sort -R 1>/dev/null 2>/dev/null
  end
  function random_line
    sort -R - | tail -n 1
  end
end
if not functions -q random_line
  function random_line
    cat - | awk 'BEGIN { srand() } { print rand() "\t" $0 }' | sort -n | cut -f2- | tail -n 1
  end
end

if not status --is-interactive
  exit
end

##########################################
# What follows is for interactive shell. #
##########################################

set -l plugin_dir ~/.config/fish/plugins

source $plugin_dir/z-fish/z.fish
source $plugin_dir/repos/repos.fish
source $plugin_dir/cd_on_error.fish

# http://www.colourlovers.com/palette/373610/mellon_ball_surprise
#colorscheme A0F070 EFFAB4 FFC48C FF9F80 F56991

# http://www.colourlovers.com/palette/848743/%28%E2%97%95_%E2%80%9D_%E2%97%95%29
#colorscheme 8A9B0F F8CA00 E97F02 BD1550 490A3D
colorscheme 490A3D BD1550 E97F02 F8CA00 8A9B0F

# http://wwew.colourlovers.com/palette/92095/Giant_Goldfish
#colorscheme 69D2E7 A7DBD8 E0E4CC F38630 FA6900
#colorscheme 5fd7d7 afd7d7 e4e4e4 ff8700 ff5f00
#colorscheme FA6900 F38630 E0E4CC A7DBD8 69D2E7
#colorscheme ff5f00 ff8700 e4e4e4 afd7d7 5fd7d7

if type -f fortune >/dev/null ^/dev/null
  set -l fortune "fortune -a"
  if type -f cowsay >/dev/null ^/dev/null
    set -l cow_file (ls -1 /opt/local/share/cowsay/cows | random_line)
    set fortune "$fortune | cowsay -f \"$cow_file\""
  end
  if type -f lolcat >/dev/null ^/dev/null
    set fortune "$fortune | lolcat"
  end
  #eval $fortune
  #echo
end

abbr -a l="ls -Alh"

function rationalize_dot
  if commandline -t | grep -q '\(^\|/\)\.\.$'
    commandline -i /..
  else
    commandline -i .
  end
end

function colon2vim
  if commandline -b | grep -q '^$'
    commandline -i "vim "
  else
    commandline -i :
  end
end

history --merge > /dev/null
#eval (python -m virtualfish)
source /Users/israel/.iterm2_shell_integration.fish
