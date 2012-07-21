#import "MIDITests.h"

@implementation MIDITests
@synthesize midi;

- (void)setUp
{
    [super setUp];
    
    [self setMidi: [[MIDI alloc] init] ];
}

- (void)tearDown
{
    // Tear-down code here.
    
    [super tearDown];
}

- (void)test_noteOn
{
    [midi noteOnChannel:0 number:64 velocity:64];
}

- (void)test_noteOff
{
     [midi noteOffChannel:0 number:64 velocity:64];
}

@end
