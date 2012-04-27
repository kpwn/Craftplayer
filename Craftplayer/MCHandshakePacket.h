//
//  MCHandshakePacket.h
//  Craftplayer
//
//  Created by qwertyoruiop on 27/04/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MCSendPacket.h"

@interface MCHandshakePacket : MCSendPacket
+(MCHandshakePacket*)packetWithInfo:(NSDictionary*)infoDict;
-(void)sendToSocket:(MCSocket*)socket;
@end
