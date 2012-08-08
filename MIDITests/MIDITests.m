#import "MIDITests.h"

@implementation MIDITests
@synthesize midi;
@synthesize lastMidiMessage;
@synthesize midiClockReceived;
@synthesize midiTickReceived;
@synthesize midiContinueReceived;
@synthesize midiStartReceived;
@synthesize midiStopReceived;

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
    [self setMidiTickReceived:NO];
    [self setMidiContinueReceived:NO];
    [self setMidiStartReceived:NO];
    [self setMidiStopReceived:NO];
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

- (void)midiTick
{
    [self setMidiTickReceived:YES];
}

- (void)midiStart
{
    [self setMidiStartReceived:YES];
}

- (void)midiStop
{
    [self setMidiStopReceived:YES];
}

- (void)midiContinue
{
    [self setMidiContinueReceived:YES];
}

- (void)test_Continue
{
    STAssertFalse( [self midiContinueReceived], @"Initial test condition");
    
    [self.midi sendContinue];
    
    while( ![self midiContinueReceived] )
    {
        // the tight loop strikes again.
    }
    
    STAssertTrue( [self midiContinueReceived], nil);
}

- (void)test_Start
{
    STAssertFalse( [self midiStartReceived], @"Initial test condition");
    
    [self.midi sendStart];
    
    while( ![self midiStartReceived] )
    {
        // the tight loop strikes again.
    }
    
    STAssertTrue( [self midiStartReceived], nil);
}

- (void)test_Stop
{
    STAssertFalse( [self midiStopReceived], @"Initial test condition");
    
    [self.midi sendStop];
    
    while( ![self midiStopReceived] )
    {
        // the tight loop strikes again.
    }
    
    STAssertTrue( [self midiStopReceived], nil);
}

- (void)test_Clock
{
    STAssertFalse( [self midiClockReceived], @"Initial test condition");
    
    [self.midi sendClock];
    
    while( ![self midiClockReceived] )
    {
        // the tight loop strikes again.
    }
    
    STAssertTrue( [self midiClockReceived], nil);
}

- (void)test_Tick
{
    STAssertFalse( [self midiTickReceived], @"Initial test condition");
    
    [self.midi sendTick];
    
    while( ![self midiTickReceived] )
    {
        // the tight loop strikes again.
    }
    
    STAssertTrue( [self midiTickReceived], nil);
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
