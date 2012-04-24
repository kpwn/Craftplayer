//
//  MCEntity.m
//  Craftplayer
//
//  Created by qwertyoruiop on 24/04/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MCEntity.h"

@implementation MCEntity
@synthesize eid,x,y,z,vx,vy,vz,pitch,yaw,item,actions,animations,count,itemid,rotation,damage,type,headyaw,direction,status,veichle,metadata,effect,name;
+(MCEntity*)entityWithIdentifier:(unsigned int)eid
{
    static NSMutableDictionary* entityPool;
    if (!entityPool) {
        entityPool=[NSMutableDictionary new];
    }
    NSNumber* nseid = [NSNumber numberWithUnsignedInt:eid];
    MCEntity* entity = [entityPool objectForKey:nseid];
    if (entity) {
        return entity;
    }
    entity = [MCEntity new];
    [entity setEid:eid];
    [entityPool setObject:entity forKey:nseid];
    return entity;
}
-(void)dealloc
{
    self.veichle=nil;
    self.metadata=nil;
    self.effect=nil;
    self.name=nil;
    [super dealloc];
}
@end
