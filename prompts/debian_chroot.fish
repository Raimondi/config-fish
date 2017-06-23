function debian_chroot
	prompter '{chroot?(c:yellow)\((chroot)\) }(c)(user)@(host) ' \
     '{root?(c:cwd_root):(c:cwd)}(cwd)(c){root?#:>} '
end
