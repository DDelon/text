local WebTool = {}
WebTool.parsingData = function (msg,formatTable)--,handleId )
	-- msg.handleId = handleId
	local returntab = {}
	for _,valueTable in pairs(formatTable) do
		--拆分消息---------------------------------------------
		local key = valueTable[1]
		local format = valueTable[2]
		local formatArr = string.split(format,"[")
		-- print("key:::::"..key)

		local format = formatArr[1]
		local countArr = nil
		for i=2,#formatArr do
			--解析数组数量
			if countArr == nil then countArr = {} end
			local countStr = string.sub(formatArr[i],0,string.len(formatArr[i])-1)
			local count = tonumber(countStr)
			--常规型[12]
			if count == nil then
				count = tonumber(DEF[countStr])
			end
			--父数组长度不同如[3][1,2,3]
			if count == nil then
				print(countStr)
				count = string.split(countStr,",")
				if #count == 1 then 
					count = nil 
				end
			end
			--不定长度型
			if count == nil then
				count = string.split(countStr,".")
				if count[1]=="self" then
					count = msg[count[2]]
					-- if type(count) == "table" then
					-- 	count = table.concat(count,",")
					-- end
				end
			end
			table.insert(countArr,count)
			--解析数组数量
		end
		--拆分消息---------------------------------------------

		--数据解释----------------------------------------
		local msgFun
		msgFun = function(format,msg,countArr,num)
			local t = nil
			if countArr then
				t={}
				local curLen = countArr[1]
				if type(countArr[1]) == "table"	then
					curLen = tonumber(curLen[num])
				end

				local nextArr = table.copy(countArr)
				table.remove(nextArr,1)
				if #nextArr == 0 then nextArr = nil end

				if format == "WORD" or format == "TCHAR" or format == "DWORD" and #countArr == 1 then
					--字符串
					t = msg:ReadStringWEx(curLen)
				else
					--数组
					print(type(curLen))
					if type(curLen) == "string" then
						print(curLen)
					end
					for i=1,curLen do
						t[i]=msgFun(format,msg,nextArr,i)
					end
				end

				
			else
				if format == "WORD" then
					t = msg:ReadWord()
				elseif format == "int" or format == "long" or format == "DWORD" then
					t = msg:ReadDword()
				elseif format == "long long" then
					t = msg:ReadLonglong()
				elseif format == "BYTE" or format == "TCHAR" then
					t = msg:ReadByte()
				elseif format == "bool" then
					t = msg:ReadBool()
				elseif format == "float" then
					t = msg:ReadFloat()
				elseif format == "double" then
					t = msg:ReadDouble()
				end
				-- print("value:::::"..t)
			end
			return t
		end
		msg[key] = msgFun(format,msg,countArr)
		returntab[key] = msg[key]
		--数据解释----------------------------------------
	end
	returntab.id = msg.id
	return returntab
end

WebTool.codingData = function (dataTable,handleId )
    local msg = CLuaMsgHeader.New()
    msg.id = handleId
    for _,v in ipairs(dataTable) do
    	local format 	= v[1]
    	local data 		= v[2]
    	print("format"..format)
    	if format == "WORD" then
			msg:WriteWord(data)
		elseif format == "int" or format == "long" or format == "DWORD" then
			msg:WriteDword(data)
		elseif format == "long long" then
			msg:WriteLonglong(data)
		elseif format == "BYTE" or format == "TCHAR" then
			msg:WriteByte(data)
		elseif format == "bool" then
			msg:WriteBool(data)
		elseif format == "float" then
			msg:WriteFloat(data)
		elseif format == "double" then
			msg:WriteDouble(data)
		elseif format == "string" then
		local dataArr = string.split(data,"[")
		local count = string.sub(dataArr[2],0,string.len(dataArr[2])-1)

			msg:WriteStringW(dataArr[1])
			for i=1,count-string.len(dataArr[1])-1 do
				msg:WriteWord(0)
			end
			-- msg:WriteDword(0)
		end


		local formatArr = string.split(format,"[")
		if formatArr[1] == "TCHAR" then
			local count = string.sub(formatArr[2],0,string.len(formatArr[2])-1)
			msg:WriteStringW(data)
			for i=1,count-string.len(data)-1 do
				msg:WriteWord(0)
			end
		end
    end
    return msg
    -- msg.WriteDword(pMsg.dwDest)
    -- msg.WriteStringWEx(pMsg.wChat)
end
return WebTool