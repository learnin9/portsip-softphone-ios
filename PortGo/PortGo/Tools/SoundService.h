
#import <Foundation/Foundation.h>
#include <AudioToolbox/AudioToolbox.h>

#import <AVFoundation/AVAudioPlayer.h>
#import <AVFoundation/AVAudioSession.h>


@interface SoundService : NSObject{
@private
	SystemSoundID dtmfLastSoundId;
	AVAudioPlayer  *playerRingBackTone;
	AVAudioPlayer  *playerRingTone;
	
	BOOL speakerOn;
}
@property (nonatomic, assign) BOOL playerState;

-(BOOL) speakerEnabled:(BOOL)enabled;
-(BOOL) isSpeakerEnabled;
-(BOOL) hasHeadset;
-(BOOL) playRingTone;
-(BOOL) stopRingTone;
-(BOOL) playRingBackTone;
-(BOOL) stopRingBackTone;
-(BOOL) playDtmf:(int)digit;
//-(BOOL) isBlueToothConnected;
//-(BOOL) isBluetoothHeadsetConnected;
-(BOOL) isBlueToothConnected;
-(BOOL) switchBluetooth:(BOOL)onOrOff;
-(AVAudioSessionPortDescription*) bluetoothAudioDevice;
-(AVAudioSessionPortDescription*) builtinAudioDevice;
-(AVAudioSessionPortDescription*) speakerAudioDevice;
-(AVAudioSessionPortDescription*) audioDeviceFromTypes:(NSArray*)types;
@end
