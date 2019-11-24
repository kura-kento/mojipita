if @new_log.size == 0
	json.array! @all_log
else
	json.array! @new_log
end
