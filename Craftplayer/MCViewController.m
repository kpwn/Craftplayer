//
//  MCViewController.m
//  Craftplayer
//
//  Created by qwertyoruiop on 23/04/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MCViewController.h"
#import "MCString.h"

@implementation MCViewController
@synthesize tv,tf;

-(IBAction)sendMessage:(id)sender
{
    m_char_t* text=[MCString MCStringFromString:[tf text]];
    unsigned char pckid=0x03;
    [[sock outputStream] write:&pckid maxLength:1];
    [[sock outputStream] write:(unsigned char*)text maxLength:m_char_t_sizeof(text)];
    free(text);
    [tf setText:@""];
}

- (void)packet:(MCPacket *)packet gotParsed:(NSDictionary *)infoDict
{
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
