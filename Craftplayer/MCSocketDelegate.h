//
//  MCSocketDelegate.h
//  Craftplayer
//
//  Created by qwertyoruiop on 27/04/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
@class MCMetadata;
@class MCPacket;
@class MCSlot;
@protocol MCSocketDelegate <NSObject>
@optional
- (void)slot:(MCSlot*)slot hasFinishedParsing:(NSDictionary*)infoDict;
@optional
- (void)metadata:(MCMetadata*)metadata hasFinishedParsing:(NSArray*)infoArray;
@optional
- (void)packet:(MCPacket*)packet gotParsed:(NSDictionary*)infoDict;
@end
