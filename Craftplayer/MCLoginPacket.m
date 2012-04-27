//
//  MCLoginPacket.m
//  Craftplayer
//
//  Created by qwertyoruiop on 27/04/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MCLoginPacket.h"

@implementation MCLoginPacket
@synthesize version;
+(MCLoginPacket*)packetWithInfo:(NSDictionary *)infoDict
{
    MCLoginPacket* ret = [MCLoginPacket new];
    NSNumber* ver = [infoDict objectForKey:@"Version"];
    if (!ver) return nil;
    [ret setVersion:OSSwapInt32([ver intValue])];
    return [ret autorelease];
}
-(void)sendToSocket:(MCSocket *)socket
{
    unsigned char pckid=0x01;
    m_char_t* __name_msg=[MCString MCStringFromString:[[socket auth] username]];
    [[socket buffer] appendBytes:&pckid length:1];
    [[socket buffer] appendBytes:&version length:4];
    [[socket buffer] appendBytes:__name_msg length:m_char_t_sizeof(__name_msg)];
    [[socket buffer] setLength:[[socket buffer] length] + 13];
    [socket writeBuffer];
    free(__name_msg);
}
-(void)dealloc
{
    [super dealloc];
}
@end
