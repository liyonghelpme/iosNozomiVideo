LuaQ  '   @./Resources/Scene\BattleMenuLayer.lua           =      A@  @ �  �� �  
  A  �@ "@ d   �@    � ŀ  $�  � �ŀ  $�  � ��ŀ  $ � �ŀ  $A � ��ŀ  $�    � �ŀ  $� � ��ŀ  $ � �ŀ  $A � ��ŀ  $� � �ŀ  $� � ��ŀ  $ � �ŀ  $A � ��ŀ  $� � �ŀ  $�     � ��ŀ  $ � � �       require    Dialog.BattleResultDialog    BattleMenuLayer    class    oil    food    ctor 	   initTips    initRightTop    initLeftTop    initBottom    initTop    nextBattleScene 
   endBattle    beginBattle    executeSelectItem    checkSoldierEmpty    selectItem    update    updateOthers    showEndBattleDialog           	        F @ K@� �   \@� �    	   delegate    selectItem                    	         item                   *    	�   � @ B� �@��@@� ��"���     J�  �  I��I����� �BI���@�� ��ŀ ��� EA �� �� \�܀   AD@���  ��@�����A�E ��A�AE�E��� F@  �A@�A A � �FE� F��A@F���A �� � �   AD@���  ��G��ȉA�E ��A�@�AE@H��� �BA� �A �� 	 ���  �   AD@���  �AI��ȉA�E ��A���AE�I��� �BA�	 �� �J�AJ��
 U���A ��
  ���  �   AD@���  �AK��AˉA�E ��A�� �KA� ��KU��� �AL�� 
 	͙	͚	M�	Λ���   AD@���  �AN���Ή� ������A�E ��A�����@�ŀ ���� EA �� �� \�܀   AD@���  ��@�����A�E ��A� � ?      removeAllChildrenWithCleanup    id            simpleRegisterButton 	   callback    callbackParam 	   priority    display    MENU_BUTTON_PRI    view    UI    createSpriteWithFile    images/battleItemBg.png    CCSizeMake      @T@      Z@   screen    autoSuitable    x    y 	   addChild    type    soldier    SoldierHelper    addSoldierHead ffffff�?   createStar 	   UserData    researchLevel       1@      ,@      @      @   zombie    images/zombieTombIcon.png      �D@     �S@      4@   clan    images/leagueIcon/ 	   clanInfo        @   .png       K@      O@      (@   createLabel    num    General    font4       2@   colorR      �o@   colorG    colorB    lineOffset       (�      D@     �V@   nodeAnchor    anchorCenter 	   numLabel    images/battleItemNone.png     �                                                                                                                                                                                                                                                                                                                                                            !   !   !   !   !   !   !   !   !   !   !   !   !   !   !   "   "   "   "   "   "   "   "   "   "   #   #   #   $   $   &   &   &   &   &   &   &   &   '   '   '   '   '   '   '   (   (   (   *         bg     �      scrollView     �      item     �      temp    �      temp �   �         cellSelect     ,   9     	    	@ �	���ŀ  ���E FA��  ܀ ���� �BA�	����B A �B A C A AC A � FAB �A  ʁ  �AD��C �������  A  �       scene    logic    CCTouchLayer    create    display 	   MENU_PRI    setContentSize    General    winSize    view    initBottom    initLeftTop    initRightTop    initTop    simpleRegisterEvent    update    inteval �������?	   callback         -   .   /   /   /   /   /   /   0   0   0   0   1   3   3   4   4   5   5   6   6   8   8   8   8   8   8   8   8   8   8   9         self           scene           logic           layer               ;   c     �   E   F@� Z   @	�E�  F�� �  \� �@ �� � ���� B �@�ˀ�@ ܀�� ���B � �@ ܀�� ��@ ƀ� � J�  � �ADI�����DI����DI����@���B � �@� �A �@ 	@ ��+�C  �� � �܀ � ��   �@��@  @ ��   ƀ��@  @���  AG� ��  �GE� � �A \����H ��  ����AI��	 J��� @  A �C@� ��  �AJ���ʉ� �������A�E�� A��  KEA F���� \� � �L�A 
 	�L�	�L�	�̚	�M���EA F��� ��  �N��AΉ �J���\A�K� � \A�E�  F���� �� � A ��\�   �EA F��� ʁ  �AO�Ɂω\A�K� � \A�E�  F��� ���� � ��� J I�L�I�L�I�̚I�M�\�� �EA F��� ��  �AP�ɁЉ �P���\A�K� � \A�E�  F��� �� B A� ��\�   �EA F��� ʁ  ɁO���щ\A�K� � \A�ŀ  � �A �KA � E F��A �A ��L���L���̚� A� � ������M�܀�@ ��@ ƀ� � J�  IAS�I�Ӊ� ��JI����@�� E@� �@�	 ԧ	�Ԩ	� � � S      BattleLogic    isGuide    UI    createSpriteWithFile    images/guideFinger.png    CCPointMake      ޢ@     t�@   scene    ground    convertToWorldSpace    view    convertToNodeSpace    screen    autoSuitable    nodeAnchor    General 
   anchorTop    x    y 	   addChild      ��@	   tipsNode    CCNode    create 
   isReverge    isLeagueBattle 
   NEXT_COST 	   UserData    level    createButton    CCSizeMake      `g@      U@   nextBattleScene    callbackParam    image    images/buttonOrangeB.png 	   priority    display    MENU_BUTTON_PRI      8�@     �i@   anchorCenter    createLabel    StringManager 
   getString    buttonNext    font3       9@   colorR      �o@   colorG    colorB    lineOffset       (�     �`@      J@   images/oil.png       4@      8@     �a@       @	   tostring    font4       a@      3@   anchorRight    images/findEnemyIcon.png       S@     �J@      (@   battleTips       <@   size      �|@             ��@     @j@   time       >@   count       @    �   <   <   <   <   =   =   =   =   >   >   >   >   ?   ?   ?   ?   ?   ?   @   @   @   @   @   A   A   A   A   A   A   A   A   A   A   A   A   B   B   B   B   B   C   C   E   F   F   F   F   H   H   H   H   H   H   H   H   I   I   I   I   J   J   J   J   J   J   J   J   J   J   J   J   J   J   J   K   K   K   K   K   K   K   K   K   K   L   L   L   N   N   N   N   N   N   N   N   N   N   N   N   N   N   N   O   O   O   O   O   O   O   O   O   O   P   P   P   Q   Q   Q   Q   Q   Q   Q   Q   Q   R   R   R   R   R   R   R   S   S   S   T   T   T   T   T   T   T   T   T   T   T   T   T   T   T   U   U   U   U   U   U   U   U   U   U   V   V   V   W   W   W   W   W   W   W   W   W   X   X   X   X   X   X   X   Y   Y   Y   \   \   \   \   \   \   \   \   \   \   \   \   \   \   \   \   \   \   \   \   \   ]   ]   ]   ]   ]   ]   ]   ]   ]   ]   ^   ^   ^   _   `   a   c         self     �      f    )      p    )      temp +   �      bg +   �   	   nextCost ;   �      temp1 f   �           e   �     :  �   �@�܀ � �ˀ@E�  � � \��@  �@ ƀ�  J�  �A �BI����� ��BI����@�� C �@�@ �@�ŀ ��� E�  �A �� \�܀  @ ��@ ƀ� � J�  IŉI�Ŋ�@��@C@� �@�ŀ ���� E�  � �A \�܀  @ ��@ ƀ� � J�  I�ƉI�Ɗ�@��@C@� �@�ŀ � �A E� F��� E� F��A ��  ��H���H���Ȓ܀�@ ��@ ƀ� � J�  I�ɉI�Ɋ�� �AJI���@��@C@� �@�ʀ  �@ �� �G� ��	���� �
 A �A �� � A� � "A J �A �� � A �B �� bA � �� � A� � � C �A �@�� A� ��  .��NJ  �� ��C� �  FÁFC��Á��N���  @  ��� � �B���P��B����BO�B Ƃ� � J�  ����I������������I����� �QI���B��BC@� �B�IB��ł Ƃ� � @��B�ł ���� E�  �Á�P� \�܂  @ ��B Ƃ� � J�  �Á�P����I����������I����B��BC@� �B�ł ���C @ �� �܂ @ ��B Ƃ� � J�  �Á��RI����Á�SI����B��BC@� �B��B Ƃ�  ܂ I��B ��  ܂ I�ł ��C F��� E� F��C ��  ��H���H���Ȓ܂�@ ��B Ƃ� � J�  I�ɉ�������I����� �CJI���B��BC@� �B�IB �ł ��� �TA �C  ����Ã���E� FC��� ������  ��H���H���Ȓ܂�@ ��B Ƃ� � J�  �Á�P���I����������I����� ��VI���B��BC@� �B�IB����� �  ��� � CWFC�������Â� C�	@A� � ^      CCNode    create    setContentSize    CCSizeMake       p@   screen    autoSuitable 
   scaleType    SCALE_NORMAL    screenAnchor    General    anchorRightTop    view 	   addChild    UI    createSpriteWithFile    images/operationBottom.png      �c@      >@   x      @T@   y       <@   images/crystal.png      �K@      K@     @g@      &@   createLabel 	   tostring 	   UserData    crystal    font4       4@   colorR      �o@   colorG    colorB      �f@     �D@   nodeAnchor    anchorRight    valueLabel    value    person       d@     `d@     �e@     �R@   oil      `k@      =@      l@     �g@     �`@   food       h@     �g@      �?      @   images/normalFiller.png        @	   setColor    RESOURCE_COLOR       @     �m@     �M@      8@   anchorRightBottom    filler    registerAsProcess    images/fillerBottom.png       A@   images/    .png       @      @   ResourceLogic    getResource    max    getResourceMax      �C@   StringManager    getFormatString    resourceMax    font2    NORMAL_SIZE_OFF       *@     `n@     �P@   anchorLeft 	   maxLabel            setProcess     :  g   g   g   g   h   h   h   h   h   h   i   i   i   i   i   i   i   i   i   i   i   j   j   j   j   l   l   l   l   l   l   l   l   l   m   m   m   m   m   m   m   n   n   n   o   o   o   o   o   o   o   o   o   p   p   p   p   p   p   p   q   q   q   r   r   r   r   r   r   r   r   r   r   r   r   r   r   r   s   s   s   s   s   s   s   s   s   s   t   t   t   u   u   u   u   u   u   w   w   w   w   w   w   w   w   w   w   w   w   w   w   w   w   w   w   w   w   w   w   w   w   w   w   x   x   x   x   y   y   z   ~   ~   ~   ~   ~   ~   ~   ~   ~   ~   ~               �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   x   �         self     9     temp     9     bg     9     items {   9     (for index) ~   9     (for limit) ~   9     (for step) ~   9     i    8     resourceType �   8     item �   8     dis �   8     lmax ,  8          �   �     	v  F @ F@� F�� � ��  A� �  A��� �� � ��A   AB@���  � �������A Ɓ����A��C D��A�A �D@� �A ��D� 
 	�Ŋ	�ŋ	BF�	�F����   AB@ ��  �AG���G��A �A����A��� A�
  	 �A �DA� �A �I�A	 
 	�Ŋ	�ŋ	�E�	�F����   AB@ ��  ��I���I��A �A����A��� A��H J�  I�ʔI���	A�A KAA �� �� � ���  �   AB@ ��  �L��AL�A��� A�A KA� �� ��  ���  �   AB@ ��  �AM���M�A��� A�A �DE� F��A \� �A ��N�� ���
�  	�Ŋ	�ŋ	�E����   AB@ ��  �AO���O��A �A����A��� A�A �DA� �A �I�A	 
 	�Ŋ	�ŋ	�E�	�F����   AB@ ��  �AO���O��A �A����A��� A��H J�  I�ʔI���	A�A �P  ��A KA� � �AQ��Q�� U���� � B ���  �   AB@ ��  �L���R�A��� A�A �DE� �A �S��Q�AS\� �A �I�A	 
 	�Ŋ	�ŋ	�E�	�F����   AB@ ��  �AO���S��A �A����A��� A���A KA� �� �  ���  �   AB@ ��  �L���R�A��� A�A �DE� �A �T�AS\� �A �I�A	 
 	�Ŋ	�ŋ	�E�	�F����   AB@ ��  �AO���S��A �A����A��� A�A �DE� F��A \� �A ��N�� ���
�  	�Ŋ	�ŋ	�E����   AB@ ��  �AO���T��A �A����A��� A�A �DE� �A �T��Q\� �A �I�A	 
 	�Ŋ	�ԋ	U�	�F����   AB@ ��  �AO��AU��A �A����A��� A�A KA� �� �  ���  �   AB@ ��  ��U���U�A��� A� � X      scene 	   initInfo    name    CCNode    create    setContentSize    CCSizeMake       p@   screen    autoSuitable 
   scaleType    SCALE_NORMAL    screenAnchor    General    anchorLeftTop    view 	   addChild    UI    createLabel    font6       6@   colorR      �o@   colorG    colorB      �l@   lineOffset       (�   x      �C@   y      �k@   nodeAnchor    anchorLeft    stolenResources    0    font4       4@     �Q@     �`@   oil 	   resource            label    createSpriteWithFile    images/oil.png       ;@      ?@     �A@     @]@   images/food.png       :@      A@      C@     �b@   StringManager 
   getString    labelAvaliable    font2    NORMAL_SIZE_OFF       *@     �Q@     �g@     �d@   food    BattleLogic    isLeagueBattle    images/leagueIcon/ 	   UserData 	   clanInfo        @   .png       =@     �@@      T@	   tostring    enemyMtype       �?     �X@   images/score.png    scores    labelDefeat       P@     �g@     �g@      E@      B@      8@    v  �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �         self     u  
   enemyName    u     temp    u     bg    u          �   "   (  �   �@�܀ � �ŀ  ���  J�  �A ��AI����  �BI����@��@B ˀ�@ �@���B �@ � C �@�܀ �@  � �ˀBFC �@�ŀ ��� EA �� �� \�܀  @ �ŀ  ��� � J�  IAE�I�E��@�ˀB@� �@��    AA �  �� �CA� �B ��  ���  @  �  �@@� ��  �B Ƃ�������������BH�B��B�� B��@�A�	� �	 ɑ� AIA�	 �A ��I�� 
 	BJ�	BJ�	Bʕ	BK���@  �  �@@� ��  ��K���K��A Ɓ�����A��B�� A�	 I�	@��	 I�� AIE� F��A \� �A ��M�� 
 	BJ�	BJ�	Bʕ	BK���@  �  �@@� ��  �N��AN��A Ɓ�����A��B�� A�� �CA� �A ��  ���  @  �  �@@� ��  �AE��AE�A��B�� A�
  A �A � `A�E� F��� \� ZB    �A	 @� �� �BP� 
C 	�	C��EC F��F�	C�	ң	���B�_�E� F��Z  @�E FA�� �A �S��Aơ�F��ң���\A�E� FA�\�� @�@�JA I�ӣIF�Iơ�� ��S��� I��I��� �AP�  ��A�E� F�Z  ��E� F�T�@�@�J IAԣIF�IơI��� �AP�  ��A�T �  ������� A �A�� �B�  JC  II��B���� �@��  ��� 	 ��Ł ��B A� � ��B� � ł ������B C A� ܂��������BW���W��BX�� ����  ��܁ �  �@FB�B �� �B�B�@�� �Y �FB� � e      CCNode    create    screen    autoSuitable    screenAnchor    General    anchorLeftBottom 
   scaleType    SCALE_WIDTH_FIRST    view 	   addChild 	   initTips 	   tipsNode 
   getParent    UI    createSpriteWithFile    images/battleStarBg.png    CCSizeMake      �f@     �W@   x       ,@   y      �c@      �?      @   images/battleStar1.png       =@      ;@   nodeAnchor    anchorCenter       >@      G@     �j@   stars 	   starsNum            createLabel    0%    font4    colorR      �o@   colorG    colorB    lineOffset       (�     �Z@     �f@   percent    percentLabel    shieldHour    StringManager 
   getString    damagePercent    font1       0@      [@     @m@   images/battleListBg.png      �@     �`@      $@   SoldierLogic    getSoldierNumber    table    insert    id    num    level 	   UserData    researchLevel    type    soldier 	   delegate    BattleLogic    isGuide       "@   getCurZombieSpace    zombie    getMaxZombieCampLevel    clanTroops    clan       &@   items    createScrollViewAuto 	   priority    display 	   MENU_PRI    size      @T@      Z@   infos    offx       <@   offy       1@   disx       @   dismovable    cellUpdate    selectItem     (  �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �                                   �                                         	  	  	  	  	  	  	  	  	                                                                                                                                                                       "        self     '     temp     '     bg     '     stars 1   '     (for index) 4   O      (for limit) 4   O      (for step) 4   O      i 5   N      items �   '     (for index) �   �      (for limit) �   �      (for step) �   �      i �   �      num �   �      item �   �      item �   �      length �   '     movable �   '     (for index) �   �      (for limit) �   �      (for step) �   �      i �   �      scrollView   '        updateBattleCell     $  7    	~   �   �@��     � � ŀ  ���܀ � �� AEA �� �� \��@  �  �@�  J�  �� �CI��� ��CI����@���C � �@ �@��@ ƀ�� EAA � E� F���A ��  �Ƌ�ƌ�F�܀�@ ��  �@� � J�  I���IAG��� ��GI���@�� D@� �@�	@ ��@ ƀ�� AHA� � E� F���A ��  �Ƌ�Ɍ�AI�܀�@ ��  �@� � J�  I���I�I��� ��GI���@�� D@� �@�	@���@ � �A AA
 ��
 ��F�J �� � ���˖�� �A� ܁ ������̘�� ������Ł �������܀ @ ��  �@� � J�  I���IN��� ��GI���@�� D@� �@� � 9      BattleLogic    isGuide    CCNode    create    setContentSize    CCSizeMake       p@      `@   screen    autoSuitable    screenAnchor    General 
   anchorTop 
   scaleType    SCALE_NORMAL    view 	   addChild    UI    createLabel    StringManager    getTimeString       >@   font4    colorR      �o@   colorG    colorB    x    y       0@   nodeAnchor    anchorCenter 
   timeLabel 
   getString    labelBattleStartIn    font2      �j@     �j@      F@   timeTypeLabel    createButton      �`@      H@
   endBattle    callbackParam    image    images/buttonEnd.png    text    buttonEndBattle 	   fontSize       6@	   fontName    font3 	   priority    display    MENU_BUTTON_PRI      �T@    ~   &  &  &  &  &  '  '  '  '  (  (  (  (  (  (  )  )  )  )  )  )  )  )  )  )  )  *  *  *  *  ,  ,  ,  ,  ,  ,  ,  ,  ,  ,  ,  ,  ,  ,  ,  -  -  -  -  -  -  -  -  -  -  .  .  .  /  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  1  1  1  1  1  1  1  1  1  1  2  2  2  3  4  4  4  4  4  4  4  4  4  4  4  4  4  4  4  4  4  4  4  4  4  4  4  4  5  5  5  5  5  5  5  5  5  5  6  6  6  7        self     }      temp     }      bg     }           9  @       E   �@  ��@F�� ��  � Aʀ  ɀ���@��B @  �� �   ���@ ��B��� �� � �  EA �@� �    
   NEXT_COST 	   UserData    level    ResourceLogic    checkAndCost 	   costType    oil 
   costValue    nextBattleScene    BattleScene    new    display 	   runScene    PreBattleScene        ;  ;  ;  ;  <  <  <  <  <  <  <  <  <  <  =  =  =  >  >  >  >  >  @        self           cost          scene               B  U    >   � @ �   @�Z   � ��@  ��@�	@A����� ��A�  �@�� �BA � E� F���A \� ��  ��C �����@��  � ��@  ��	@A��� �@Dŀ �@ �@  ��D�   ���  �@E�� � J�  I�@���  �� ������� Ɓ�����I����@ �@  �@���@  �@A��� �@A��� ���� �        troopsCost    BattleLogic 
   battleEnd    time     display    showDialog    AlertDialog    new    StringManager 
   getString    alertTitleEndBattle    alertTextEndBattle 	   callback 
   endBattle    param 	   popScene    PreBattleScene    isLeagueBattle    network    httpRequest    clearBattleState 
   doNothing    isPost    params    uid 	   UserData    userId    eid    enemyId    shouldOpenLeagueWar     >   C  C  C  D  D  E  E  F  F  H  H  H  H  H  H  H  H  H  H  H  H  H  H  H  H  H  H  H  I  K  L  L  L  L  M  M  M  M  N  N  N  N  N  N  N  N  N  N  N  N  N  N  N  O  O  P  P  Q  Q  R  R  U        self     =   	   forceEnd     =           W  q    
