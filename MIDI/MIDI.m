#import "MIDI.h"

static void midi_read_proc(const MIDIPacketList *pktlist, void *readProcRefCon, void *srcConnRefCon);

@implementation MIDI

- (id)init
{
    self = [super init];
    if (self) {
        MIDIClientCreate(CFSTR("midiOutStarter"),0,0,&client);
        MIDISourceCreate(client, CFSTR("midiOutStarter_out"), &out_endpoint);
        MIDIInputPortCreate(client, CFSTR("midiOutStarter_in"), midi_read_proc, (__bridge void *)(self), &input_port);
        [self connectExistingDevices];
    }
    
    return self;
}

- (void)transmit:(MIDIEndpointRef)endpoint byte_1:(unsigned)byte_1 byte_2:(unsigned)byte_2 byte_3:(unsigned)byte_3
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
	result = MIDIReceived( endpoint,  packet_list);
}

- (void)noteOn:(unsigned int)channel number:(unsigned int)number velocity:(unsigned int)velocity
{
	[self transmit:out_endpoint
            byte_1:0x90 + channel
            byte_2:number
            byte_3:velocity];
}

- (void)noteOff:(unsigned int)channel number:(unsigned int)number velocity:(unsigned int)velocity
{
	[self transmit:out_endpoint
            byte_1:0x80 + channel
            byte_2:number
            byte_3:velocity ];
}

- (void)all_notes_off:(unsigned)channel
{
	for( unsigned number = 0; number < 128; number++ )
		[self noteOff:channel
               number:number
             velocity:0
         ];
}

- (void) connectExistingDevices
{
    const ItemCount numberOfSources = MIDIGetNumberOfSources();
    
    for (ItemCount index = 0; index < numberOfSources; ++index)
    {
        MIDIPortConnectSource( input_port, MIDIGetSource(index), NULL );
    }
}

- (void) disconnectExistingDevices
{
    const ItemCount numberOfSources = MIDIGetNumberOfSources();
    
    for (ItemCount index = 0; index < numberOfSources; ++index)
    {
        MIDIPortDisconnectSource( input_port, MIDIGetSource(index) );
    }
}

- (void) reset
{
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

static void midi_read_proc(const MIDIPacketList *packetList, void *readProcRefCon, void *srcConnRefCon)
{
    const MIDIPacket *packet = &packetList->packet[0];
    
    for (int i = 0; i < packetList->numPackets; ++i)
    {
        [(__bridge MIDI*)readProcRefCon midiPacket:packet];
        packet = MIDIPacketNext( packet );
    }
}

@end