//
//  PortSIPcorelib.h
//  PortSIPLib
//
//  Created by Joe Lepple on 3/15/13.
//  Copyright (c) 2013 Joe Lepple. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <UIKit/UIKit.h>

@interface HSKeepAwake : NSObject{
@public
    BOOL        isRegistered;
    
@private
	NSTimer		*keepAwakeTimer;
    AVAudioPlayer  *playerKeepAwake;
    NSMutableData* audioSilenceData;
};

@property BOOL        isRegistered;
@property NSMutableData* audioSilenceData;


- (BOOL) startKeepAwake;
- (BOOL) stopKeepAwake;

@end
