function append(text) {
  output[nest] = (output[nest] text)
}
BEGIN {
  FS = ""
  OFS = ""
  ORS = ""
  mark = "%"
  marked = 0
  cond[0] = 0
  output[0] = color0 fg_normal
  nest = 0
  get_cond = 0
  open[0] = 0
  byte_count = 0
  open_bracket[0] = 0
  "echo $USER" | getline user
  "echo $SSH_CLIENT" | getline ssh_client
  "echo $SSH_TTY" | getline ssh_tty
  ssh = (ssh_client || ssh_tty)
  "echo $TMUX" | getline tmux
  "echo $STY" | getline screen
}
{
  for (i = 1; i <= NF; i++) {
  byte_count++
    if (! marked) {
      if ($i == mark) {
        marked = 1
        mod = ""
      } else {
        append($i)
      }
      continue
    } else if (get_cond) {
      if (   ($i == "j" && jobs) \
          || ($i == "u" && ! (user == "root")) \
          || ($i == "U" && user == "root") \
          || ($i == "s" && status) \
          || ($i == "v" && vcs) \
          ) {
        cond[nest] = 1
      } else if ($i ~/[^juUsv]/) {
        print ("Error in byte " byte_count ": condition not accepted \"" $i "\"") > "/dev/stderr"
        exit 4
      }
      get_cond = 0
    } else if ($i ~ /[0-9]/) {
      mod = mod $i
      continue
    } else if ($i == "{") {
      nest++
      output[nest] = ""
      get_cond = 1
      open_bracket[nest] = byte_count
      continue
    } else if ($i == "}") {
      nest--
      if (cond[nest + 1] && nest >= 0) {
        append(output[nest + 1])
      } else if (nest < 0) {
        print ("Error in byte " byte_count ": unpaired \"}\"") > "/dev/stderr"
        exit 2
      }
      cond[nest + 1] = 0
    } else if ($i == mark) {
      append($i)
    } else if ($i == "u") {
      # User
      append(user)
    } else if ($i == "h") {
      # Host
      if (mod == 2) {
        "hostname -s" | getline hostname
        append(hostname)
      } else {
        "hostname" | getline hostname
        append(hostname)
      }
    } else if ($i == "p") {
      # PWD
      "printf $PWD" | getline pwd
      append(pwd)
    } else if ($i == "j") {
      # Jobs
      append(jobs)
    } else if ($i == "s") {
      # Exit status
      append(status)
    } else if ($i == "v") {
      # VCS info
      append(vcs)
    } else if ($i == "t") {
      # Time
    } else if ($i == "d") {
      # Command duration
    } else if ($i == "c") {
      # Color
      if (mod == 0) {
        append(color0)
      } else if (mod == 1) {
        append(fg_1)
      } else if (mod == 2) {
        append(fg_2)
      } else if (mod == 3) {
        append(fg_3)
      } else if (mod == 4) {
        append(fg_4)
      } else if (mod == 5) {
        append(fg_5)
      } else if (mod == 6) {
        append(fg_6)
      } else if (mod == 7) {
        append(fg_7)
      } else if (mod == 8) {
        append(fg_8)
      } else if (mod == 9) {
        append(fg_9)
      }
    } else if ($i == "C") {
      # Color
      if (mod == 0 || mod == 1) {
        append(bg_1)
      } else if (mod == 2) {
        append(bg_2)
      } else if (mod == 3) {
        append(bg_3)
      } else if (mod == 4) {
        append(bg_4)
      } else if (mod == 5) {
        append(bg_5)
      } else if (mod == 6) {
        append(bg_6)
      } else if (mod == 7) {
        append(bg_7)
      } else if (mod == 8) {
        append(bg_8)
      } else if (mod == 9) {
        append(bg_9)
      }
    } else {
      # Not recognized
      printf "%s\nError in byte " byte_count ": flag not recognized \"%s\"\n", color0, $i > "/dev/stderr"
      exit 1
    }
    marked = 0
  }
  append("\n")
  byte_count++
}
END {
  if (nest > 0) {
    print "\nError in byte " open_bracket[nest] ": unpaired \"{\"\n" > "/dev/stderr"
    exit 3
  }
  print output[0]
  print color0
}
