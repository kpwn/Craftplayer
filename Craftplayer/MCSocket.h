//
//  MCSocket.h
//  Craftplayer
//
//  Created by qwertyoruiop on 23/04/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MCAuth.h"
#import "MCEntity.h"
#import "MCSlot.h"
#import "MCSocketDelegate.h"
@class MCPacket;
@class MCSlot;
@class MCMetadata;
@interface MCSocket : NSObject <NSStreamDelegate>
{
    NSInputStream *inputStream;
    NSOutputStream *outputStream;
    MCAuth* auth;
    MCEntity* player;
    NSString* server;
    id<MCSocketDelegate> delegate;
}
@property(readonly) NSInputStream *inputStream;
@property(readonly) NSOutputStream *outputStream;
@property(retain) MCAuth* auth;
@property(retain) NSString* server;
@property(readonly) MCEntity* player;
@property(retain) id<MCSocketDelegate> delegate;
- (MCSocket*)initWithServer:(NSString*)iserver andAuth:(MCAuth*)iauth;
- (void)metadata:(MCMetadata*)metadata hasFinishedParsing:(NSArray*)infoArray;
- (void)slot:(MCSlot*)slot hasFinishedParsing:(NSDictionary*)infoDict;
- (void)packet:(MCPacket*)packet gotParsed:(NSDictionary*)infoDict;
- (void)connect;
- (void)connect:(BOOL)threaded;
@end
