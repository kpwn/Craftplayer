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
    [self performSelectorInBackground:@selector(sendToSocketThread:) withObject:socket];
}
-(void)sendToSocketThread:(MCSocket *)socket
{
    unsigned char pckid=0x01;
    [[socket outputStream] write:&pckid maxLength:1];
    [[socket outputStream] write:(uint8_t*)&version maxLength:4];
    m_char_t* __name_msg=[MCString MCStringFromString:[[socket auth] username]];
    [[socket outputStream] write:(unsigned char*)__name_msg maxLength:m_char_t_sizeof(__name_msg)];
    char* z=malloc(13);
    bzero(z, 13);
    [[socket outputStream] write:(unsigned char*)z maxLength:13];
    free(__name_msg);
    free(z);
}
-(void)dealloc
{
    [super dealloc];
}
@end
