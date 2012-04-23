//
//  MCSocket.h
//  Craftplayer
//
//  Created by qwertyoruiop on 23/04/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MCAuth.h"
@interface MCSocket : NSObject <NSStreamDelegate>
{
    NSInputStream *inputStream;
    NSOutputStream *outputStream;
    MCAuth* auth;
}
@property(readonly) NSInputStream *inputStream;
@property(readonly) NSOutputStream *outputStream;
@property(readonly) MCAuth* auth;
@end
