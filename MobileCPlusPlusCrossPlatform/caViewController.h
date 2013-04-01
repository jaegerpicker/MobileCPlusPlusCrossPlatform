//
//  caViewController.h
//  MobileCPlusPlusCrossPlatform
//
//  Created by Shawn Campbell on 03/22/13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface caViewController : UIViewController
@property (strong, nonatomic) IBOutlet UIButton * send;
@property (strong, nonatomic) IBOutlet UITextView * chatLog;
@property (strong, nonatomic) IBOutlet UITextField * toSendMessage;
@property (strong, nonatomic) IBOutlet UIScrollView * scrollView;
-(IBAction)sendText:(id)sender;
@end