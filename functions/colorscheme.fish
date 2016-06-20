function colorscheme --description "Set fish color variables according to the given color values."
  # This function depends on __colorscheme_set to do the magic
  set -l argc (count $argv)
  set -l colors
  set -l colorc
  set -l action
  set -l exit
  set -l help_msg "\
Usage:
colorscheme -p|--print|-l|--list|-d|--default|-h|--help [COLOR1[ COLOR2...]]
colorscheme [-s|--set] COLOR1[ COLOR2...]
Tool to set fish colors using a colorscheme of up to 5 colors.
With no arguments it behaves as with --print.
When colors are provided for preview or list, the given colors are used.
  -s, --set	set fish colors with the given colorscheme.
  -p, --preview	display every fish color variable with their values colorized
  -l, --list	display all fish color variables in a manner suitable for eval
  -r, --reset	set fish color variables to the default values
  -h, --help	display this text
"
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
     "fish_color_host" \
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

  if test $argc -gt 0
    for i in (seq $argc)
      switch $argv[$i]
        case --list -l
          set action list
        case --print -p
          set action preview
        case --help -h
          set action help
        case --reset -r
          set action reset
        case --test -t
          set action test
        case --set -s
          set action set
        case -\*
          # We don't like --background and friends here
          echo "Error: colorscheme does not accept $argv[$i]" >&2
          printf $help_msg >&2
          return 1
        case \*
          set colors $colors $argv[$i]
          if not set_color $argv[$i] >/dev/null ^&1
            echo "Error: set_color did not like \"$argv[$i]\", see \"man set_color\"" >&2
            set exit true
          end
      end
    end
  end
  if test -n "$exit"
    # Problem with the colors
    return 4
  end
  if test -z "$action"
    # Default behaviour
    if test -z "$colors"
      # Without colors
      set action preview
    else
      # With colors
      set action set
    end
  end
  set colorc (count $colors)
  if test $colorc -gt 5
    echo "Error: too many colors" >&2
    printf $help_msg >&2
    return 2
  end
  if begin
      test -z "$colors"
      and test "$action" = 'set'
    end
    echo "Error: did you forget the colors?" >&2
    printf $help_msg >&2
    return 3
  end

  switch $action
    case help
      printf $help_msg
    case reset
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

      set -ge colorscheme_colors
  end

  if contains $action reset help
    return
  else if test -n "$colors"
    __colorscheme_set $colors
  else
    set colors $colorscheme_colors
  end

  switch $action
    case list
      for color_name in $color_names
        set color_values $$color_name
        printf "set -g %-28s %s\n" $color_name $$color_name
      end
    case preview
      echo
      if test -n "$colors"
        # Print header
        printf "These are the colors in use (including the terminal background):\
           \n\n	[       ] "
        for color in $colors
          set_color $color
          echo -n "$color "
        end
        set_color normal
        echo
      else
        echo 'Default colors:'
      end
      echo
      for color_name in $color_names
        set color_values $$color_name
        if test -z "$color_values"
          set color_values normal
        end
        set_color normal
        printf "%-29s" $color_name
        set whole_value
        set fg_color
        for i in (seq (count $color_values))
          if begin
              test -z "$whole_value"
              and echo $color_values[$i] | grep -q '^-'
             end
             # Give some color to flags
             set fg_color $fish_color_normal
          end
          set whole_value $whole_value $color_values[$i]
          if begin
              test (count $color_values) -gt $i
              and echo $color_values[(math "$i + 1")] | grep -q '^-'
            end
            # if next value is a flag go and get it
            continue
          end
          if test -n "$fg_color"
            set_color $fg_color
            set fg_color
          end
          set_color $whole_value
          printf "%s" "$whole_value"
          # prevent bleeding of the current color.
          set_color normal
          printf " "
          set whole_value
        end
        printf "\n"
        set_color normal
      end
      if functions -q theme_showcase
        # More bling
        theme_showcase
      else
        echo
      end
  end
  if begin
      contains $action preview list
      and test -n "$colorscheme_colors"
    end
    # Restore colors
    __colorscheme_set $colorscheme_colors
  else
    set -g colorscheme_colors $colors
  end
end
