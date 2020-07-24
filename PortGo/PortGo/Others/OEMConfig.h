//
//  OEMConfig.h
//  PortGo
//
//  Created by Joe Lepple on 18/5/15.
//  Copyright (c) 2015 PortSIP Solutions, Inc. All rights reserved.
//

#ifndef PortGo_OEMConfig_h
#define PortGo_OEMConfig_h
#include "constatnts.h"

#define USER_AGENT @"PortGo for iOS"
#define LICENSE_KEY @"9Dx5ENTI2MUEzRkU4N0E0MEFGMUI3RTUxNEY1REZENTdGQUBBMkU0OTZFRkFGNEIwRjI4N0ZGMEJGMjI3NTc1RjM3Q0AyQzFCRjEzMTcyRjk5MjUzRjMyMDVBNUVDNjQxM0E2QkBFRjQ1RUQ0N0NGMzU2RDBBRjc5ODg3RDcxQTYzMjBCQw"


#ifdef MBUZZZPLUS
#define kFIXEDRealm	@"sip.mbuzzz.co.uk"

#elif defined MOJO
#define kFIXEDRealm	@""

#elif defined IPTALKER
#define kFIXEDRealm	@"sip.iptalker.com"
#define kSINGUPACCOUNT @"http://www.iptalker.com/register"
#define ENABLE_AUTO_PROVISIONING 1

#elif defined TALK_1
#define kFIXEDRealm	@"sip.1-talk.com"
#define kSINGUPACCOUNT @"https://1-talk.com/registration.html"

#elif defined PEROLAPA
#define kFIXEDRealm	@"perolapa.selfip.com"
//#define kFIXEDRealm	@"66.231.242.52"

#undef USER_AGENT
#define USER_AGENT @"PeroLaPa"

#undef LICENSE_KEY
#define LICENSE_KEY @"9yR04QTg0NUVFOTM1NkY0MTNDNDEwNDg1RDY5NUUzOTFBNEA0OUJDNjhFOUNDNjE5Mjg1ODhFMkFFNEY0MjVBREE2MUA0MjQ5NjNBQzBBRDBFQUI1RTQxQjU4NDlEQjY5RjdDQkA2NjI0N0M3QUNFQkU4MkQ0M0Q2MDFERUQ4RjI0NzE1Ng"

//Enable All Video Codec
#undef DEFALUT_OPTIONS_MEDIA_CODEC_USE_H263
#define DEFALUT_OPTIONS_MEDIA_CODEC_USE_H263 1

#undef DEFALUT_OPTIONS_MEDIA_CODEC_USE_H263_1998
#define DEFALUT_OPTIONS_MEDIA_CODEC_USE_H263_1998 1

#undef DEFALUT_OPTIONS_MEDIA_CODEC_USE_H264
#define DEFALUT_OPTIONS_MEDIA_CODEC_USE_H264 1

#undef DEFALUT_OPTIONS_MEDIA_CODEC_USE_VP8
#define DEFALUT_OPTIONS_MEDIA_CODEC_USE_VP8 0


#elif defined CELLVOZ
#define kFIXEDRealm	@"sip03.cellvoz.com"

#endif

#define kFIXEDPort	@"5060"


#ifdef ZADARMA
#undef USER_AGENT
#define USER_AGENT @"Zadarma IOS App"

#undef LICENSE_KEY
#define LICENSE_KEY @"9Dx5ENTI2MUEzRkU4N0E0MEFGMUI3RTUxNEY1REZENTdGQUBBMkU0OTZFRkFGNEIwRjI4N0ZGMEJGMjI3NTc1RjM3Q0AyQzFCRjEzMTcyRjk5MjUzRjMyMDVBNUVDNjQxM0E2QkBFRjQ1RUQ0N0NGMzU2RDBBRjc5ODg3RDcxQTYzMjBCQw"
#endif

#endif
