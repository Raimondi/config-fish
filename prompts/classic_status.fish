function classic-status
  prompter "{status?(color:red)\\((status)\\) }" \
     "(color)(user)@(host) " \
     "{root?(color:cwd_root)(pwd)(color)#:(color:cwd)}(pwd)(color)> "
end
