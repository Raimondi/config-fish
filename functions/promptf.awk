# %{condition%?ifTrue%:ifFalse%}
#  root        -> if $USER is root
#  jobs        -> if jobs > 0
#  status      -> if exit_status != 0
#  nested      -> if $SHLVL > 0
#  remote      -> if in a remote session
#  multiplexer -> if runnning inside a teminal multiplexer
#
# %(item:modifier1,modifier2)
#  user     -> $USER
#  host     -> host
#  pwd      -> $PWD
#  jobs     -> number of jobs
#  status   -> exit status
#  vcs      -> VCS status (currently git only)
#  duration -> command duration
#  fg       -> foreground color
#  bg       -> background color

function append(text, depth_offset) {
  output[depth + depth_offset] = (output[depth + depth_offset] text)
}
function get_ident() {
  byte_ident[depth] = i
  ident = ""
  id_cnt = i
  while (($id_cnt ~ /[a-zA-Z0-9_]/) && (id_cnt <= NF)) {
    ident = ident $id_cnt
    id_cnt++
  }
  inc_i(id_cnt - i)
  return ident
}
function inc_i(inc_arg) {
  inc_arg = inc_arg ? inc_arg : 1
  i += inc_arg
  byte_count += inc_arg
}
BEGIN {
  FS = ""
  OFS = ""
  ORS = ""
  mark = "!"
  condition[0] = 0
  output[0] = color0 fg_normal
  depth = 0
  get_condition = 0
  open[0] = 0
  byte_count = 0
  byte_ocurly[0] = 0
  byte_question[0] = 0
  byte_colon[0] = 0
  byte_ident[0] = 0
  byte_item[0] = 0
  byte_args[0] = 0
  ifTrue_done[depth] = 0
  ifFalse_done[depth] = 0
  split(fg_str, fg, / +/)
  split(bg_str, bg, / +/)
  fg["user"]     = fg_user
  fg["normal"]   = fg_normal
  fg["status"]   = fg_status
  fg["cwd"]      = fg_cwd
  fg["cwd_root"] = fg_cwd_root
  fg["host"]     = fg_host
  fg["error"]    = fg_error
  bg["user"]     = bg_user
  bg["normal"]   = bg_normal
  bg["status"]   = bg_status
  bg["cwd"]      = bg_cwd
  bg["cwd_root"] = bg_cwd_root
  bg["host"]     = bg_host
  bg["error"]    = bg_error
  item = ""
  get_item = 0
}
{
  i = 0
  rdone = 0
  inc_i()
  if (NR > 1) {
    append("\n")
  }
  while (i <= NF) {
    if ($i == mark) {
      inc_i()
      # Delimiter
      if (i > NF) {
        print "Error in byte " byte_count ": unnexpected end of line after " mark "."
        exit 6
      } else if ($i == "{") {
        # Conditional block
        depth++
        output[depth] = ""
        byte_ocurly[depth] = byte_count - 1
        ifTrue_done[depth] = 0
        ifFalse_done[depth] = 0
        inc_i()
        ident = get_ident()
        if (ident == "root") {
          condition[depth] = user == "root"
        } else if (ident == "jobs") {
          condition[depth] = jobs
        } else if (ident == "status") {
          condition[depth] = exit_status
        } else if (ident == "nested") {
          condition[depth] = status != 0
        } else if (ident == "remote") {
          condition[depth] = remote
        } else if (ident == "vcs") {
          condition[depth] = vcs
        } else if (ident == "multiplexer") {
          condition[depth] = multiplexer
        } else {
          print "Error in byte " byte_ident[depth] ": unrecognized condition \"" ident "\"."
          exit 1
        }
        if ($i != mark) {
          print "Error in byte " byte_count ": was expecting " mark " but found " $(i + 1) "."
          exit 7
        }
      } else if ($i == "?") {
        # evaluate condition
        if (ifTrue_done[depth]) {
          print "Error in byte " (byte_count - 1) ": " mark $i " after " mark $i "."
          exit 3
        }
        byte_question[depth] = byte_count
        inc_i()
      } else if ($i == ":") {
        # ifTrue
        if (ifFalse_done[depth]) {
          print "Error in byte " (byte_count - 1) ": " mark $i " after " mark $i "."
          exit 4
        }
        byte_colon[depth] = byte_count
        if (condition[depth]) {
          append(output[depth], -1)
        }
        ifTrue_done[depth] = 1
        output[depth] = ""
        inc_i()
      } else if ($i == "}") {
        if (! byte_question[depth] && ! byte_colon[depth]) {
          print "Error in byte " (byte_count - 1) ": was expecting " mark "? or " mark ": but found " mark $i "."
          exit 5
        }
        if (byte_colon[depth] && ! condition[depth]) {
          # ifFalse
          append(output[depth], -1)
        } else if (! ifTrue_done[depth] && byte_question[depth] && condition[depth]) {
          # ifTrue
          append(output[depth], -1)
        }
        depth--
        # unnecessary?
        output[depth + 1] = ""
        byte_question[depth + 1] = 0
        byte_colon[depth + 1] = 0
        inc_i()
      } else if ($i == "(") {
        # Insert item
        inc_i()
        byte_item[nest] = byte_count
        item = get_ident()
        for (key in args) delete args[key]
        if ($i != ":" && $i != ")") {
          print "Error in byte " byte_count ": was expecting \":\" or \")\" but found \"" $i "\"."
          exit 8
        } else if ($i == ":" && $(i + 1) != ")") {
          arg_cnt = 0
          do {
            inc_i()
            arg_cnt++
            byte_args[nest,arg_cnt] = byte_count
            args[arg_cnt] = get_ident()
          } while ($i == ",")
        } else if ($i == ":") {
          inc_i()
        }
        if ($i != ")") {
          print "Error in byte " byte_count ": was expecting \")\" but found \"" $i "\"."
          exit 9
        }
        if (item == "user") {
          append(user)
        } else if (item == "host") {
          if (args[1] == "full") {
            cmd = "hostname"
          } else if (args[1] == "first") {
            cmd = "hostname -s"
          } else {
            cmd = "hostname -s"
          }
          cmd | getline host
          close(cmd)
          append(host)
        } else if (item == "time") {
          if (!time) {
            cmd = "date " time_format
            cmd | getline time
            close(cmd)
          }
          append(time)
        } else if (item == "pwd") {
          append(user)
        } else if (item == "jobs") {
          append(jobs)
        } else if (item == "status") {
          append(status)
        } else if (item == "vcs") {
          append(vcs)
        } else if (item == "nested") {
          append(nested)
        } else if (item == "duration") {
          append(duration)
        } else if (item == "fg") {
          if (!args[1]) {
            append(color0)
          } else if (args[1] in fg) {
            append(fg[args[1]])
          } else {
            print "Error in byte " byte_args[nest,1] ": wrong foreground color \"" args[1] "\"."
            exit 10
          }
        } else if (item == "bg") {
          if (!args[1]) {
            append(color0)
          } else if (args[1] in bg) {
            append(bg[args[1]])
          } else {
            print "Error in byte " byte_args[nest,1] ": wrong background color \"" args[1] "\"."
            exit 11
          }
        } else {
          print "Error in byte " byte_item[nest] ": unrecognized item \"" item "\"."
          exit 12
        }
        inc_i()
      } else if ($i == mark) {
        append($i)
        inc_i()
      } else {
        print "Error in byte " (byte_count - 1) ": unrecognized delimiter \"" mark $i "\"."
        exit 2
      }
    } else if (get_item && ($i == ")")) {
      item_name = ident
      ident = get_ident()
      inc_i()
    } else {
      append($i)
      inc_i()
    }
  }
  byte_count++
  rdone = 1
}
END {
  if (rdone) {
    # Only if no errors before this
    if (depth > 0) {
      print "\nError in byte " byte_ocurly[depth] ": unpaired \"" mark "{\"\n"
      exit 3
    }
    print output[0]
    print color0
  }
}
