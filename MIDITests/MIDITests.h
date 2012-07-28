#import <SenTestingKit/SenTestingKit.h>
#import "MIDI.h"

@interface MIDITests : SenTestCase <RealtimeProtocol, StatusProtocol>

@property (nonatomic, strong) MIDI* midi;
@property (atomic) BOOL midiClockReceived;
@property (atomic, strong) NSDictionary *lastMidiMessage;
@end
