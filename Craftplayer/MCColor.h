//
//  MCColor.h
//  Craftplayer
//
//  Created by qwertyoruiop on 24/04/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MCColor : UIColor
+(UIColor*)colorWithCode:(char)code;
+(UIColor*)shadowForCode:(char)code;
@end
