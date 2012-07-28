#import "MIDITests.h"

@implementation MIDITests
@synthesize midi;
@synthesize lastMidiMessage;

- (void)setUp
{
    [super setUp];
    [self setMidi:[[MIDI alloc] initWithName:@"midi_unit_tests"]];
    [self.midi setRealtimeDelegate:self];
    [self.midi connectDestinationByIndex:0];
    [self.midi connectSourceByIndex:0];
    [self setLastMidiMessage:nil];
}

- (void)tearDown
{
    [self.midi disconnectDestinationByIndex:0];
    [super tearDown];
}

- (void)midiClock
{
}

- (void)midiContinue
{
}

- (void)midiStart
{
}

- (void)midiStop
{
}

- (void)waitForMessage
{
    while( [self lastMidiMessage] == nil )
    {
        //a tight loop waiting for data...erg, bleh lol?
    }
}

- (void)test_sendOnToChannel
{
    [self.midi sendOnToChannel:1 number:64 velocity:63];
    NSDictionary *expected =
    @{
        @"status" : @(0x91),
        @"data1" : @(64),
        @"data2" : @(63)
    };
    
    [self waitForMessage];
    
    STAssertTrue( [expected isEqualToDictionary:[self lastMidiMessage]], nil);
}

- (void)test_sendOffToChannel
{
    [self.midi sendOffToChannel:1 number:64 velocity:63];
    NSDictionary *expected =
    @{
    @"status" : @(0x81),
    @"data1" : @(64),
    @"data2" : @(63)
    };
    
    [self waitForMessage];
    
    STAssertTrue( [expected isEqualToDictionary:[self lastMidiMessage]], nil);
}

- (void)midiUnhandledStatus:(Byte)status data1:(Byte)data1 data2:(Byte)data2 tag:(NSString *)tag
{
    NSDictionary *result =
    @{
        @"status" : @(status),
        @"data1" : @(data1),
        @"data2" : @(data2)
    };
    
    [self setLastMidiMessage:result];
}

@end