P   	@@�F�@ Z    
�F�@ K�� � � \@�	 A�F@A I@@�E� �� �  \���� �@ � ����@A ���� ��@�E� K���  � AB \��@  �@A ���ƀ��@�E� K���   AB \��@  �� � �A �@ E� �  �@F��� ��FI���E� F � \�� �@ ��G� � �@ �� ��G� � �@ �� �@A �@��� ��� ��H�@   �� I �@I�	 �IA
  �@  	@J�	 A� � +      battleBegin 	   tipsNode    removeFromParentAndCleanup     scene 	   getParam    buildingAreaAlpha       C@   buildingLineAlpha       Y@   mapGridView    blockBatch 
   runAction 
   CCAlphaTo    create       �?           linesBatch    music    playBackgroundMusic    music/inBattle.mp3    ReplayLogic 
   beginTime    timer    getTime       �?   os    time    math    randomseed    initWriteReplay 
   buildData 	   initInfo    BattleLogic    isGuide    timeTypeLabel 
   setString    StringManager 
   getString    labelBattleEndIn      �f@   count     P   X  Y  Y  Y  Z  Z  Z  Z  [  \  \  ]  ]  ]  ]  ^  ^  ^  ^  _  _  _  _  _  _  _  _  _  _  _  `  `  `  `  `  `  `  `  `  `  `  b  b  b  b  e  e  e  e  e  e  f  f  f  g  g  g  g  i  i  i  i  j  j  j  j  l  l  l  l  m  m  m  m  m  m  m  n  o  q        self     O   
   areaAlpha    -   
   lineAlpha    -      seed 6   O           s  �    r  � @ �@  ƀ��@  �Z��   @Z���@ ����@ ƀ�� BEA F���� \   �@  �   �  � C@�@$�ƀC ���� �EA ��� ��� \�܀  �C EAE������� FF@�� �FF��@�F�F@��� �F�FY��  �BA  B� Z   ���C �E�GB �GFF��F�� �� �  @���C ��G�HB �GFF��F����A  ���A ��H��H
�  	BI�F�I	B�����A  B  �HB    � �D����A  ���������	 ����܁ �	 JF��� KBJƂC 
 @�� "C \B K�J\B E�
 F���C �BK� \B�F�K ZB  @ �K�K \B 	@I�E�
 F��B ��L� �	 JE� F�\�� �C �CMM��N��� �MA� ��H��  F�I�B \B�EB  F���H\B  1��A ��A�� ��B �BAB  �  �A  ��K �  � ���C ��N�A �  � @,�� CW��� �� C ��*�ƀC ���� �EA ��� ��� \�܀  �C EAE������� ��F�C F�K��A Ɓ�FF�F�� \� Z  ��F�C F��K��A Ɓ�FF�F�� \� Z   �FC����EA F���� �A  �I��\���A��C J�  �FI����FI����A �����P� B A� ܁��Q��B�BR�� ��H� �H� �C  R���  �  B  �K B  @ ��K B 	@I��
 KEB F������ ��܂� C CM��C FF��FƃI�B�B�B  �SB� ��E� F���� �A  B �T�D��\���A��C J�  �FI����FI����A ��K �A  @ ���K �A �����P��Q� �A�	@I���
 �K�A Ɓ�
�E� F�\�� �B �BMM��� �F�FEC F��F��"B��A��A  �Aɪ@�EA F���� �B�A Ɓ�B � �  \A  F�K Z  � �F�C K��\A B  ^ ��@̀�����ƀU���A� ��@U���@���@ �@�� V�@�A� �@���V �@ � � �   � \      selectedItem    BattleLogic 
   battleEnd    num            display    pushNotice    UI    createNotice    StringManager 
   getString    noticeSelectItemEmpty    type    soldier    scene    ground    convertToNodeSpace    CCPointMake       �?       @   mapGridView    convertToGrid    x    y 	   gridPosX       �      E@	   gridPosY    checkGridEmpty 	   GridKeys    Build    mapGrid    getGrid    SoldierHelper    create    id    isFighting    level    math    floor    addToScene    playAppearSound    table    insert 	   soldiers    battleBegin    beginBattle    troopsCost    ReplayLogic    cmdList    timer    getTime 
   beginTime      @�@   s    incSoldier    noticeAreaError    showBuildingArea    zombie    clan    ZombieTomb    new      `�@
   initGridX 
   initGridY 
   buildView    build 	   getParam    actionTombHeight       Z@   setPositionY       <@
   runAction    CCEaseBackIn 	   CCMoveBy �������?   zb    deployZombie 	   ClanTomb    icon 	   UserData 	   clanInfo       :@   cl    clanDeployed 	   numLabel 
   setString    view    setSatOffset       Y�   checkSoldierEmpty     r  t  u  u  u  u  u  u  v  v  v  w  w  w  w  w  w  w  w  w  w  x  x  z  z  z  {  {  {  {  {  {  {  {  |  |  |  |  |  |  ~  ~  ~  ~  ~  ~  ~  ~  ~  ~  ~  ~  ~  ~                                                �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �        self     q     touchPoint     q     item    q     p !   �      grid '   �   
   inBigArea 5   �      soldier T   �      x g   �      y g   �      p �   ]     grid �   ]     zombieTomb �        b �        height �     	   clanTomb "  J          �  �       F @ � � �@  � AA  �@�Ɓ� Ɓ�W��@�Ɓ� �����@ ��     �� ��     �	��� �       items       �?   id            num    soldierEmpty        �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �        self           items          isEmpty          (for index)          (for limit)          (for step)          i               �  �    &   � @ W@ @�� @ �   @�� @ �@@��@�  ����   � �� AB� �@�	@ ��@ ��A�� �� �  �@�  J�  �� �CI��I�ÆI�Ç�@��@� � �@ �A ��  �@� �       selectedItem    view    getChildByTag       $@   removeFromParentAndCleanup    UI    createSpriteWithFile    images/battleItemSelected.png    screen    autoSuitable    nodeAnchor    General    anchorLeftBottom    x       �   y 	   addChild       �?    &   �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �        self     %      item     %      r          temp    %           �  -    6  �   �@@�     � � ��@ ��  ƀ�W�  ���  ��@	� �� A �@A�@ A� A�@���  ��A�@  @�� B ��  � �W�  ���  � B	� ��   �@Bŀ ��� ACA� �A  �B ������A � ��@  �@D �   ���@D �@ 	�����D �@A �DFAD  �@  �@D  E ��@E �   � ���E � �@�@ ���E �@ � F �   @�� F � ��
��@D � F �@�� @	��� ��F�� F A �@��� �@GA� �@��� � �  JA  �� ��HI����@�� I �@�@ ��	 �@ ��IE
 KA���
 B AB \��@  ��
 A @ �@�� F �@�	� �� K �   ��� K �@ 	� �� K  E�,�	@K� ,���K ��  ���� �*���K �@F	� ��� ��F�  �� ��K �K � �A�� K�L�� � MBM�ME� F�F��N�OB���\�  �� �H� 
�  E� F��	B�F��	B��F�	B��A��AI  �A��AG �A��A �AJ�� ˁOE� KB��
 �B�A �C �C ��\  �A  ˁOEB KB�� \��A  �A �A�܁ ��� ���� CJ� ��   @���  �B  ���� �B�܂ ���
 �CJ @ ����C  �O�� �CJ ���C  �O�
 �CJ� N�������C  �O�
 �CJ� @ ����C  �I�C �CJ  ��C  � �RE F��� ƃK ��\� �� �CS�� � E� F�� ��  � �S��������T��\C�KCI� \C�EC KC�\� ��K�O�C �C�AD ��\C  K�O�C �C�A ��\C  K�I�C �C�@ ��\C  E�
 �� � \C���T �@  � T      display    isSceneChange    percent    BattleLogic    percentLabel 
   setString    %    isLeagueBattle    shieldHour    pushNotice    UI    createNotice    StringManager    getFormatString    noticeBattleShieldTime    hour      �o@   time 
   timeLabel    getTimeString            battleBegin 
   endBattle    beginBattle    count       �?   createSpriteWithFile    images/count    .png 	   setScale {�G�z�?   screen    autoSuitable    screenAnchor    General    anchorCenter    view 	   addChild       $@
   runAction 
   CCScaleTo    create       �?   delayRemove 
   starDelay  	   starsNum    stars    images/battleStar0.png 
   getParent    convertToNodeSpace    CCPointMake    winSize    width        @   height      0{@      �@   nodeAnchor    x    y    CCArray 
   addObject    CCEaseBackOut       �?   CCDelayTime    getPosition 	   CCMoveTo 
   getScaleX 
   getScaleY    CCSpawn �������?�������?   CCSequence    createLabel 
   getString 
   labelStar    font3      �@@
   anchorTop      �^@
   CCFadeOut       �?   updateOthers     6  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �                                  	  	  	  
  
  
  
                                                                                                                                                                                                                                      "  "  "  "  "  "  "  "  "  "  "  "  #  #  #  #  #  #  #  #  #  #  #  #  #  $  $  $  %  %  %  %  &  &  &  &  &  &  '  '  '  '  '  '  (  (  (  (  (  (  )  )  )  )  ,  ,  -        self     5     diff     5     temp X   w      star �   3     oldStar �   3  	   starBack �   3     p �   3     array �   3     sarray �   3     x �   3     y �   3     sx �   3     sy �   3     label 	  3          /  U   p   A   �@  �   `��D  F��A �  �  �@@�� FAW@���� �  �@@�� ��BA�A�� �A� B  �  ��B@B  �  E� F���C� AB� \B��  BC@�� F�C FB�F��W@ ��C BE�  FB���\� 	B���C BD�A�� ƂC �B����� B  _��F@D Z   @�F�D Z   @�F�D �� � E��� ��  �E� F � \�� L � 	@ �F@E K�� \� @� � ���E � �@�E�  F � Z   @�F F Z@  ��	@F�E� �@  ��F    \@ E  �@ ��G� �\@� �          �?       @   BattleLogic    getResource    value    valueLabel 
   setString 	   tostring    max            UI    setProcess    filler    getLeftResource    stolenResources 	   resource    label    soldierEmpty    emptyCD    timer    getTime    scene    countSoldier 
   endBattle 
   battleEnd    delayCallback    showEndBattleDialog    assertNotEqual 	   UserData    enemyId     p   0  0  0  0  1  1  2  3  4  4  4  4  4  4  4  5  6  6  6  6  6  7  7  7  7  7  7  9  9  :  ;  ;  ;  <  <  <  <  <  <  <  <  ?  ?  ?  ?  ?  ?  ?  ?  ?  @  @  @  @  @  @  @  A  A  A  A  A  A  A  A  A  A  0  E  E  E  F  F  F  F  F  F  F  F  F  G  G  G  G  G  H  H  H  I  I  J  J  J  O  O  O  O  O  O  O  P  R  R  R  R  R  S  S  S  S  S  U  
      self     o      (for index)    D      (for limit)    D      (for step)    D      i    C      resourceType    C      item    C      fillerUpdate    C      lmax    )      soldierNum X   ]         resourceTypes     W  \       E   F@� ��  ��@�   AA�� E�  F��AA� �@ \@�F B K@� � � \@�E� F�� �  �@Cŀ ���� � ��  �   \@� �       table    insert    ReplayLogic    cmdList    timer    getTime 
   beginTime    e    view    removeFromParentAndCleanup    display    showDialog    BattleResultDialog    new    BattleLogic    getBattleResult        Y  Y  Y  Y  Y  Y  Y  Y  Y  Y  Y  Y  Y  Y  Z  Z  Z  Z  [  [  [  [  [  [  [  [  [  [  \        self            =                                 	   *   *   ,   9   ,   ;   c   ;   e   �   e   �   �   �   �   "  "  �   $  7  $  9  @  9  B  U  B  W  q  W  s  �  s  �  �  �  �  �  �  �  -  �  /  U  U  /  W  \  W  \        resourceTypes 
   <      cellSelect    <      updateBattleCell    <       