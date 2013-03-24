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

@implementation caAppDelegate
OpenGLSquare * square;

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
    square = new OpenGLSquare();
    NSString *vshader = @"attribute vec4 vPosition;\nattribute vec3 vColor;\nuniform mat4 mvp;\nvarying vec3 vvColor;\nvoid main() \n{\n    vvColor = vColor.xyz;\n    gl_Position = mvp * vPosition;\n}";
    NSString *fshader = @"uniform mediump float intensity;\nprecision mediump float;\nvarying vec3 vvColor;\nvoid main()\n{\n    gl_FragColor = vec4(vvColor.x,vvColor.y,vvColor.z,1.0);\n}";
    std::string * vshd = new std::string([vshader UTF8String]);
    std::string * fshd = new std::string([fshader UTF8String]);
    square->init((int)5,
            (int)5,
            *vshd,
            *fshd
    );
    NSThread* myThread = [[NSThread alloc] initWithTarget:self selector:@selector(doSquareStep) object:nil];
    [myThread start];
    return YES;
}


-(void)doSquareStep
{
    while(TRUE) {
        square->step();
    }
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