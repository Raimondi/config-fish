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
  set jobs (jobs | awk '/[0-9]+\t/ {count++} END {print count}')

  if not set -q promptf_awk_file
    set promptf_awk_file ~/.config/fish/promptf.awk
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
  if not set -q promptf_ignore_vcs
    set vcs (__fish_git_prompt '%s')
  end
  echo -sn $fmt | awk \
     -f "$promptf_awk_file" \
     -v color0=(set_color normal) \
     -v fg_1=(set_color "$promptf_color1") \
     -v fg_2=(set_color "$promptf_color2") \
     -v fg_3=(set_color "$promptf_color3") \
     -v fg_4=(set_color "$promptf_color4") \
     -v fg_5=(set_color "$promptf_color5") \
     -v fg_6=(set_color "$promptf_color6") \
     -v fg_7=(set_color "$promptf_color7") \
     -v fg_8=(set_color "$promptf_color8") \
     -v fg_9=(set_color "$promptf_color9") \
     -v bg_1=(set_color -b "$promptf_color1") \
     -v bg_2=(set_color -b "$promptf_color2") \
     -v bg_3=(set_color -b "$promptf_color3") \
     -v bg_4=(set_color -b "$promptf_color4") \
     -v bg_5=(set_color -b "$promptf_color5") \
     -v bg_6=(set_color -b "$promptf_color6") \
     -v bg_7=(set_color -b "$promptf_color7") \
     -v bg_8=(set_color -b "$promptf_color8") \
     -v bg_9=(set_color -b "$promptf_color9") \
     -v fg_user=(set_color "$fish_color_user") \
     -v fg_normal=(set_color "$fish_color_normal") \
     -v fg_status=(set_color "$fish_color_status") \
     -v fg_cwd=(set_color "$fish_color_cwd") \
     -v fg_cwd_root=(set_color "$fish_color_cwd_root") \
     -v fg_host=(set_color "$fish_color_host") \
     -v fg_error=(set_color "$fish_color_error") \
     -v bg_user=(set_color -b "$fish_color_user") \
     -v bg_normal=(set_color -b "$fish_color_normal") \
     -v bg_status=(set_color -b "$fish_color_status") \
     -v bg_cwd=(set_color -b "$fish_color_cwd") \
     -v bg_cwd_root=(set_color -b "$fish_color_cwd_root") \
     -v bg_host=(set_color -b "$fish_color_host") \
     -v bg_error=(set_color -b "$fish_color_error") \
     -v jobs="$jobs" \
     -v status="$status" \
     -v vcs="$vcs" \
     -v shlvl="$SHLVL" \
     -

end
