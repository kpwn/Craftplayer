//
//  MCViewController.h
//  Craftplayer
//
//  Created by qwertyoruiop on 23/04/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MCAuth.h"
#import "MCSocket.h"
#import "MCSocketDelegate.h"

@interface MCViewController : UIViewController <MCSocketDelegate>
{
    UITextView* tv;
    UITextField* tf;
    MCSocket* sock;
}
@property(retain) IBOutlet UITextView* tv;
@property(retain) IBOutlet UITextField* tf;
-(IBAction)sendMessage:(id)sender;
@end
