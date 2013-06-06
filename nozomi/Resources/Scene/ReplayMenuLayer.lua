LuaQ  '   @./Resources/Scene\ReplayMenuLayer.lua           4   @  ��       d   	@ �   d@  	@��   d�  	@ �   d�  	@��   d  	@ �   d@ 	@��   d� 	@ �   d� 	@��   d  	@ �   d@ 	@��   d� 	@ �   d� 	@��   d  	@ �   d@ 	@��   d� 	@ �   d� 	@�� �       ReplayMenuLayer    class    onPlay    onDownload    readyToDownload    addReplayView    addReplayMenu    update    initBattleResultView    changeTimeScale    addDownloadView    updateDownload    beginReplay    beginLoadingFrame    cancelRecord 
   endReplay 
   endRecord    ctor                   F @ Z@  @�F@@ K�� � � \@�	���F A I���K�A \@ � �F A K � �@ \@� � 
      replayOver    replayView    removeFromParentAndCleanup     scene    pause     addReplayMenu    reloadScene    play                                      	   	   	                        self                           F @ Z@  ��F@@ Z    �F@@ K�� � � \@�	���K A \@ E@ F�� �� � B\@ � �F@B K�� �� \@� �       replayOver    replayView    removeFromParentAndCleanup     addDownloadView 	   UserStat    stat    UserStatType    VIDEO_DOWNLOAD    scene    reloadScene 	   download                                                                                      self                   (     /   �   �@@�@  ����  ��@�  �@�� �AA  �   �@   � Z    ��@ ��B�� �� �   ��� C �@ ����  �@Cŀ ���� �AA � E� F���A \� ��  ��D ����AE���E��  � ��@   �       General    supportVideo    display    pushNotice    UI    createNotice    StringManager 
   getString    noticeUnlockFunction    CrystalLogic    changeCrystal       $�   onDownload    showDialog    AlertDialog    new    alertTitleDownload    alertTextDownload 	   callback    readyToDownload    param    crystal       $@    /                                                !   !   "   "   "   "   "   "   #   #   $   &   &   &   &   &   &   &   &   &   &   &   &   &   &   &   &   &   &   &   &   (         self     .      force     .           *   G     �     A@� �  �@ �@��A�A   � �A AA�� A�	� �	@ �� A@� �A B AB �� ��B���Ł ���A�� C�C���  � D@ A ��� A�A �DE� � �A \���� �� ��B A� �� �G�B �� ł � �  � D@ �A �ȏ��ȐŁ ������Ł Ɓ������� ������A���� A�A �DE� � �A \���A
 ƁJ    A�
 �� �G� �� ł � �  � D@ �A �Aˏ��ȐŁ Ɓ�����Ł Ɓ������� ������A���� A�A �KE� F�� \� �� �AL�� 
�  	͙	͚	M����  � D@ � �A��͐Ł Ɓ������� ������A���� A�A NE� �A �� \����N ʁ  � �ɁϞ� �  � D@ � �A��ϐŁ Ɓ������� ������A���� A� � @      CCNode    create    view 	   addChild    replayView    removeFromParentAndCleanup    replayOver    CCLayerColor    ccc4            General 
   darkAlpha    winSize    width    height    screen    autoSuitable    UI    createMenuButton    CCSizeMake      �[@     @[@   images/buttonChildMenu.png    display 	   popScene    PreBattleScene    images/menuItemAchieve.png    StringManager 
   getString    buttonReturnHome    MENU_BUTTON_SIZE    x       R@   y      �Q@   screenAnchor    anchorLeftBottom    nodeAnchor    anchorCenter 
   scaleType    SCALE_NORMAL    images/buttonMenu.png    readyToDownload    images/menuItemDownload.png    buttonDownload      �Q�   anchorRightBottom    createLabel 
   labelPlay    font3      �A@   colorR      �o@   colorG    colorB      �T�   createButton      �_@     �a@   onPlay    callbackParam    image    images/buttonReplay.png       (@    �   ,   ,   ,   ,   -   -   -   -   .   .   .   /   /   /   /   1   2   4   4   4   4   4   4   4   4   4   4   4   4   4   4   4   4   4   5   5   5   5   6   6   6   8   8   8   8   8   8   8   8   8   8   8   8   8   8   8   8   8   8   9   9   9   9   9   9   9   9   9   9   9   9   9   9   9   9   :   :   :   <   <   <   <   <   <   <   <   <   <   <   <   <   <   <   <   <   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   >   >   >   @   @   @   @   @   @   @   @   @   @   @   @   @   @   @   A   A   A   A   A   A   A   A   A   A   A   A   A   B   B   B   D   D   D   D   D   D   D   D   D   D   D   D   E   E   E   E   E   E   E   E   E   E   E   E   E   F   F   F   G         self     �      isReplayOver     �      temp     �      bg     �           I   l     �   �   �@�܀ @ �	@ ���  � �A A� �� ��A �A ��B��  EB F���� \� � ܀ � ��@ ƀ�  JA IŉI�Ŋ� �AFI���� ��FI���A �AGI���@�ˀ� @ �@���  ���A A �A ��F�H ��  ����AI��A ������܀ � ��@ ƀ�  JA IʉIAʊ� ��FI��� ��JI����A �AGI���@�ˀ� @ �@���  ��� E FA��� ܀ A �D@���  � ��������ˉ�̊A��G��A�
�  	� �	͙	 ��A �M� �M� N� A�AN A �  �JEA F���� \� � ��N� 
�  	�Ϟ	ʟ	J����  A �D@ �A �AЉ��Њ� ������� �������A �A����A��� � A��  AQA� �A ��  ���  �  A �D@ �A � �A����� �������A҉��Ҋ�A �A����A��� � A�� A@� KS�A �A�A� ��\A  KS�� �A�A� ��\A  KT�A �A�E� KB�� \��  \A  E� �� �A  
�  	�ӪFU 	B���   \A F�U K���� \A� � X      CCNode    create    replayView    UI    createMenuButton    CCSizeMake      �[@     @[@   images/buttonChildMenu.png    display 	   popScene    PreBattleScene    images/menuItemAchieve.png    StringManager 
   getString    buttonReturnHome    MENU_BUTTON_SIZE    screen    autoSuitable    x       R@   y      �Q@   screenAnchor    General    anchorLeftBottom    nodeAnchor    anchorCenter 
   scaleType    SCALE_NORMAL 	   addChild    createButton       e@      S@   changeTimeScale    callbackParam    image    images/buttonGreen.png 	   priority    MENU_BUTTON_PRI              @X@   anchorBottom    createLabel    x1    font4       >@     @U@      C@
   timeScale    valueLabel    value       �?   CCDirector    sharedDirector    getScheduler    setTimeScale    initBattleResultView    labelReplay    font3       9@   colorR      �o@   colorG    colorB      �]�     �E�   anchorLeft    anchorRightTop    createSpriteWithFile    images/replayIcon.png       <@      ;@     @d�      K�   CCArray 
   addObject 
   CCFadeOut       �?	   CCFadeIn 
   runAction    CCRepeatForever    CCSequence    simpleRegisterEvent    update    inteval 	   callback    view     �   K   K   K   K   L   N   N   N   N   N   N   N   N   N   N   N   N   N   N   N   N   N   N   O   O   O   O   O   O   O   O   O   O   O   O   O   O   O   O   P   P   P   R   R   R   R   R   R   R   R   R   R   R   R   R   R   R   S   S   S   S   S   S   S   S   S   S   S   S   S   S   S   S   T   T   T   V   V   V   V   V   V   V   W   W   W   W   W   W   W   W   W   W   X   X   X   Y   Y   Y   Y   Z   Z   Z   Z   Z   Z   Z   Z   \   \   ^   ^   ^   ^   ^   ^   ^   ^   ^   ^   ^   ^   ^   ^   ^   _   _   _   _   _   _   _   _   _   _   _   _   _   _   _   _   `   `   `   b   b   b   b   b   b   b   b   b   c   c   c   c   c   c   c   c   c   c   c   c   c   c   c   c   d   d   d   e   e   e   f   f   f   f   f   f   g   g   g   g   g   g   h   h   h   h   h   h   h   h   h   j   j   j   j   j   j   j   j   j   j   k   k   k   k   l         self     �      bg     �      temp     �      label S   �      array �   �           n   �     n   �   �@@�    
���@ ��  ƀ�W�  ���  ��@	� �� A �@A�@ A� A�@���A ��  � �W� @�� B ��A �� �@BE� K��� ���AB �� �� ��\  �@  �� A @ �@���A � �	�������@ �@ ƀ�W�  ��@ ��@	� �� A �@A�@ A� A�@���A �@ � �W�  ���A � D	����� ��D�  �� � B �A � �A�� K�E�� \A�E� F�� ��  � �F���B�� ����� ��\A�KH� \A�KAB�A ���E K���B ��� K��\ \  �  \A   � $      ReplayLogic 	   isZombie    percent    ZombieLogic    percentLabel 
   setString    % 	   starsNum    stars 
   runAction    CCEaseBackIn    create 
   CCScaleTo       �?           delayRemove       �?   BattleLogic    UI    createSpriteWithFile    images/battleStar0.png 
   getParent 	   setScale    screen    autoSuitable    nodeAnchor    General    anchorCenter    x    getPositionX    y    getPositionY 	   addChild    CCEaseBackOut 
   getScaleX 
   getScaleY     n   o   o   o   o   p   p   p   p   p   q   q   q   r   r   r   r   r   r   t   t   t   t   t   u   u   u   v   v   v   v   v   v   v   v   v   v   v   w   w   w   w   x   x   x   y   {   {   {   {   {   |   |   |   }   }   }   }   }   }                  �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �         self     m      diff     m      oldStar    ,      star G   m      oldStar J   m   	   starBack L   m           �   �     �   E   K@� \� ��� �  A � ��@  �@ ��A� � 
 E FA�	A��EA F��	A�	AC�	�C��@�� D �@D � �@��� � E�@ �  A� �� ���  �� �@ ��Aŀ 
�  	F�	AF��@��@� � �@��   �� � A� �@��� �� E�  �B �� \�܁  ǁ �A Ɓ�� J�  � �HI����BH���I��I�H��A��A� E� �A�Ł ���	 �A��  ���� ���	 E�  �B �� \�܁  B �A@���  � �����BH��������H�B�B� ��B���� �	���	@J�� 	 �@��     �	�F��� ƀ��
 E F��A � Ɂ˖Ɂ˗ɁK�Ɂ̘܀�ǀ �@ ƀ�� J�  I�L�IM�� �HI����@��@� E� �@�	@ʚŀ 	� ��� ƀ�� NAA � E F���� � Ɂ˖Ɂ˗ɁK�Ɂ̘܀�ǀ �@ ƀ�� J�  IO�IAO�� �HI����@��@� E� �@� � >      CCNode    create    setContentSize    CCSizeMake       p@   screen    autoSuitable    screenAnchor    General    anchorLeftTop 
   scaleType    SCALE_NORMAL    x       @   y       $�   replayView 	   addChild    temp    UI    createSpriteWithFile    images/battleStarBg.png      �f@     �W@      ,@     �c@      �?      @   images/battleStar1.png       =@      ;@   nodeAnchor    anchorCenter       >@      G@     �j@   ReplayLogic 	   isZombie    images/battleStar0.png    stars 	   starsNum            createLabel    0%    font4    colorR      �o@   colorG    colorB    lineOffset       (�     �Z@     �f@   percent    percentLabel    StringManager 
   getString    damagePercent    font1       0@      [@     @m@    �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �         self     �      bg    �      stars .   �      (for index) 1   i      (for limit) 1   i      (for step) 1   i      i 2   h      star X   h           �   �        F @ � @ �@@��@��@I���E  � @ �@@F�� � @ �@A��A� @� A�@��  �@B�� ��B�� ��B � �@� �    
   timeScale    value       @      �?   TIME_SCALE    valueLabel 
   setString    x    CCDirector    sharedDirector    getScheduler    setTimeScale        �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �         self           tvalue 
              �   �     j  E@  K�� \� 	@ �F�@ � � �@A@ �@�� �� �AE FA��� ��  �Å� �C���� ��� �  A �D@�A � �DA �A �� � ���  �  A �D@ � �AF���F�� �A�����A ������A�A�� A�� �DA �A �A � ���  EA F��� ʁ  ��H���H�\A�KAA� \A�J�  I��IAF�	@�E� F��� �I \A�E� F�� �I B \A E� FA���
 ��J� �� � �A�� J�  I̗I̘IL�\�� �EA F��� ��  ��L��M� BG���\A�KAA� \A�E� K��\� � �K�M�A  A ��\A  EA F��� ʁ   BN��B �G��\A�KA�� \A�E� FA���
 ��J�� �� � ��� J I̗I̘IL��� I���\�� �EA F��� ��  ��O��P� BP���\A�KAA� \A�E� FA���
 ��J�� �� � �A�� J�  I̗I̘IL�\�� �EA F��� ��  �Q��AQ� BP���\A�KAA� \A�E� F���� �A � A ��\�   �EA F��� ʁ  �AR�ɁR�\A�KAA� \A�E� F���A � B ����� �S @  � ł
 ���C ܂ � J��� �  bC�\��� �EA F��� �A �AU�ɁU� �U�� BG���B �G��\A�KA�� \A�	� �	@ƬF�@ F��LA�	@�EA ���A  
�  	دF�X 	B����   \A E� F���A  �� �\A F@ K���\A�KA� Ɓ� �� ZAB \A�E� K���� B AB �B � ܁� BB[E FB�FB�\���� ��D�� �� �A Ɓ�  J�  � �BGI���B ��GI���A��A�@ �A���[AB �A�� B K�\�� ˂�@�� � ��\B  EB F����\B F� KB���\B�	@��E� K��\� K��� \B�EB ��Ƃ^    \B E� F��  \B E� FB��  \B  � ~      camera    VideoCamera    create    scene    view 	   addChild    UI    createButton    General    winSize 
   doNothing    image    images/downloadBack.png 	   priority    display 	   MENU_PRI    nodeChangeHandler    screen    autoSuitable    createSpriteWithFile    images/videoProcessBack.png    CCSizeMake       }@      D@   x            y       :�   screenAnchor    anchorCenter 
   scaleType    SCALE_NORMAL    images/videoProcessFiller.png      `|@      <@      @   replayProcess    node    percent    registerAsProcess    setProcess    createLabel    StringManager 
   getString    labelDownloading    font3       9@   colorR      �o@   colorG    colorB       m@     �P@   nodeAnchor    CCNode    setContentSize       p@   anchorLeftTop    labelDownloadTips    font1       2@   align    kCCTextAlignmentLeft       q@      a@   anchorLeft    labelFreeCrystals       >@     q@     @i@   images/storeItemCrystal5.png       j@     �a@      ?@      T@   createMenuButton      �[@     @[@   images/buttonChildMenu.png    cancelRecord    images/menuItemAchieve.png    buttonCancel    MENU_BUTTON_SIZE      �n@     �G@      R@     �Q@   anchorLeftBottom 
   showScene    downloadTime 
   totalTime    battleTime       @   simpleRegisterEvent    update    inteval       �?	   callback    updateDownload 	   addScene    startRecord    scaleTo    scMin    SIZEX        @     ��@   CCLayerColor    ccc4    width    height    images/logo.png 	   setScale �������?�������?
   runAction 
   CCScaleTo       �?   frame    CCTextureCache    sharedTextureCache    removeTextureForKey    delayCallback    beginLoadingFrame    music    changeMusicState    changeSoundState     j  �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   	      self     i     scene    i     temp 
   i     bg 
   i     temp1 =   i     frame .  i     logo 2  i     t1 D  i     t2 E  i                   � @ �@ 	� �� @ �@@ �� ŀ  ���A AAFA � �@  �       downloadTime 
   totalTime    UI    setProcess    replayProcess    node                                          self           diff           p                        F @ K@� � � \@�	�@�F�@ I@A� �       frame    removeFromParentAndCleanup     scene    pause                 	  
  
          self                  F    �   E   K@� \� �  ŀ  ��� ܀ � ��@ ƀ�  J�  � �ABI����A ��BI���@�� � @ �@��@ ˀ�܀ ���A �@�ŀ  ��� EA �� �� \�܀  � ��@ ƀ�  J � �EI����A ��BI��I�ŊIƋ�@�� � @ �@�ŀ  ���A EA �� �� \�܀  � ��@ ƀ�  J � �GI����A ��BI��IAǊI�ǋ�@�� � @ �@�ŀ  ��� AHA� � E F���	 � ɁɒɁɓɁI�B A�
 ��
 �����܀�A �A@���  �ˊ�Aˋ� �A����A�C��A�A �C� �C�A A��  �@A� �A � B ���  �  A �A@ � � �������A �������AǊ��̋A�� � A��  �@A� �A � B ���  EA F��� ʁ  Ɂ͊��͋\A�KC� \A�J  ��  �N�  ��A��A ��C�� ��C� �A��A ��C�� ��C� �A���  ��G� �A�B ܁  �NAB ��  ��ɒ��ɓ��I�����A Ɓ�  J�  I�ΊIB̋� �BBI���A��C@ �A��       � �AB B B C��B       �    ł  ��� EC �C �� \�܂  � ��B Ƃ�  J�  � ��OI���IЊICЋ�B��� @ �B�ł  � JC  ��  ����CǢI����B�ƂQ ��@� �B� � G      CCNode    create    UI    createSpriteWithFile    images/loadingBack.png    screen    autoSuitable    screenAnchor    General    anchorCenter 
   scaleType    SCALE_NORMAL 	   addChild    CCTextureCache    sharedTextureCache    removeTextureForKey    images/loadingTitle.png    CCSizeMake      ��@      s@
   anchorTop    x       6�   y      �O@   images/tipsBg.png      0�@     �P@   anchorBottom               (@   createLabel    StringManager 
   getString 
   dataTips1    font1       2@   colorR      �o@   colorG    colorB    size      �@      I@     0p@      <@   nodeAnchor    images/loadingProcessBack.png      �q@      9@     �P@    images/loadingProcessFiller.png      pq@      4@       @      @   registerAsProcess    labelLoading    font4      �a@   images/downloadNoticeIcon.png      @m@     `e@   anchorLeftTop       7@      *�   simpleRegisterEvent    update 	   callback    inteval    frame        2  4      E   F@� �   � � �@ \@  �       UI    setProcess       Y@       3  3  3  3  3  3  4        percent              filler    ttable     8  ?      D   L � H   D � �   �@@�   �� �����  \@  D   @�� �D  K � \@ A�  H    �       math    floor       Y@      @   beginReplay        9  9  9  :  :  :  :  :  :  :  :  ;  ;  ;  <  <  <  =  =  ?        diff              cp    setPercent    self �                                                                                                                                                                                                                                                   "  "  "  "  "  "  "  "  "  #  #  #  #  #  #  #  #  #  #  #  #  #  $  $  $  %  %  %  %  %  %  %  %  &  &  &  &  &  &  &  '  '  '  (  )  )  )  )  )  +  +  +  +  +  +  ,  ,  ,  ,  ,  ,  .  .  .  .  .  .  .  .  .  .  .  .  .  .  /  /  /  /  /  /  /  /  /  /  0  0  0  4  4  4  5  5  5  6  7  ?  ?  ?  ?  @  @  @  @  @  @  @  @  @  A  A  A  A  A  A  A  A  A  A  B  B  B  C  C  C  C  C  C  C  C  E  E  E  E  F        self     �      bg    �      temp    �      temp1 b   �      filler �   �      ttable �   �   
   infoLabel �   �      setPercent �   �      cp �   �   	   loadData �   �      update �   �           H  L       E   F@� ��  ��@�  �� ŀ  ���A ܀ 
�  F�A 	A�	 �\� ��B I����� � C� � �@  �       AlertDialog    new    StringManager 
   getString    alertTitleCancelRecord    alertTextCancelRecord 	   callback 
   endRecord    param    scene 
   showScene    display    showDialog        I  I  I  I  I  I  I  I  I  I  I  I  I  I  I  J  J  K  K  K  K  L        self           dialog               N  o    	�   F @ Z   @'�E@  K�� \� ���  �@�A �� � ��@  �  �@B�� � A �A ���  ŀ ���  J�  �A ��DI���� �EI����@��@EA� �@�ˀ� @ �@��� � �܀ �@�A� �@��  �@�� E� �� � \�܀  � �ŀ ���  J �A �AGI��I�G�IAH��� �EI����@�ˀ� @ �@��@EA� �@��� � �܀ �@�A� �@��  �@�� E� �� �	 \�܀  � �ŀ ���  J �A �AII��I�A�I�I��� �EI����@�ˀ� @ �@��@EA� �@��� � �܀ �@�A� �@��  �@��	 E� �
 �A
 \�܀  � �ŀ ���  J�  �A ��JI��I�J�IK��@�ˀ� @ �@��@EA� �@��� � �܀ �@�A�	 �@��@K ƀ�ˀ�@� �@�	@���  A F�L �  �@ �� � �A �M�@ � �K�M � � \@� � 8      camera    CCNode    create 
   runAction 
   CCAlphaTo       �?             �o@   UI    createSpriteWithFile    images/downloadLastframeBg.png    CCSizeMake       �@      �@   screen    autoSuitable    screenAnchor    General    anchorCenter 
   scaleType    SCALE_NORMAL    setOpacity 	   addChild    CCTextureCache    sharedTextureCache    removeTextureForKey    images/downloadNoticeIcon.png      �s@      m@   anchorRightBottom    x      �P�   y       "@#   images/downloadLastframeZombie.png      �@     ��@   anchorLeft       @   images/loadingTitle.png      ��@      s@   anchorRightTop       L�      �   scene    view 
   lastFrame    delayCallback        @
   endRecord 	   UserStat    stat    UserStatType 	   DOWNLOAD    addReplayView     �   O  O  O  Q  Q  Q  R  R  R  R  R  R  R  R  S  S  S  S  S  S  S  S  T  T  T  T  T  T  T  T  T  T  T  U  U  U  V  V  V  W  W  W  W  W  W  X  X  X  X  X  X  X  X  X  Y  Y  Y  Y  Y  Y  Y  Y  Y  Y  Y  Y  Y  Z  Z  Z  [  [  [  \  \  \  \  \  \  ]  ]  ]  ]  ]  ]  ]  ]  ]  ^  ^  ^  ^  ^  ^  ^  ^  ^  ^  ^  ^  ^  _  _  _  `  `  `  a  a  a  a  a  a  b  b  b  b  b  b  b  b  b  c  c  c  c  c  c  c  c  c  c  d  d  d  e  e  e  f  f  f  f  f  f  g  g  g  g  g  h  i  i  i  i  i  k  k  k  k  k  k  m  m  m  o        self     �      frame    �      temp    �           q         F @ K@� \@ E�  F�� �  \@ E@ F�� �� � B\@ E@ F@� �� ��B\@ d       �� �   � �@� �       camera 
   endRecord    display 	   popScene    PreBattleScene    music    changeMusicState    UserSetting    musicOn    changeSoundState    soundOn    delayCallback        @       w  }          @@ E�  F�� �  �@A�� �� �� \ �@      B    ��    B @B � � @�   	�B� �       display    pushNotice    UI    createNotice    StringManager 
   getString    noticeDownloadOver      �o@
   showScene    removeFromParentAndCleanup         x  x  x  x  x  x  x  x  x  x  x  y  y  y  y  z  z  z  z  z  {  {  }            self    r  r  r  s  s  s  s  u  u  u  u  u  v  v  v  v  v  }  }  ~  ~  ~  ~          self        
   localtest               �  �       	@ �ŀ  ���܀ 	����@@ � �EA F���@��   @��A� �� B �@ ��� @ ɀ��B �@ @ �� C �@  �       scene    view    CCNode    create    setContentSize    General    winSize 	   download    addDownloadView    pause     addReplayMenu    addReplayView        �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �        self           scene        
   menuParam            4                                 (      *   G   *   I   l   I   n   �   n   �   �   �   �   �   �   �   �   �                 F    H  L  H  N  o  N  q    q  �  �  �  �          