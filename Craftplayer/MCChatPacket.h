//
//  MCChatPacket.h
//  Craftplayer
//
//  Created by qwertyoruiop on 27/04/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MCSendPacket.h"
#import "MCString.h"

@interface MCChatPacket : MCSendPacket
{
    NSString* message;
}
@property(retain) NSString* message;
+(MCChatPacket*)packetWithInfo:(NSDictionary*)infoDict;
-(void)sendToSocket:(MCSocket*)socket;
@end
