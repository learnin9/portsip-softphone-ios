#import "SoundService.h"
#import "AppDelegate.h"

#if TARGET_OS_IPHONE
#	import <AVFoundation/AVFoundation.h>
#elif TARGET_OS_MAC
#endif

#import "RBDMuteSwitch.h"

//
// private implementation
//
@interface SoundService()<AVAudioPlayerDelegate,RBDMuteSwitchDelegate>{
    NSTimer *_mUpdateTimer;
    NSTimer *_mVibrateTimer;
    float lastVolume;
}

#if TARGET_OS_IPHONE
+(AVAudioPlayer*) initPlayerWithPath:(NSString*)path;
#elif TARGET_OS_MAC
+(NSSound*) initSoundWithPath:(NSString*)path;
#endif
@end


//
// default implementation
//
@implementation SoundService

+(AVAudioPlayer*) initPlayerWithPath:(NSString*)path{
    NSURL *url = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/%@", [[NSBundle mainBundle] resourcePath], path]];
    
    NSError *error;
    AVAudioPlayer *player = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:&error];
    if (player == nil){
    }
    
    return player;
}


-(SoundService*)init{
    if((self = [super init])){
        playerRingTone = [SoundService initPlayerWithPath:@"ringtone.mp3"];
        playerRingTone.numberOfLoops = -1;
        playerRingTone.delegate = self;
        _playerState = YES;
    }
    return self;
}

-(void)dealloc{
    
    if(dtmfLastSoundId){
        AudioServicesDisposeSystemSoundID(dtmfLastSoundId);
        dtmfLastSoundId = 0;
    }
#define RELEASE_PLAYER(player) \
if(player){ \
if(player.playing){ \
[player stop]; \
} \
}
    RELEASE_PLAYER(playerRingBackTone);
    RELEASE_PLAYER(playerRingTone);
    
#undef RELEASE_PLAYER
}


//
// SoundService
//
-(BOOL) speakerEnabled:(BOOL)enabled{
    AVAudioSession* session = [AVAudioSession sharedInstance];
    AVAudioSessionCategoryOptions options = session.categoryOptions;
    if (enabled) {
        options |= AVAudioSessionCategoryOptionDefaultToSpeaker;
    } else {
        options &= ~AVAudioSessionCategoryOptionDefaultToSpeaker;
    }
    
    NSError* error = nil;
    [session setCategory:AVAudioSessionCategoryPlayAndRecord
             withOptions:options
                   error:&error];
    if (error != nil) {
        return NO;
    }
    return YES;
}

-(BOOL) isSpeakerEnabled{
    return speakerOn;
}

- (BOOL)hasHeadset
{
    AVAudioSessionRouteDescription* route = [[AVAudioSession sharedInstance] currentRoute];
    for (AVAudioSessionPortDescription* desc in [route outputs]) {
        if ([[desc portType] isEqualToString:AVAudioSessionPortHeadphones])
            return YES;
    }
    return NO;
}


-(BOOL) playRingTone{
    if (!databaseManage.mOptions.enableCallKit){
        if(playerRingTone){
            if (_playerState) {
                if ([self hasHeadset]) {
                    [self speakerEnabled:NO];
                }
                else{
                    [self speakerEnabled:YES];
                }
                
                [self beginDetection];
                
                lastVolume = [[AVAudioSession sharedInstance] outputVolume];
                [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(volumeChanged:) name:@"AVSystemController_SystemVolumeDidChangeNotification" object:nil];

                //[playerRingTone play];
                //_playerState = NO;
            }
        }
    }
    return NO;
}


-(BOOL) stopRingTone{
    if (!databaseManage.mOptions.enableCallKit){
        if(playerRingTone && playerRingTone.playing){
            [playerRingTone stop];
            _playerState = YES;
        }
        
        if(_mVibrateTimer){
            [_mVibrateTimer invalidate];
            _mVibrateTimer = nil;
        }
        
        [[NSNotificationCenter defaultCenter] removeObserver:self name:@"AVSystemController_SystemVolumeDidChangeNotification" object:nil];
    }
    return YES;
}

