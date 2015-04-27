module('setbit', package.seeall)
bit = require('bit')

function set_stat(user_id)
	 local rownum = math.floor(user_id / 512)
	 local rest = user_id % 512
	 local fldnum, bitnum = math.floor(rest / 32) + 1, rest % 32
	 local onebit = bit.lshift(1, bitnum)
	 local stat_row = box.space.dailystat:get(rownum)
	 local row_exists = stat_row ~= nil
	 
	 if (row_exists) then
			local current_tuple = stat_row[2]
			local current_fld = current_tuple[fldnum]
			if (bit.band(current_fld, onebit) == 0) then
				 local current_fld_tuned = bit.bor(current_fld, onebit)
				 current_tuple[fldnum] = current_fld_tuned 
				 box.space.dailystat:update({rownum}, {{'=', 2, box.tuple.new(current_tuple)}})
			end
	 else
			local zero_tuple = box.tuple.new(0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0)
			local tuned_zero_tuple = zero_tuple:update({{'=', fldnum, onebit}})
			box.space.dailystat:insert({rownum, tuned_zero_tuple})
	 end

end

function stat_sum()
	 local sum = 0
	 for _, words in ipairs(box.space.dailystat:select()) do	 
			for _, word in ipairs(words[2]) do
				 nword = tonumber(word)
				 if (nword) then
						for bitnum = 0, 31 do
							 sum = sum + bit.band(nword, 1)
							 nword = bit.rshift(nword, 1)
						end
				 end
			end
	 end
	 return sum
end
