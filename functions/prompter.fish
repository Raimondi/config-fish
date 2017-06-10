function prompter
  set exit_status $status
  set duration $CMD_DURATION
  set flags_done
  set args
  set git
  set hg
  set svn
  set nocolor
  set jobs (jobs | awk '/[0-9]+\t/ {count++} END {print count}')
  if not set -q __prompter_setup
    set -g __prompter_help '
        '(set_color -o white)'prompter'(set_color normal)' -- noun: a person or thing that prompts.

    '(set_color -o white)'Synopsis'(set_color normal)'
        prompter [--help | -h] [--git] [--hg] [--svn] [--default-color=<color>]
                [--color=<color>] <args>

    '(set_color -o white)'Description'(set_color normal)'
        prompter is a command to quickly create a prompt from a template string.

        The following options are available:

        · --help or -h prints this text.
        · --default-color=acolor sets the default color to "acolor". "acolor"
          can be any color accepted by set_color.
        · --color=bcolor defines a color that can be used with (color:bcolor).

        The arguments are joined and the sequence of characters will be
        interpreted as follows:

        · These characters are special and must be escaped (, ), {, }, ? and :,
          to be inserted in the output. Any other will be inserted literally.

        · A label will be replaced for the corresponding text. A label has the
          the following format: (name:[modifier1[,modifier2,...]])

        · A conditional block has the following form: {condition?ifTrue:ifFalse}
          if the condition is true the sequence ifTrue will be inserted,
          otherwise the sequence ifFalse will be.

        The available labels and what they are replaced with are these:
        · (user)   -> $USER
        · (host: style) -> host name
          style can be one of the following:
          · short: just the host (default)
          · full:  host and domain
        · (pwd: style, length) -> $PWD
          Every element will be shortened to the given length unless it is 0.
          style can be one of the following:
          · full: full path
          · relative: path relative to $HOME (default)
          · tail: last element of the path
          · bothends: ~/ or / folowed by the last element of the path
        · (jobs)     -> number of jobs
        · (time: "format") -> current time
          The format is a double quoted string that is passed to `date` to get
          the time. See `man strftime`.
        · (status)   -> exit status
        · (vcs)      -> VCS status (currently git only)
        · (duration) -> command duration
        · (c[olor]: foreground, background) -> colorize with the given colors
          foreground and background can be one of the following:
          · auto: start colorizing automatically.
          · reset: like doing `set_color normal`. This is the default when no
            color is given.
          · Any of fish color variables with the "fish_color_" part removed with
            the exception of search_match, valid_path and the pager variables.
            See fish documentation for the list of color variable names.
          · Any of the colors listed by `set_color -c`.
          · Any color given with the --color flag.

        A conditional block can use one of the following items to see which part
        to insert in the output:
          · root        -> true if effective uid is 0
          · jobs        -> true if jobs > 0
          · status      -> true if exit_status != 0
          · nested      -> true if $SHLVL > 0
          · vcs         -> true if under VCS
          · remote      -> true if in a remote session
          · multiplexer -> true if runnning inside a terminal multiplexer

        prompter will colorize the output automatically if no color label is
        used, in order to prevent this behavior you can use an empty (color)
        label at the beggining of the template.

    '(set_color -o white)'Examples'(set_color normal)'
        '(set_color -o white)'prompter'(set_color normal)' '"'"'{status?(color:red)\((status)\) }'"'"' \
                '"'"'(c)(user)@(host) '"'"' \
                '"'"'{root?(color:cwd_root)(pwd)(color)#:(color:cwd)(pwd)(color:reset)>} '"'"'

          This replicates the built-in prompt classic_status.fish. The first
          argument is a conditional block that inserts the exit status in red
          if it is non-zero. The next one resets the color and adds the user
          name and host. And the last part checks if the user is root and puts
          the cwd colorized with the according color and then resets colors and
          adds a "> " or "# " at the end.
