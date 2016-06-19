function theme_showcase -d 'Create a showcase of the current color theme.'
  if not functions -q __theme_showcase_clean
    function __theme_showcase_clean --argument text
      echo -n  "$text" \
         | string replace -r -a "\\x1B\\[(\\d{1,3}(;\\d{1,3})*)?[mGK]" ""\
         | string replace -r -a "\x1B](\\d{1,3};(\\d{1,3};)*)?B" ""\
         | string replace -r -a "[[:cntrl:]]" ""
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
    function __theme_showcase_prompt -a text
      # Print the left prompt and the given text, if there is enough space
      # print the right prompt.
      set -l output
      set -l padding
      set -l rprompt
      stty size | read rows cols
      set_color normal
      if functions -q fish_prompt
        set output (fish_prompt)
      end
      set output[-1] "$output[-1]$text"
      set ltext (__theme_showcase_clean "$output[-1]")
      if functions -q fish_right_prompt
        set rprompt (fish_right_prompt | tr -d '\\n')
      end
      set -l rtext (__theme_showcase_clean "$rprompt")
      set -l text_length (string length "$ltext$rtext")
      set -l pad_length (math $cols - $text_length)
      if test "$pad_length" -gt 0
        set padding (printf "%"$pad_length"s" "")
        set output[-1] "$output[-1]$padding"
        set output[-1] "$output[-1]$rprompt"
      end
      for line in $output
        echo $line
      end
    end
  end

  set -l title_color "$fish_color_comment --bold"
  stty size | read rows cols

  printf "\
The following cases are showcased:

- Full command:
  > man 7 re_format
- Command with a valid path and an invalid path:
  > multitail valid/path.log invalid/path.log
- Incomplete command (error) and autosuggestion (as if the cursor were at the |):
  > wee|chat
- Completion pager:
  > git checkout v7.2.250
- A more complex command:
  > printf \"foo %s\\\\n\" (echo \$bar) ^ /dev/null | tr \" \" \\\\t
- As root, a command and a comment (works if $USER is used to detect root user):
  > make install # this is a nice comment
- Search match (as if the cursor were at the |):
  > apt-get ins|tall vim-nox\n\n"

  # Complete command
  __theme_showcase_prompt (__theme_showcase_print "$fish_color_command" "man"
  __theme_showcase_print normal " "
  __theme_showcase_print "$fish_color_param" "7"
  __theme_showcase_print normal " "
  __theme_showcase_print "$fish_color_param" "re_format")

  # Command plus two arguments, one of them is a valid path
  __theme_showcase_prompt (__theme_showcase_print "$fish_color_command" "multitail"
  __theme_showcase_print normal " "
  set_color $fish_color_param
  set_color $fish_color_valid_path
  printf "valid/path.log"
  __theme_showcase_print normal " "
  __theme_showcase_print "$fish_color_param" "invalid/path.log\n")

  # Incomplete command with autosuggestion
  __theme_showcase_prompt (__theme_showcase_print "$fish_color_error" "wee"
  __theme_showcase_print "$fish_color_autosuggestion" "chat")

  # Completion pager
  __theme_showcase_prompt (__theme_showcase_print "$fish_color_command" "git"
  __theme_showcase_print normal " "
  __theme_showcase_print "$fish_color_param" "checkout"
  __theme_showcase_print normal " "
  __theme_showcase_print "$fish_color_param" "v7.2.250\n")

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
  __theme_showcase_prompt (__theme_showcase_print "$fish_color_command" "printf"
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
  __theme_showcase_print "$fish_color_escape" "\\\\t\n")

  # Root user
  # This relies on fish_prompt using $USER to change colors.
  set -l current_user $USER
  set -gx USER root
  __theme_showcase_prompt (__theme_showcase_print "$fish_color_command" "make"
  __theme_showcase_print normal " "
  __theme_showcase_print "$fish_color_param" "install"
  __theme_showcase_print normal " "
  __theme_showcase_print "$fish_color_comment" "# this is a nice comment :D\n")
  set -gx USER $current_user

  # History search
  __theme_showcase_prompt (set_color "$fish_color_search_match"
  set_color "$fish_color_command"
  printf "apt-get"
  printf " "
  set_color "$fish_color_param"
  printf "ins"
  __theme_showcase_print "$fish_color_param" "tall"
  __theme_showcase_print normal " "
  __theme_showcase_print "$fish_color_param" "vim-nox")
end