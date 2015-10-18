function cd_on_error -d 'Try to cd when command not found.' -e fish_command_not_found
  if begin
      test (count $argv) -ne 1
      or not test -d $argv[1]
    end
    return
  end
  echo "$USER, did you try to cd?"
  commandline "$argv/"
  return 0
  echo "Trying to cd into \"$argv[1]/\"..."
  cd $argv[1]
end
