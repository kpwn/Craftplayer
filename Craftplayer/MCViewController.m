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
        NSRange range = NSMakeRange(tv.text.length - 1, 1);
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
    [tf becomeFirstResponder];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    sock = [[MCSocket alloc] initWithServer:@"176.31.64.248:25565" andAuth:[MCAuth authWithUsername:@"xpwn" andPassword:@"dummy"]];
    [sock setDelegate:self];
    [sock connect:NO];
	// Do any additional setup after loading the view, typically from a nib.
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
