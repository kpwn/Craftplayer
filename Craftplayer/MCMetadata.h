//
//  MCMetadata.h
//  Craftplayer
//
//  Created by qwertyoruiop on 24/04/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MCEntity.h"
@class MCSocket;
@class MCEntity;
@interface MCMetadata : NSObject <NSStreamDelegate>
{
    id oldDelegate;
    id stream;
    NSMutableData* buffer;
    NSMutableArray* metadata;
    NSString* etype;
}
@property(retain) id oldDelegate;
@property(retain) id stream;
@property(readonly) NSMutableArray* metadata;
@property(retain) NSString* etype;
+(MCMetadata*)metadataWithSocket:(MCSocket*)socket andEntity:(MCEntity*)entity andType:(NSString*)etype;
@end
