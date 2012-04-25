//
//  MCSocket.m
//  Craftplayer
//
//  Created by qwertyoruiop on 23/04/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MCSocket.h"
#import "MCString.h"
#import "MCPacket.h"
@implementation MCSocket
@synthesize inputStream, outputStream, auth, player;
-(void)connect
{
    auth = [[MCAuth authWithUsername:@"xpwn" andPassword:@"dummy"] retain];
    CFReadStreamRef readStream;
    CFWriteStreamRef writeStream;
    CFStreamCreatePairWithSocketToHost(kCFAllocatorDefault, (CFStringRef)@"127.0.0.1", 13371
                                       , &readStream, &writeStream);
    inputStream = (NSInputStream *)readStream;
    outputStream = (NSOutputStream *)writeStream;
    [inputStream setDelegate:self];
    [outputStream setDelegate:self];
    [inputStream scheduleInRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
    [outputStream scheduleInRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
    [inputStream open];
    [outputStream open];
    m_char_t* _handshake_msg=[MCString MCStringFromString:[NSString stringWithFormat:@"%@;%@", [auth username], @"176.31.64.248:25565", nil]];
    unsigned char pckid=0x02;
    [outputStream write:&pckid maxLength:1];
    [outputStream write:(unsigned char*)_handshake_msg maxLength:m_char_t_sizeof(_handshake_msg)];
    free(_handshake_msg);
}
- (void)packet:(MCPacket*)packet gotParsed:(NSDictionary*)infoDict
{
    if ([[infoDict objectForKey:@"PacketType"] isEqualToString:@"Login"]) {
        player = [MCEntity entityWithIdentifier:[[infoDict objectForKey:@"EntityID"] intValue]];
    }
    NSLog(@"Got packet! %@", infoDict);
}
- (void)stream:(NSStream *)theStream handleEvent:(NSStreamEvent)streamEvent {
	switch (streamEvent) {
		case NSStreamEventHasSpaceAvailable:
			NSLog(@"None!");
			break;
		case NSStreamEventOpenCompleted:
			NSLog(@"Stream opened");
			break;
		case NSStreamEventHasBytesAvailable:
            ;;
            unsigned char packetIdentifier=0x00;
            [(NSInputStream *)theStream read:&packetIdentifier maxLength:1];
            [MCPacket packetWithID:packetIdentifier andSocket:self]; 
            break;
    }
}
@end
