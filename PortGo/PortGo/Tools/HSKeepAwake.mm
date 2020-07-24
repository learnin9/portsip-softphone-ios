//
//  PortSIPcorelib.m
//  PortSIPLib
//
//  Created by Joe Lepple on 3/15/13.
//  Copyright (c) 2013 Joe Lepple. All rights reserved.
//

#import "HSKeepAwake.h"
#if defined(__APPLE__) || defined(__MACH__)
#include <TargetConditionals.h>
#endif
static UIBackgroundTaskIdentifier sBackgroundTask = UIBackgroundTaskInvalid;
static dispatch_block_t sExpirationHandler = nil;
static const unsigned char wavHeader[] = {
    0x52,0x49,0x46,0x46,0x94,0x1B,0x00,0x00,0x57,0x41,0x56,0x45,0x66,0x6D,0x74,0x20,
    0x10,0x00,0x00,0x00,0x01,0x00,0x01,0x00,0x40,0x1F,0x00,0x00,0x80,0x3E,0x00,0x00,
    0x02,0x00,0x10,0x00,0x46,0x4C,0x4C,0x52,0xCC,0x0F,0x00,0x00,0x00,0x00,0x00,0x00};
static const unsigned char wavDataSilence[]={
    0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00};

static const unsigned char wavDataHeader[]={
    0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x64,0x61,0x74,0x61,0x9C,0x0B,0x00,0x00};
//00000000h: 52 49 46 46 94 1B 00 00 57 41 56 45 66 6D 74 20 ; RIFF?..WAVEfmt
//00000010h: 10 00 00 00 01 00 01 00 40 1F 00 00 80 3E 00 00 ; ........@...€>..
//00000020h: 02 00 10 00 46 4C 4C 52 CC 0F 00 00 00 00 00 00 ; ....FLLR?......
//00000ff0h: 00 00 00 00 00 00 00 00 64 61 74 61 9C 0B 00 00 ; ........data?..



//
//	private implementation
//
@interface HSKeepAwake(Private)
#if TARGET_OS_IPHONE
-(void)keepAwakeCallback;
-(BOOL) playKeepAwakeSoundLooping: (BOOL)looping;
-(BOOL) stopKeepAwakeSound;

- (void)StartLocalKeepAwake;
- (void)StopLocalKeepAwake;
#endif
@end

@implementation HSKeepAwake(Private)

#if TARGET_OS_IPHONE
-(void)keepAwakeCallback{
    [self playKeepAwakeSoundLooping:YES];
}
#endif

- (void) handleInterruption: (NSNotification *) notification
{
    NSNumber *interruptionOption = [[notification userInfo] objectForKey:AVAudioSessionInterruptionOptionKey];
    if ([notification.name isEqualToString:AVAudioSessionInterruptionNotification]) {
        if ([[notification.userInfo valueForKey:AVAudioSessionInterruptionTypeKey] isEqualToNumber:[NSNumber numberWithInt:AVAudioSessionInterruptionTypeBegan]]) {
            if(isRegistered)
            {
                [playerKeepAwake stop];
            }
            
            
        } else if([[notification.userInfo valueForKey:AVAudioSessionInterruptionTypeKey] isEqualToNumber:[NSNumber numberWithInt:AVAudioSessionInterruptionTypeEnded]]){
            //Resume your audio
            // Resume playing the audio.
            if (interruptionOption.unsignedIntegerValue == AVAudioSessionInterruptionOptionShouldResume) {
                // Here you should continue playback.
                if(isRegistered)
                {
                    [playerKeepAwake play];
                }
            }
        }
    }
}

