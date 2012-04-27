//
//  MCHandshakePacket.m
//  Craftplayer
//
//  Created by qwertyoruiop on 27/04/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MCHandshakePacket.h"
#import "MCString.h"
@implementation MCHandshakePacket
+(MCHandshakePacket*)packetWithInfo:(NSDictionary *)infoDict
{
    MCHandshakePacket* ret = [MCHandshakePacket new];
    return [ret autorelease];
}
-(void)sendToSocket:(MCSocket *)socket
{
    m_char_t* text=[MCString MCStringFromString:[NSString stringWithFormat:@"%@;%@", [[socket auth] username], [socket server], nil]];
    unsigned char pckid=0x02;
    [[socket buffer] appendBytes:&pckid length:1];
    [[socket buffer] appendBytes:text length:m_char_t_sizeof(text)];
    [socket writeBuffer];
    free(text);
}
-(void)dealloc
{
    [super dealloc];
}

@end
