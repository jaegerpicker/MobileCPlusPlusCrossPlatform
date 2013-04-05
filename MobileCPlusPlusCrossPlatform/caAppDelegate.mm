//
//  caAppDelegate.m
//  MobileCPlusPlusCrossPlatform
//
//  Created by Shawn Campbell on 03/22/13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#import "caAppDelegate.h"

#import "caViewController.h"
#import "OpenGLSquare.h"
#import "string.h"
#import "easywsclient.hpp"
#import "libwebsockets.h"
#import <assert.h>
#import <stdio.h>
#import "syslog.h"

@implementation caAppDelegate
@synthesize toSendMessage;
@synthesize send;
@synthesize chatLog;
OpenGLSquare * square;
int force_exit = 0;
std::string * sendBuf = new std::string("0");
BOOL newmessage = false;

-(void)sendText:(NSString *)msg {
    sendBuf->assign([msg UTF8String]);
    newmessage = true;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        self.viewController = [[caViewController alloc] initWithNibName:@"caViewController_iPhone" bundle:nil];
    } else {
        self.viewController = [[caViewController alloc] initWithNibName:@"caViewController_iPad" bundle:nil];
    }
    self.window.rootViewController = self.viewController;
    [self.window makeKeyAndVisible];
    return YES;
    
}

-(void)startChatThread {
    NSThread * wsThread = [[NSThread alloc] initWithTarget:self selector:@selector(wsComms) object:nil];
    [wsThread start];
    sendBuf->assign("testing the global buffer");
    newmessage = true;
}

-(void)wsComms
{
    using easywsclient::WebSocket;
    WebSocket::pointer ws = WebSocket::from_url("ws://10.151.37.36:8765/chatsocket");
    //assert(ws);
    NSString * jsonString = jsonify(new std::string("Hello"));
    std::string toSend = *new std::string([jsonString UTF8String]);
    ws->send(toSend);
    //ws->send("{'body':'goodbye'}");
    //ws->send("{'body':'hello'}");
    //std::string * compare = new std::string("0");
    while (true) {
        std::string message;
        if(newmessage) {
            jsonString = jsonify(sendBuf);
            toSend = *new std::string([jsonString UTF8String]);
            ws->send(toSend);
            sendBuf->assign("0");
            newmessage = false;
        }
        //ws->send("{'body':'loop'}");
        
        ws->poll();
        ws->dispatch([&message](const std::string & message_) {
            printf(">>> %s\n", message_.c_str());
            message = message_;
        });
        if(message.length() > 0) {
            NSString * mess = [[NSString alloc] initWithCString:(&message)->c_str()];
            NSError * jErr = nil;
            NSData * messData = [mess dataUsingEncoding:NSUnicodeStringEncoding];
            NSDictionary * jdict = [NSJSONSerialization JSONObjectWithData:messData options:0 error:&jErr];
            NSString * body = [[NSString alloc] initWithString:[jdict objectForKey:@"body"]];
            [chatLog performSelectorOnMainThread:@selector(setText:) withObject:[NSString stringWithFormat:@"%@ \n %@", chatLog.text, body] waitUntilDone:YES];
        }
        if (message == "world") { break; }
    }
}

NSString *jsonify(std::string *pre) {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict removeAllObjects];
    NSError *jsonError = nil;
    [dict setValue:[NSString stringWithCString:pre->c_str()] forKey:@"body"];
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:0 error:&jsonError];
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSASCIIStringEncoding];
    return jsonString;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.

}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.

}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.

}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.

}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.

}

@end