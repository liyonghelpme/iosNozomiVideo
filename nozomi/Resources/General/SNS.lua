LuaQ     @./Resources/General\SNS.lua           +   
         @  @  d   	@@  d@  	@ @  d  	@@  dΐ  	@ @  d  	@@   B  	Β	 Γ	Γ	 Δ	Δ	 ΕE   I E@  F Β \ IΕIΐΕI ΖI@ΖIΖIΐΖ   @         SNS 	   snsModel    class    initAccessToken    getAccessToken    getAuthUrl    requestOver    request    new    callbackUrl #   http://uhz000738.chinaw3.com:5000/    authUrl +   https://graph.facebook.com/oauth/authorize 
   client_id    304997242960340    client_secret !   8db39417e4862af619beca8f4414d8e4    scopes   user_about_me,user_activities,user_birthday,user_education_history,user_events,user_groups,user_hometown,user_interests,user_likes,user_location,user_notes,user_online_presence,user_photo_video_tags,user_photos,user_relationships,user_religion_politics,user_status,user_videos,user_website,user_work_history,read_friendlists,read_requests,publish_stream,create_event,rsvp_event,sms,offline_access,friends_about_me,friends_activities,friends_birthday,friends_education_history,friends_events,friends_groups,friends_hometown,friends_interests,friends_likes,friends_location,friends_notes,friends_online_presence,friends_photo_video_tags,friends_photos,friends_relationships,friends_religion_politics,friends_status,friends_videos,friends_website,friends_work_history,read_stream,photo_upload 	   tokenUrl .   https://graph.facebook.com/oauth/access_token 	   facebook *   https://api.weibo.com/oauth2/default.html '   https://api.weibo.com/oauth2/authorize 
   987947670 !   e09d2481fc636a7c12ae783d8d5ac806  *   https://api.weibo.com/oauth2/access_token    weibo                (   F @ Z@   d       @@  Ε  Α  ά@ Ε  Λ@Α@  ά@ E   Ζ @ ΐ \@ Eΐ F Β @B ΖB 
  	ΓJ @ IC IΑC IAD I	A@  \@        code    getAuthUrl    print    begin request auth 
   CCWebView    create    begin request token     network    httpRequest 	   tokenUrl    getAccessToken    isPost    params 
   client_id    client_secret    redirect_uri    callbackUrl               *   E   K@ΐ Α  Α  \@ E  @ ΐ   \@E FΐΑ    Δ   Ζ Β\ΐΐ @Ε ΖΐΑ   AA @άΐ   @ Z   ΐΔ    ΑB@  @Ι Δ   Λ Γά@ Α@ ή  Α  ή       	   CCNative    postNotification       π?   test    print 
   checkCode    string    find    callbackUrl    code=    code    sub    initAccessToken             *                  	   	   	   	   
   
   
   
   
   
                                                                                          url     )      pos1    )      pos2    )         self (                                                                                                                                 self     '   
   checkCode          authUrl                  )     	   Ε   A  @  ά@ Z   Ε  Ζΐΐ  ά Α	 AA   @AA 	ΑKΑA ΖBBB\A   
      print    SNS REQUEST OVER    json    decode    access_token    requestItem     request    url    params                               !   !   !   !   "   "   #   #   #   $   %   &   &   &   &   )         self           suc           result           data          item               +   1        F @ @  Ζ@ Α  FA U@ @A    ΐ   Α AA U ^          authUrl    ?client_id= 
   client_id    &redirect_uri=    callbackUrl    scopes    &scope=        ,   ,   ,   ,   ,   ,   -   -   -   .   .   .   .   0   1         self           url               3   8        Z    Ε   Ζ@ΐά@         display    closeDialog        4   4   6   6   6   8         self           suc           result                :   C     	   Ζ @ Ϊ   Ε@    ά @ Ι   Α@@ A Κ  ΙΑΙΑ   A@Κ  Ι@Ι	ΐ ΛB ά@         access_token 	   copyData    network    httpRequest    requestOver    isPost    params    requestItem    url    initAccessToken        ;   ;   ;   <   <   <   =   =   >   >   >   >   >   >   >   >   >   >   @   @   @   @   A   A   C         self           requestUrl           requestParam           params           +                              )      +   1   +   3   8   3   :   C   :   E   E   E   F   G   H   I   J   K   M   M   O   O   O   P   Q   R   S   T   U   X   X   X      	   facebook    *      weibo "   *       