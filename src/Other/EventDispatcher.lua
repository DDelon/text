local EventDispatcher = class ("EventDispatcher")

function EventDispatcher.create()
	local dispatcher = EventDispatcher.new();
	dispatcher:init();
	return dispatcher;
end

function EventDispatcher:init()
	self.listenerTab = {};
end

function EventDispatcher:registerCustomListener(key, obj, func)
	local temp = self.listenerTab[key];
	if temp == nil then
		local valTab = {};
		valTab.obj = obj;
		valTab.func = func;
		self.listenerTab[key] = valTab;
	else
		print("监听器已经存在")
	end
end

function EventDispatcher:removeListener(key)
	self.listenerTab[key] = nil;
end

function EventDispatcher:removeAllListener()
	self.listenerTab = {};
end

function EventDispatcher:dispatch(key, val)
	local temp = self.listenerTab[key];
	if temp == nil then
		print("监听器不存在");
	else
		temp.func(val);
	end
end

return EventDispatcher;