function fish_prompt --description 'Write out the prompt'

  set -l last_status $status
  set -l nest_lvl

  # Setup colors
  set -l normal_c $fish_color_normal
  set -l filler_c $fish_color_cwd_root
  set -l root_c   $fish_color_cwd_root
  set -l user_c   $fish_color_user
  set -l cwd_c    $fish_color_cwd
  set -l host_c   $fish_color_host
  set -l status_c $fish_color_status

  # Configure __fish_git_prompt
  set -g __fish_git_prompt_char_stateseparator     ' '
  set -g __fish_git_prompt_color                   "$normal_c"
  set -g __fish_git_prompt_color_flags             "$normal_c"
  set -g __fish_git_prompt_color_prefix            "$filler_c"
  set -g __fish_git_prompt_color_suffix            "$filler_c"
  set -g __fish_git_prompt_showdirtystate          true
  set -g __fish_git_prompt_showuntrackedfiles      true
  set -g __fish_git_prompt_showstashstate          true
  set -g __fish_git_prompt_show_informative_status true
  #set -g __fish_git_prompt_showcolorhints	         true

  # Just calculate these once, to save a few cycles when displaying the prompt
  if not set -q __fish_prompt_hostname
    set -g __fish_prompt_hostname (hostname|cut -d . -f 1)
  end

  if not set -q -g __fish_classic_git_functions_defined
    set -g __fish_classic_git_functions_defined

    function __fish_repaint_user --on-variable fish_color_user --description "Event handler, repaint when fish_color_user changes"
      if status --is-interactive
        set -e __fish_prompt_user
        commandline -f repaint ^/dev/null
      end
    end

    function __fish_repaint_host --on-variable fish_color_host --description "Event handler, repaint when fish_color_host changes"
      if status --is-interactive
        set -e __fish_prompt_host
        commandline -f repaint ^/dev/null
      end
    end

    function __fish_repaint_status --on-variable fish_color_status --description "Event handler; repaint when fish_color_status changes"
      if status --is-interactive
        set -e __fish_prompt_status
        commandline -f repaint ^/dev/null
      end
    end
  end

  set -l delim

  switch $USER
    case root
      set user_c "-b$root_c"
      set cwd_c  "-b$root_c"
      set host_c "-b$root_c"
      set delim '#'
    case '*'
      set delim '>'
  end

  # Line 1
  eval "set_color $filler_c"; echo -n -s '┌['
  eval "set_color $normal_c"
  eval "set_color $user_c";   echo -n -s "$USER"
  eval "set_color $normal_c"
  eval "set_color $filler_c"; echo -n -s  '@'
  eval "set_color $normal_c"
  eval "set_color $host_c";   echo -n -s "$__fish_prompt_hostname"
  eval "set_color $normal_c"
  eval "set_color $filler_c"; echo -n -s  ']–['
  eval "set_color $normal_c"
  eval "set_color $cwd_c";    echo -n -s  (prompt_pwd)
  eval "set_color $normal_c"
  eval "set_color $filler_c"; echo -n -s  ']'
  echo -n -s (__fish_git_prompt      '–[%s]')
  set_color normal;      echo

  # Line 2
  eval "set_color $filler_c"; echo -n -s '└'
  # Print exit status if not zero
  fish_prompt_cond "test $last_status -ne 0" "$last_status" "$status_c"
  # Print fish level if greater than 1
  if test -n "$TMUX"
    set nest_lvl (math $SHLVL - 2)
  else
    set nest_lvl (math $SHLVL - 1)
  end
  fish_prompt_cond "test $nest_lvl -gt 1" "><> $nest_lvl" "$normal_c"
  fish_prompt_cond "set -q VIRTUAL_ENV" (basename "$VIRTUAL_ENV") "$normal_c"
  eval "set_color $filler_c"; echo -n -s "–$delim "
  eval "set_color $normal_c"
end

function fish_prompt_cond -d 'Print some text if the condition is true.' -a test text color
  if eval $test
    eval "set_color $fish_color_cwd_root"
    echo -n -s "–["
    eval "set_color $normal_c"
    eval "set_color $color"
    echo -n -s $text
    eval "set_color $normal_c"
    eval "set_color $fish_color_cwd_root"
    echo -n -s "]"
    eval "set_color $normal_c"
  end
end
