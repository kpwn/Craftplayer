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
    m_char_t* text=[MCString MCStringFromString:[self message]];
    unsigned char pckid=0x03;
    [[socket buffer] appendBytes:&pckid length:1];
    [[socket buffer] appendBytes:text length:m_char_t_sizeof(text)];
    free(text);
    [socket writeBuffer];
}
-(void)dealloc
{
    [self setMessage:nil];
    [super dealloc];
}
@end
