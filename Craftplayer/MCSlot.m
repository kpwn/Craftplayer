//
//  MCSlot.m
//  Craftplayer
//
//  Created by qwertyoruiop on 25/04/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MCSlot.h"
#import "MCSocket.h"
#import "NSData+UserAdditions.h"
#define canEnchant(value) ((256 <= value && value <= 259) || \
                          (267 <= value && value <= 279) || \
                          (283 <= value && value <= 286) || \
                          (290 <= value && value <= 294) || \
                          (298 <= value && value <= 317) || \
                          value == 261 || value == 359 || \
                          value == 346)

@implementation MCSlot
@synthesize window,socket,oldDelegate,index,slotData;
+(MCSlot*)slotWithWindow:(MCWindow *)awindow atPosition:(short)aindex withSocket:(MCSocket*)asocket
{
    MCSlot* ret=(MCSlot*)[NSNull null];
    if ([[awindow items] count] > aindex)
        ret=[[awindow items] objectAtIndex:aindex];
    if (ret == (MCSlot*)[NSNull null])
    {
        ret = [MCSlot new];
        [ret setWindow:awindow];
        [ret setIndex:aindex];
        if ([[awindow items] count] > aindex)
            [[awindow items] removeObjectAtIndex:aindex];
        [[awindow items] insertObject:ret atIndex:aindex];
    }
    [ret setSocket:asocket];
    [ret setOldDelegate:[[asocket inputStream] delegate]];
    [[asocket inputStream] setDelegate:ret];
    return [ret retain];
}
- (void)stream:(NSStream *)theStream handleEvent:(NSStreamEvent)streamEvent
{
    if (!buffer) {
        buffer = [NSMutableData new];
    }
    if (!slotData) {
        [self setSlotData:[NSMutableDictionary new]];
    }
    switch (streamEvent) {
        case NSStreamEventHasBytesAvailable:
            ;;
            unsigned char byte;
            [(NSInputStream *)theStream read:&byte maxLength:1];
            [buffer appendBytes:&byte length:1];
            const unsigned char* data = [buffer bytes];
            if ([buffer length] >= 2) {
                [slotData setObject:[NSNumber numberWithShort:OSSwapInt16(*(short*)(data))] forKey:@"ID"];
                if (*(short*)(data)==(short)-1) {
                    [slotData setObject:[NSNumber numberWithChar:0] forKey:@"Count"];
                    [slotData setObject:[NSNumber numberWithShort:0] forKey:@"Damage"];
                    [slotData removeObjectForKey:@"EnchantmentData"];
                    goto end;
                } else if ([buffer length] >= 5){
                    if (canEnchant(OSSwapInt16(*(short*)(data))) ) {
                        short len = OSSwapInt16(*(short*)(data+5));
                        if (len == -1)
                        {
                            [slotData setObject:[NSNumber numberWithChar:(*(char*)(data+2))] forKey:@"Count"];
                            [slotData setObject:[NSNumber numberWithShort:OSSwapInt16(*(short*)(data+3))] forKey:@"Damage"];
                            [slotData removeObjectForKey:@"EnchantmentData"];
                            goto end;
                        }
                        if ([buffer length] == 7+len)
                        {
                            [slotData setObject:[NSNumber numberWithChar:(*(char*)(data+2))] forKey:@"Count"];
                            [slotData setObject:[NSNumber numberWithShort:OSSwapInt16(*(short*)(data+3))] forKey:@"Damage"];
                            [slotData setObject:[[NSData dataWithBytes:(char*)(data+7) length:len] gzipInflate] forKey:@"EnchantmentData"];
                            goto end;
                        }
                    } else {
                        [slotData setObject:[NSNumber numberWithChar:(*(char*)(data+2))] forKey:@"Count"];
                        [slotData setObject:[NSNumber numberWithShort:OSSwapInt16(*(short*)(data+3))] forKey:@"Damage"];
                        [slotData removeObjectForKey:@"EnchantmentData"];
                        goto end;
                    }
                }
            }
            break;
        default:
            break;
    }
    return;
end:
    [[self socket] slot:self hasFinishedParsing:slotData];
    [theStream setDelegate:oldDelegate];
    [buffer release];
    buffer=nil;
    [self setOldDelegate:nil];
    [self autorelease];
    return;
}
-(void)dealloc
{
    NSLog(@"Out!");
    [[self slotData] release];
    [self setSlotData:nil];
    [super dealloc];
}
@end
