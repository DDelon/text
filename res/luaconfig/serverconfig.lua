local intType = FishGI.SYSTEM_STATE
if intType == 0 then
	local serverconfig = {}
	serverconfig[1] = {url="game10.weile.com",port=6532};
	serverconfig["RoomId"] = 113;
	return serverconfig;
else
	local serverconfig = {}
	serverconfig[1] = {url="192.168.67.6",port=6532};
	serverconfig["RoomId"] = 113;
	return serverconfig;
end
 
