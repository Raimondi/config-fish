function fish_prompt --description 'Write out the left prompt'
  # Setup colors
  set -l normal_c $fish_color_normal
  set -l filler_c $fish_color_cwd_root
  set -l root_c   $fish_color_cwd_root
  set -l user_c   $fish_color_user
  set -l cwd_c    $fish_color_cwd
  set -l host_c   $fish_color_host
  set -l status_c $fish_color_status

  # Git prompt
  set -g __fish_git_prompt_color			"$normal_c"
  set -g __fish_git_prompt_color_flags		"$normal_c"
  set -g __fish_git_prompt_color_prefix		"$filler_c"
  set -g __fish_git_prompt_color_suffix		"$filler_c"
  #set -g __fish_git_prompt_color_bare			"$filler_c"
  #set -g __fish_git_prompt_color_merging		"$filler_c"
  #set -g __fish_git_prompt_color_branch		"$filler_c"
  #set -g __fish_git_prompt_color_branch_detached	"$filler_c"
  #set -g __fish_git_prompt_color_dirtystate		"$filler_c"
  #set -g __fish_git_prompt_color_stagedstate		"$filler_c"
  #set -g __fish_git_prompt_color_upstream		"$filler_c"

  set template '{sudo?\(sudo\)}{su?\(su\)}(user)@(host)\:(cwd){cwdwrite:(c:error) !(c:auto)}{git? | (git)}{jobs? | (c:user)jobs\:(c:auto )(jobs)}\n{status?(c:status)exit status\: (status)(c:auto) }{root?#:>} '
  if prompter "$template"
    return 0
  end

  set -l last_status $status
  set -l nest_lvl
  set -l item_prefix
  set -l item_sufix
  set -l delim

  # Just calculate these once, to save a few cycles when displaying the prompt
  if not set -q __fish_prompt_hostname
    set -g __fish_prompt_hostname (hostname|cut -d . -f 1)
  end

  if set -q __fish_prompt_item_prefix
    set item_prefix $__fish_prompt_item_prefix
  else
    set -g __fish_prompt_item_prefix '━['
    set item_prefix $__fish_prompt_item_prefix
  end
  if set -q __fish_prompt_item_sufix
    set item_sufix $__fish_prompt_item_sufix
  else
    set -g __fish_prompt_item_sufix ']'
    set item_sufix $__fish_prompt_item_sufix
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

  if not functions -q __fish_prompt_cond
    function __fish_prompt_cond -d 'Print some text if the condition is true.' -a test text color
      if eval $test
        __prompt_set_color $fish_color_cwd_root
        echo -n -s "$__fish_prompt_item_prefix"
        __prompt_set_color $fish_color_normal
        __prompt_set_color $color
        echo -n -s $text
        __prompt_set_color $fish_color_normal
        __prompt_set_color $fish_color_cwd_root
        echo -n -s "$__fish_prompt_item_sufix"
        __prompt_set_color $fish_color_normal
      end
    end
  end
  if not functions -q __prompt_set_color
    function __prompt_set_color -a color
      set_color normal
      eval "set_color $color"
    end
  end


  switch $USER
    case root
      set user_c "-b $normal_c $root_c "
      set cwd_c  "-b $normal_c $root_c "
      set host_c "-b $normal_c $root_c "
      set delim '#'
    case '*'
      set delim '>'
  end

  # LINE 1

  # user@host
  __prompt_set_color $filler_c; echo -n -s "┌$item_prefix"
  __prompt_set_color $user_c;   echo -n -s "$USER"
  __prompt_set_color $filler_c; echo -n -s  '@'
  __prompt_set_color $host_c;   echo -n -s "$__fish_prompt_hostname"
  __prompt_set_color $filler_c; echo -n -s  "$item_sufix$item_prefix"

  # Current path
  __prompt_set_color $cwd_c;    echo -n -s  (prompt_pwd last)

  #__prompt_set_color $cwd_c;    echo -n -s  (basename $PWD)/
  __prompt_set_color $filler_c; echo -n -s  "$item_sufix"

  # Git info
  echo -n -s (__fish_git_prompt $item_prefix"%s"$item_sufix)
  set_color normal;      echo

  # LINE 2

  __prompt_set_color $filler_c; echo -n -s '└'

  # Print exit status if not zero
  __fish_prompt_cond "test $last_status -ne 0" "$last_status" "$status_c"

  # Print fish nested level if greater than 1
  if test -n "$TMUX"
    set nest_lvl (math $SHLVL - 2)
  else
    set nest_lvl (math $SHLVL - 1)
  end
  __fish_prompt_cond "test $nest_lvl -gt 0" "><> $nest_lvl" "$normal_c"

  # virtualenv
  __fish_prompt_cond "set -q VIRTUAL_ENV" (basename "$VIRTUAL_ENV") "$normal_c"

  # number of jobs:  \o/ 3 o+< 2
  set -l act_lbl "\o/"
  set -l stp_lbl "o+<"
  set -l job_lbl "jobs: "
  set -l all_jobs (count (jobs))
  set -l act_jobs (count (jobs | grep running))
  set -l stp_jobs (count (jobs | grep stopped))
  if test "$act_jobs" -gt 0
    set jobs "$jobs_lbl$act_lbl $act_jobs"
    if test "$stp_jobs" -gt 0
      set jobs "$jobs $stp_lbl $stp_jobs"
    end
  else if test "$stp_jobs" -gt 0
    set jobs "$jobs_lbl$stp_lbl $stp_jobs"
  end
  __fish_prompt_cond "test $all_jobs -gt 0" "$jobs" "$normal_c"

  # -> for regular looser, -# for groot
  __prompt_set_color $filler_c; echo -n -s "–$delim "
  __prompt_set_color $normal_c
end