-(BOOL) playRingBackTone{
    if(!playerRingBackTone){
        playerRingBackTone = [SoundService initPlayerWithPath:@"ringbacktone.wav"];
    }
    if(playerRingBackTone){
        playerRingBackTone.numberOfLoops = -1;
        [self speakerEnabled:NO];
        [playerRingBackTone play];
        return YES;
    }
    return NO;
    
}

-(BOOL) stopRingBackTone{
    
    if(playerRingBackTone && playerRingBackTone.playing){
        [playerRingBackTone stop];
    }
    return YES;
}


//static void SoundFinished(SystemSoundID soundID,void* clientData){
//    AudioServicesDisposeSystemSoundID(soundID);
//    CFRunLoopStop(CFRunLoopGetCurrent());
//}

-(BOOL) playDtmf:(int)digit{
    

//    if (!_enableCallKit){
        NSString* code = nil;
    //    BOOL ok = NO;
        switch(digit){
            case 0: case 1: case 2: case 3: case 4: case 5: case 6: case 7: case 8: case 9: code = [NSString stringWithFormat:@"120%i", digit];
                
                break;
            case 10:
                code = @"1210";
                break;
                
            case 11:
                code = @"1211";
                
                break;
                
            default: code = @"0";
        }
    
    

    
    AudioServicesPlaySystemSoundWithCompletion(1200, ^{
            //播放完毕之后的动作
            NSLog(@"1007");
    
        });
    
    
        return  YES;
    
    
    
        
//        CFURLRef soundUrlRef = (__bridge CFURLRef) [[NSBundle mainBundle]
//                                                    URLForResource:[@"dtmf-" stringByAppendingString:code]
//                                                    withExtension:@"wav"];
//    
//        
//        if(soundUrlRef && AudioServicesCreateSystemSoundID(soundUrlRef, &dtmfLastSoundId) == 0){
//            
//            AudioServicesAddSystemSoundCompletion(dtmfLastSoundId, NULL, NULL, SoundFinished,(void*)soundUrlRef);
//            AudioServicesPlaySystemSound(dtmfLastSoundId);
//            ok = YES;
//        }
//        
//        CFRunLoopRun();
//        return ok;

    
    
}

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag{
    _playerState = YES;
}

- (void)audioPlayerEndInterruption:(AVAudioPlayer *)player withOptions:(NSUInteger)flags{
    _playerState = YES;
}


- (void)beginDetection {
    [[RBDMuteSwitch sharedInstance] setDelegate:self];
    [[RBDMuteSwitch sharedInstance] detectMuteSwitch];
}

- (void)volumeChanged:(NSNotification *)notification
{
    
    float volume = [notification.userInfo[@"AVSystemController_AudioVolumeNotificationParameter"] floatValue];
    if (volume - lastVolume == 0.0625 || lastVolume - volume == 0.0625) {
        [self stopRingTone];
    }
}


#pragma mark RBDMuteSwitchDelegate methods
- (void)isMuted:(BOOL)muted
{
    if (muted) {
        [soundServiceEngine stopRingTone];
        if (_mVibrateTimer == nil) {
            _mVibrateTimer = [NSTimer scheduledTimerWithTimeInterval:1.5 target:self selector:@selector(vibrate) userInfo:nil repeats:YES];
        }
    }
    else {
        [playerRingTone play];
        _playerState = NO;
        if(_mVibrateTimer){
            [_mVibrateTimer invalidate];
            _mVibrateTimer = nil;
        }
    }
}

- (void)vibrate
{
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
}


//[self switchBluetooth:YES];

- (AVAudioSessionPortDescription*)bluetoothAudioDevice
{
    NSArray* bluetoothRoutes = @[AVAudioSessionPortBluetoothA2DP, AVAudioSessionPortBluetoothLE, AVAudioSessionPortBluetoothHFP];
    return [self audioDeviceFromTypes:bluetoothRoutes];
}

