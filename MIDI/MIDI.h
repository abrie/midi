#import <Foundation/Foundation.h>
#import "CoreMidi/Midiservices.h"

@interface MIDI : NSObject {
@private
    MIDIClientRef client;
    MIDIPortRef input_port;
    MIDIPortRef output_port;
	MIDIEndpointRef out_endpoint;
}

@property (strong) NSArray *sources;
@property (strong) NSArray *destinations;

- (void) transmitToEndpoint:(MIDIEndpointRef)endpoint byte:(unsigned int)byte;
- (void) transmitToEndpoint:(MIDIEndpointRef)endpoint byte_1:(unsigned)byte_1 byte_2:(unsigned)byte_2 byte_3:(unsigned)byte_3;
- (NSArray *) discoverSources;
- (NSArray *) discoverDestinations;
- (void) reset;
- (void) noteOnChannel:(unsigned int)channel number:(unsigned int)number velocity:(unsigned int)velocity;
- (void) noteOffChannel:(unsigned int)channel number:(unsigned int)number velocity:(unsigned int)velocity;
- (void) connectDestination:(NSInteger)index;
- (void) connectSource:(NSInteger)index;
- (void) disconnectSource:(NSInteger)index;
- (void) midiClock;
- (void) midiStart;
- (void) midiStop;
- (void) midiContinue;
- (void) midiPacket:(const MIDIPacket *)packet;

@end
