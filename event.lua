--/ eventy v0.3 by Anton 'at@nda' Petrov
--/ purpose: just for fan

local log = function(fmt,...) print(string.format(tostring(fmt), ...)) end

--/ events implementation

local tblEvents = {}

local function xRegistrator(how, name, func) --/ how: true-add, false-remove, nil-check
	local tblSubs = name and tblEvents[name]
	if tblSubs then
		if how ~= nil then 
			--/ mode [un]registration
			
			local i = 1
			while tblSubs[i] ~= nil do
				if rawequal(func, tblSubs[i]) then
					--/ unregistration or excluding of duplication
					table.remove(tblSubs, i) 
				else
					i = i + 1
				end
			end
			
			if how == true then 
				--/ re-registration
				table.insert(tblSubs, func)
			end
			return true --/>
		else 
			--/ mode of check of having signed EventManager
			for _,v in ipairs(tblSubs) do
				if rawequal(func, v) then
					return true --/> callback registered
				end
			end
		end
	end
	return false
end

--/ fancy oop implementation
local EventManager = {}
setmetatable(EventManager, {
	__call = function (self, ...) 
		return self:__init(...) --/>
	end
})

--/ constructor
function EventManager:__init(name) 
	if name and name ~= "" then
		if not tblEvents[name] then 
			tblEvents[name] = {}
		end
		self._name = name
	end
	return self --/>
end

function EventManager:trigger(tbl_props) 
	if tbl_props and type(tbl_props) == 'table' then
		for k,v in pairs(tbl_props) do
			--/ accumulate props inside class
			self[k] = v
		end
	elseif tbl_props ~= nil then
		log("EventManager:trigger<%s>: tbl_props=[%s] not a table!", "Warning!", type(tbl_props))
	end
	
	local tblSubs = tblEvents[self._name]
	local idx, func = next(tblSubs or {}) 
	if idx then
		--/ cycle of processing EventManager
		while idx and self._stop ~= true do 
			--/ execution itself
			func(self) 
			
			--/ unsubscribe, i.e remove collected callbacks
			if self._remove == true then 
				self._remove = nil
				table.remove(tblSubs,idx) 
				
				--/ index shift back
				idx = (idx > 1 and idx -1) or nil 
			end
			
			--/ from the next position of the table
			idx, func = next(tblSubs,idx) 
		end
		if self._once == true then 
			tblEvents[self._name] = nil
		end
	end
	return self --/>
end

function EventManager:register(func)
	 if xRegistrator(true, self._name, func) ~= true then
		log("EventManager:register<%s>: func=[%s] not registered!", "Error!", func)
		return nil
	 end
	 return self --/>
end

function EventManager:registered(func)
	return xRegistrator(nil, self._name, func) and self or nil --/>
end

function EventManager:remove() 
	self._remove = true
	return self --/>
end

function EventManager:once()
	self._once = true
	return self --/>
end

function EventManager:clear(name) 
	if name and tblEvents[name] then 
		tblEvents[name] = nil
	end
end

function EventManager:start()
	self._stop = false
	return self --/>
end

function EventManager:stop()
	self._stop = true
	return self --/>
end

return EventManager --/>
