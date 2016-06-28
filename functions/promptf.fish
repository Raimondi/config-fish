function promptf
  # %% literal %
  # %u user
  # %h host
  # %p pwd
  # %j jobs
  # %s status
  # %t time
  # %d command duration
  # %c fg color
  # %C bg color
  # %v VCS info
  # %n $SHLVL
  # %{x...%} conditional block, x is the condition which can one of the following:
  #   j if there are jobs running
  #   s if the exit status is non zero
  #   u if $USER is non root
  #   U if $USER is root
  #   v if under version control (currently git only)
  #   n if $SHLVL is higher than 1
  set exit_status $status
  set duration $CMD_DURATION
  set jobs (jobs | awk '/[0-9]+\t/ {count++} END {print count}')

  if not set -q promptf_awk_file
    for dir in $fish_function_path
      if test -r $dir/promptf.awk
        set promptf_awk_file $dir/promptf.awk
        break
      end
    end
    if not set -q promptf_awk_file
      echo "Could not find the promptf.awk" >&2
      return 1
    end
  end
  if not set -q promptf_color1
    set promptf_color1 $fish_color_normal
  end
  if not set -q promptf_color2
    set promptf_color2 $fish_color_command
  end
  if not set -q promptf_color3
    set promptf_color3 $fish_color_match
  end
  if not set -q promptf_color4
    set promptf_color4 $fish_color_error
  end
  if not set -q promptf_color5
    set promptf_color5 $fish_color_cwd_root
  end
  if not set -q promptf_color6
    set promptf_color6 $fish_color_cwd
  end
  if not set -q promptf_color7
    set promptf_color7 $fish_color_status
  end
  if not set -q promptf_color8
    set promptf_color8 $fish_color_host
  end
  if not set -q promptf_color9
    set promptf_color9 $fish_color_normal
  end
  set fg
  set bg
  set prefix promptf_color
  for i in (seq 9)
    set varname $prefix$i
    set fg[$i] (set_color $$varname)
    set bg[$i] (set_color -b $$varname)
  end
  if not set -q promptf_ignore_vcs
    set vcs (__fish_git_prompt '%s')
  end
  if test -n "$TMUX$STY"
    set multiplexer true
  end
  if test -n "$SSH_CLIENT$SSH_TTY"
    set remote true
  end
  if not set -q promptf_time_format
    set promptf_time_format '+%F %T'
  end
  echo -sn $argv | awk                                    \
     -f "$promptf_awk_file"                               \
     -v color0=(set_color normal)                         \
     -v fg_str="$fg"                                      \
     -v bg_str="$bg"                                      \
     -v fg_user=(set_color        "$fish_color_user")     \
     -v fg_normal=(set_color      "$fish_color_normal")   \
     -v fg_status=(set_color      "$fish_color_status")   \
     -v fg_cwd=(set_color         "$fish_color_cwd")      \
     -v fg_cwd_root=(set_color    "$fish_color_cwd_root") \
     -v fg_host=(set_color        "$fish_color_host")     \
     -v fg_error=(set_color       "$fish_color_error")    \
     -v bg_user=(set_color -b     "$fish_color_user")     \
     -v bg_normal=(set_color -b   "$fish_color_normal")   \
     -v bg_status=(set_color -b   "$fish_color_status")   \
     -v bg_cwd=(set_color -b      "$fish_color_cwd")      \
     -v bg_cwd_root=(set_color -b "$fish_color_cwd_root") \
     -v bg_host=(set_color -b     "$fish_color_host")     \
     -v bg_error=(set_color -b    "$fish_color_error")    \
     -v jobs="$jobs"                                      \
     -v status="$status"                                  \
     -v vcs="$vcs"                                        \
     -v shlvl="$SHLVL"                                    \
     -v duration="$duration"                              \
     -v user="$USER"                                      \
     -v multiplexer="$multiplexer"                        \
     -v remote="$remote"                                  \
     -v time_format="$promptf_time_format"                \
     -
end
