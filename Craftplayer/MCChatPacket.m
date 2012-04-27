//
//  MCChatPacket.m
//  Craftplayer
//
//  Created by qwertyoruiop on 27/04/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MCChatPacket.h"
#import "MCString.h"
@implementation MCChatPacket
@synthesize message;
+(MCChatPacket*)packetWithInfo:(NSDictionary *)infoDict
{
    MCChatPacket* ret = [MCChatPacket new];
    NSString* msg = [infoDict objectForKey:@"Message"];
    if (!msg) return nil;
    if ([msg isEqualToString:@""]) return nil;
    [ret setMessage:msg];
    return [ret autorelease];
}
-(void)sendToSocket:(MCSocket *)socket
{
    [self performSelectorInBackground:@selector(sendToSocketThread:) withObject:socket];
}
-(void)sendToSocketThread:(MCSocket *)socket
{
    m_char_t* text=[MCString MCStringFromString:[self message]];
    unsigned char pckid=0x03;
    [[socket outputStream] write:&pckid maxLength:1];
    [[socket outputStream] write:(unsigned char*)text maxLength:m_char_t_sizeof(text)];
    free(text);
}
-(void)dealloc
{
    [self setMessage:nil];
    [super dealloc];
}
@end
