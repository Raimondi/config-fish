function test_promptf
  set fmt '┌━[(user)@(host:short)]-[(pwd)]{vcs?-[(vcs)]}'\n'└{status?━[(status)]}{nested?-[(nested)]}-> '
  promptf $fmt
end
