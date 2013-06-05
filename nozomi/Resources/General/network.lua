network = {baseUrl="http://uhz000738.chinaw3.com:9000/", scoreUrl="http://uhz000738.chinaw3.com:9002/" }
--network = {baseUrl="http://192.168.3.110:5000/"}
--network = {baseUrl="http://192.168.3.100:5000/", scoreUrl="http://192.168.3.100:5001/"}
-- 默认参数只支持字符串和数字
network.httpRequest = function (url, callback, setting, delegate)
	local paramStr = ""
	setting = setting or {}
	local request = nil
	local function httpOver(isSuc)
		if not isSuc then
		    local retry = setting.retry or 0
		    if retry>2 then
    			print("HTTP Canceled")
    			EventManager.sendMessage("EVENT_NETWORK_OFF")
    	    else
    	        setting.retry = retry + 1
    	        network.httpRequest(url, callback, setting, delegate)
    	    end
		else
			local hcode = request:getResponseStatusCode()
			if hcode==200 then
				local responseStr = request:getResponseString()
				if delegate then
					callback(delegate, true, responseStr, setting.callbackParam)
				else
					callback(true, responseStr, setting.callbackParam)
				end
			else
				print("HTTP Failed " .. hcode)
				if delegate then
					callback(delegate, false, nil, setting.callbackParam)
				else
					callback(false, nil, setting.callbackParam)
				end
			end
		end
		request:release()
	end
	local pos = string.find(url, "http")
	local rurl = url
	if pos ~= 1 then
		rurl = network.baseUrl .. rurl
	end
	if not setting.isPost then
		local emptyParam = true
		if setting.params then
			for key, value in pairs(setting.params) do
				if emptyParam then
					paramStr = key .. "=" .. value
					emptyParam = false
				else
					paramStr = paramStr .. "&" .. key .. "=" .. value
				end
			end
		end
		if not emptyParam then
			rurl = rurl .. "?" .. paramStr
		end
		request = CCHttpRequest:create(httpOver, rurl)
		request:retain()
	else
		request = CCHttpRequest:create(httpOver, rurl, false)
		request:retain()
		if setting.params then
			for key, value in pairs(setting.params) do
				request:addPostValue(key, value)
			end
		end
	end
	if setting.timeout then
		request:setTimeout(setting.timeout)
	end
	local isCache = setting.isCache or false
	request:start(isCache)
	return request
end
