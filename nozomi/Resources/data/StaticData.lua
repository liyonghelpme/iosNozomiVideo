LuaQ  !   @./Resources/data\StaticData.lua           Y   
      
   J      ä       Ç@  Å  Á  Ü@ Ã Ç@  ä@     Ç@  Å   Ü@ Ã Ç@  ä     Ç@  Å  A Ü@ Ã Ç@  Å   $Á      É Å   $    É Å   $A    É Å   $ É Ê   
  dÁ   GA  E   \A CGA  d      GA  E  Á \A CGA  E  ¤A   IE  ¤    IE  ¤Á IJ  ¤   A    ÁÁ A  A    äA   Á#           StaticData    Entry    require    data.buildInfos    data.buildDatas    data.buildDefences    getBuildInfo    getBuildData    getDefenseData    getMaxLevelData    data.soldierInfos    data.soldierDatas    getSoldierInfo    getSoldierData    getMaxSoldierData    data.researchInfos    getResearchInfo              "   J I IAI IÁA AÁÁ    Õ I À  ÁÅA ÆÁ  Ü W  IÁ
  A Â Á `B F	B_ÿID  IB         bid    btype 	   levelMax 	   totalMax    name    StringManager 
   getString    dataBuildName    dataBuildInfo    info       ð?      "@   levelLimits     "   	   	   	   	   	   
   
   
   
   
   
   
                                                                           bid     !      btype     !   	   levelMax     !   	   totalMax     !      arg     !      info    !      ikey    !      binfo    !      levelLimits    !      (for index)          (for limit)          (for step)          i             build_info_cache        #       Ä  ÆÚB  À 
  À   	Ã 
Ã 	 	C	 	Ã		C		Ã		C	É         bid    level    time 	   costType 
   costValue 
   needLevel 
   hitPoints    extendValue1    extendValue2 	   gridSize    soldierSpace                                !   !   !   !   !   !   !   !   !   !   !   !   "   #         bid           level           time        	   costType        
   costValue        
   needLevel        
   hitPoints           extendValue1           extendValue2        	   gridSize           soldierSpace        
   dataArray          data             build_data_cache     '   )         J I À I@IBÁI@IIBIIÂ	B   
      bid    range       $@   extendRange    attackSpeed      @@   damageRange    attackUnitType 	   favorite    favoriteRate        (   (   (   (   (   (   (   (   (   (   (   (   (   (   (   )         bid           range           extendRange           attackSpeed           damageRange           attackUnitType        	   favorite           favoriteRate              build_defense_cache     -   /       D   F  ^               .   .   .   /         bid              build_info_cache     1   3            @                2   2   2   2   3         bid           level              build_data_cache     5   7       D   F  ^               6   6   6   7         bid              build_defense_cache     9   =        E   F@À    \    @À   ÁÀ           StaticData    getBuildInfo    getBuildData 	   levelMax        :   :   :   :   ;   ;   ;   ;   ;   <   =         bid     
      binfo    
      bdata 	   
           C   F       Ä  
Ã 	 	C	 	Ã	OÁ	COB	COÂ	C		C	É Ä  Æ ÃCA   U É        sid    space    time    attackType 
   moveSpeed    attackSpeed      @@   range       $@   damageRange 	   favorite    favoriteRate 	   unitType    name    StringManager 
   getString    dataSoldierName        D   D   D   D   D   D   D   D   D   D   D   D   D   D   D   D   D   E   E   E   E   E   E   E   E   E   F         sid           space           time           attackType        
   moveSpeed           attackSpeed           range           damageRange        	   favorite           favoriteRate        	   unitType              soldier_info_cache     J   T       D  F ÀÀ   @   A A A Á I   AA    Á @    A          sid    level    dps 
   hitpoints    cost 	   levelMax                K   K   L   L   M   M   N   N   P   P   P   P   P   P   P   Q   Q   Q   Q   Q   Q   Q   Q   R   R   R   T         sid           level           dps        
   hitpoints           cost        
   dataArray             soldier_data_cache    soldier_info_cache     X   Z       D   F  ^               Y   Y   Y   Z         sid              soldier_info_cache     \   ^            @                ]   ]   ]   ]   ^         sid           level              soldier_data_cache     `   d        E   F@À    \    @À   ÁÀ           StaticData    getSoldierInfo    getSoldierData 	   levelMax        a   a   a   a   b   b   b   b   b   c   d         sid     
      sinfo    
      sdata 	   
           g   o       JA I IAI IÁI   A  À Ê  Ä  É A         id    level    cost    time    requireLevel        h   h   h   h   h   h   i   i   j   j   k   k   l   l   n   o         rid           level           cost           time           requireLevel           item       
   dataArray             research_info_cache     s   u            @                t   t   t   t   u         lid           level              research_info_cache Y                                          #   #   #   $   $   $   %   %   )   )   )   *   *   *   +   +   -   /   /   -   1   3   3   1   5   7   7   5   9   =   9   @   A   F   F   F   G   G   G   H   H   T   T   T   T   U   U   U   V   V   X   Z   Z   X   \   ^   ^   \   `   d   `   f   o   o   o   p   p   p   q   q   s   u   u   s   u   v         build_info_cache    W      build_data_cache    W      build_defense_cache    W      soldier_info_cache -   W      soldier_data_cache .   W      research_info_cache K   W       