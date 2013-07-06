PARAM = {
    flow1Time=5000, flow2Time=500, boxOnRiverTime = 1000, riverTime=2000, 
    soldierMoveTime = 2000, soldierCallTime=2000, 
    buildViewOffy4000=47, buildViewOffy4001=36, buildViewOffy4002=28, buildViewOffy4003=42, buildViewOffy4004=38, buildViewOffy4006=38, 
    buildViewOffy4007=42, buildViewOffy4008=49, buildViewOffy4009=70, buildViewOffy4012=43, buildViewOffy4013=41, buildViewOffy4014=52,
    buildViewOffy4015=35, buildViewOffy4016=49, buildViewOffy4017=28, buildViewOffy4018=26,
    buildViewOffy5002=27, buildViewOffy3007=71, buildViewOffy3005=25, buildViewOffy3004=59, buildViewOffy3003=45, buildViewOffy3002=60,
    buildViewOffy3001=71, buildViewOffy2003=26, buildViewOffy2001=65, buildViewOffy1002=68, buildViewOffy1004=132,
    buildViewOffy6001=52, buildViewOffy6002=52, buildViewOffy6003=52, buildViewOffy3006=9, 
    -- db's data
    actionNumButtonNotice=3, actionScaleButtonNotice=230,
    actionTimeButtonNotice=250, actionTimeChangeScene=600, actionTombHeight=0, builderMoveSpeed=60,
    buildingAreaAlpha=25, buildingLineAlpha=100, buildViewOffx2004=8, buildViewOffy0=32,
    buildViewOffy1000=135, buildViewOffy1001=44, buildViewOffy1003=46, buildViewOffy2=39,
    buildViewOffy2004=43, buildViewOffy2005=47, buildViewOffy3000=58, buildViewOffy5000=15,
    buildViewOffy5001=9, buildViewOffy6000=44, cannonScale1=75, cannonScale2=75,
    cannonScale3=88, cannonScale6=88, fontStroke13=11, fontStroke15=10,
    fontStroke16=14, fontStroke18=12, fontStroke20=12, fontStroke21=20,
    fontStroke26=18, mapScaleMax=450, menuInTime=600, npcMovingTime2=1250,
    npcMovingTime3=1000, npcMovingTime4=1000, npcScale1=100, npcSpeed2=40,
    npcSpeed3=70, npcSpeed4=70, npcSpeed5=70, populationPercent0=3,
    populationPercent1=5, populationPercent2005=4, scaleMinDialogClose=80, scaleMinDialogOpen=80,
    switchGuideOpen=0, switchZombieOpen=0, zombieDelayTime1=900, zombieDelayTime2=1800,
    zombieDelayTime3=3600, zombieDelayTime4=7200, zombieDelayTime5=14400, zombieRepairTime=7000,
    actionTombHeight=0
}

function getParam(key, default)
	return PARAM[key] or default
end