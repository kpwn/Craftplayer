//
//  MCLoginPacket.h
//  Craftplayer
//
//  Created by qwertyoruiop on 27/04/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MCSendPacket.h"
#import "MCString.h"

@interface MCLoginPacket : MCSendPacket
{
    int version;
}
@property(assign) int version;
+(MCLoginPacket*)packetWithInfo:(NSDictionary*)infoDict;
-(void)sendToSocket:(MCSocket*)socket;
@end
