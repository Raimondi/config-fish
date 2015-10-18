function colorscheme --description "Set fish color variables according to the given colors."
  #-a c1 c2 c3 c4 c5 grey error normal
  set -l argc (count $argv)
  set -l colors
  set -l action
  set -l action_set
  set -l current_colors $colorscheme_colors
  set -l exit

  if test $argc -gt 0
    for i in (seq $argc)
      switch $argv[$i]
        case --list -l
          set action list
        case --print -p
          set action print
        case --help -h
          set action help
        case --default -d
          set action default
        case --test -t
          set action test
        case -\*
          echo "Error: colorscheme does not accept $argv[$i]" >&2
          colorscheme -h >&2
          return 1
        case \*
          set colors $colors $argv[$i]
      end
    end
  end
  for color in $colors
    if not set_color $color
      echo "Error: colorscheme does not accept colors in this format: $color" >&2
      set exit true
    end
  end
  if test -n "$exit"
    return 5
  end
  if test -z "$action"
    if test -z "$colors"
      set action print
    else
      set action set
    end
  end
  if test -n "$colors"
    set -l colorc (count $colors)
    if test $colorc -gt 8
      echo "Error: too many colors" >&2
      colorscheme -h >&2
      return 2
    end
    if test $colorc -lt 5
      echo "Error: not enough colors" >&2
      colorscheme -h >&2
      return 3
    end
  end
  if begin
      test -n "$colors"
      and test "$action" != "set"
    end
    colorscheme $colors
  end
  switch $action
    case help
      printf "Usage: colorscheme [-p|--print|-l|--list|-d|--default|-s|--show|-h|--help] [COLOR1 COLOR2 COLOR3 COLOR4 COLOR5[ GREY[ ERROR[ NORMAL]]]]\n"
      printf "Set fish colors using a colorscheme.\n"
      printf "With no arguments it behaves as with --print.\n"
      printf "When colors are provided for print, show and list, the given colors are used.\n"
      printf "  -p, --print   display every fish color variable with their values colorized\n"
      printf "  -l, --list    display all fish color variables in a manner suitable for eval\n"
      printf "  -d, --default set fish color variables to the default values\n"
      printf "  -h, --help    display this help and exit\n"

    case set
      set -l color
      set -l colorc (count $colors)
      set -l abort 0

      if test $colorc -ge 6
        set grey $colors[6]
      else
        set grey $colors[4]
      end
      if test $colorc -ge 7
        set error $colors[7]
      else
        set error $colors[1]
      end
      if test $colorc -ge 8
        set normal $colors[8]
      else
        set normal $colors[3]
      end
      # Color 1
      set color $colors[1]

      set -g fish_color_history_current   "$color"
      set -g fish_color_cwd_root          "$color"
      set -g fish_color_quote             "$color"

      # Color 2
      set color $colors[2]

      set -g fish_color_match             "$color"
      set -g fish_color_redirection       "$color"
      set -g fish_color_operator          "$color"
      set -g fish_pager_color_progress    "$color"
      set -g fish_color_search_match      "--background=$color"

      # Color 3
      set color $colors[3]

      set -g fish_color_user              "$color"
      set -g fish_color_cwd               "$color"
      set -g fish_color_host              "$color"

      # Color 4
      set color $colors[4]

      set -g fish_color_escape            "$color"
      set -g fish_color_param             "$color"

      # Color 5
      set color $colors[5]

      set -g fish_color_command           "$color"
      set -g fish_color_end               "$color"
      set -g fish_color_status            "$color"
      set -g fish_pager_color_secondary   "$color"
      set -g fish_pager_color_prefix      "$color"

      # Color normal
      set color $normal

      set -g fish_color_normal            "$color"
      set -g fish_pager_color_description "$color"

      # Color error
      set color $error

      set -g fish_color_error             "$color"

      # Color grey
      set color $grey

      set -g fish_color_autosuggestion    "$color"
      set -g fish_color_comment           "$color"
      set -g fish_pager_color_completion  "$color"

      set -g fish_color_valid_path        "--underline"

    case print list
      set -l color_names \
         "fish_color_autosuggestion" \
         "fish_color_command" \
         "fish_color_comment" \
         "fish_color_cwd" \
         "fish_color_cwd_root" \
         "fish_color_end" \
         "fish_color_error" \
         "fish_color_escape" \
         "fish_color_history_current" \
         "fish_color_match" \
         "fish_color_normal" \
         "fish_color_operator" \
         "fish_color_param" \
         "fish_color_quote" \
         "fish_color_redirection" \
         "fish_color_search_match" \
         "fish_color_status" \
         "fish_color_user" \
         "fish_color_valid_path" \
         "fish_pager_color_completion" \
         "fish_pager_color_description" \
         "fish_pager_color_prefix" \
         "fish_pager_color_progress" \
         "fish_pager_color_secondary"

      if test -n "$colors"
        eval "colorscheme $colors"
      end
      if test "$action" = "print"
        for color_name in $color_names
          set color_values $$color_name
          if test -z "$color_values"
            set color_values normal
          end
          set_color normal
          set_color ffffff
          printf "%-29s" $color_name
          for color_value in $color_values
            set_color $color_value
            printf "%s" $color_value
            # prevent bleeding of the current color.
            set_color normal
            printf " "
          end
          printf "\n"
          set_color normal
        end
      else
        for color_name in $color_names
          set color_values $$color_name
          if test -z "$color_values"
            set color_values normal
          end
          printf "set -g %-28s" $color_name
          for color_value in $color_values
            printf " %s" $color_value
          end
          printf "\n"
        end
      end

    case default
      # Set colors to default values
      set -g fish_color_autosuggestion    555 yellow
      set -g fish_color_command           005fd7 purple
      set -g fish_color_comment           red
      set -g fish_color_cwd               green
      set -g fish_color_cwd_root          red
      set -g fish_color_end               normal
      set -g fish_color_error             red --bold
      set -g fish_color_escape            cyan
      set -g fish_color_history_current   cyan
      set -g fish_color_match             cyan
      set -g fish_color_normal            normal
      set -g fish_color_operator          cyan
      set -g fish_color_param             00afff cyan
      set -g fish_color_quote             brown
      set -g fish_color_redirection       normal
      set -g fish_color_search_match      --background=purple
      set -g fish_color_status            normal
      set -g fish_color_user              normal
      set -g fish_color_valid_path        --underline
      set -g fish_pager_color_completion  normal
      set -g fish_pager_color_description 555 yellow
      set -g fish_pager_color_prefix      cyan
      set -g fish_pager_color_progress    cyan
      set -g fish_pager_color_secondary   normal

  end

  if test $action = 'set'
    set -g colorscheme_colors $colors
  else if test $action = 'default'
    set -g colorscheme_colors
  else
    if test -z "$colorscheme_colors"
      colorscheme --default
    else
      colorscheme $current_colors
    end
  end
end
