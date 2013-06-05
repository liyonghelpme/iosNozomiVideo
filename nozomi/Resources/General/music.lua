music = {}

do
	local engine = SimpleAudioEngine:sharedEngine()
	local musicOn = true
	local soundOn = true
	local curMusic = nil
	music.playBackgroundMusic = function(music)
	    if music==0 or curMusic==music then return end
		curMusic = music
		if musicOn then
		    if curMusic then
    			engine:playBackgroundMusic(curMusic, true)
    		else
	            engine:stopBackgroundMusic(true)
    		end
		end
	end
	
	-- 思路：存放3个值，最短间隔、容许继续播放的时间、冷却时间
	local musicBuffer = {}
	local minDis, conDis, coldDis, conNum = 0.4, 1, 1, 2
	
	music.playCleverEffect = function(effect)
		if soundOn then
		    local ctime = timer.getTime()
		    if musicBuffer[effect] then
		        local bitem = musicBuffer[effect]
		        if ctime<bitem[1] or (ctime>bitem[2] and ctime<bitem[3]) then
		            return
		        elseif ctime>bitem[3] then
		            musicBuffer[effect] = {minDis+ctime, conDis+ctime, coldDis+ctime, 0}
		        else
		            bitem[1] = bitem[1]+minDis
		            bitem[4] = bitem[4]+1
		            if bitem[4]>=conNum then
		                bitem[3] = bitem[2]+coldDis
		            end
		        end
		    else
		        musicBuffer[effect] = {minDis+ctime, conDis+ctime, conDis+ctime, 0}
		    end
			engine:playEffect(effect, false)
		end
	end
	
	music.playEffect = function(effect)
		if soundOn then
			engine:playEffect(effect, false)
		end
	end
	
	music.changeMusicState = function(on)
		if musicOn~=on then
			musicOn = on
			if curMusic~=nil then
				if musicOn then
					engine:playBackgroundMusic(curMusic, true)
				else
					engine:stopBackgroundMusic(true)
				end
			end
		end
	end
	
	music.changeSoundState = function(on)
		if soundOn~=on then
			soundOn = on
		end
	end
	
	music.getMusicState = function()
		return musicOn
	end
	
	function music.initBattle()
	    local battleList = {"cannon","laser","air","magic","mortar"}
	    for i=1, 5 do
		    engine:preloadEffect("music/" .. battleList[i] .. "Shot.mp3")
		    engine:preloadEffect("music/" .. battleList[i] .. "Bomb.mp3")
	    end
	end
	
	-- 把需要预加载的音乐音效都放这
	local function init()
		engine:preloadEffect("music/but.mp3")
		engine:preloadEffect("music/afterBattle.mp3")
		engine:preloadEffect("music/buildClicked.mp3")
		engine:preloadEffect("music/personCollect.mp3")
		engine:preloadEffect("music/oilCollect.mp3")
		engine:preloadEffect("music/foodCollect.mp3")
		engine:preloadEffect("music/builderSound.mp3")
		engine:preloadEffect("music/buildFinish.mp3")
		engine:preloadEffect("music/soldierFinish.mp3")
		engine:preloadEffect("music/buildMove.mp3")
		engine:preloadEffect("music/buildSet.mp3")
		music.initBattle()
	end
	init()
end