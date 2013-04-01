//
//  caAppDelegate.h
//  MobileCPlusPlusCrossPlatform
//
//  Created by Shawn Campbell on 03/22/13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class caViewController;

@interface caAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) caViewController *viewController;

@property (strong, nonatomic) IBOutlet UIButton *send;

@property (strong, nonatomic) IBOutlet UITextField * toSendMessage;

@property (strong, nonatomic) IBOutlet UITextView * chatLog;

-(void)sendText:(NSString*)msg;

-(void)startChatThread;
@end