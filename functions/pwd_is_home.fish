function pwd_is_home --description 'Test if cwd equals or is a child of HOME'
	switch "$PWD"
        case ~{,/\*}
            return 0
    end
    return 1
end
