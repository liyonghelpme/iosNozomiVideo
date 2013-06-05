SNS = {}

snsModel = class()

function snsModel:initAccessToken()
    if not self.code then
        local function checkCode(url)
            CCNative:postNotification(1,"test");
            print("checkCode", url)
            local pos1, pos2 = string.find(url, self.callbackUrl)
            if pos1==1 then
                pos1, pos2 = string.find(url, "code=", pos2+1)
                if pos1 then
                    self.code = string.sub(url, pos2+1)
                    self:initAccessToken()
                    return 0
                end
            end
            return 1
        end
        local authUrl = self:getAuthUrl()
        print("begin request auth")
        CCWebView:create(authUrl, checkCode)
    else
        print("begin request token " .. self.code)
        network.httpRequest(self.tokenUrl, self.getAccessToken, {isPost=true, params={code=self.code, client_id=self.client_id, client_secret=self.client_secret, redirect_uri=self.callbackUrl}}, self)
    end
end

function snsModel:getAccessToken(suc, result)
    print("SNS REQUEST OVER", suc, result)
    if suc then
        local data = json.decode(result)
        self.access_token = data.access_token
        if self.requestItem then
            local item = self.requestItem
            self.requestItem = nil
            self:request(item.url, item.params)
        end
    end
end

function snsModel:getAuthUrl()
    local url = self.authUrl .. "?client_id=" .. self.client_id .. "&redirect_uri=" .. self.callbackUrl 
    if self.scopes then
        url = url .. "&scope=" .. self.scopes
    end
    return url
end

function snsModel:requestOver(suc, result)
    if suc then
        --local data = json.decode(result)
        display.closeDialog()
    end
end

function snsModel:request(requestUrl, requestParam)
    if self.access_token then
        local params = copyData(requestParam)
        params.access_token = self.access_token
        network.httpRequest(requestUrl, self.requestOver, {isPost=true, params=params}, self)
    else
        self.requestItem = {url=requestUrl, params=requestParam}
        self:initAccessToken()
    end
end

local facebook = snsModel.new()
facebook.callbackUrl="http://uhz000738.chinaw3.com:5000/"
facebook.authUrl="https://graph.facebook.com/oauth/authorize"
facebook.client_id="304997242960340"
facebook.client_secret="8db39417e4862af619beca8f4414d8e4"
facebook.scopes="user_about_me,user_activities,user_birthday,user_education_history,user_events,user_groups,user_hometown,user_interests,user_likes,user_location,user_notes,user_online_presence,user_photo_video_tags,user_photos,user_relationships,user_religion_politics,user_status,user_videos,user_website,user_work_history,read_friendlists,read_requests,publish_stream,create_event,rsvp_event,sms,offline_access,friends_about_me,friends_activities,friends_birthday,friends_education_history,friends_events,friends_groups,friends_hometown,friends_interests,friends_likes,friends_location,friends_notes,friends_online_presence,friends_photo_video_tags,friends_photos,friends_relationships,friends_religion_politics,friends_status,friends_videos,friends_website,friends_work_history,read_stream,photo_upload"
facebook.tokenUrl="https://graph.facebook.com/oauth/access_token"

SNS.facebook = facebook

local weibo = snsModel.new()
weibo.callbackUrl = "https://api.weibo.com/oauth2/default.html"
weibo.authUrl="https://api.weibo.com/oauth2/authorize"
weibo.client_id="987947670"
weibo.client_secret="e09d2481fc636a7c12ae783d8d5ac806"
weibo.scopes=nil
weibo.tokenUrl="https://api.weibo.com/oauth2/access_token"
--weibo.code = "c3089c829684d3efa1f612530c595519"

SNS.weibo = weibo