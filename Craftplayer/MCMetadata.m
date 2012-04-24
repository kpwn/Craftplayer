//
//  MCMetadata.m
//  Craftplayer
//
//  Created by qwertyoruiop on 24/04/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MCMetadata.h"
#import "MCSocket.h"
@implementation MCMetadata
@synthesize oldDelegate, stream, metadata, etype;
+(MCMetadata*)metadataWithSocket:(MCSocket*)socket andEntity:(MCEntity*)entity andType:(NSString *)etype
{
    id ret = [MCMetadata new];
    [ret setStream:[socket inputStream]];
    [ret setOldDelegate:[[socket inputStream] delegate]];
    [ret setEtype:etype];
    [[socket inputStream] setDelegate:ret];
    return ret;
}

- (void)stream:(NSStream *)theStream handleEvent:(NSStreamEvent)streamEvent
{
    if (!buffer) {
        buffer = [NSMutableData new];
    }
    if (!metadata) {
        metadata = [NSMutableArray new];
    }
    switch (streamEvent) {
        case NSStreamEventHasBytesAvailable:
            ;;
            unsigned char byte;
            [(NSInputStream *)theStream read:&byte maxLength:1];
            [buffer appendBytes:&byte length:1];
            const unsigned char* data = [buffer bytes];
            if (*((signed char*)data)==127) {
                [stream setDelegate:oldDelegate];
                [buffer release];
                [self setOldDelegate:nil];
                [self autorelease];
                return;
            }
            char index=(*data)&0x1F; 
            char type=(*data) >> 5;
            switch (type) {
                case 0:
                    if ([buffer length] == 2) {
                        switch (index) {
                            case 0:;;
                                BOOL isOnFire = (*(char*)(data+1)) & 0x01;
                                BOOL isCrouched = (*(char*)(data+1)) & 0x02;
                                BOOL isRiding = (*(char*)(data+1)) & 0x04;
                                BOOL isSprinting = (*(char*)(data+1)) & 0x08;
                                BOOL isRightClicking = (*(char*)(data+1)) & 0x10;
                                [metadata addObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:
                                                     [NSNumber numberWithBool:isOnFire], @"isOnFire",
                                                     [NSNumber numberWithBool:isCrouched], @"isCrouched",
                                                     [NSNumber numberWithBool:isRiding], @"isRiding",
                                                     [NSNumber numberWithBool:isSprinting], @"isSprinting",
                                                     [NSNumber numberWithBool:isRightClicking], @"isRightClicking",
                                                     nil]
                                 ];
                                break;
                                
                            default:
                                break;
                        }
                        [buffer setLength:0];
                    }
                    break;
                case 1:
                    if ([buffer length] == 3) {
                        switch (index) {
                            default:
                                break;
                        }
                        [buffer setLength:0];
                    }
                    break;
                case 2:
                    if ([buffer length] == 5) {
                        switch (index) {
                            default:
                                break;
                        }
                        [buffer setLength:0];
                    }
                    break;
                case 3:
                    if ([buffer length] == 5) {
                        switch (index) {
                            default:
                                break;
                        }
                        [buffer setLength:0];
                    }
                    break;
                case 4:
                    if ([buffer length] == 3 + OSSwapInt16(*(short*)(data+1))) {
                        switch (index) {
                            default:
                                break;
                        }
                        [buffer setLength:0];
                    }
                    break;
                case 5:
                    if ([buffer length] == 5) {
                        switch (index) {
                            default:
                                break;
                        }
                        [buffer setLength:0];
                    }
                    break;
                case 6:
                    if ([buffer length] == 13) {
                        switch (index) {
                            default:
                                break;
                        }
                        [buffer setLength:0];
                    }
                    break;
                default:
                    break;
            }
            break;
        default:
            [oldDelegate stream:theStream handleEvent:streamEvent];
            break;
    }
}

-(void)dealloc
{
    [buffer release];
    buffer=nil;
    [self setOldDelegate:nil];
    [super dealloc];
}
@end
