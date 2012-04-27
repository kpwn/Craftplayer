//
//  MCNBT.m
//  Craftplayer
//
//  Created by qwertyoruiop on 27/04/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MCNBT.h"
#import "MCString.h"
@implementation MCNBT
+(NSDictionary*)NBTWithBytes:(const unsigned char*)bytes andLen:(int)len
{
    NSMutableDictionary* ret = [[NSMutableDictionary new] autorelease];
    const unsigned char* obytes = bytes;
    while (bytes!=(obytes+len)) {
        switch (*bytes++) {
            case 0:
                return ret;
                break;
            case 1:;
                NSString* str = [MCString NSStringWithNBTString:bytes];
                [ret setObject:[NSNumber numberWithChar:*(char*)(bytes+m_char_t_sizeof(((m_char_t*)bytes)))] forKey:str];
                bytes = bytes+m_char_t_sizeof(((m_char_t*)bytes));
            case 2:;
                
            default:
                break;
        }
    }
    return ret;
}
+(NSDictionary*)NBTWithRawData:(NSData*)data
{
    return [self NBTWithBytes:[data bytes] andLen:[data length]];
}
@end
