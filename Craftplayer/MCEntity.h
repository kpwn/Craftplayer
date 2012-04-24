//
//  MCEntity.h
//  Craftplayer
//
//  Created by qwertyoruiop on 24/04/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MCMetadata.h"
#import "MCEffect.h"
@interface MCEntity : NSObject
{
    unsigned int eid;
    unsigned int x;
    unsigned int y;
    unsigned int z;
    unsigned short vx;
    unsigned short vy;
    unsigned short vz;
    unsigned char pitch;
    unsigned char yaw;
    unsigned short item;
    unsigned char* actions;
    unsigned char* animations;
    unsigned char count;
    unsigned short itemid;
    unsigned char rotation;
    unsigned short damage;
    unsigned char type;
    unsigned char headyaw;
    unsigned char direction;
    unsigned char status;
    MCEntity* veichle;
    MCMetadata* metadata;
    MCEffect* effect;
    NSString* name;
}
@property(assign) unsigned int eid;
@property(assign) unsigned int x;
@property(assign) unsigned int y;
@property(assign) unsigned int z;
@property(assign) unsigned short vx;
@property(assign) unsigned short vy;
@property(assign) unsigned short vz;
@property(assign) unsigned char pitch;
@property(assign) unsigned char yaw;
@property(assign) unsigned short item;
@property(assign) unsigned char* actions;
@property(assign) unsigned char* animations;
@property(assign) unsigned char count;
@property(assign) unsigned short itemid;
@property(assign) unsigned char rotation;
@property(assign) unsigned short damage;
@property(assign) unsigned char type;
@property(assign) unsigned char headyaw;
@property(assign) unsigned char direction;
@property(assign) unsigned char status;
@property(retain) MCEntity* veichle;
@property(retain) MCMetadata* metadata;
@property(retain) MCEffect* effect;
@property(retain) NSString* name;
+(MCEntity*)entityWithIdentifier:(unsigned int)eid;
@end
