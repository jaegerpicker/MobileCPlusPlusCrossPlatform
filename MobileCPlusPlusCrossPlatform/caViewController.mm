//
//  caViewController.m
//  MobileCPlusPlusCrossPlatform
//
//  Created by Shawn Campbell on 03/22/13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#import "caViewController.h"
#import "caAppDelegate.h"


@interface caViewController ()

@end

@implementation caViewController
@synthesize send;
@synthesize chatLog;
@synthesize toSendMessage;
@synthesize scrollView;
caAppDelegate *appD;
- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    appD = [[UIApplication sharedApplication] delegate];
    appD.toSendMessage = toSendMessage;
    appD.chatLog = chatLog;
    [appD startChatThread];
    [self registerForKeyboardNotifications];
}

- (void)registerForKeyboardNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasShown:)
                                                 name:UIKeyboardDidShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification object:nil];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)sendText:(id)sender {
    if([toSendMessage.text length] > 0) {
        [appD sendText:toSendMessage.text];
        [toSendMessage setText:@""];
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return (toInterfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)keyboardWasShown:(NSNotification*)aNotification
{
    NSDictionary* info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, kbSize.height, 0.0);
    scrollView.contentInset = contentInsets;
    scrollView.scrollIndicatorInsets = contentInsets;
    
    // If active text field is hidden by keyboard, scroll it so it's visible
    // Your application might not need or want this behavior.
    CGRect aRect = self.view.frame;
    aRect.size.height -= kbSize.height;
    if (!CGRectContainsPoint(aRect, toSendMessage.frame.origin) ) {
        CGPoint scrollPoint = CGPointMake(0.0, toSendMessage.frame.origin.y-kbSize.height);
        [scrollView setContentOffset:scrollPoint animated:YES];
    }
}

- (void)keyboardWillBeHidden:(NSNotification*)aNotification
{
    UIEdgeInsets contentInsets = UIEdgeInsetsZero;
    scrollView.contentInset = contentInsets;
    scrollView.scrollIndicatorInsets = contentInsets;
}

@end