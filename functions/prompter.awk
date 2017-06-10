# [ ] duration style

# prompt       : (conditional | block) *
# conditional  : if_either | if_true | if_false
# if_either    : "{" blank ident if_true if_false "}"
# if_false     : "{" blank ident if_false "}"
# if_true      : "{" blank ident true_block "}"
# true_block   : "?" blank block ?
# false_block  : ":" blank block ?
# block        : (label | literal | conditional) +
# label        : "(" blank ident label_mods ? ")"
# label_mods   : label_mod ("," blank label_mod) *
# label_mod    : (ident | string)
# string       : "\"" schar * "\"" blank
# schar        : escaped | /[^"]/
# literal      : lchar +
# lchar        : escaped | /[^{}()?:]/
# escaped      : "\" /./
# ident        : /[a-zA-Z0-9_]/ + blank
# blank        : " " *

function append(a_text, a_depth_offset) {
  output[depth + a_depth_offset] = (output[depth + a_depth_offset] a_text)
}
function get_ident() {
  byte_ident[depth] = i
  b_ident = ""
  b_i = i
  while (($b_i ~ /[a-zA-Z0-9_]/) && (b_i <= NF)) {
    b_ident = b_ident $b_i
    b_i++
  }
  b_delta = b_i - i
  if (b_delta) inc_i(b_delta)
  return b_ident
}
function inc_i(c_arg) {
  c_arg = c_arg ? c_arg : 1
  i += c_arg
  byte_count += c_arg
}
function skip_blank() {
  while (i <= NF && $i ~ /[[:blank:]]/) inc_i()
}
function colorize(d_default_fg, d_default_bg) {
  if (! auto_colors) return 0
  if (d_default_fg == "cwd"){
    if (user == "root") {
      append(fg["cwd_root"])
      append(bg["cwd"])
    } else if (!conditions["cwdwrite"]) {
      append(fg["error"])
    } else {
      append(fg["cwd"])
    }
  } else {
    append(fg[d_default_fg])
  }
  if (d_default_bg) append(bg[d_default_bg])
}
function re_escape(e_str) {
  gsub(/\\/,   "\\\\", e_str)
  gsub(/\(/,   "\\(", e_str)
  gsub(/\)/,   "\\)", e_str)
  gsub(/[\]]/, "\\[", e_str)
  gsub(/\]/,   "\\]", e_str)
  gsub(/\+/,   "\\+", e_str)
  gsub(/\*/,   "\\*", e_str)
  gsub(/\?/,   "\\?", e_str)
  gsub(/[{]/,  "\\{", e_str)
  gsub(/[}]/,  "\\}", e_str)
  gsub(/\|/,   "\\|", e_str)
  gsub(/\./,   "\\.", e_str)
  gsub(/\^/,   "\\^", e_str)
  gsub(/\$/,   "\\$", e_str)
  return e_str
}
function subhome(f_str) {
  sub(re_escape(home), "~", f_str)
  sub(/\/?$/, "/", f_str)
  return f_str
}
function abbrpath(g_str, g_len) {
  if (! g_len) return g_str
  g_result = ""
  g_count = split(g_str, g_array, "/")
  for (g_i = 1; g_i < g_count; g_i++) {
    g_result = g_result substr(g_array[g_i], 1, g_len) "/"
  }
  return g_result g_array[g_i]
}
function fmtpath(h_str, h_style, h_len) {
  if (h_str == "/") return h_str
  h_tail = h_str
  sub(/.*\//, "", h_tail)
  h_relative = subhome(h_str)
  underhome = h_relative ~ /^~/
  if (h_style == "full") {
    return abbrpath(h_str, h_len)
  } else if (h_style == "relative") {
    h_str = subhome(h_str)
    h_str = abbrpath(h_str, h_len)
    return h_str
  } else if (h_style == "tail") {
    return h_tail
  } else if (h_style == "bothends") {
    sub(/'/, "'\"'\"'", h_relative)
    cmd = "echo '" h_relative "' | sed -E -e 's-^(~?/)(.*/)?([^/]*)-\\1\\3-'"
    cmd | getline h_short
    close(cmd)
    sub(/\//, "/.../", h_short)
    return (h_short == "~" ? "~/" : h_short)
  }
  return h_str
}
function get_string() {
  byte_string[depth] = i
  i_string = ""
  i_i = i
  while (($i_i != "\"") && (i_i <= NF)) {
    if ($i_i == esc) {
      i_i++
      if (i_i > NF) break
    }
    i_string = i_string $i_i
    i_i++
  }
  inc_i(i_i - i)
  return i_string
}
function empty_a(j_array) {
  for (j_i in j_array) return 1
  return 0
}
function print_error(k_msg, k_byte) {
  k_line_c = "."
  k_out = name ": " k_msg "\n\n" fg["normal"]
  k_len = split(template, k_chars, "")
  k_eol = k_byte == -1
  k_byte = k_byte > 0 ? k_byte : byte_count
  for (k_i = 1; k_i <= k_len; k_i++) {
    k_count++
    if (k_i >= (k_byte - k_eol)&& !k_pointer) {
      # Prepare pointer and highlight error.
      k_pointer = fg["reset"]
      for (k_j = 1; k_j < k_count; k_j++) k_pointer = k_pointer k_line_c
      if (k_eol) k_pointer = k_pointer k_line_c
      k_pointer = k_pointer fg["bold"] "^\n" fg["reset"]
      k_out = k_out fg["error"] fg["bold"] k_chars[k_i] fg["reset"] fg["normal"]
    } else if (k_chars[k_i] == "\n" || k_count >= winwidth) {
      # Line feed
      k_out = k_out k_chars[k_i]
      if (k_chars[k_i] != "\n") k_out = k_out "\n"
      k_count = 0
      if (k_pointer) break
    } else {
      k_out = k_out k_chars[k_i]
    }
  }
  print k_out k_pointer "\n" > "/dev/stderr"
}
BEGIN {
  if (name == "") {
    name = "prompter"
    print name ": error: this script must be used from its companion fish script " name ".fish." > "/dev/stderr"
    exit 17
  }
  FS = ""
  OFS = ""
  ORS = ""
  esc = "\\"
  condition[0] = 0
  depth = 0
  byte_count = 0
  byte_ocurly[0] = 0
  byte_question[0] = 0
  byte_colon[0] = 0
  byte_ident[0] = 0
  byte_element_name[0] = 0
  byte_element_mod[0] = 0
  condition_done[depth] = 0
  ifTrue_done[depth] = 0
  ifFalse_done[depth] = 0
  label_name = ""
  template = ""
  fg["default"] = default_color
  fg["reset"] = reset_color
  fg["bold"] = bold_color
  fg["underline"] = underline_color
  split(named_str, named, / +/)
  split(namedfg_str, namedfg, / +/)
  split(namedbg_str, namedbg, / +/)
  for (idx in named) {
    fg[named[idx]] = namedfg[idx]
    bg[named[idx]] = namedbg[idx]
  }
  split(fish_str, fish, / +/)
  split(fishfg_str, fishfg, / +/)
  split(fishbg_str, fishbg, / +/)
  for (idx in fish) {
    fg[fish[idx]] = fishfg[idx]
    bg[fish[idx]] = fishbg[idx]
  }
  split(custom_str, custom, / +/)
  split(customfg_str, customfg, / +/)
  split(custombg_str, custombg, / +/)
  for (idx in custom) {
    fg[custom[idx]] = customfg[idx]
    bg[custom[idx]] = custombg[idx]
  }
  # name="prompter"
  # nocolor="$nocolor"
  # reset_color="$__prompter_reset_color"
  # winwidth=(tput cols)
  # bold_color="$__prompter_bold_color"
  # underline_color="$__prompter_underline_color"
  # default_color="$__prompter_default_color"
  # custom_str="$custom_colors"
  # customfg_str="$fg_custom"
  # custombg_str="$bg_custom"
  # named_str="$__prompter_named_colors"
  # namedfg_str="$__prompter_fg_named"
  # namedbg_str="$__prompter_bg_named"
  # fish_str="$__prompter_fish_colors"
  # fishfg_str="$__prompter_fg_fish"
  # fishbg_str="$__prompter_bg_fish"
  # jobs="$jobs"
  # hostname="$__prompter_hostname"
  # status="$exit_status"
  # vcs="$vcs"
  # git="$git"
  # hg="$hg"
  # svn="$svn"
  # chroot="$__prompter_chroot"
  # tty="$__prompter_tty"
  # duration="$duration"
  # user="$USER"
  # uid=(id -u $USER)
  # shlvl="$SHLVL"
  # sudouser="$SUDO_USER"
  # logname="$LOGNAME"
  # multiplexer="$multiplexer"
  # remote="$remote"
  # cwd="$PWD"
  # cwdreadable="$cwd_readable"
  # home="$HOME"
  # console="$__prompter_console"
  root = uid == 0
  sudo = sudouser ? 1 : 0
  su = logname ? 1 : 0
  auto_colors = !nocolors
  if (nocolor == "") output[0] = default_color
  nested = shlvl > 1
  conditions["0"] = 0
  conditions["1"] = 1
  conditions["root"] = root
  conditions["jobs"] = jobs
  conditions["status"] = status
  conditions["nested"] = nested
  conditions["chroot"] = chroot
  conditions["remote"] = remote
  conditions["vcs"] = vcs
  conditions["git"] = git
  conditions["hg"] = hg
  conditions["svn"] = svn
  conditions["console"] = console
  conditions["multiplexer"] = multiplexer
  conditions["sudo"] = sudouser ? 1 : 0
  conditions["su"] = logname != user
  conditions["simple_user"] = !(sudo || su)
  conditions["cwdwrite"] = cwdwrite ? 1 : 0
  labels["root"] = root
  labels["user"] = user
  labels["host"] = host
  labels["time"] = time
  labels["pwd"] = cwd
  labels["cwd"] = cwd
  labels["jobs"] = jobs
  labels["status"] = status
  labels["vcs"] = vcs
  labels["git"] = git
  labels["hg"] = hg
  labels["svn"] = svn
  labels["chroot"] = chroot
  labels["nested"] = shlvl
  labels["duration"] = duration
}
{
  i = 0
  rdone = 0
  inc_i()
  template = template $0 "\n"
  if (NR > 1) {
    append("\n")
  }
  while (i <= NF) {
    if ($i == esc) {
      inc_i()
      if (i > NF) {
        continue
      }
      colorize("default")
      if ($i == "n") {
        append("\n")
      } else if ($i == "b") {
        append("\b")
      } else if ($i == "f") {
        append("\f")
      } else if ($i == "r") {
        append("\r")
      } else if ($i == "t") {
        append("\t")
      } else if ($i == "v") {
        append("\v")
      } else {
        append($i)
      }
      colorize("reset")
      inc_i()
    } else if ($i == "{") {
      # Conditional block
      depth++
      # Clear previous content
      output[depth] = ""
      byte_ocurly[depth] = byte_count
      condition_done[depth] = 1
      ifTrue_done[depth] = 0
      ifFalse_done[depth] = 0
      inc_i()
      skip_blank()
      if (i > NF) {
        errmsg = "error in line " NR ": was expecting a condition but reached the end of line:"
        print_error(errmsg, -1)
        exit 13
      }
      ident = get_ident()
      if (ident == "") {
        errmsg = "error in byte " byte_count ": condition not found."
        print_error(errmsg)
        exit 6
      } else if (ident in conditions) {
        condition[depth] = conditions[ident]
      } else {
        errmsg = "error in byte " byte_ident[depth] ": unrecognized condition \"" ident "\"."
        print_error(errmsg, byte_ident[depth])
        exit 1
      }
      if (i > NF) {
        errmsg = "error in line " NR ": was expecting \"?\" or \":\" but reached the end of line."
        print_error(errmsg, -1)
        exit 16
      }
      skip_blank()
      #if ($i != "?" && $i != ":") {
      #  errmsg = "error in byte " byte_count ": was expecting \"?\" or \":\" but found \"" $i "\":"
      #  print_error(errmsg)
      #  exit 7
      #}
    } else if ($i == "?") {
      # evaluate condition
      if (ifTrue_done[depth]) {
        errmsg = "error in byte " byte_count ": " $i " after " $i ":"
        print_error(errmsg)
        exit 2
      }
      if (! condition_done[depth]) {
        errmsg = "error in byte " byte_count ": unescaped \"" $i "\":"
        print_error(errmsg)
        exit 20
      }
      byte_question[depth] = byte_count
      inc_i()
      ifTrue_done[depth] = 1
    } else if ($i == ":") {
      # ifTrue
      if (ifFalse_done[depth]) {
        errmsg = "error in byte " byte_count ": \"" $i "\" after \"" $i "\":"
        print_error(errmsg)
        exit 4
      }
      if (! condition_done[depth]) {
        errmsg = "error in byte " byte_count ": unescaped \"" $i "\":"
        print_error(errmsg)
        exit 21
      }
      byte_colon[depth] = byte_count
      if (ifTrue_done[depth] && condition[depth]) {
        append(output[depth], -1)
      }
      ifFalse_done[depth] = 1
      # Clear previous content
      output[depth] = ""
      inc_i()
    } else if ($i == "}") {
      if (!condition_done[depth]) {
        errmsg = "error in byte " byte_count ": unpaired \"" $i "\":"
        print_error(errmsg)
        exit 22
      }
      if (condition_done[depth] && ! ifTrue_done[depth] && ! ifFalse_done[depth]) {
        errmsg = "error in byte " byte_count ": was expecting \"?\" or \":\" but found \"" $i "\":"
        print_error(errmsg)
        exit 5
      }
      if (ifFalse_done[depth] && ! condition[depth]) {
        # ifFalse
        append(output[depth], -1)
      } else if (!ifFalse_done[depth] && ifTrue_done[depth] && condition[depth]) {
        # ifTrue
        append(output[depth], -1)
      }
      condition_done[depth] = 0
      ifTrue_done[depth] = 0
      ifFalse_done[depth] = 0
      depth--
      # unnecessary?
      output[depth + 1] = ""
      byte_question[depth + 1] = 0
      byte_colon[depth + 1] = 0
      inc_i()
    } else if ($i == "(") {
      # Insert item
      inc_i()
      skip_blank()
      if (i > NF) {
        errmsg = "error in line " NR ": was expecting a label name but reached the end of line:"
        print_error(errmsg, -1)
        exit 14
      }
      # Get tag name
      byte_element_name[depth] = byte_count
      label_name = ""
      label_name = get_ident()
      if (! label_name) {
        errmsg = "error in byte " byte_count ": was expecting a tag name but found \"" $i "\":"
        print_error(errmsg)
        exit 23
      }
      skip_blank()
      if (i > NF) {
        errmsg = "error in line " NR ": was expecting \":\" or \")\" but reached the end of line:"
        print_error(errmsg, -1)
        exit 24
      }
      # Clean up
      for (key in label_mods) delete label_mods[key]
      if ($i != ":" && $i != ")") {
        errmsg = "error in byte " byte_count ": was expecting \":\" or \")\" but found \"" $i "\":"
        print_error(errmsg)
        exit 8
      } else if ($i == ":") {
        # Get arguments
        mod_cnt = 0
        do {
          inc_i()
          skip_blank()
          if (i > NF) {
            errmsg = "error in line " NR ": was expecting an label modifier but reached the end of line:"
            print_error(errmsg, -1)
            exit 15
          }
          mod_cnt++
          byte_element_mod[depth,mod_cnt] = byte_count
          if ($i == "\"") {
            inc_i()
            # String
            label_mods[mod_cnt] = get_string()
            if (i > NF) {
              errmsg = "error in line " NR ": was expecting '\"' but reached the end of line:"
              print_error(errmsg, -1)
              exit 19
            }
            inc_i()
            skip_blank()
          } else {
            # Ident
            label_mods[mod_cnt] = get_ident()
          }
          skip_blank()
        } while (i <= NF && $i == ",")
      }
      if (i > NF) {
        errmsg = "error in line " NR ": was expecting \")\" but reached the end of line:"
        print_error(errmsg, -1)
        exit 18
      }
      if ($i != ")") {
        errmsg = "error in byte " byte_count ": was expecting \")\" but found \"" $i "\":"
        print_error(errmsg)
        exit 11
      }
      if (label_name == "user") {
        colorize("user")
        append(user)
        colorize("reset")
      } else if (label_name == "user_info") {
        colorize("user")
        if (conditions["root"]) {
          if (conditions["sudo"]) {
          } else if (conditions["su"]) {
          }
        } else {
        }
        append(user)
        colorize("reset")
      } else if (label_name == "tty") {
        atty = tty
        colorize("user")
        if (label_mods[1] != "full") sub(/tty|pts/, "", atty)
        append(atty)
        colorize("reset")
      } else if (label_name == "host") {
        host = hostname
        colorize("host")
        if (label_mods[1] != "full") sub(/\..*/, "", host)
        append(host)
        colorize("reset")
      } else if (label_name == "time") {
        if (label_mods[1]) {
          time_format = label_mods[1]
          sub(/^\+?/, "+", time_format)
          gsub(/'/, "'\"'\"'", time_format)
        } else {
          time_format = "+%F %T"
        }
        cmd = "date '" time_format "'"
        cmd | getline time
        close(cmd)
        colorize("host")
        append(time)
        colorize("reset")
      } else if (label_name == "pwd" || label_name == "cwd") {
        if (! label_mods[1]) label_mods[1] = "relative"
        colorize("cwd")
        new_cwd = fmtpath(cwd, label_mods[1], label_mods[2])
        append(new_cwd)
        colorize("reset")
      } else if (label_name == "color" || label_name == "c") {
        put_fg = 1
        color_name = ""
        if (empty_a(label_mods)) {
          append(fg["reset"])
          auto_colors = 0
        }
        if (length(label_mods) == 0) label_mods[1] == "reset"
        for (mod in label_mods) {
          if (label_mods[mod] == "" || label_mods[mod] == "reset") {
            append(fg["reset"])
            auto_colors = 0
            break
          } else if (label_mods[mod] == "auto") {
            auto_colors = 1
            break
          } else if (label_mods[mod] == "underline") {
            append(fg["underline"])
            auto_colors = 0
          } else if (label_mods[mod] == "bold") {
            append(fg["bold"])
            auto_colors = 0
          } else if (label_mods[mod] in fg) {
            color_name = label_mods[mod]
            auto_colors = 0
          } else if (label_mods[mod] == "bg") {
            put_fg = 0
          } else if (label_mods[mod] == "fg") {
            put_fg = 1
          } else {
            errmsg = "error in byte " byte_element_mod[depth,1] ": wrong foreground color \"" label_mods[1] "\":"
            print_error(errmsg, byte_element_mod[depth,1])
            exit 10
          }
        }
        if (color_name && put_fg) {
          append(fg[color_name])
        } else if (color_name) {
          append(bg[color_name])
        }
      } else if (label_name in labels) {
        if (label_name == "status") {
          colorize("status")
        } else {
          colorize("user")
        }
        append(labels[label_name])
        colorize("reset")
      } else {
        errmsg = "error in byte " byte_element_name[depth] ": unrecognized label name \"" label_name "\":"
        print_error(errmsg, byte_element_name[depth])
        exit 12
      }
      inc_i()
    } else if ($i == ")") {
      errmsg = "error in byte " byte_count ": unpaired \"" $i "\":"
      print_error(errmsg)
      exit 9
    } else {
      colorize("default")
      do {
        append($i)
        inc_i()
      } while (i <= NF && $i ~ /[^\\(){}?:]/)
      colorize("reset")
    }
  }
  byte_count++
  rdone = 1
}
END {
  if (rdone) {
    # Only if no errors before this
    if (depth > 0) {
      errmsg = "error in byte " byte_ocurly[depth] ": unpaired \"{\"\n"
      print_error(errmsg, byte_ocurly[depth])
      exit 3
    }
    print output[0]
    if (!nocolor) print default_color
  }
}
