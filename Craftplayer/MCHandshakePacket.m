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
    [self performSelectorInBackground:@selector(sendToSocketThread:) withObject:socket];
}
-(void)sendToSocketThread:(MCSocket *)socket
{
    m_char_t* text=[MCString MCStringFromString:[NSString stringWithFormat:@"%@;%@", [[socket auth] username], [socket server], nil]];
    unsigned char pckid=0x02;
    [[socket outputStream] write:&pckid maxLength:1];
    [[socket outputStream] write:(unsigned char*)text maxLength:m_char_t_sizeof(text)];
    free(text);
}
-(void)dealloc
{
    [super dealloc];
}

@end