'
    set -g __prompter_fish_colors autosuggestion command comment cwd cwd_root \
       end error escape history_current host match normal operator param quote \
       redirection status user
    set -g __prompter_named_colors (set_color -c)
    set -g __prompter_reset_color (set_color normal)
    set -g __prompter_bold_color (set_color -o)
    set -g __prompter_underline_color (set_color -u)
    set -g __prompter_fg_named
    set -g __prompter_bg_named
    set -g __prompter_fg_fish
    set -g __prompter_bg_fish
    set -g __prompter_default_color (set_color $fish_color_quote)
    for name in $__prompter_named_colors
      set __prompter_fg_named $__prompter_fg_named (set_color $name)
      set __prompter_bg_named $__prompter_bg_named (set_color -b $name)
    end
    # TODO Need to be certain these really work.
    set -g __prompter_tty (tty)
    switch (uname)
      case Linux
        if string match -q -r 'console|tty' "$__prompter_tty"
          set -g __prompter_console true
        end
      case Darwin
        if string match -q -r 'console' "$__prompter_tty"
          set -g __prompter_console true
        end
      case FreeBSD
        if string match -q -r 'console|tty' "$__prompter_tty"
          set -g __prompter_console true
        end
      case OpenBSD
        if string match -q -r 'console|ttyC?\d' "$__prompter_tty"
          set -g __prompter_console true
        end
      case NetBSD
        if string match -q -r 'console|tty' "$__prompter_tty"
          set -g __prompter_console true
        end
      case \*
        if string match -q -r 'console|tty' "$__prompter_tty"
          set -g __prompter_console true
        end
    end
    set -g __prompter_setup true
  end

  for arg in $argv
    if test -n "$flags_done"
      set args $args $arg
      continue
    end
    switch $arg
      case --help -h
        echo $__prompter_help
        return 0
      case --default-color\*
        set color_arg (string replace -r -- '--default-color=(.*)' '$1' "$arg")
        set __prompter_default_color (eval "set_color $color_arg")
      case --color\*
        set arg (string replace -r -- '--color=(.+)' '$1' "$arg")
        set custom_colors $custom_colors $arg
        set fg_custom $fg_custom (set_color $arg)
        set bg_custom $bg_custom (set_color -b $arg)
      case --git
        set git true
      case --hg
        set hg true
      case --svn
        set svn true
      case --nocolors
        set nocolor true
      case --
        set flags_done true
      case -\*
        echo "prompter: wrong flag \"$arg\"." >&2
        return 30
      case \*
        set flags_done true
        set args $args $arg
    end
  end

  set __prompter_fg_fish
  set __prompter_bg_fish
  for name in $__prompter_fish_colors
    set color_name fish_color_$name
    set __prompter_fg_fish $__prompter_fg_fish (eval "set_color $$color_name")
    set __prompter_bg_fish $__prompter_bg_fish (eval "set_color -b $$color_name")
  end

  if begin
      not set -q __prompter_awk_file
      or not test -r "$__prompter_awk_file"
    end
    for dir in $fish_function_path
      if test -r $dir/prompter.awk
        set -g __prompter_awk_file $dir/prompter.awk
        break
      end
    end
    if not set -q __prompter_awk_file
      echo "Could not find prompter.awk" >&2
      return 1
    end
  end
  # This can be slow so only do it if vcs is used
  if string match -q -r 'vcs' "$args"
    set git (__fish_git_prompt '%s')
    set hg  (__fish_hg_prompt  '%s')
    set svn (__fish_svn_prompt '%s')
    set vcs "$git$hg$svn"
  else if string match -q -r 'git' "$args"
    set git (__fish_git_prompt '%s')
  else if string match -q -r 'hg' "$args"
    set hg (__fish_hg_prompt '%s')
  else if string match -q -r 'svn' "$args"
    set svn (__fish_svn_prompt '%s')
  end
  if test -n "$TMUX$STY"
    set multiplexer true
  end
  if test -n "$SSH_CLIENT$SSH_TTY"
    set remote true
  end
  if not set -q __prompter_hostname
    set -g __prompter_hostname (hostname)
  end
  if not set -q __prompter_chroot
    if test -r /etc/debian_chroot
      set -g __prompter_chroot (cat /etc/debian_chroot)
    else
      set -g __prompter_chroot
    end
  end
  if test -w "$PWD"
    set cwd_write 1
  end
  echo -sn $args | awk                                \
     -f "$__prompter_awk_file"                        \
     -v name="prompter"                               \
     -v nocolor="$nocolor"                            \
     -v reset_color="$__prompter_reset_color"         \
     -v winwidth=(tput cols)                          \
     -v bold_color="$__prompter_bold_color"           \
     -v underline_color="$__prompter_underline_color" \
     -v default_color="$__prompter_default_color"     \
     -v custom_str="$custom_colors"                   \
     -v customfg_str="$fg_custom"                     \
     -v custombg_str="$bg_custom"                     \
     -v named_str="$__prompter_named_colors"          \
     -v namedfg_str="$__prompter_fg_named"            \
     -v namedbg_str="$__prompter_bg_named"            \
     -v fish_str="$__prompter_fish_colors"            \
     -v fishfg_str="$__prompter_fg_fish"              \
     -v fishbg_str="$__prompter_bg_fish"              \
     -v jobs="$jobs"                                  \
     -v hostname="$__prompter_hostname"               \
     -v status="$exit_status"                         \
     -v vcs="$vcs"                                    \
     -v git="$git"                                    \
     -v hg="$hg"                                      \
     -v svn="$svn"                                    \
     -v chroot="$__prompter_chroot"                   \
     -v tty="$__prompter_tty"                         \
     -v duration="$duration"                          \
     -v user="$USER"                                  \
     -v uid=(id -u $USER)                             \
     -v shlvl="$SHLVL"                                \
     -v sudouser="$SUDO_USER"                         \
     -v logname="$LOGNAME"                            \
     -v multiplexer="$multiplexer"                    \
     -v remote="$remote"                              \
     -v cwd="$PWD"                                    \
     -v cwdwrite="$cwd_write"                         \
     -v home="$HOME"                                  \
     -v console="$__prompter_console"                 \
     -
end