- (AVAudioSessionPortDescription*)builtinAudioDevice
{
    NSArray* builtinRoutes = @[AVAudioSessionPortBuiltInMic];
    return [self audioDeviceFromTypes:builtinRoutes];
}

- (AVAudioSessionPortDescription*)speakerAudioDevice
{
    NSArray* builtinRoutes = @[AVAudioSessionPortBuiltInSpeaker];
    return [self audioDeviceFromTypes:builtinRoutes];
}

- (AVAudioSessionPortDescription*)audioDeviceFromTypes:(NSArray*)types
{
    
    NSArray* routes = [[AVAudioSession sharedInstance] availableInputs];
    
    for (AVAudioSessionPortDescription* route in routes)
    {
        if ([types containsObject:route.portType])
        {
            return route;
        }
    }
    return nil;
}

//- (BOOL) isBluetoothHeadsetConnected
//{
//    AVAudioSessionPortDescription* _bluetoothPort = [self bluetoothAudioDevice];
//    if(_bluetoothPort != nil)
//        return YES;
//    else
//        return NO;
//}


- (BOOL)isBlueToothConnected {
    AVAudioSession* session = [AVAudioSession sharedInstance];
    AVAudioSessionCategoryOptions options = session.categoryOptions;
    AVAudioSessionCategoryOptions optionsback = session.categoryOptions;
    options |= AVAudioSessionCategoryOptionAllowBluetooth;
    
    
    NSError* error = nil;
    [session setCategory:AVAudioSessionCategoryPlayAndRecord
             withOptions:options
                   error:&error];
    //    if (error != nil) {
    //        return NO;
    //    }
    //    return YES;
    
    
    BOOL hasBlueTooth = NO;
    NSArray *arrayInputs = [[AVAudioSession sharedInstance] availableInputs];
    for (AVAudioSessionPortDescription *port in arrayInputs)
    {
        if ([port.portType isEqualToString:AVAudioSessionPortBluetoothA2DP] || [port.portType isEqualToString: AVAudioSessionPortBluetoothHFP] || [port.portType isEqualToString:AVAudioSessionPortBluetoothLE])
        {
            hasBlueTooth = YES;
            break;
        }
    }
    
    [session setCategory:AVAudioSessionCategoryPlayAndRecord//
             withOptions:optionsback
                   error:&error];
    return hasBlueTooth;
}

-(BOOL) switchBluetooth:(BOOL)onOrOff{
    AVAudioSession* session = [AVAudioSession sharedInstance];
    NSString* category = session.category;
    AVAudioSessionCategoryOptions options = session.categoryOptions;
    //    1. allow sound to be routed to bluetooth devices
    if ([category isEqualToString:AVAudioSessionCategoryPlayAndRecord]) {
        if (onOrOff) {
            options |= AVAudioSessionCategoryOptionAllowBluetooth;
        } else {
            options &= ~AVAudioSessionCategoryOptionAllowBluetooth;
        }
        
        NSError* error = nil;
        [session setCategory:AVAudioSessionCategoryPlayAndRecord
                 withOptions:options
                       error:&error];
        if (error != nil) {
            return NO;
        }
    }
    
    //2. Switching to bluetooth
    NSError* audioError = nil;
    BOOL changeResult = NO;
    if (onOrOff == YES)
    {
        AVAudioSessionPortDescription* _bluetoothPort = [self bluetoothAudioDevice];
        changeResult = [[AVAudioSession sharedInstance] setPreferredInput:_bluetoothPort
                                                                    error:&audioError];
    }
    else
    {
        AVAudioSessionPortDescription* builtinPort = [self builtinAudioDevice];
        changeResult = [[AVAudioSession sharedInstance] setPreferredInput:builtinPort
                                                                    error:&audioError];
    }
    return changeResult;
}
@end
