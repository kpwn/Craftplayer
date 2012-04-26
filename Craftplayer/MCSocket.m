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
#import "MCWindow.h"
@implementation MCSocket
@synthesize inputStream, outputStream, auth, player, server;
-(MCSocket*)initWithServer:(NSString*)iserver andAuth:(MCAuth*)iauth
{
    [self setAuth:iauth];
    [self setServer:iserver];
    return self;
}
-(void)connect
{
    CFReadStreamRef readStream;
    CFWriteStreamRef writeStream;
    NSArray* pieces = [server componentsSeparatedByString:@":"];
    NSString* target = @"";
    int port = 25565;
    if ([pieces count] == 1) {
        target = [pieces objectAtIndex:0];
    }
    else if ([pieces count] > 1) {
        target = [pieces objectAtIndex:0];
        port = [[pieces objectAtIndex:1] intValue];
    }
    CFStreamCreatePairWithSocketToHost(kCFAllocatorDefault, (CFStringRef)target, port
                                       , &readStream, &writeStream);
    inputStream = (NSInputStream *)readStream;
    outputStream = (NSOutputStream *)writeStream;
    [inputStream setDelegate:self];
    [outputStream setDelegate:self];
    [inputStream scheduleInRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
    [outputStream scheduleInRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
    [inputStream open];
    [outputStream open];
    m_char_t* _handshake_msg=[MCString MCStringFromString:[NSString stringWithFormat:@"%@;%@", [auth username], @"lmkcraft.com:20000", nil]];
    unsigned char pckid=0x02;
    [outputStream write:&pckid maxLength:1];
    [outputStream write:(unsigned char*)_handshake_msg maxLength:m_char_t_sizeof(_handshake_msg)];
    free(_handshake_msg);
}
- (void)slot:(MCMetadata*)slot hasFinishedParsing:(NSDictionary*)infoDict
{
    NSLog(@"Got slot! %@", infoDict);
}
- (void)metadata:(MCMetadata*)metadata hasFinishedParsing:(NSArray*)infoArray
{
    NSLog(@"Got metadata! %@", infoArray);
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
-(void)dealloc
{
    [self setAuth:nil];
    [super dealloc];
}
@end
