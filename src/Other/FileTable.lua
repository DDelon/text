--[[
* 序列化/反序列化表到文件
]]

local FileTable ={};

--创建一个序列化对象
function FileTable.New()
	local tmp = {};
	local mt = {};
	mt.__index=FileTable;
	setmetatable(tmp,mt);
	return tmp;
end

--读取一个文件，并序列化为table
function FileTable:Open(filename)
	self.filename = filename;
	if not Helper.IsFileExist(filename) then
		return {};
	else
		local tmp = gg.DoFile(filename) or {};
		self.lastsaved = gg.TableClone(tmp);
		return tmp;
	end
end

--保存一个表到文件，filename如果为nil，则保存为打开时的文件名
function FileTable:Save(t,filename)
	
	if gg.TableComp(t,self.lastsaved) then
		return true;
	end

	self.lastsaved = gg.TableClone(t);
	filename = filename or self.filename;

	local fWrite = io.open(filename,"w+");
	if fWrite then
		fWrite:write("return "..gg.SerialObject(t));
		fWrite:close();
		return true;
	else
		return false;
	end
end
--获得最后一次序列化的数据内容
function FileTable:LastSaved()
	return self.lastsaved;
end

--获得文件名
function FileTable:GetFileName()
	return self.filename;
end

return FileTable;

