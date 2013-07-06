General = {
    anchorLeftTop = CCPointMake(0, 1), anchorLeftBottom = CCPointMake(0, 0),
    anchorRightTop = CCPointMake(1, 1), anchorRightBottom = CCPointMake(1, 0),
    anchorCenter = CCPointMake(0.5, 0.5), anchorBottom = CCPointMake(0.5, 0),
    anchorTop = CCPointMake(0.5, 1), anchorLeft = CCPointMake(0, 0.5), 
    anchorRight = CCPointMake(1, 0.5);
    winSize = CCDirector:sharedDirector():getVisibleSize();
    TOUCH_DOWN = 1, TOUCH_CANCEL = 2, TOUCH_CLICK = 3;
    font1 = "Heiti SC Medium", font2 = "bold", font3 = "bold2", font4="fonts/font3.fnt";
    font5 = "Heiti SC Medium", font6 = "bold2", 
    nightColor = ccc3(100, 100, 100), normalColor = ccc3(255, 255, 255);
    darkAlpha=100,
    useGameCenter=false, supportVideo=false
}

require "General.screen"
require "General.display"
require "General.timer"
require "General.network"
require "General.SNS"
require "General.music"

require "General.StringManager"
require "General.EventManager"
require "General.Achievements"