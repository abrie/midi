#import <SenTestingKit/SenTestingKit.h>
#import "MIDI.h"

@interface MIDITests : SenTestCase <RealtimeProtocol, StatusProtocol>

@property (nonatomic, strong) MIDI* midi;
@property (atomic) BOOL midiClockReceived;
@property (atomic) BOOL midiStartReceived;
@property (atomic) BOOL midiStopReceived;
@property (atomic) BOOL midiContinueReceived;
@property (atomic) BOOL midiTickReceived;
@property (atomic, strong) NSDictionary *lastMidiMessage;
@property (atomic, strong) dispatch_queue_t sync;

@end
