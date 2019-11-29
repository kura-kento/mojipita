if @turn_last
  json.merge! @turn_last.attributes
elsif @new_log.size == 0
	json.array! @all_log
elsif
	json.array! @new_log
end
