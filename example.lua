event = require 'event'

local log = function(fmt,...) print(string.format(tostring(fmt), ...)) end

--/ some examples
do
	function test(e)
		print(e.msg)
	end

	event("test"):register(test)
	for i=0, 2 do
		event("test"):trigger({ msg = "Hello world! x"..i })
	end

	event("test"):stop()
	for i=0, 2 do
		event("test"):trigger({ msg = "it's 'Hello world!' will never be printed x"..i })
	end

	function test1(e)
		print("Test1 "..e.msg)
	end

	event("test"):register(test1):start()
	assert(event("test"):registered(test1) ~= nil)

	event("test"):trigger({ msg = "Hello world!" })
end


do
	event("once-triggerred"):register(function(e)
		log("This msg has been printed only %s:)", e.once)
	end):once():
		trigger({ once = "once" }):
		trigger({ once = "twice" })
end


