#import "midi.h"

static void midiRead(const MIDIPacketList *pktlist, void *readProcRefCon, void *srcConnRefCon);

@implementation MIDI
@synthesize clientName = _clientName;

- (id)initWithName:(NSString *)clientName
{
    self = [super init];
    
    if (self)
    {
        [self instantiateClient:clientName];
        
        internalClock = [[Clock alloc] initWithStartBlock:^(){ [self sendStart]; }
                                                    clock:^(){ [self sendClock]; }
                                                     stop:^(){ [self sendStop]; }];
    }
    
    return self;
}

- (void)instantiateClient:(NSString *)clientName
{
    MIDIClientCreate((__bridge CFStringRef)clientName,
                     0,
                     0,
                     &client);
    
    MIDIOutputPortCreate(client,
                         CFSTR("output"),
                         &output_port);
    
    MIDIInputPortCreate(client,
                        CFSTR("input"),
                        midiRead,
                        (__bridge void *)(self),
                        &input_port);
    
    self.destinations = [self discoverDestinations];
    self.sources = [self discoverSources];
    _clientName = [NSString stringWithString:clientName];
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
    [[self discoverDestinations]
     enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop)
     {
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
    [[self discoverSources]
     enumerateObjectsUsingBlock: ^(id obj, NSUInteger idx, BOOL *stop)
     {
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
                      byte:(unsigned int)byte
{
    Byte buffer[1024];
	MIDIPacketList *packet_list = (MIDIPacketList *)buffer;
	MIDIPacket *packet = MIDIPacketListInit(packet_list);
	Byte message[1];
	OSStatus result;
    
	message[0] = byte;
	
    packet = MIDIPacketListAdd(
                               packet_list,
                               sizeof(buffer),
                               packet,
                               0,
                               1,
                               message);
	
    result = MIDISend(output_port, endpoint, packet_list);
}

- (void)transmitToEndpoint:(MIDIEndpointRef)endpoint
                    status:(unsigned)byte_1
                    data_1:(unsigned)byte_2
                    data_2:(unsigned)byte_3
{
	Byte buffer[1024];
	MIDIPacketList *packet_list = (MIDIPacketList *)buffer;
	MIDIPacket *packet = MIDIPacketListInit(packet_list);
	Byte message[3];
	OSStatus result;
    
	message[0] = byte_1;
	message[1] = byte_2;
	message[2] = byte_3;
	
	packet = MIDIPacketListAdd(packet_list,
                               sizeof(buffer),
                               packet,
                               0,
                               3,
                               message);
    
	result = MIDISend(output_port,
                      endpoint,
                      packet_list);
}

- (void)sendClock
{
    [self transmitToEndpoint:out_endpoint byte:0xF8];
}

- (void)sendTick
{
    [self transmitToEndpoint:out_endpoint byte:0xF9];
}

- (void)sendStart
{
    [self transmitToEndpoint:out_endpoint byte:0xFA];
}

- (void)sendContinue
{
    [self transmitToEndpoint:out_endpoint byte:0xFB];
}

- (void)sendStop
{
    [self transmitToEndpoint:out_endpoint byte:0xFC];
}

- (void)sendOnToChannel:(unsigned int)channel
                 number:(unsigned int)number
               velocity:(unsigned int)velocity
{
	[self transmitToEndpoint:out_endpoint
                      status:0x90 + channel
                      data_1:number
                      data_2:velocity];
}

- (void)sendOffToChannel:(unsigned int)channel
                  number:(unsigned int)number
                velocity:(unsigned int)velocity
{
	[self transmitToEndpoint:out_endpoint
                      status:0x80 + channel
                      data_1:number
                      data_2:velocity ];
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