LuaQ  *   @./Resources/Dialog\AchievementDialog.lua           
   
      $   d@         ä     À        AchievementDialog    show                    E   F@À \@ E  FÀÀ  A \@ E@ FÁ ÀA \@ E   F Â @ BÅÀ Æ ÃA JA  ÁA IÜÁ  \@  E  F@Ä  Ê@  É Å\@        display    closeDialog    Achievements    completeAchievement    id    CrystalLogic    changeCrystal    crystal    pushNotice    UI    createNotice    StringManager    getFormatString    noticeGetReward    num      ào@   EventManager    sendMessage    EVENT_NOTICE_BUTTON    name    achieve                                                                                    
   
   
   
   
   
            info                   c    »    A@A  Á  Á B   À   ÁA@  ABABAÁB A  CFAC ÁCÁ 
 	BÂ	BB	BÂEÂ  B ÁB \	BÀ   ÁA@Á  EÁEÅ ÆAÆÁAÁB A  CFF ÁFÁ 
Â  	BÇ	BG	ÇÀ   ÁA@Á  ÁGHÅ ÆAÈÁAÁB AHÀH0IFAI E  FÉÁ  ÁÁ	 
 Ä  
B 		ÂJEB FËÂ \ 	B	GE FÂÆ	B\ À E FÁÁÊÁ  ÉLÉÁL MÉ\AKÁB À\AÀE  FAÀA ÅÁ   AÂ Ü\  À E FÁÁÊ  ÉNÉAN\AKÁB À\AE  FAÀ ÅÁ  Â A Ü\  À E FÁÁÊ  ÉAOÉO\AKÁB À\AJ    ÁOÀ A  PÀ FBIOBA   CÀ B FBIÕA PA  BÇBGBÇÑ¡À   ÁAÀ
Â  	L	BQE FÍ	BAÁB  AE  FÃA KÁ  Å ÆÁÃÂ JÂ  IÒIBRIBÒ\À E FÁÁÊÁ  ÉRÉÁR SÉ\AKÁB À\AE  FÃASÁ ÁÅ ÆÐ J IBÇIBGIBÇIÑ¡\À E FÁÁÊÁ  ÉÁSÉT SÉ\AKÁB À\AE  FAÀA ÅÁ   AÂ Ü\  À E FÁÁÊ  ÉUÉAU\AKÁB À\AÀ  CEA FË \  ÁUÁ 
Â  	Ö	BV	ÖÀ   ÁA@Á  LÁVÅ ÆÍÁAÁB A  A@A Á  ÁA    À   ÁA@  ÁWÁWAÁB A  A@A Á  ÁA    À   ÁA@  ÁXYAÁB A  A@A Á  Á
 Â   À   ÁA@  ÁTAYAÁB A  A@A Á  Á
 B   À   ÁA@  YAYAÁB AH ³  A@A Á  ÁA B   À   ÁA@  ÁTAYAÁB AH µ 
  A@A Á  ÁÁ    À   ÁA@  ÁXYAÁB AH   A@A Á  ÁA B   À   ÁA@  YAYAÁB A  l      UI    createSpriteWithFile !   images/dialogItemAchieveCell.png    CCSizeMake      ø@      ]@   screen    autoSuitable    x            y 	   addChild    createLabel    desc    General    font1       .@   colorR    colorG    colorB    size       n@     ài@     @U@   nodeAnchor    anchorLeftTop    title    font3       2@     ào@     Àk@      j@     @Y@   anchorLeft    level       @   num    max    createButton      @b@     E@   callbackParam    image    images/buttonGreenB.png    text    StringManager 
   getString    buttonReward 	   fontSize 	   fontName      `t@     @@   anchorCenter %   images/dialogItemInfoProcessBack.png      @n@      8@      i@      ,@'   images/dialogItemInfoProcessFiller.png       n@      4@     Ài@      0@   registerAsProcess    setProcess    /    font4    lineOffset       (À      :@   labelReward       *@     ÀU@     ÀT@     P@      O@   anchorRight    crystal       6@     8@      A@   images/crystal.png       C@     B@     `@      (@   labelAchieveComplete    font2       c@     @l@      S@      D@   images/battleEndRibbon.png       e@     K@      1@   images/battleStar1.png      M@     L@     ÀP@      G@     D@     \@      ð?   images/battleStar0.png       F@       @     N@    »                                                                                                                                                                                                                                                                                                                                                                  "   "   "   "   "   "   "   "   "   #   #   #   #   #   #   #   $   $   $   %   %   %   %   %   %   %   %   %   &   &   &   &   &   &   &   '   '   '   (   )   )   )   )   )   *   *   *   *   *   *   *   +   +   +   +   +   +   +   +   +   +   +   +   +   +   +   +   ,   ,   ,   ,   ,   ,   ,   ,   ,   ,   -   -   -   /   /   /   /   /   /   /   /   /   /   /   /   /   /   /   0   0   0   0   0   0   0   0   0   0   1   1   1   8   8   8   8   8   8   8   8   8   8   8   8   8   8   8   9   9   9   9   9   9   9   9   9   9   :   :   :   ;   ;   ;   ;   ;   ;   ;   ;   ;   <   <   <   <   <   <   <   =   =   =   =   ?   ?   ?   ?   ?   ?   ?   ?   ?   ?   ?   ?   ?   ?   ?   @   @   @   @   @   @   @   @   @   @   A   A   A   G   G   G   G   G   G   G   G   G   H   H   H   H   H   H   H   I   I   I   K   K   K   K   K   K   K   K   K   L   L   L   L   L   L   L   M   M   M   N   N   N   N   N   N   N   N   N   O   O   O   O   O   O   O   P   P   P   Q   Q   Q   Q   Q   Q   Q   Q   Q   R   R   R   R   R   R   R   S   S   S   T   T   T   U   U   U   U   U   U   U   U   U   V   V   V   V   V   V   V   W   W   W   X   X   X   Y   Y   Y   Y   Y   Y   Y   Y   Y   Z   Z   Z   Z   Z   Z   Z   [   [   [   \   \   \   ]   ]   ]   ]   ]   ]   ]   ]   ]   ^   ^   ^   ^   ^   ^   ^   _   _   _   c         bg     º     scrollView     º     info     º     temp     º     num N        ttable    Ä         onGetRewards     e        I     @@Å  Á  A ÜA JÁ  IÁAA BIA I @    @CÀ  
  EÁ FÄ	AE FÄ	A@   ÀDÀ  @     EÁ@   A Á        @CÀ   
  	AF	ÁF@ Ç    @@ Á Á H T Î@A  Á `Á FFÂÈMÈ@_þE  FÉ  ÁÁ  B	 Â  
 	ÂI	H	ÊE   ÁB \	B	D  	B\  ACÆÌ
Â  EÂ FÌ	B	BG	ÂLAÇ ÌA  EÁ   AB        ACÀ  
  	ÂM	NAÇ    A  ANÅ ÆÁÎ Ü Â BOA Â  ÐÐ P¡    ACÀ  
Â  	ÂP	QEÂ FBÑ	BAÇ    A  ANÀ  @ÕAÂ ÂQA  ÐÐ P¡Ò¤    ACÀ  
Â  	ÂR	SEÂ FÄ	BAÇ    A  EÁA   A Â       ACÀ  
  	T	BTAÇ    A  ANÅ ÆÁÎ Ü Â ÂTA  ÐÐ P¡Ò¤    ACÀ  
Â  	BU	UEÂ FÄ	BAÇ    A  A@Å  Â A ÜB VJB  IBV     ACÀ  
Â  	V	ÂVEÂ FÄ	BAÇ    AÁ W    EÁA   A Â       ACÀ  
  	X	BXAÇ    A  ANÅ ÆÁÎ Ü Â BOA Â  BÇBÇ BG¡    ACÀ  
Â  	ÂX	YEÂ FBÙ	BAÇ    AA YÊA  ÉA  AÁ ZOÁ AZ  Á ZA Á ÁZ´Á A[¶A [ Á[A  A\A   r      UI    createButton    CCSizeMake      @     p@
   doNothing    image    images/dialogBgA.png 	   priority    display    DIALOG_PRI    nodeChangeHandler    screen    autoSuitable    screenAnchor    General    anchorCenter 
   scaleType    SCALE_DIALOG_CLEVER    setShowAnimate    createSpriteWithFile    images/dialogItemBlood.png      @r@     Àk@   x      `z@   y      À`@	   addChild              I@   Achievements    getAchievementsAllData       @      ð?   level    createScrollViewAuto      @u@   offx       7@   offy    disy       "@   size      ø@      ]@   infos    cellUpdate    view    nodeAnchor    anchorLeftTop      Ð{@   images/dialogItemAchieveBg.png      ¨@      N@      =@      <@   createLabel    StringManager 
   getString    labelComplete    font1       *@   colorR      ào@   colorG    colorB       d@     Q@   anchorLeft    /    font4       5@   lineOffset       (À      h@      G@   images/achieveNpcFeature.png      @X@     @_@     @@      2@   titleAchievement    font3       >@     v@     ~@     G@   closeDialog    images/buttonClose.png      @@     ~@   useGameCenter    images/gamecenterIcon.png       E@     E@      @      B@   labelGameCenterAchieve      0@     K@   anchorRight    showDialog    GuideLogic    step    pointer    clearPointer       ,@	   complete    getCurrentScene    checkCanBuild 	   ChatRoom    showNotice     I  g   g   g   g   g   g   g   g   g   g   g   g   g   g   g   g   h   h   h   h   h   h   h   h   h   h   h   i   i   i   i   j   j   j   j   j   j   j   j   j   k   k   k   k   k   k   k   l   l   l   n   n   o   o   o   p   p   q   q   q   q   r   r   r   r   q   t   t   t   t   t   t   t   t   t   t   t   t   t   t   t   t   t   t   t   t   u   u   u   u   u   u   u   u   u   u   v   v   v   x   x   x   x   x   x   x   x   x   y   y   y   y   y   y   y   z   z   z   {   {   {   {   {   {   {   {   {   {   {   {   {   {   {   |   |   |   |   |   |   |   |   |   |   }   }   }   ~   ~   ~   ~   ~   ~   ~   ~   ~   ~   ~   ~   ~   ~   ~   ~                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                        
      temp     H     bg     H     stars 4   H     starMax 4   H     items 7   H     (for index) <   B      (for limit) <   B      (for step) <   B      i =   A      scrollView V   H        updateAchievementCell 
            c   c   e         e            onGetRewards    	      updateAchievementCell    	       