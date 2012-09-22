#import "midi.h"

static void midiRead(const MIDIPacketList *pktlist, void *readProcRefCon, void *srcConnRefCon);

@implementation MIDI
@synthesize clientName;

- (id)initWithName:(NSString *)name
{
    self = [super init];
    
    if (self)
    {
        [self instantiateClientNamed:name];
        [self initializeInternalClock];
    }
    
    return self;
}

- (void)instantiateClientNamed:(NSString *)name
{
    MIDIClientCreate((__bridge CFStringRef)name,
                     0,
                     0,
                     &client);
    
    MIDIOutputPortCreate(client,
                         CFSTR("output"),
                         &outputPort);
    
    MIDIInputPortCreate(client,
                        CFSTR("input"),
                        midiRead,
                        (__bridge void *)(self),
                        &input_port);
    
    self.destinations = [self discoverDestinations];
    self.sources = [self discoverSources];
    clientName = [NSString stringWithString:name];
}

- (void)initializeInternalClock
{
    internalClock = [[Clock alloc] initWithStartBlock:^(){ [self sendStart]; }
                                                clock:^(){ [self sendClock]; }
                                                 stop:^(){ [self sendStop]; }];
}

- (void)stopInternalClock
{
    [internalClock stop];
}

- (void)runInternalClock:(NSTimeInterval)timeInterval
{
    [internalClock startAtInterval:timeInterval];
}

- (void)adjustInternalClock:(NSTimeInterval)timeInterval
{
    [internalClock adjustToInterval:timeInterval];
}

- (NSString *)stringFromMIDIObjectRef:(MIDIObjectRef)object
{
    CFStringRef name = nil;
    
    if( noErr != MIDIObjectGetStringProperty(object,
                                             kMIDIPropertyDisplayName,
                                             &name) )
    {
        return nil;
    }
    else
    {
        return (__bridge NSString *)name;
    }
}

