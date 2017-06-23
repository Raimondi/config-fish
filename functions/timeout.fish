function timeout --argument time command
	set -l success_msg "timeout: \"$command\" has timeouted and was terminated."
	set -l error_msg "timeout: Error, could not terminate the command \"$command\"."
	eval "$command &"
	if jobs --last >/dev/null ^&1
		set pid (jobs --last --pid | tail -n 1)
	else
		echo "timeout: job has already ended"
		return 1
	end
	sleep $time
	if kill -SIGTERM $pid
		sleep 1
		if not jobs $pid >/dev/null ^&1
			echo "$success_msg"
			return 0
		end
	else
		echo "$error_msg"
		return 1
	end
	if kill -SIGQUIT $pid
		sleep 1
		if not jobs $pid >/dev/null ^&1
			echo "$success_msg"
			return 0
		end
	else
		echo "$error_msg"
		return 1
	end
	if kill -SIGKILL $pid
		sleep 1
		if not jobs $pid >/dev/null ^&1
			echo "$success_msg"
			return 0
		end
	else
		echo "$error_msg"
		return 1
	end
end
