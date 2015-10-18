function -d 'Extracts the contents of archives.' unarchive
  set name unarchive
  set first
  set remove_archive 0
  set success
  set file_name
  set extract_dir
  if test -z "$argv"
    echo "usage: $name [-option] [file ...]

options:
    -r, --remove    remove archive

Report bugs to <israel.chauca@gmail.com>." 1>&2
    return
  end
  for arg in $argv
    if test -z "$list" -a -z "$first"
      set first 1
      if test "$arg" = "-r"
        set remove_archive 1
        continue
      end
      if test "$arg" = "--remove"
        set remove_archive 1
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
    set success 0
    set file_name (basename $file)
    # extract to archive's dir.
    #set extract_dir (echo -n "$file" | sed 's/\\.[^.]*$//')
    # extract to current dir.
    set extract_dir (echo -n "$file_name" | sed 's/\\.[^.]*$//')
    echo "extract dir: $extract_dir"
    switch $file
      case '*.tar.gz' '*.tgz'
        tar xvzf "$file"
      case '*.tar.bz2' '*.tbz' '*.tbz2'
        tar xvjf "$file"
      case '*.tar.xz' '*.txz'
        tar --xz --help 1> /dev/null
        and tar --xz -xvf "$file"
        or xzcat "$file" | tar xvf -
      case '*.tar.zma' '*.tlz'
        tar --lzma --help 1> /dev/null
        and tar --lzma -xvf "$file"
        or lzcat "$file" | tar xvf -
      case '*.tar'
        tar xvf "$file"
      case '*.gz'
        gunzip "$file"
      case '*.bz2'
        bunzip2 "$file"
      case '*.xz'
        unxz "$file"
      case '*.lzma'
        unlzma "$file"
      case '*.Z'
        uncompress "$file"
      case '*.zip'
        unzip "$file" -d $extract_dir
      case '*.rar'
        unrar 1> /dev/null
        and unrar e -ad "$file"
        or rar e -ad "$file"
      case '*.7z'
        7za x "$file"
      case '*.deb'
        mkdir -p "$extract_dir/control"
        mkdir -p "$extract_dir/data"
        cd "$extract_dir"; ar vx "../{$file}" 1> /dev/null
        cd control; tar xzvf ../control.tar.gz
        cd ../data; tar xzvf ../data.tar.gz
        cd ..; rm *.tar.gz debian-binary
        cd ..
      case '*'
        echo "$name: cannot extract: $file" 1>&2
        set success 1
    end
    if test ! $success -gt 0
      set success $status
    end
    if test $success -eq 0 -a $remove_archive -eq 1
      rm "$file"
    end
  end
end
