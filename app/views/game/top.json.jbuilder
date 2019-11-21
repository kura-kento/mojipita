if @new_log.size >= 1
	json.array! @new_log
else
	json.array! @all_log
end
