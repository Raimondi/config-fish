# Use $EDITOR to edit the current command
function edit_commandline
    set -q EDITOR; or begin
      echo '$EDITOR is not set'
      return 1
    end
    set -l tmpfile (mktemp); or return 1
    commandline > $tmpfile
    eval $EDITOR $tmpfile
    commandline -r -- (cat $tmpfile)
    rm $tmpfile
end
