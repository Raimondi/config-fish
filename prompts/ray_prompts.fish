function fish_prompt
    set -l status_copy $status
    set -l pwd_info (pwd_info "/")
    set -l dir
    set -l base
    set -l color (set_color white)
    set -l color2 (set_color normal)
    set -l color3 (set_color $fish_color_command)
    set -l color_error (set_color $fish_color_error)
    set -l color_normal "$color2"

    if not functions -q fish_right_prompt
        function fish_right_prompt
            set -l status_copy $status
            set -l status_code $status_copy

            set -l color_normal (set_color normal)
            set -l color_error (set_color $fish_color_error)
            set -l color "$color_normal"

            switch "$status_copy"
                case 0 "$_ray_status_last"
                    set status_code
            end

            set -g _ray_status_last $status_copy

            if test "$status_copy" -ne 0
                set color "$color_error"
            end

            if set -l job_id (last_job_id)
                echo -sn "$color%$job_id$color_normal "
            end

            if test ! -z "$status_code"
                echo -sn "$color$status_code$color_normal "
            end

            if test "$CMD_DURATION" -gt 1000
                set -l duration (echo $CMD_DURATION | humanize_duration)
                echo -sn "$color$duration$color_normal "
            end
        end
    end

    echo -sn " "

    if test "$status_copy" -ne 0
        set color "$color_error"
        set color2 "$color_error"
        set color3 "$color_error"
    end

    set -l glyph " $color2\$$color_normal"
    set -l user_id (command id -u "$USER")

    if test ! -z "$SSH_CLIENT"
        set -l color "$color3"
        if test 0 -eq "$user_id"
            set color "$color_error"
        end
        echo -sn "$color"(printf "%.1s" (command id -un))@(hostname -s)"$color_normal:"
    else if test 0 -eq "$user_id"
        echo -sn "$color_error#$color_normal "
    end

    if test "$PWD" = ~
        set base "$color~"
        set glyph
    else if pwd_is_home
        set dir
    else
        if test "$PWD" = /
            set glyph
        else
            set dir "/"
        end
        set base "$color_error/"
    end

    if test ! -z "$pwd_info[1]"
        set base "$pwd_info[1]"
    end

    if test ! -z "$pwd_info[2]"
        set dir "$dir$pwd_info[2]/"
    end

    echo -sn "$color2$dir$color$base$color_normal"

    if test ! -z "$pwd_info[3]"
        echo -sn "$color2/$pwd_info[3]"
    end

    #if set branch_name (git_branch_name)
    #    set -l git_color
    #    set -l git_glyph \$

    #    if git_is_staged
    #        set git_color (set_color green)
    #        if git_is_dirty
    #            set git_glyph "$git_color$git_glyph$color_error$git_glyph"
    #            set git_color "$color_error"
    #        end
    #    else if git_is_dirty
    #        set git_color "$color_error"
    #    else if git_is_touched
    #        set git_color "$color_error"
    #    else
    #        set git_color "$color3"
    #    end

    #    set -l git_ahead (git_ahead " +" " -" " +-")
    #    if test "$branch_name" = "master"
    #        set branch_name
    #        if git_is_stashed
    #            set branch_name "{}"
    #        end
    #    else
    #        set -l left_par "("
    #        set -l right_par ")"
    #        if git_is_stashed
    #            set left_par "{"
    #            set right_par "}"
    #        end
    #        set branch_name " $git_color$left_par$color2$branch_name$git_color$right_par"
    #    end
    #    echo -sn "$branch_name$git_color$git_ahead $git_glyph"
    #end

    echo -sn "$color_normal "
end
