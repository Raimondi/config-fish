function prompt_pwd --description "Print the current working directory, shortened to fit the prompt" -a type
	# TODO: use the string built-in instead of sed
	set -l prefix
	set -l infix
	set -l sufix
	set -l length 2
	set pwd (echo "$PWD" | sed -e "s|^$HOME|~|" -e 's|^/private||')
	switch "$type"
		# turn ~/abcdfe/ghi/jklmn/opqrst
		case compact
			# ~/abc…/ghi/jkl…/opqrst
			if test -n "$fish_prompt_pwd_length"
				set length (math "$fish_prompt_pwd_length - 1")
			end
			echo $pwd | sed -E -e 's-([^/.][^/]{'$length'})[^/]+/-\1…/-g'
		case last
			# ~/…/opqrst
			set new_pwd (echo $pwd | sed -E -e 's-^(~?/)(.*/)?([^/]*)-\1\3-')
			if test "$pwd" = "$new_pwd"
				echo "$pwd"
			else
				echo $new_pwd | sed -E -e 's-/-/…/-'
			end
		case basename
			# opqrst
			echo $pwd | sed -E -e 's-.*/([^/]+)$-\1-'
		case '*'
		  # ~/abcdfe/ghi/jklmn/opqrst
			echo $pwd
	end
end

# Not sure where this came from.
#switch (uname)
#case Darwin
#	function prompt_pwd --description "Print the current working directory, shortened to fit the prompt"
#		#echo $PWD | sed -e "s|^$HOME|~|" -e 's|^/private||' -e 's-\([^/.]\)[^/]*/-\1/-g'
#		echo $PWD | sed -e "s|^$HOME|~|" -e 's|^/private||' -e 's-\([^/.][^/][^/]\)[^/][^/]*/-\1…/-g'
#	end
#case 'CYGWIN_*'
#	function prompt_pwd --description "Print the current working directory, shortened to fit the prompt"
#		echo $PWD | sed -e "s|^$HOME|~|" -e 's|^/cygdrive/\(.\)|\1/:|' -e  's-\([^/.][^/][^/]\)[^/][^/]*/-\1…/-g' -e 's-^\([^/]\)/:/\?-\u\1:/-'
#	end
#case '*'
#	function prompt_pwd --description "Print the current working directory, shortened to fit the prompt"
#		echo $PWD | sed -e "s|^$HOME|~|" -e  's-\([^/.][^/][^/]\)[^/][^/]*/-\1…/-g'
#	end
#end
