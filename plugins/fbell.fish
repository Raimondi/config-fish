# This script will notify you after a long running process has finished.
# Whenever a command runs longer than a set number of seconds some actions
# will be triggererd, like ringing a bell (sending the \a character to the
# terminal), playing a sound, sending an email or executing a command.
#
# This script was inspired by Jean-Philippe Ouellet's zbell.zsh
# (https://gist.github.com/oknowton/8346801)
#
# Configuration
#
# General:
# - fbell_time_limit: minimum time in seconds that a command runs to trigger
#   an action.
# - fbell_ignored: space delimited list of commands to ignore. e.g. vim, less,
#   etc.
# - fbell_actions: a space delimited list of actions to perform, available
#   actions are: bell sound email command.
#
# Bell action:
# - fbell_bell_times: how many times the bell will ring.
#
# Sound action:
# - fbell_sound_player: command that will play the sound file.
# - fbell_sound_file: file that will be played.
#
# Eval action:
# - fbell_eval_string: string that will be passed to eval.
#
# Email action:
# - fbell_email_server: smtp server.
# - fbell_email_port: smtp server port.
# - fbell_email_user: user for the smtp server.
# - fbell_email_password: password for the smtp server.
# - fbell_email_to_name: name for the To field.
# - fbell_email_to_address: email address for the To field.
# - fbell_email_from_name: name for the From field.
# - fbell_email_from_address: email address for the From field.

if not status --is-interactive
  # This is a non-interactive session, bail out!
  exit
end

function __fbell_after -e fish_postexec
  set -l exit_status $status
  set -l run_time (math "$CMD_DURATION / 1000")
  set -l actions bell
  set -l time_limit 60
  set -l ignored $fbell_ignored \
     $EDITOR $PAGER watch htop top ssh iotop dstat vmstat nano emacs vi bwm-ng \
     less more fdisk audacious play aplay sqlite3 wine mtr ping traceroute vlc \
     mplayer smplayer tail tmux screen man sawfish-config powertop g vim yi xi \
     mvim gvim afplay pico lynx w3m elinks newsbeuter mutt nvim weechat irssi \
     fish_config vidir ranger
  set -l command (echo "$argv" | sed -E -e 's-^ *(sudo *)?([^ ]+).*-\2-')
  if set -q fbell_actions
    set actions $fbell_actions
  end
  if set -q fbell_time_limit
    set time_limit $fbell_time_limit
  end
  # Check if command qualifies
  if begin
      test "$run_time" -lt "$time_limit"
      or contains $command $ignored
    end
    return
  end
  if contains bell $actions
    # Ring the bell
    __fbell_bell
  end
  if contains sound $actions
    # Play a sound
    __fbell_sound
  end
  if contains command $actions
    # Run some command.
    __fbell_eval $command $exit_status "$argv"
  end
  if contains email $actions
    # Send an email
    __fbell_email $command $exit_status
  end
end

function __fbell_bell
  set -l times 1
  if set -q fbell_bell_times
    set times fbell_bell_times
  end
  # Ring the bell as many times as needed
  printf "%.*s" $times \
     \a\a\a\a\a\a\a\a\a\a\a\a\a\a\a\a\a\a\a\a\a\a\a\a\a\a\a\a\a\a\a\a\a
end

function __fbell_sound
  set -l command afplay
  set -l file /System/Library/Sounds/Blow.aiff
  if set -q fbell_sound_player
    set command $fbell_sound_player
  end
  if set -q fbell_sound_file
    set file $fbell_sound_file
  end
  eval "$command $file" >/dev/null ^&1 &
end

function __fbell_eval -a command exit_status commandline
  set -l string 'say "$command has finished with exit status $exit_status."'
  if set -q fbell_eval_string
    set string $fbell_eval_string
  end
  eval "$string"
end

function __fbell_email -a command exit_status
  if not set -q fbell_email_password
    echo 'fbell: Could not send email because fbell_email_password is not set!'
    echo 'Fix that or remove "email" from fbell_actions to stop this alert message.'
    return
  end
  set -l server       "mail.nice.tld"
  set -l port         "465"
  set -l user         "big@boss.tld"
  set -l to_name      "Big Boss"
  set -l to_address   "big+fbell@boss.tld"
  set -l from_name    "FBell"
  set -l from_address "fbell_noreply@null.tld"
  if set -q fbell_email_server
    set server $fbell_email_server
  end
  if set -q fbell_email_port
    set port $fbell_email_port
  end
  if set -q fbell_email_user
    set user $fbell_email_user
  end
  if set -q fbell_email_to_name
    set to_name $fbell_email_to_name
  end
  if set -q fbell_email_to_address
    set to_address $fbell_email_to_address
  end
  if set -q fbell_email_from_name
    set from_name $fbell_email_from_name
  end
  if set -q fbell_email_from_address
    set from_address $fbell_email_from_address
  end
  # Send the email
  echo "\
From: \"$from_name\" <$from_address>
To: \"$to_name\" <$to_address>
Subject: Fish Notification: "(hostname)" - $command

\"$command\" completed with exit status $exit_status

Love,

Fbell

" | \
 curl --ssl-reqd \
   --url "smtps://$server:$port" \
   --mail-from "$from_address" \
   --mail-rcpt "$from_address" \
   --user "$user:$fbell_email_password" \
   --insecure --upload-file - >/dev/null ^&1 &
  # let's give it time to finish so it doesn't mess with my jobs indicator.
  sleep 2
end
