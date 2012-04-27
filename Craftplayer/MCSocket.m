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
#import "MCHandshakePacket.h"
@implementation MCSocket
@synthesize inputStream, outputStream, auth, player, server, delegate, buffer;
-(MCSocket*)initWithServer:(NSString*)iserver andAuth:(MCAuth*)iauth
{
    [self setAuth:iauth];
    [self setServer:iserver];
    return self;
}
-(void)threadLoop
{
    id pool = [NSAutoreleasePool new];
    [self __connect];
    while (1) {
        [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:1]];
        [pool drain];
        pool = [NSAutoreleasePool new];
    }
}
-(void)connect
{
    [self connect:NO];
}
-(void)connect:(BOOL)threaded
{
    [self setBuffer:[[NSMutableData new] autorelease]];
    if (threaded) {
        [self performSelectorInBackground:@selector(threadLoop) withObject:nil];
        return;
    }
    [self __connect];
}
-(void)__connect
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
    [inputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [outputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [inputStream open];
    [outputStream open];
    [[MCHandshakePacket packetWithInfo:nil] sendToSocket:self];
}
- (void)slot:(MCSlot*)slot hasFinishedParsing:(NSDictionary*)infoDict
{
    if ([delegate respondsToSelector:@selector(slot:hasFinishedParsing:)]) {
        if ([NSThread isMainThread])
            [delegate slot:slot hasFinishedParsing:infoDict];
        else
            [self performSelectorOnMainThread:@selector(sendMessageToDelegatewithTwoArgs:) withObject:[NSArray arrayWithObjects:NSStringFromSelector(@selector(slot:hasFinishedParsing:)), slot, infoDict, nil] waitUntilDone:NO];
    }
}
- (void)metadata:(MCMetadata*)metadata hasFinishedParsing:(NSArray*)infoArray
{
    if ([delegate respondsToSelector:@selector(metadata:hasFinishedParsing:)]) {
        if ([NSThread isMainThread])
            [delegate metadata:metadata hasFinishedParsing:infoArray];
        else
            [self performSelectorOnMainThread:@selector(sendMessageToDelegatewithTwoArgs:) withObject:[NSArray arrayWithObjects:NSStringFromSelector(@selector(metadata:hasFinishedParsing:)), metadata, infoArray, nil] waitUntilDone:NO];
    }
}
- (void)packet:(MCPacket*)packet gotParsed:(NSDictionary*)infoDict
{
    if ([[infoDict objectForKey:@"PacketType"] isEqualToString:@"Login"]) {
        player = [MCEntity entityWithIdentifier:[[infoDict objectForKey:@"EntityID"] intValue]];
    }
    if ([[infoDict objectForKey:@"PacketType"] isEqualToString:@"Disconnect"]) {
        [outputStream removeFromRunLoop:[NSRunLoop currentRunLoop]
                                forMode:NSDefaultRunLoopMode];
        [inputStream removeFromRunLoop:[NSRunLoop currentRunLoop]
                               forMode:NSDefaultRunLoopMode];
        [inputStream close];
        [outputStream close];
        [outputStream release];
        [inputStream release];
        outputStream = nil;
        inputStream = nil;
    }
    if ([delegate respondsToSelector:@selector(packet:gotParsed:)]) { 
        if ([NSThread isMainThread])
            [delegate packet:packet gotParsed:infoDict];
        else
            [self performSelectorOnMainThread:@selector(sendMessageToDelegatewithTwoArgs:) withObject:[NSArray arrayWithObjects:NSStringFromSelector(@selector(packet:gotParsed:)), packet, infoDict, nil] waitUntilDone:NO];
    }
}
- (void)sendMessageToDelegatewithTwoArgs:(NSArray*)args
{
    [[self delegate] performSelector:NSSelectorFromString([args objectAtIndex:0]) withObject:[args objectAtIndex:1] withObject:[args objectAtIndex:2]];
}
- (void)writeBuffer
{
    if ([outputStream streamStatus]==NSStreamStatusOpen) {
        if ([buffer length])
            [(NSOutputStream*)outputStream write:(uint8_t*)[buffer bytes] maxLength:[buffer length]];
        [buffer setLength:0];
    }
}
- (void)stream:(NSStream *)theStream handleEvent:(NSStreamEvent)streamEvent {
	switch (streamEvent) {
        case NSStreamEventEndEncountered:;
            NSDictionary* infoDict = [NSDictionary dictionaryWithObjectsAndKeys:
                                      [NSArray arrayWithObjects:[NSArray arrayWithObjects:[UIColor whiteColor], @"End of stream", nil], nil], @"Message",
                                      @"Disconnect", @"PacketType",
                                      nil];
            [self packet:nil gotParsed:infoDict];
            break;
		case NSStreamEventHasSpaceAvailable:
            [self writeBuffer];
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
    [self setBuffer:nil];
    [self setAuth:nil];
    [super dealloc];
}
@end
