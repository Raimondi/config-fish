function showcase
  if not functions -q __showcase_p
    function __showcase_p -a color text
      if test (count $argv) -eq 0
        set_color normal
        printf " "
      else
        set_color normal
        eval "set_color $color"
        printf $text
      end
    end
  end
  set -l title_color "green --bold"
  stty size | read rows cols
  __showcase_p "green --bold" "\nStart of showcase"

  # Incomplete command
  __showcase_p "$title_color" "\nAn incomplete command name is an error\n\n"
  set_color normal
  fish_prompt
  __showcase_p "$fish_color_error" "tcls\n"

  # Command plus two arguments, one of them is a valid path
  __showcase_p "$title_color" "\nCommand and two arguemtns, one of those is a valid path\n\n"
  set_color normal
  fish_prompt
  __showcase_p "$fish_color_command" "tclsh"
  __showcase_p normal " "
  set_color $fish_color_param
  set_color $fish_color_valid_path
  printf "a/valid/path"
  __showcase_p
  __showcase_p "$fish_color_param" "another_argument\n"

  # Autosuggestion
  __showcase_p "$title_color" "\nAutosuggestion\n\n"
  set_color normal
  fish_prompt
  __showcase_p "$fish_color_command" "git"
  __showcase_p
  __showcase_p "$fish_color_autosuggestion" "status\n"

  # Completion pager
  __showcase_p "$title_color" "\nThe completion pager\n\n"
  set_color normal
  fish_prompt
  __showcase_p "$fish_color_command" "git"
  __showcase_p
  __showcase_p "$fish_color_param" "checkout"
  __showcase_p
  __showcase_p "$fish_color_param" "v7-\n"

  # Print the pager
  set -l length 17
  set -l linec 0
  set -l i 1
  set -l tags  2-250 3-617 4-167 0-001 2-251 3-618 4-168 0-002 2-252 3-619 4-169 0-003 2-253 3-620 4-170 0 2-250 3-617 4-167 0-001 2-251 3-618 4-168 0-002 2-252 3-619 4-169 0-003 2-253 3-620 4-170 2-250 3-617 4-167 0-001 2-251 3-618 4-168 0-002 2-252 3-619 4-169 0-003 2-253 3-620 4-170 0 2-250 3-617 4-167 0-001 2-251 3-618 4-168 0-002 2-252 3-619 4-169 0-003 2-253 3-620 4-170
  set -l tagc (count $tags)
  __showcase_p "$fish_color_search_match $fish_pager_color_prefix" "v7-"
  set_color $fish_color_search_match $fish_pager_color_completion
  printf "%-5s" "$tags[$i]"
  __showcase_p $fish_color_search_match "  "
  __showcase_p "$fish_color_search_match $fish_pager_color_description" "(Tag)"
  __showcase_p normal "  "

  while test $tagc -le (count $tags)
    __showcase_p "$fish_pager_color_prefix" "v7-"
    set_color $fish_pager_color_completion
    printf "%-5s" "$tags[$i]"
    __showcase_p normal "  "
    __showcase_p "$fish_pager_color_description" "(Tag)"
    __showcase_p normal "  "
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

  __showcase_p "$fish_pager_color_progress" "…and 861 more rows\n"

  # Complex command
  __showcase_p "$title_color" "\nA bit more complex command\n\n"
  set_color normal
  fish_prompt
  __showcase_p "$fish_color_command" "printf"
  __showcase_p
  __showcase_p "$fish_color_quote" "\"foo %%s\\\n\""
  __showcase_p
  __showcase_p "$fish_color_match" "("
  __showcase_p "$fish_color_command" "echo"
  __showcase_p
  __showcase_p "$fish_color_param" "\$bar"
  __showcase_p "$fish_color_match" ")"
  __showcase_p
  __showcase_p "$fish_color_redirection" "^"
  __showcase_p
  __showcase_p "$fish_color_redirection" "/dev/null"
  __showcase_p
  __showcase_p "$fish_color_end" "|"
  __showcase_p
  __showcase_p "$fish_color_command" "tr"
  __showcase_p
  __showcase_p "$fish_color_quote" "\" \""
  __showcase_p
  __showcase_p "$fish_color_escape" "\\\\t\n"

  # Root user
  # This relies on fish_prompt using $USER to change colors.
  __showcase_p "$title_color" "\nRoot user's prompt and a comment\n\n"
  set -l current_user $USER
  set -gx USER root
  set_color normal
  fish_prompt
  __showcase_p "$fish_color_command" "git"
  __showcase_p
  __showcase_p "$fish_color_param" "status"
  __showcase_p
  __showcase_p "$fish_color_comment" "# this is a nice comment :D\n"
  set -gx USER $current_user

  # History search
  __showcase_p "$title_color" "\nHistory search\n\n"
  set_color normal
  fish_prompt
  set_color "$fish_color_search_match"
  set_color "$fish_color_command"
  printf "git"
  set_color normal
  set_color "$fish_color_search_match"
  printf " "
  set_color "$fish_color_param"
  printf "fetch"
  __showcase_p
  __showcase_p "$fish_color_param" "upstream"

  __showcase_p "$title_color" "\n\n~~~~~~~~~\n"
end
