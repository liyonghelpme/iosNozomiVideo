LuaQ  )   @./Resources/Mould\Build\WizardTower.lua              @  E�  �       d   	@��   d@  	@ �   d�  	@��   d�  	@ � �       WizardTower    class    Defense    getBuildView    changeNightMode    attack    getBuildShadow                j   F @ F@� � @ ��@��  � �܀ �@�A� ܀��@   ��  A� �A� �� B �A�� �B� ��  ��A � E� F���� \� �DB� �A  �AD�� ��D��D� �A� �J�  �� �FI��I����A�ˁF@��A��������   A� ���ł ��� @ � �܂  CE@���  �� ���������C��F��C����Ł ���B E� F���H\� N�M��� �܁  BE@���  �� ���������B��F���� B   � !   
   buildData    bid    level    CCSpriteFrameCache    sharedSpriteFrameCache    spriteFrameByName    wizardTower1.png    addSpriteFramesWithFile    images/build/build    .plist    CCSpriteBatchNode    create    .png       4@   UI    createSpriteWithFrame    setContentSize    getContentSize    width        @   screen    autoSuitable    nodeAnchor    General    anchorBottom    x 	   addChild       �?   wizardTower    wizardTowerTop    math    ceil       @    j                                       	   	   	   	   	   	   	   	   	                                                                                                                                                                                                                                                                        self     i      bid    i      level    i      frame 
   i      build    i      temp !   i      w )   i      (for index) :   O      (for limit) :   O      (for step) :   O      i ;   N      temp B   N      temp [   i              6     ^   � @ �@@� @ ƀ��@ AA    � � Z   ��EA F�����\� N��M��A ��B��  �A �A��� �ACA �A�Ł ���  J�  �B ��DI���E�� �BE�BI���I�E��A��F@ �B ł �A��A Ɓ�� @�� �܁ ��Ł ���  J�  �B ��DI���E�� �BE�BI���I�E��A��F@ �B ł ���A�@�KAGŁ \��Z  � ����� �A��AG� G���@ Z  � ����� �A� �    
   buildData    bid    level 
   buildView    build    math    ceil       @       @   UI    createSpriteWithFrame    wizardTowerLight    .png 	   setScale    screen    autoSuitable    nodeAnchor    General    anchorBottom    x    getContentSize    width    y         	   addChild       $@
   TAG_LIGHT    wizardTowerTlight       �?   getChildByTag    removeFromParentAndCleanup     ^                 !   !   "   "   "   #   #   $   $   $   $   $   $   %   %   %   %   %   %   %   &   &   &   '   '   '   '   '   '   '   '   '   '   '   '   '   '   (   (   (   (   (   )   )   )   )   )   )   )   )   *   *   *   *   *   *   *   *   *   *   *   *   *   *   +   +   +   +   +   +   +   -   -   -   .   .   /   /   /   1   1   1   1   1   2   2   3   3   3   6         self     ]      isNight     ]      bid    ]      level    ]      build    ]      llevel    J      light    J      light N   ]           8   H     S   � @ �   A@�@ �@  ��A� ���AA� ��ABF�A� � FA� K��\� �A� Ɓ��� ��� ��BC �CF�C F�BAB ����� �@ ��C ��D�� ���  ED F����E ��A	\ ܁   �@��� ��BC �CF�C F�BAB ����� �F� FC�LC��C ��D�� �� ED F����E ��A	\ ܁   �ˁFF�A�A���C ��	��� �    
   buildView    view    getPosition       �?       @      p@      @   scene    SIZEY    info 	   unitType    MagicSplash    new 
   buildData    extendValue1    defenseData    attackSpeed      �f@   damageRange    GroupTypes    Defense    math    ceil    buildLevel 	   viewInfo    y    addToScene 	   coldTime     S   9   :   :   :   :   :   ;   ;   ;   <   <   <   =   =   =   =   =   ?   @   @   @   A   A   A   A   B   B   B   B   B   B   B   B   B   B   B   B   B   B   B   B   B   B   B   B   B   B   B   B   B   D   D   D   D   D   D   D   D   D   D   D   D   D   D   D   D   D   D   D   D   D   D   D   D   D   D   F   F   F   G   G   G   H         self     R      target     R      build    R      p    R      shot    R      tx    R      ty    R           J   L     	   K @ �@  �  A�  � �A ] �^    �    
   getShadow    images/shadowCircle.png       P�      L@     �[@     @S@    	   K   K   K   K   K   K   K   K   L         self                                       6      8   H   8   J   L   J   L           