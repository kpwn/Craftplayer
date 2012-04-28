//
//  MCViewController.m
//  Craftplayer
//
//  Created by qwertyoruiop on 23/04/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MCViewController.h"
#import "MCString.h"
#import "MCChatPacket.h"

@implementation MCViewController
@synthesize tv,tf;

-(IBAction)sendMessage:(id)sender
{
    [[MCChatPacket packetWithInfo:[NSDictionary dictionaryWithObjectsAndKeys:
                                  [tf text], @"Message"
                                   , nil]] sendToSocket:sock];
    [tf setText:@""];
}

- (void)slot:(MCSlot *)slot hasFinishedParsing:(NSDictionary *)infoDict
{
}
- (void)packet:(MCPacket *)packet gotParsed:(NSDictionary *)infoDict
{
    //NSLog(@"Got packet! %@", infoDict);
    if ([[infoDict objectForKey:@"PacketType"] isEqualToString:@"ChatMessage"]||[[infoDict objectForKey:@"PacketType"] isEqualToString:@"Disconnect"]) {
        NSArray* txt = [infoDict objectForKey:@"Message"];
        UIColor* color=nil;
        if (![[tv text] isEqualToString:@""]) {
            [[self tv] setText:[[[self tv] text] stringByAppendingString:@"\n"]];
        }
        if ([[infoDict objectForKey:@"PacketType"] isEqualToString:@"Disconnect"]) {
            [[self tv] setText:[[[self tv] text] stringByAppendingString:@"Disconnected: "]];
        }
        for (NSArray* message in txt) {
            for (NSString* tx in message) {
                if (!color) {
                    color=(UIColor*)tx;
                    continue;
                }
                [[self tv] setText:[[[self tv] text] stringByAppendingFormat:@"%@", tx]];
                color = nil;
            }

        }
        NSRange range = NSMakeRange(tv.text.length, 0);
        [tv scrollRangeToVisible:range];
    } 
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self sendMessage:nil];
    return NO;
}
- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    return NO;
}

- (void)viewWillAppear:(BOOL)animated
{
    sock = [[MCSocket alloc] initWithServer:@"176.31.64.248:25565" andAuth:[MCAuth authWithUsername:@"xpwn" andPassword:@"dummy"]];
    [sock setDelegate:self];
    [sock connect:NO];
    keyboardDoneButtonView=[[UIToolbar alloc] initWithFrame:CGRectMake(0, 200, 0, 0)];
    keyboardDoneButtonView.barStyle = UIBarStyleBlack;
    keyboardDoneButtonView.translucent = YES;
    keyboardDoneButtonView.tintColor = nil;
    [keyboardDoneButtonView sizeToFit];
    tf = [[UITextField alloc]initWithFrame:CGRectMake(30, 10, 300, 30)];
    tf.borderStyle = UITextBorderStyleRoundedRect;
    tf.autocorrectionType = UITextAutocorrectionTypeNo;
    tf.keyboardType = UIKeyboardTypeDefault;
    tf.returnKeyType = UIReturnKeySend;
    tf.clearButtonMode = UITextFieldViewModeWhileEditing;
    tf.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;    
    
    [tf setDelegate:self];
    [[self view] addSubview:keyboardDoneButtonView];
    UIBarButtonItem *textFieldItem = [[[UIBarButtonItem alloc] initWithCustomView:tf] autorelease];
    UIBarButtonItem *sp = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:NULL] autorelease];
    [keyboardDoneButtonView setItems:[NSArray arrayWithObjects:sp, textFieldItem, sp, nil]];
        
    // where masterTextField is the textField is the one you tap, and the keyboard rises up along with the small textField.
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didRotate:) name:@"UIDeviceOrientationDidChangeNotification" object:nil];
    [tf setKeyboardType:UIKeyboardTypeDefault];
	// Do any additional setup after loading the view, typically from a nib.
    [tf becomeFirstResponder];
}
- (void) didRotate:(NSNotification *)notification
{   
    UIDeviceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    
    if (orientation == UIDeviceOrientationLandscapeLeft || orientation == UIDeviceOrientationLandscapeRight)
    {
        CGRect tx = tv.frame;
        tx.size.height=106;
        tv.frame = tx;
        tf.frame = CGRectMake(30, 10, 460, 26);
        keyboardDoneButtonView.frame=CGRectMake(0, 106, 0, 0);
        [keyboardDoneButtonView sizeToFit];
    }
    else {
        CGRect tx = tv.frame;
        tx.size.height=200;
        tv.frame = tx;
        tf.frame = CGRectMake(30, 10, 300, 30);
        keyboardDoneButtonView.frame=CGRectMake(0, 200, 0, 0);
        [keyboardDoneButtonView sizeToFit];
    }
}
- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

@end
