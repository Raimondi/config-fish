function nim
	set template \
	   '{status?(c:red):(c:green)}{console?.-:┬─}' \
		 '(c:green,bold)[' \
     '{root?(c:bold,red):(c:bold,yellow)}(user)' \
		 '(c:white,bold)@' \
		 '{remote?(c:cyan,bold):(c:blue,bold)}(host:full)' \
     '(c:white,bold)\:(cwd)' \
		 '(c:green,bold)]' \
		 '(c){status?(c:red):(c:green)}{console?-:─}' \
		 '(c:green,bold)[' \
		 '(c){status?(c:red):(c:green)}(time:"+%X")' \
		 '(c:green,bold)]'
		 if begin
					type -q acpi
					and [ (acpi -a ^/dev/null | string match -r off) ]
				end
				set template $template '-[(c:red,bold)'(acpi -b | cut -d' ' -f 4-) \
					 '(c:green,bold)]'
			end
		 set template $template \n'(c){jobs?'
		 for job in (jobs)
			 set template $template "{status?(c:red):(c:green)}{console?; :│ }" \
				"(c:brown)"(echo $job | sed -E -e 's/([{}()?:])/\\\\\\1/g')\n
		 end
		 set template $template "}{status?(c:red):(c:green)}{console?'->:╰─>}" \
		 '(c:red,bold)$ '
		 prompter $template
end
