#import <SenTestingKit/SenTestingKit.h>
#import "MIDI.h"

@interface MIDITests : SenTestCase <RealtimeProtocol>

@property (nonatomic, strong) MIDI* midi;
@property (atomic, strong) NSDictionary *lastMidiMessage;
@end
