LuaQ     @./Resources/Mould\NPC.lua           &      A@  @ ΐ  E       d   	@  d@  	@   d  	@  dΐ  	@   d  	@  d@ 	@   d 	@  dΐ 	@   d  	@  d@ 	@         require    Mould.Person    NPC    class    Person    ctor    resetFreeState    resetMoveState    resetOtherState    getFrameEspecially    setPose    getInitPos    randomMove    runBackHome    updateState 
               4   Κ  A  A   UΑ  AΙ ΙΑΙ@Ι@B	 ΐΒ @ Ι C W@Γ @ Γ   ΙΐCD AA  AA  U DJΑ  IIΕI	@	Ε	ΐFFG FΑΑXΐΒΐ FG FΑΑΓ@ 	Η  	ΐΗ      
   moveSpeed 	   getParam 	   npcSpeed       N@      $@	   unitType       π?   sid    moveNum       (@   home        @      &@      @      @      .@   initWithInfo 	   npcScale       Y@	   viewInfo    scale    x            y       0@
   moveTimes 
   plistFile    animate/npc.plist    info    shadowScale       ΰ?α?    4                                                	   	   
   
   
   
                                                                                                      self     3      sid     3      home     3      sinfo    3      scale     3                       F @ IΐF @ I ΑF @ IΐF @ ΐ Ζ B Ζ@Β  I         displayState 	   duration       π?	   isRepeat     num    prefix    npc    info    sid    _p                                                         self                "   '        F @   Αΐ  A AAΥ  AIF @ I ΒF @  A BIF @   Ζ A Ζ@ΑA  I        displayState 	   duration 	   getParam    npcMovingTime    info    sid      @@	   isRepeat    num    moveNum    prefix    npc    _m        #   #   #   #   #   #   #   #   #   #   $   $   %   %   %   %   &   &   &   &   &   &   &   '         self                )   0        F @ F@ΐ ΐ @Fΐ@ @ Α Α  BI Fΐ@ IΒFΐ@ I ΓFΐ@  ΖΐC Ζ ΔA  I     
   stateInfo    action    pose    displayState 	   duration 	   getParam    soldierPoseTime      ΐ@     @@	   isRepeat     num       @   prefix    npc    info    sid    _p        *   *   *   *   +   +   +   +   +   +   +   ,   ,   -   -   .   .   .   .   .   .   .   0         self                2   D          @ Ε@  Ζΐΐ ΐ ΐ@  AW@A@     @  ΐΑ @ A   @Β @ MΑ  Β @ Aΐ   Γ @ MΐΑ   A@ ^          state    PersonState    STATE_OTHER 
   stateInfo    action    pose       @      (@      @      2@      8@      &@      ;@                3   3   3   3   3   3   3   3   3   4   4   6   6   7   7   8   8   9   9   :   :   ;   ;   <   <   =   =   >   >   @   C   D         self           i                F   N         F @ @  @ @E@  Fΐΐ 	@ E@ FΑ  A @    ΐ  B\ N@Β MΒ 	@ J  I@Cΐ Α  A DI 	@	 ΕK@E \@         state    PersonState    STATE_FREE    STATE_OTHER 
   direction    math    ceil       π?      @      @      @
   stateInfo    action    pose    actionTime 	   getParam    npcPoseTime      p§@     @@
   stateTime            resetPersonView         G   G   G   G   G   H   H   H   I   I   I   I   I   I   I   I   I   I   I   J   J   J   J   J   J   J   J   J   K   L   L   N         self                P   a     	%      @@Ζ@ ΖΐΐΤ  Ε  @ Α@ά ΐ  @ @ @ α  @ώZ@    F@A 	@ ΛΐA ά@ Ζ Β Ζ@ΒΛΒάΐ KΑΒ \  ΖΓΜΑBΓ’A          math    random    scene    builds    pairs    home    target    setPose 
   buildView    view    getPosition    getDoorPosition       π?       @    %   R   R   R   R   R   R   S   S   S   S   S   T   T   U   V   S   W   Y   Y   Z   \   ]   ]   ^   ^   ^   ^   _   _   `   `   `   `   `   `   `   a         self     $      targetBuild     $      ri    $      (for generator) 
         (for state) 
         (for control) 
         i          build          x    $      y    $      off    $           c        F   A   @@ @  Aΐ    Ε  Ζ@Αά @@Ε  Ζ@ΑA ΑA ά  FA FΑΑΐ ΐ@    !  @ώ@ @B 	ΐBΖ C Wΐ     Ζ@CΪ@  ΐ ΖCΖΐΓ Δ Λ@D ά@ 	 ΖDΖΐΔΖ ΕA AEEΑΕΖΖ KAF\ F Β@FΒΐBFΒFΒΖLA A@ Α@	     ffffffζ?
   moveTimes               π?   math    random    scene    builds    pairs    home    isOver    target    deleted 
   buildData    bid      |§@   setPose 
   buildView    state 	   backGrid    mapGrid    convertToPosition 	   gridPosX 	   gridPosY    getDoorPosition    setMoveTarget        @    F   d   e   e   e   f   h   i   i   i   i   i   j   j   j   j   j   j   k   k   k   k   k   l   l   m   n   k   o   p   r   s   u   u   u   u   u   u   u   u   u   u   u   u   v   v   v   x   y   y   y   z   z   z   z   z   z   {   {   |   |   |   |   |   |   |   |   }   }   }            self     E      randPercent    E      targetBuild    E      ri          (for generator)          (for state)          (for control)          i          build          grid 2   E      p 8   E      off :   E                      F @ F@ΐ Fΐ Kΐΐ \ΐ Ζ @ Λ Αά AA A ΑAA	ΐBC AΒ ΖAΓΜΑA         home 
   buildView    view    getPosition    getDoorPosition    setMoveScale    info 
   moveSpeed       8@      π?   isOver    setMoveTarget        @                                                                               self           x          y          off                        8    @ @@   @@ @   	ΐ@ A @ @A Ε ΖΐΑΐ  B     @B B @	ΐΐ C @CC ΑC@    ΐ D @  @A Ε Ζ@Δΐ ΐD ΖΐD Ζ ΕΐD @EE 	ΐE F @ @F @             scene    battleBegin    running    runBackHome    state    PersonState    STATE_FREE    isOver    view    removeFromParentAndCleanup    deleted    home    npcReturnHome    info    sid    setPose    STATE_OTHER 
   stateTime 
   stateInfo    actionTime    action    pose            randomMove    resetPersonView     8                                                                                                                                                                                  self     7      diff     7       &                                           "   '   "   )   0   )   2   D   2   F   N   F   P   a   P   c      c                                  