-(BOOL) playKeepAwakeSoundLooping: (BOOL)looping
{
    if(!playerKeepAwake){
        //generated silence sounds
        audioSilenceData = [[NSMutableData alloc] initWithCapacity:8000];
        [audioSilenceData appendBytes:wavHeader length:sizeof(wavHeader)];
        for(int i = 3 ; i < 255 ; i++)
        {
            [audioSilenceData appendBytes:wavDataSilence length:sizeof(wavDataSilence)];
        }
        [audioSilenceData appendBytes:wavDataHeader length:sizeof(wavDataHeader)];
        for(int i = 0 ; i < 186 ; i++)
        {
            [audioSilenceData appendBytes:wavDataSilence length:sizeof(wavDataSilence)];
        }
        
        NSError *error;
        playerKeepAwake = [[AVAudioPlayer alloc] initWithData:audioSilenceData error:&error];
        if (playerKeepAwake == nil){
            return NO;
        }
    }
    if(playerKeepAwake){
        NSError *setError = nil;
        
        AVAudioSession *session = [AVAudioSession sharedInstance];
        
        [session setCategory:AVAudioSessionCategoryPlayback
                 withOptions:AVAudioSessionCategoryOptionMixWithOthers
                       error:&setError];
        
        playerKeepAwake.numberOfLoops = looping ? -1 : +1;
        [playerKeepAwake play];
        NSLog(@"playKeepAwakeSoundLooping");
        return YES;
    }
    return NO;
};

-(BOOL) stopKeepAwakeSound{
    if(playerKeepAwake && playerKeepAwake.playing){
        [playerKeepAwake stop];
    }
    return YES;
}

-(void) StartLocalKeepAwake
{
    if(!keepAwakeTimer){
        BOOL iOS4Plus = YES;
        // the iOS4 device will sleep after 10seconds of inactivity
        // On iOS4, playing the sound each 10seconds doesn't work as the system will imediately frozen
        // if you stop playing the sound. The only solution is to play it in loop. This is why
        // the 'repeats' parameter is equal to 'NO'.
        keepAwakeTimer = [[NSTimer alloc] initWithFireDate:[NSDate dateWithTimeIntervalSinceNow:0]
                                                  interval:6.f
                                                    target:self
                                                  selector:@selector(keepAwakeCallback)
                                                  userInfo:nil
                                                   repeats:iOS4Plus ? NO : YES];
        [[NSRunLoop currentRunLoop] addTimer:keepAwakeTimer forMode:NSRunLoopCommonModes];
        if(iOS4Plus){
            keepAwakeTimer = nil;
        }
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleInterruption:) name:AVAudioSessionInterruptionNotification object:nil];
    }
}

-(void) StopLocalKeepAwake
{
    if(keepAwakeTimer){
        [keepAwakeTimer invalidate];
        // already released
        keepAwakeTimer = nil;
    }
    
    [self stopKeepAwakeSound];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVAudioSessionInterruptionNotification object:nil];
}

@end

@implementation HSKeepAwake
@synthesize isRegistered;
@synthesize audioSilenceData;

-(id)init{
    if((self = [super init])){
        isRegistered = NO;
        
        audioSilenceData = nil;
        
        sBackgroundTask = UIBackgroundTaskInvalid;
        sExpirationHandler = ^{
            [[UIApplication sharedApplication] endBackgroundTask:sBackgroundTask];
            //NSLog(@"KeepAwake - endBackgroundTask");
            sBackgroundTask = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:sExpirationHandler];
            //sBackgroundTask = UIBackgroundTaskInvalid;
            //NSLog(@"KeepAwake - restart beginBackgroundTaskWithExpirationHandler");
        };
        
    }
    return self;
}

-(void)dealloc{
    
}


- (BOOL) startKeepAwake
{
    if(isRegistered)
        return YES;
    
    sBackgroundTask = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:sExpirationHandler];
    //NSLog(@"KeepAwake - beginBackgroundTaskWithExpirationHandler remaining [%g s]",[[UIApplication  sharedApplication] backgroundTimeRemaining]);
    
    [self StartLocalKeepAwake];
    isRegistered = YES;
    return YES;
}

-(BOOL) stopKeepAwake
{
    if(!isRegistered)
        return NO;
    
    if(sBackgroundTask != UIBackgroundTaskInvalid){
        [[UIApplication sharedApplication] endBackgroundTask:sBackgroundTask]; // Using shared instance will crash the application
        sBackgroundTask = UIBackgroundTaskInvalid;
        //NSLog(@"KeepAwake - endBackgroundTask");
    }
    
    [self StopLocalKeepAwake];
    isRegistered = NO;
    return YES;
}
@end

