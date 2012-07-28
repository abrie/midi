#import <Foundation/Foundation.h>
#import "CoreMidi/Midiservices.h"

@protocol RealtimeProtocol <NSObject>

- (void)midiStart;
- (void)midiStop;
- (void)midiContinue;
- (void)midiClock;

@end

@protocol VoiceProtocol <NSObject>

- (void)midiStatus:(Byte)status data1:(Byte)data1 data2:(Byte)data2;

@end

@interface MIDI : NSObject {
@private
    MIDIClientRef client;
    MIDIPortRef input_port;
    MIDIPortRef output_port;
	MIDIEndpointRef out_endpoint;
}
@property (readonly) NSString *clientName;
@property (strong) NSArray *sources;
@property (strong) NSArray *destinations;
@property (strong) id<RealtimeProtocol> realtimeDelegate;
@property (strong) id<VoiceProtocol> voiceDelegate;

- (id)initWithName:(NSString *)clientName;

- (void) connectSourceByName:(NSString *)name;
- (void) connectSourceByIndex:(NSInteger)index;


- (void) connectDestinationByName:(NSString *)name;
- (void) connectDestinationByIndex:(NSInteger)index;
- (void) disconnectDestinationByIndex:(NSInteger)index;

- (void) sendOnToChannel:(unsigned int)channel
                  number:(unsigned int)number
                velocity:(unsigned int)velocity;

- (void) sendOffToChannel:(unsigned int)channel
                   number:(unsigned int)number
                 velocity:(unsigned int)velocity;

@end
