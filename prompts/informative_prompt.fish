function fish_prompt
	prompter '{root?(c)(user)@(host) (c:cwd_root)(cwd)(c)# :' \
	'(c)[(time:"+%H:%M:%S")] (c:blue,bold)(user)@(host) (c:cwd)(cwd:full) ' \
	'{status?(c:red,bold):(c:green,bold)}\((status)\)'\n'(c)> }'
end
