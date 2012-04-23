//
//  NSString+javaString.m
//  Minecraft
//
//  Created by qwertyoruiop on 23/04/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//


#import "MCString.h"
#include <iconv.h>

@implementation MCString
+(m_char_t*)MCStringFromString:(NSString*)str
{
    m_char_t* ret = (m_char_t*)malloc(sizeof(short) + [str lengthOfBytesUsingEncoding:NSUTF16BigEndianStringEncoding]);
    memcpy(ret->data, [str cStringUsingEncoding:NSUTF16BigEndianStringEncoding], [str lengthOfBytesUsingEncoding:NSUTF16BigEndianStringEncoding]);
    ret->len = flipshort([str lengthOfBytesUsingEncoding:NSUTF16BigEndianStringEncoding]/2);
    return ret;
}
+(NSString*)NSStringWithMinecraftString:(m_char_t*)string;
{
    NSData* data = [[NSData alloc] initWithBytes:string->data length:flipshort(string->len)*2];
    id ret = [[NSString alloc] initWithData:data encoding:NSUTF16BigEndianStringEncoding];
    [data release];
    return [ret autorelease];
}
@end
