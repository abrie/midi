#import <Foundation/Foundation.h>
#import "CoreMidi/Midiservices.h"

@interface MIDI : NSObject {
@private
    MIDIClientRef client;
    MIDIPortRef input_port;
	MIDIEndpointRef out_endpoint;
}

-(void) transmit:(MIDIEndpointRef)endpoint byte_1:(unsigned)byte_1 byte_2:(unsigned)byte_2 byte_3:(unsigned)byte_3;
-(void) all_notes_off:(unsigned)channel;
-(void) connectExistingDevices;
-(void) disconnectExistingDevices;
-(void) midiClock;
-(void) midiStart;
-(void) midiStop;
-(void) midiContinue;
-(void) midiPacket:(const MIDIPacket *)packet;

@end
