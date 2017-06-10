function ls --description 'List contents of directory'
	#if type gls 1>/dev/null 2>/dev/null
  #  set ls gls
  #else
  #  set ls ls
  #end
  set -l param --color=auto
  if isatty 1
    set param $param --indicator-style=classify
  end
  set param $param --sort=extension
  set param $param --group-directories-first
  #eval "command $ls $param $argv"
  if type gls 1>/dev/null 2>/dev/null
    gls $param $argv
  else
    ls $param $argv
  end
end
