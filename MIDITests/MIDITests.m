#import "MIDITests.h"

@implementation MIDITests
@synthesize midi;
@synthesize lastMidiMessage;
@synthesize midiClockReceived;

- (void)setUp
{
    [super setUp];
    [self setMidi:[[MIDI alloc] initWithName:@"midi_unit_tests"]];
    [self.midi setRealtimeDelegate:self];
    [self.midi setVoiceDelegate:self];
    [self.midi connectDestinationByIndex:0];
    [self.midi connectSourceByIndex:0];
    [self setLastMidiMessage:nil];
    [self setMidiClockReceived:NO];
}

- (void)tearDown
{
    [self.midi disconnectDestinationByIndex:0];
    [super tearDown];
}

- (void)midiClock
{
    [self setMidiClockReceived:YES];
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

- (void)test_Clock
{
    [self.midi sendClock];
    
    while( ![self midiClockReceived] )
    {
        // the tight loop strikes again.
    }
    
    STAssertTrue( [self midiClockReceived], nil);
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

- (void)midiStatus:(Byte)status data1:(Byte)data1 data2:(Byte)data2
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
