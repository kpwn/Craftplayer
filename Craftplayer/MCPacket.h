//
//  MCPacket.h
//  Craftplayer
//
//  Created by qwertyoruiop on 23/04/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
@class MCSocket;
@interface MCPacket : NSObject <NSStreamDelegate>
{
    MCSocket* sock;
    unsigned char identifier;
    NSMutableData* buffer;
}
@property(retain) MCSocket* sock;
@property(assign) unsigned char identifier;
@property(retain) NSMutableData* buffer;
+(MCPacket*)packetWithID:(unsigned char)idt andSocket:(MCSocket*)sock;
@end
