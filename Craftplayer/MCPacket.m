//
//  MCPacket.m
//  Craftplayer
//
//  Created by qwertyoruiop on 23/04/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MCPacket.h"
#import "MCSocket.h"
#import "MCString.h"
@implementation MCPacket
@synthesize sock,identifier,buffer;
+(MCPacket*)packetWithID:(unsigned short)idt andSocket:(MCSocket*)sock
{
    MCPacket* kret=[MCPacket new];
    [[sock inputStream] setDelegate:kret];
    [kret setIdentifier:idt];
    [kret setSock:sock];
    [kret setBuffer:[[NSMutableData new] autorelease]];
    NSLog(@"Packet: %02X", idt);
    return kret;
}
- (void)stream:(NSStream *)theStream handleEvent:(NSStreamEvent)streamEvent {
	switch (streamEvent) {
		case NSStreamEventHasBytesAvailable:;;
            unsigned char byte;
            [(NSInputStream *)theStream read:&byte maxLength:1];
            [buffer appendBytes:&byte length:1];
            switch (identifier) {
                case 0x02:
                    if ([buffer length]>2) {
                        const unsigned char* data=[buffer bytes];
                        short len = flipshort(*(short*)data);
                        if ([buffer length] == (len*2 + 2))
                        {
                            [[[self sock] inputStream] setDelegate:[self sock]];
                            NSString* kdata=[MCString NSStringWithMinecraftString:(m_char_t*)data];
                            if(![[[self sock] auth] joinToServer:kdata])
                            {
                                NSLog(@"A wild error! <%@>", [[[[self sock] auth] login] objectForKey:kMCAuthError]);
                            } else {
                                unsigned char pckid=0x01;
                                [[[self sock] outputStream] write:&pckid maxLength:1];
                                unsigned int ver=OSSwapInt32(29);
                                [[[self sock] outputStream] write:(uint8_t*)&ver maxLength:4];
                                m_char_t* __name_msg=[MCString MCStringFromString:[[sock auth] username]];
                                [[[self sock] outputStream] write:(unsigned char*)__name_msg maxLength:m_char_t_sizeof(__name_msg)];
                                char* z=malloc(13);
                                bzero(z, 13);
                                [[[self sock] outputStream] write:(unsigned char*)z maxLength:13];
                                free(__name_msg);
                                free(z);
                            }
                            [self release];
                            return;
                        }
                    }
                    break;
                case 0x01:
                    if ([buffer length]>8) {
                        const unsigned char* data=[buffer bytes];
                        short len = flipshort(*(short*)(data+6));
                        if ([buffer length] == (len*2 + 8 + 2 + 4 + 4 + 1))
                        {
                            NSLog(@"Connected!");
                            [[[self sock] inputStream] setDelegate:[self sock]];
                            [self release];
                            return;
                        }
                    }
                    break;
                case 0x06:
                    if ([buffer length]>12) {
                        const unsigned char* data=[buffer bytes];
                        NSLog(@"Spawn Point is at: X: %d Y: %d Z: %d", OSSwapInt32((*(int*)data)), OSSwapInt32((*(int*)(data+4))), OSSwapInt32((*(int*)(data+8))));
                        [[[self sock] inputStream] setDelegate:[self sock]];
                        [self release];
                        return;
                    }
                    break;
                case 0x00:
                    if ([buffer length]>4) {
                        const unsigned char* data=[buffer bytes];
                        char x = 0x00;
                        [[[self sock] outputStream] write:(unsigned char*)&x maxLength:1];
                        [[[self sock] outputStream] write:(unsigned char*)data maxLength:4];
                        [[[self sock] inputStream] setDelegate:[self sock]];
                        [self release];
                        return;
                    }
                    break;
                default:
                    break;
            }
    }
}
- (oneway void)dealloc
{
    [self setSock:nil];
    [self setBuffer:nil];
    [super dealloc];
}
@end
