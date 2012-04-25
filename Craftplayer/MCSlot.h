//
//  MCSlot.h
//  Craftplayer
//
//  Created by qwertyoruiop on 25/04/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MCWindow.h"
#import "MCSocket.h"
@interface MCSlot : NSObject <NSStreamDelegate>
{
    MCWindow* window;
    int index;
    MCSocket* socket;
    id oldDelegate;
    NSMutableData* buffer;
    NSMutableDictionary* slotData;
}
@property(retain) MCWindow* window;
@property(assign) int index;
@property(retain) MCSocket* socket;
@property(retain) NSMutableDictionary* slotData;
@property(assign) id oldDelegate;
+(MCSlot*)slotWithWindow:(MCWindow*)awindow atPosition:(short)aindex withSocket:(MCSocket*)asocket;
@end
