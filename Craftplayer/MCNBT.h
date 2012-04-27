//
//  MCNBT.h
//  Craftplayer
//
//  Created by qwertyoruiop on 27/04/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MCNBT : NSObject
+(NSDictionary*)NBTWithRawData:(NSData*)data;
@end