- (NSArray *)discoverSources
{
    NSMutableArray *result = [[NSMutableArray alloc] init];
    ItemCount sourceCount = MIDIGetNumberOfSources();
    
    for( ItemCount i = 0 ; i < sourceCount ; ++i )
    {
        MIDIEndpointRef source = MIDIGetSource(i);
        
        if( (void*)source != NULL )
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

-(void) connectDestinationByName:(NSString *)name
{
    NSArray *destinations = [self discoverDestinations];
    [destinations enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if( (*stop = [name isEqualToString:obj]) )
        {
            [self connectDestinationByIndex:idx];
        }
    }];
}

-(void) connectDestinationByIndex:(NSInteger)index
{
    out_endpoint = MIDIGetDestination(index);
}

-(void) disconnectDestinationByIndex:(NSInteger)index
{
    MIDIPortDisconnectSource(input_port, MIDIGetSource(index) );
}

-(void) connectSourceByName:(NSString *)name
{
    NSArray *sources = [self discoverSources];
    
    [sources enumerateObjectsUsingBlock: ^(id obj, NSUInteger idx, BOOL *stop) {
        if( (*stop = [name isEqualToString:obj]) )
        {
            [self connectSourceByIndex:idx];
        }
    }];
}

-(void) connectSourceByIndex:(NSInteger)index
{
    MIDIPortConnectSource( input_port, MIDIGetSource(index), NULL );
}

-(void) disconnectSource:(NSInteger)index
{
    MIDIPortDisconnectSource( input_port, MIDIGetSource(index) );
}

- (void)transmitToEndpoint:(MIDIEndpointRef)endpoint
                   message:(Byte[])message
                    length:(unsigned int)length
{
    Byte buffer[1024];
	MIDIPacketList *packet_list = (MIDIPacketList *)buffer;
	MIDIPacket *packet = MIDIPacketListInit(packet_list);
	
	OSStatus result;
    
	packet = MIDIPacketListAdd(
                               packet_list,
                               sizeof(buffer),
                               packet,
                               0,
                               length,
                               message);
	
    result = MIDISend(outputPort, endpoint, packet_list);
}

- (void)transmitToEndpoint:(MIDIEndpointRef)endpoint
                      status:(Byte)status
{
    Byte message[1] = {status};
    [self transmitToEndpoint:endpoint message:message length:1];
}

- (void)transmitToEndpoint:(MIDIEndpointRef)endpoint
                    status:(Byte)status
                    data1:(Byte)data1
                    data2:(Byte)data2
{
	Byte message[3] = {status, data1, data2};
	[self transmitToEndpoint:endpoint message:message length:3];
}

- (void)sendSongPosition:(unsigned int)position
{
    Byte data1 = position & 0xFF;
    Byte data2 = position >> 8;
    [self transmitToEndpoint:out_endpoint status:0xF2 data1:data1 data2:data2];
}

- (void)sendClock
{
    [self transmitToEndpoint:out_endpoint status:0xF8];
}

- (void)sendTick
{
    [self transmitToEndpoint:out_endpoint status:0xF9];
}

- (void)sendStart
{
    [self transmitToEndpoint:out_endpoint status:0xFA];
}

- (void)sendContinue
{
    [self transmitToEndpoint:out_endpoint status:0xFB];
}

- (void)sendStop
{
    [self transmitToEndpoint:out_endpoint status:0xFC];
}

- (void)sendOnToChannel:(unsigned int)channel
                 number:(unsigned int)number
               velocity:(unsigned int)velocity
{
	[self transmitToEndpoint:out_endpoint
                      status:0x90 + channel
                      data1:number
                      data2:velocity];
}

- (void)sendOffToChannel:(unsigned int)channel
                  number:(unsigned int)number
                velocity:(unsigned int)velocity
{
	[self transmitToEndpoint:out_endpoint
                      status:0x80 + channel
                      data1:number
                      data2:velocity ];
}

- (void)notify_midiClock
{
    [_realtimeDelegate midiClock];
}

- (void)notify_midiTick
{
    [_realtimeDelegate midiTick];
}

- (void)notify_midiStart
{
    [_realtimeDelegate midiStart];
}

- (void)notify_midiStop
{
    [_realtimeDelegate midiStop];
}

- (void)notify_midiContinue
{
    [_realtimeDelegate midiContinue];
}

- (void)notify_SongPosition:(Byte)data1 data2:(Byte)data2
{
    unsigned int lo = data1;
    unsigned int hi = data2;
    unsigned int position = (hi << 8) + lo;
    [_realtimeDelegate midiSetSongPosition:position];
}

- (void)notify_midiStatus:(Byte)status withData1:(Byte)data1 withData2:(Byte)data2
{
    [_voiceDelegate midiStatus:status
                         data1:data1
                         data2:data2];
}

- (void)processMidiPacket:(const MIDIPacket *)packet
{
    switch (packet->data[0])
    {
        case 0xF2:
            [self notify_SongPosition:packet->data[1]
                                data2:packet->data[2]];
        case 0xF8:
            [self notify_midiClock];
            break;
        case 0xF9:
            [self notify_midiTick];
            break;
        case 0xFA:
            [self notify_midiStart];
            break;
        case 0xFC:
            [self notify_midiStop];
            break;
        case 0xFB:
            [self notify_midiContinue];
            break;
        default:
            [self notify_midiStatus:packet->data[0]
                          withData1:packet->data[1]
                          withData2:packet->data[2]];
            break;
    }
}

static void midiRead(const MIDIPacketList *packetList,
                     void *readProcRefCon,
                     void *srcConnRefCon)
{
    const MIDIPacket *packet = &packetList->packet[0];
    
    for( int i = 0; i < packetList->numPackets; ++i )
    {
        [(__bridge MIDI*)readProcRefCon processMidiPacket:packet];
        packet = MIDIPacketNext( packet );
    }
}

@end