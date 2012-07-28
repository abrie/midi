#import <SenTestingKit/SenTestingKit.h>
#import "MIDI.h"

@interface MIDITests : SenTestCase <RealtimeProtocol, VoiceProtocol>

@property (nonatomic, strong) MIDI* midi;
@property (atomic, strong) NSDictionary *lastMidiMessage;
@end
