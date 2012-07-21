#import "midi.h"

static void readProc(const MIDIPacketList *pktlist, void *readProcRefCon, void *srcConnRefCon);

@implementation MIDI

- (id)init
{
    self = [super init];
    if (self) {
        MIDIClientCreate(CFSTR("feelers synthesizer"),0,0,&client);
        MIDIOutputPortCreate(client, CFSTR("output"), &output_port);
        MIDIInputPortCreate(client, CFSTR("input"), readProc, (__bridge void *)(self), &input_port);
        [self setDestinations: [self discoverDestinations] ];
        [self setSources: [self discoverSources]];
    }
    
    return self;
}

- (NSString *)stringFromMIDIObjectRef:(MIDIObjectRef)object
{
   CFStringRef name = nil;
    if (noErr != MIDIObjectGetStringProperty(object, kMIDIPropertyDisplayName, &name))
        return nil;
    return (__bridge NSString *)name;
}

- (NSArray *)discoverSources
{
    NSMutableArray *result = [[NSMutableArray alloc] init];
    ItemCount sourceCount = MIDIGetNumberOfSources();
    
    for (ItemCount i = 0 ; i < sourceCount ; ++i)
    {
        MIDIEndpointRef source = MIDIGetSource(i);
        if ((void*)source != NULL)
        {
            [result addObject: [self stringFromMIDIObjectRef:source ]];
        }
    }
    
    return result;
}

- (NSArray *)discoverDestinations;
{
    NSMutableArray *result = [[NSMutableArray alloc] init];
    ItemCount destCount = MIDIGetNumberOfDestinations();
    
    for (ItemCount i = 0 ; i < destCount ; ++i)
    {
        MIDIEndpointRef dest = MIDIGetDestination(i);
        if ((void*)dest != NULL)
        {
            [result addObject: [self stringFromMIDIObjectRef:dest]];
        }
    }
    
    return result;
}
 
-(void) connectDestination:(NSInteger)index
{
    out_endpoint = MIDIGetDestination(index);
}

-(void) connectSource:(NSInteger)index
{
    MIDIPortConnectSource( input_port, MIDIGetSource(index), NULL );
}

-(void) disconnectSource:(NSInteger)index
{
    MIDIPortDisconnectSource( input_port, MIDIGetSource(index) );
}

- (void)transmitToEndpoint:(MIDIEndpointRef)endpoint byte:(unsigned int)byte
{
    Byte buffer[1024];
	MIDIPacketList *packet_list = (MIDIPacketList *)buffer;
	MIDIPacket *packet = MIDIPacketListInit(packet_list);
	Byte message[1];
	OSStatus result;
    
	message[0] = byte;
	
    packet = MIDIPacketListAdd( packet_list, sizeof(buffer), packet, 0, 1, message);
	result = MIDISend(output_port, endpoint, packet_list);
}

- (void)transmitToEndpoint:(MIDIEndpointRef)endpoint byte_1:(unsigned)byte_1 byte_2:(unsigned)byte_2 byte_3:(unsigned)byte_3
{
	Byte buffer[1024];
	MIDIPacketList *packet_list = (MIDIPacketList *)buffer;
	MIDIPacket *packet = MIDIPacketListInit(packet_list);
	Byte message[3];
	OSStatus result;
    
	message[0] = byte_1;
	message[1] = byte_2;
	message[2] = byte_3;
	
	packet = MIDIPacketListAdd( packet_list, sizeof(buffer), packet, 0, 3, message);
	result = MIDISend(output_port, endpoint, packet_list);
}

- (void)noteOnChannel:(unsigned int)channel number:(unsigned int)number velocity:(unsigned int)velocity
{
	[self transmitToEndpoint:out_endpoint
             byte_1:0x90 + channel
             byte_2:number
             byte_3:velocity];
}

- (void)noteOffChannel:(unsigned int)channel number:(unsigned int)number velocity:(unsigned int)velocity
{
	[self transmitToEndpoint:out_endpoint
             byte_1:0x80 + channel
             byte_2:number
             byte_3:velocity ];
}

- (void)reset
{
	[self transmitToEndpoint:out_endpoint
               byte:0xFF ];
}

- (void)midiStart
{
 }

- (void)midiStop
{
}

- (void)midiContinue
{
}

- (void)midiClock
{
}

- (void)midiPacket:(const MIDIPacket *)packet
{
    switch (packet->data[0]) {
        case 0xF8:
            [self midiClock];
            break;
        case 0xFA:
            [self midiStart];
            break;
        case 0xFC:
            [self midiStop];
            break;
        case 0xFB:
            [self midiContinue];
            break;
        default:
            break;
    }
}

static void readProc(const MIDIPacketList *packetList, void *readProcRefCon, void *srcConnRefCon)
{
   const MIDIPacket *packet = &packetList->packet[0];
        
    for (int i = 0; i < packetList->numPackets; ++i)
    {
        [(__bridge MIDI*)readProcRefCon midiPacket:packet];
        packet = MIDIPacketNext( packet );
    }
}

@end