//
//  NSString+javaString.m
//  Minecraft
//
//  Created by qwertyoruiop on 23/04/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "NSString+javaString.h"
#define Endian16_Swap(value) (UInt16) (__builtin_constant_p(value) ? OSSwapConstInt16(value) : OSSwapInt16(value))
#define Endian32_Swap(value) (UInt32) (__builtin_constant_p(value) ? OSSwapConstInt32(value) : OSSwapInt32(value))
#define Endian64_Swap(value) (UInt64) (__builtin_constant_p(value) ? OSSwapConstInt64(value) : OSSwapInt64(value))
#define flipshort(x) Endian16_Swap(x)
typedef struct m_char
{
    short len;
    char data[];
} m_char_t;
@implementation NSString (javaString)
-(m_char_t*)minecraftString
{
    m_char_t* ret = (m_char_t*)malloc(sizeof(short) + [self lengthOfBytesUsingEncoding:NSUTF16BigEndianStringEncoding]);
    memcpy(ret->data, [self javaString], [self lengthOfBytesUsingEncoding:NSUTF16BigEndianStringEncoding]);
    ret->len = flipshort([self lengthOfBytesUsingEncoding:NSUTF16BigEndianStringEncoding]);
    return ret;
}
-(const char*)javaString
{
    return [self cStringUsingEncoding:NSUTF16BigEndianStringEncoding];
}
+(NSString*)stringWithMinecraftString:(m_char_t*)string
{
    char* kp=malloc(string->len+sizeof(short));
    bzero(kp, string->len+sizeof(short));
    memcpy(kp, string->data, string->len);
    id ret = [self stringWithCString:kp encoding:NSUTF16BigEndianStringEncoding];
    free(kp);
    return ret;
}
@end
