function theme_showcase -d 'Create a showcase of the current color theme.'
  set -l saved_lprompt __theme_showcase_fish_prompt
  set -l saved_rprompt __theme_showcase_fish_right_prompt
  set -l args 'current one'
  set -l mode
  set -l title_color "$fish_color_comment --bold"
  set -l confirm
  set -l confirm_msg 'set_color normal; echo; echo -n "[q]uit/show [a]ll/any key to go next: "'
  stty size | read rows cols
  set -l help_msg (set_color green)"
Show the fishy looks
"(set_color normal)"
Usage: $_ [OPTIONS] [PATHS]

OPTIONS:
-h --help	Show this text.
-l --long	Use the long format, the default without path[s].
-s --short	Use the short format, the default whith path[s].
-k --skip	Skip the prompt.

PATHS:
Every file found in the given path[s] will be sourced and showcased.

The following cases are showcased with the short format:

- Empty prompt:
  \$
- A long command with a non-zero exit status:
  \$ printf \"foo %%s\\\\n\" (echo \$bar) ^ /dev/null | tr \" \" \\\\t
- As root (\$USER is set to \"root\"), a command, a comment and a couple of background jobs:
  \$ make install # this is a nice comment
- Empty prompt:
  \$

The following cases are showcased with the long format:

- Empty prompt:
  \$
- Command with argument and autosuggestion (as if the cursor were at the |):
  \$ man 7 re_|format
- Command with a valid path and an invalid path:
  \$ multitail valid/path.log invalid/path.log
- Empty prompt showing non zero exit status and some jobs on the background:
  \$
- Incomplete command (error) and autosuggestion (as if the cursor were at the |):
  \$ wee|chat
- Completion pager:
  \$ git checkout v7.2.250
- A more complex command:
  \$ printf \"foo %%s\\\\n\" (echo \$bar) ^ /dev/null | tr \" \" \\\\t
- As root, a command and a comment (works if \$USER is used to detect root user):
  \$ make install # this is a nice comment
- Search match (as if the cursor were at the |):
  \$ apt-get ins|tall vim-nox
- Empty prompt:
  \$

 "(set_color green)"~ <>< <>< # ><> ><> J
"

  # Define some functions {{{
  if not functions -q __theme_showcase_clean
    function __theme_showcase_clean --argument text
      echo -n  "$text" \
         | string replace -r -a "\\x1B\\[(\\d{1,3}(;\\d{1,3})*)?[mGK]" ""\
         | string replace -r -a "\x1B](\\d{1,3};(\\d{1,3};)*)?B" ""\
         | string replace -r -a "[[:cntrl:]]" ""
    end
  end
  if not functions -q __theme_showcase_status
    function __theme_showcase_status -a exit_status
      return $exit_status
    end
  end
  if not functions -q __theme_showcase_print
    function __theme_showcase_print -a color text
      set_color normal
      eval "set_color $color"
      printf $text
    end
  end
  if not functions -q __theme_showcase_prompt
    function __theme_showcase_prompt -a exit_status jobs text
      # Print the left prompt and the given text, if there is enough space
      # left then print the right prompt.
      set -l prompt
      set -l padding
      set -l rprompt
      set -l job_ids
      set -l job_template "vi theme_showcase_foo_bar_baz_%s_%s >/dev/null ^&1 &"
      if test -n "$jobs" -a "$jobs" -gt 0
        set job_ids (seq $jobs)
      end
      stty size | read rows cols
      # Add some jobs in case the prompt uses them
      for job_id in $job_ids
        eval (printf $job_template inactive $job_id)
        kill -SIGSTOP %(printf $job_template inactive $job_id)
        eval (printf $job_template active $job_id)
      end
      set_color normal
      if functions -q fish_prompt
        __theme_showcase_status $exit_status
        set prompt (fish_prompt)
      end
      # Left prompt could be multiline, append to the last line only
      set prompt[-1] "$prompt[-1]$text"
      set ltext (__theme_showcase_clean "$prompt[-1]")
      if functions -q fish_right_prompt
        __theme_showcase_status $exit_status
        set rprompt (fish_right_prompt | tr -d '\\n')
      end
      set -l rtext (__theme_showcase_clean "$rprompt")
      set -l text_length (string length "$ltext$rtext")
      set -l pad_length (math $cols - $text_length)
      if test "$pad_length" -gt 0
        set padding (printf "%"$pad_length"s" "")
        set prompt[-1] "$prompt[-1]$padding"
        set prompt[-1] "$prompt[-1]$rprompt"
      end
      for line in $prompt
        echo $line
      end
      # Now remove the jobs
      for job_id in $job_ids
        kill -9 %(printf $job_template active $job_id)
        kill -9 %(printf $job_template inactive $job_id)
      end
    end
  end # }}}

  # Argument parsing
  for arg in $argv
    switch $arg
      case --help -h
        echo "$help_msg"
        return 0
      case --short -s
        set mode short
      case --long -l
        set mode long
      case --skip -k
        set confirm false
      case -\*
        echo "Error: $_ does not accept $arg" >&2
        printf $help_msg >&2
        return 1
      case \*
        if not test -r $arg
          echo "Error: \"$arg\" can not be read or does not exist." >&2
          continue
        end

        if test -d "$arg"
          set args $args (ls "$arg/*.fish")
        else
          set args $args $arg
        end
    end
  end

  if test -z "$mode"
    if test (count $args) -gt 1
      set mode short
    else
      set mode long
    end
  end
  if test -z "$confirm" -a (count $args) -eq 1
    set confirm false
  else if test -z "$confirm"
    set confirm true
  end
  for arg in $args
    if test "$arg" = 'current one'
      echo
      set_color normal; echo 'Prompt: current'
      echo
    else
      if not functions -q $saved_lprompt
        functions -c fish_prompt $saved_lprompt
        functions -c fish_right_prompt $saved_rprompt
        function fish_right_prompt
        end
      end
      if test -r "$arg"
        source "$arg"
        echo
        echo "Prompt: $arg"
        echo
      else
        echo "$_: \"$arg\" could not be read" >&2
        continue
      end
    end

    # Empty prompt
    __theme_showcase_prompt

    if test "$mode" = 'short'
      # Complex command
      __theme_showcase_prompt 130 0 (
        __theme_showcase_print "$fish_color_command" "printf"
        __theme_showcase_print normal " "
        __theme_showcase_print "$fish_color_quote" "\"foo %%s\\\n\""
        __theme_showcase_print normal " "
        __theme_showcase_print "$fish_color_match" "("
        __theme_showcase_print "$fish_color_command" "echo"
        __theme_showcase_print normal " "
        __theme_showcase_print "$fish_color_param" "\$bar"
        __theme_showcase_print "$fish_color_match" ")"
        __theme_showcase_print normal " "
        __theme_showcase_print "$fish_color_redirection" "^"
        __theme_showcase_print normal " "
        __theme_showcase_print "$fish_color_redirection" "/dev/null"
        __theme_showcase_print normal " "
        __theme_showcase_print "$fish_color_end" "|"
        __theme_showcase_print normal " "
        __theme_showcase_print "$fish_color_command" "tr"
        __theme_showcase_print normal " "
        __theme_showcase_print "$fish_color_quote" "\" \""
        __theme_showcase_print normal " "
        __theme_showcase_print "$fish_color_escape" "\\\\t\n"
      )

      # Root user
      # This relies on fish_prompt using $USER to change colors.
      set -l current_user $USER
      set -gx USER root
      __theme_showcase_prompt 0 1 (
        __theme_showcase_print "$fish_color_command" "make"
        __theme_showcase_print normal " "
        __theme_showcase_print "$fish_color_param" "install"
        __theme_showcase_print normal " "
        __theme_showcase_print "$fish_color_comment" "# this is a nice comment :D\n"
      )
      set -gx USER $current_user

    else
      # Complete command
      __theme_showcase_prompt 0 0 (
        __theme_showcase_print "$fish_color_command" "man"
        __theme_showcase_print normal " "
        __theme_showcase_print "$fish_color_param" "7"
        __theme_showcase_print normal " "
        __theme_showcase_print "$fish_color_param" "re_"
        __theme_showcase_print "$fish_color_autosuggestion" "format"
      )

      # Command plus two arguments, one of them is a valid path
      __theme_showcase_prompt 0 0 (
        __theme_showcase_print "$fish_color_command" "multitail"
        __theme_showcase_print normal " "
        set_color $fish_color_param
        set_color $fish_color_valid_path
        printf "valid/path.log"
        __theme_showcase_print normal " "
        __theme_showcase_print "$fish_color_param" "invalid/path.log\n"
      )

      # Empty prompt
      __theme_showcase_prompt 130 2

      # Incomplete command with autosuggestion
      __theme_showcase_prompt 0 3 (
        __theme_showcase_print "$fish_color_error" "wee"
        __theme_showcase_print "$fish_color_autosuggestion" "chat"
      )

      # Completion pager
      __theme_showcase_prompt 1 0 (
        __theme_showcase_print "$fish_color_command" "git"
        __theme_showcase_print normal " "
        __theme_showcase_print "$fish_color_param" "checkout"
        __theme_showcase_print normal " "
        __theme_showcase_print "$fish_color_param" "v7.2.250\n"
      )

      # Print the pager
      set -l length 17
      set -l linec 0
      set -l i 1
      set -l tags  2.250 3.617 4.167 0.001 2.251 3.618 4.168 0.002 2.252 3.619 4.169 0.003 2.253 3.620 4.170 0 2.250 3.617 4.167 0.001 2.251 3.618 4.168 0.002 2.252 3.619 4.169 0.003 2.253 3.620 4.170 2.250 3.617 4.167 0.001 2.251 3.618 4.168 0.002 2.252 3.619 4.169 0.003 2.253 3.620 4.170 0 2.250 3.617 4.167 0.001 2.251 3.618 4.168 0.002 2.252 3.619 4.169 0.003 2.253 3.620 4.170
      set -l tagc (count $tags)
      __theme_showcase_print "$fish_color_search_match $fish_pager_color_prefix" "v7."
      set_color $fish_color_search_match $fish_pager_color_completion
      printf "%-5s" "$tags[$i]"
      __theme_showcase_print $fish_color_search_match "  "
      __theme_showcase_print "$fish_color_search_match $fish_pager_color_description" "(Tag)"
      __theme_showcase_print normal "  "

      while test $tagc -le (count $tags)
        __theme_showcase_print "$fish_pager_color_prefix" "v7."
        set_color $fish_pager_color_completion
        printf "%-5s" "$tags[$i]"
        __theme_showcase_print normal "  "
        __theme_showcase_print "$fish_pager_color_description" "(Tag)"
        __theme_showcase_print normal "  "
        set length (math $length + 17)
        set tagc (math $tagc - 1)
        set i (math $i + 1)
        if test (math $length + 19) -gt $cols
          printf "\n"
          set linec (math $linec + 1)
          set length 0
          if begin
              test $tagc -lt (math $cols / 17)
              or test $linec -ge 4
            end
            break
          end
        end
      end

      __theme_showcase_print "$fish_pager_color_progress" "…and 861 more rows\n"

      # Complex command
      __theme_showcase_prompt 0 0 (
        __theme_showcase_print "$fish_color_command" "printf"
        __theme_showcase_print normal " "
        __theme_showcase_print "$fish_color_quote" "\"foo %%s\\\n\""
        __theme_showcase_print normal " "
        __theme_showcase_print "$fish_color_match" "("
        __theme_showcase_print "$fish_color_command" "echo"
        __theme_showcase_print normal " "
        __theme_showcase_print "$fish_color_param" "\$bar"
        __theme_showcase_print "$fish_color_match" ")"
        __theme_showcase_print normal " "
        __theme_showcase_print "$fish_color_redirection" "^"
        __theme_showcase_print normal " "
        __theme_showcase_print "$fish_color_redirection" "/dev/null"
        __theme_showcase_print normal " "
        __theme_showcase_print "$fish_color_end" "|"
        __theme_showcase_print normal " "
        __theme_showcase_print "$fish_color_command" "tr"
        __theme_showcase_print normal " "
        __theme_showcase_print "$fish_color_quote" "\" \""
        __theme_showcase_print normal " "
        __theme_showcase_print "$fish_color_escape" "\\\\t\n"
      )

      # Root user
      # This relies on fish_prompt using $USER to change colors.
      set -l current_user $USER
      set -gx USER root
      __theme_showcase_prompt 0 0 (
        __theme_showcase_print "$fish_color_command" "make"
        __theme_showcase_print normal " "
        __theme_showcase_print "$fish_color_param" "install"
        __theme_showcase_print normal " "
        __theme_showcase_print "$fish_color_comment" "# this is a nice comment :D\n"
      )
      set -gx USER $current_user

      # History search
      __theme_showcase_prompt 2 0 (
        set_color "$fish_color_search_match"
        set_color "$fish_color_command"
        printf "apt-get"
        printf " "
        set_color "$fish_color_param"
        printf "ins"
        __theme_showcase_print "$fish_color_param" "tall"
        __theme_showcase_print normal " "
        __theme_showcase_print "$fish_color_param" "vim-nox"
      )
    end

    # Empty prompt
    __theme_showcase_prompt

    if test "$confirm" = 'true'
      read -p "$confirm_msg" -n 1 answer
      if test $answer = 'q'
        break
      else if test "$answer" = 'a'
        set confirm false
      end
    end
  end

  # Restore prompts
  if functions -q $saved_lprompt
    functions -e fish_prompt
    functions -c $saved_lprompt fish_prompt
    functions -e $saved_lprompt
  end
  if functions -q $saved_rprompt
    functions -e fish_right_prompt
    functions -c $saved_rprompt fish_right_prompt
    functions -e $saved_rprompt
  end
  echo
  set_color normal; echo "Done"
end
