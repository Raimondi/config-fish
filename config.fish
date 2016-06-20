#umask 0027

set -xg EDITOR vim
set -xg VISUAL vim
set -xg PAGER "less -X"
set -xg fish_user_paths ~/bin
set -xg VIDIR_EDITOR_ARGS '-c "set nolist ft=vidir-ls"'
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
set -xg LUA_PATH "/opt/local/share/luarocks/share/lua/5.3/?.lua;/opt/local/share/luarocks/share/lua/5.3/?/init.lua;$LUA_PATH"
set -xg LUA_CPATH "/opt/local/share/luarocks/lib/lua/5.3/?.so;$LUA_CPATH"
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
set -g __sensitive_dir "$HOME/.config/sensitive"
if test -r "$__sensitive_dir/fish.fish"
  source "$__sensitive_dir/fish.fish"
end

set -l plugin_dir ~/.config/fish/plugins

source "$plugin_dir/z-fish/z.fish"
source "$plugin_dir/repos/repos.fish"
source "$plugin_dir/cd_on_error.fish"
source "$plugin_dir/fbell.fish"

# http://www.colourlovers.com/palette/373610/mellon_ball_surprise
#colorscheme A0F070 EFFAB4 FFC48C FF9F80 F56991

# http://www.colourlovers.com/palette/848743/%28%E2%97%95_%E2%80%9D_%E2%97%95%29
#colorscheme 8A9B0F F8CA00 E97F02 BD1550 490A3D
#colorscheme 490A3D BD1550 E97F02 F8CA00 8A9B0F

# http://wwew.colourlovers.com/palette/92095/Giant_Goldfish
#colorscheme 69D2E7 A7DBD8 E0E4CC F38630 FA6900
#colorscheme 5fd7d7 afd7d7 e4e4e4 ff8700 ff5f00
#colorscheme FA6900 F38630 E0E4CC A7DBD8 69D2E7
#colorscheme ff5f00 ff8700 e4e4e4 afd7d7 5fd7d7

# http://www.colourlovers.com/palette/694737/Thought_Provoking
#colorscheme ECD078 D95B43 C02942 542437 53777A
#colorscheme 53777A 542437 C02942 D95B43 ECD078
colorscheme 53777A D95B43 C02942 542437 ECD078

# http://www.colourlovers.com/palette/123774/Homage_to_the_Chefs
#colorscheme FFF2AF D31900 7CB490 FF6600

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

function colon2x
  if commandline -b | grep -q '^$'
    commandline -i ""
  else
    commandline -i :
  end
end

function sync_history -e fish_prompt
  history --merge > /dev/null
end

function sudo-my-prompt
  set -l cmd (commandline)
  commandline --replace "sudo $cmd"
end

set -g fbell_actions bell email sound
set -g fbell_time_limit 15

# Configure __fish_git_prompt
#set -g __fish_git_prompt_showcolorhints			true
set -g __fish_git_prompt_showdirtystate			true
#set -g __fish_git_prompt_char_dirtystate		'*'
#set -g __fish_git_prompt_char_stagedstate		'+'
#set -g __fish_git_prompt_char_invalidstate		'#'
set -g __fish_git_prompt_showstashstate			true
#set -g __fish_git_prompt_char_stashstate		'$'
set -g __fish_git_prompt_showuntrackedfile		true
#set -g __fish_git_prompt_char_untrackedfiles		'%'
set -g __fish_git_prompt_showupstream			true
#set -g __fish_git_prompt_char_upstream_equal		'='
#set -g __fish_git_prompt_char_upstream_behind		'<'
#set -g __fish_git_prompt_char_upstream_ahead		'>'
#set -g __fish_git_prompt_char_upstream_diverged	'<>'
set -g __fish_git_prompt_show_informative_status	true
#set -g __fish_git_prompt_char_cleanstate		'√'
set -g __fish_git_prompt_char_stateseparator		' '

#if test "$TERM_PROGRAM" = "iTerm.app"
#  source /Users/israel/.iterm2_shell_integration.fish
#end
