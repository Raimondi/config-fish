function -d 'Lists the contents of archives.' lsarchive
  set name lsarchive
  set verbose '' l
  set list
  if test -z "$argv"
    echo "usage: $name [-option] [file ...]

options:
    -v, --verbose    verbose archive listing

Report bugs to <israel.chauca@gmail.com>." 1>&2
    return
  end
  set first
  for arg in $argv
    if test -z "$list" -a -z "$first"
      set first 1
      if test $arg = "-v" -o $arg = "--verbose"
        set verbose v v
        continue
      end
    end
    set list $list $arg
  end
  for file in $list
    if test ! -s "$file"
      echo "$name: file not valid: $file" 1>&2
      continue
    end
    switch $file
      case '*tar.gz' '*.tgz'
        tar t{$verbose[1]}vzf "$file"
      case '*.tar.bz2' '*.tbz' '*.tbz2'
        tar t{$verbose[1]}jf "$file"
      case '*.tar.xz' '*.txz'
        tar --xz --help 1> /dev/null
        and tar --xz -t{$verbose[1]}f "$file"
        or xzcat "$file" | tar t{$verbose[1]}f -
      case '*.tar.zma' '*.tlz'
        tar --lzma --help 1> /dev/null
        and tar --lzma -t{$verbose[1]}f "$file"
        or lzcat "$file" | tar x{$verbose[1]}f -
      case '*.tar'
        tar t{$verbose[1]}f "$file"
      case '*.zip'
        unzip -l{$verbose[1]} "$file"
      case '*.rar'
        unrar 1> /dev/null
        and unrar {$verbose[2]} "$file"
        or rar {$verbose[2]} "$file"
      case '*.7z'
        7za l "$file"
      case '*'
        echo "$name: can not list $file" 1>&2
    end
  end
end
