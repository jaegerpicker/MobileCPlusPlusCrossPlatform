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
OpenGLSquare * square;
int force_exit = 0;
std::string * sendBuf = new std::string("0");

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        self.viewController = [[caViewController alloc] initWithNibName:@"caViewController_iPhone" bundle:nil];
    } else {
        self.viewController = [[caViewController alloc] initWithNibName:@"caViewController_iPad" bundle:nil];
    }
    //self.window.rootViewController = self.viewController;
    //[self.window makeKeyAndVisible];
    //square = new OpenGLSquare();
    //NSString *vshader = @"attribute vec4 vPosition;\nattribute vec3 vColor;\nuniform mat4 mvp;\nvarying vec3 vvColor;\nvoid main() \n{\n    vvColor = vColor.xyz;\n    gl_Position = mvp * vPosition;\n}";
    //NSString *fshader = @"uniform mediump float intensity;\nprecision mediump float;\nvarying vec3 vvColor;\nvoid main()\n{\n    gl_FragColor = vec4(vvColor.x,vvColor.y,vvColor.z,1.0);\n}";
    //std::string * vshd = new std::string([vshader UTF8String]);
    //std::string * fshd = new std::string([fshader UTF8String]);
    //square->init((int)5,
    //        (int)5,
    //        *vshd,
    //        *fshd
    //);
    //NSThread* myThread = [[NSThread alloc] initWithTarget:self selector:@selector(doSquareStep) object:nil];
    //[myThread start];
    NSThread * wsThread = [[NSThread alloc] initWithTarget:self selector:@selector(wsComms) object:nil];
    [wsThread start];
    return YES;
    sendBuf = new std::string("testing the global buffer");
}


-(void)doSquareStep
{
    while(TRUE) {
        square->step();
    }
}

//#define MAX_CHAT_PAYLOAD 1400

/*struct per_session_data__chat {
	unsigned char buf[LWS_SEND_BUFFER_PRE_PADDING + MAX_CHAT_PAYLOAD + LWS_SEND_BUFFER_POST_PADDING];
	unsigned int len;
	unsigned int index;
};



static int
callback_chat(struct libwebsocket_context *context, struct libwebsocket *wsi, enum libwebsocket_callback_reasons reason, void *user, void * in, size_t len) {
    struct per_session_data__chat *pss = (struct per_session_data__chat *)user;
    int n;
    
    switch(reason) {
        case LWS_CALLBACK_SERVER_WRITEABLE:
            n = libwebsocket_write(wsi, &pss->buf[LWS_SEND_BUFFER_PRE_PADDING], pss->len, LWS_WRITE_HTTP);
            if (n < 0) {
                lwsl_err("ERROR %d writing to socket, hanging up\n", n);
                return 1;
            }
            if (n < pss->len) {
                lwsl_err("Partial write\n");
                return -1;
            }
            break;
            
        case LWS_CALLBACK_RECEIVE:
            if (len > MAX_CHAT_PAYLOAD) {
                lwsl_err("Server received packet bigger than %u, hanging up\n", MAX_CHAT_PAYLOAD);
                return 1;
            }
            memcpy(&pss->buf[LWS_SEND_BUFFER_PRE_PADDING], in, len);
            pss->len = len;
            libwebsocket_callback_on_writable(context, wsi);
            break;
        case LWS_CALLBACK_CLIENT_ESTABLISHED:
            lwsl_notice("Client had connected\n");
            pss->index = 0;
            break;
        case LWS_CALLBACK_CLIENT_RECEIVE:
            lwsl_notice("Client RX: %s", (char *)in);
            break;
        case LWS_CALLBACK_CLIENT_WRITEABLE:
            pss->len = sprintf((char *)&pss->buf[LWS_SEND_BUFFER_PRE_PADDING], "hello form libwebsocket-test-chat client pid %d index %d\n", getpid(), pss->index++);
            lwsl_notice("Client TX: %s", &pss->buf[LWS_SEND_BUFFER_PRE_PADDING]);
            n = libwebsocket_write(wsi, &pss->buf[LWS_SEND_BUFFER_PRE_PADDING], pss->len, LWS_WRITE_HTTP);
            if(n < 0) {
                lwsl_err("ERROR %d writing to socket, hanging up\n", n);
                return -1;
            }
            if(n < pss->len) {
                lwsl_err("Partial write\n");
                return -1;
            }
            break;
        default:
            break;
    }
    return 0;
}

static struct libwebsocket_protocols protocols[] = {
    
	{
		"default",
		callback_chat,
		sizeof(struct per_session_data__chat)
	},
	{
		NULL, NULL, 0
	}
};

void sighandler(int sig)
{
	force_exit = 1;
}*/

-(void)wsComms
{
    /*int n = 0;
    int port = 8765;
    const char* address = "192.168.0.8";
    int use_ssl = 0;
    int opts = 0;
    int listen_port = CONTEXT_PORT_NO_LISTEN;
    int syslog_options = LOG_PID | LOG_PERROR;
    int debug_level = 7;
    int client = 1;
    int rate_us = 250000;
	unsigned int oldus = 0;
    const char *interface = NULL;
    char interface_name[128] = "";
    struct libwebsocket_context *context;
    struct libwebsocket *wsi;
    struct lws_context_creation_info info;
    
    std::memset(&info, 0, sizeof( info));
    setlogmask(LOG_UPTO(LOG_DEBUG));
    openlog("lwsts", syslog_options, LOG_DEBUG);
    
    lws_set_log_level(debug_level, lwsl_emit_syslog);
    
    info.port = port;
    info.iface = interface;
    info.protocols = protocols;
    info.gid = -1;
    info.uid = -1;
    info.options = opts;
    
    context = libwebsocket_create_context(&info);
    if(context == NULL) {
        lwsl_err("libwebsocket init failed");
        return;
    }
    lwsl_notice("Client connecting to %s:%u....\n", address, port);

    wsi = libwebsocket_client_connect(context, address,
                                      port, use_ssl, "/chatsocket", address,
                                      "origin", NULL, -1);
    if (!wsi) {
        lwsl_err("Client failed to connect to %s:%u\n", address, port);
        return;
    }
    lwsl_notice("Client connected to %s:%u\n", address, port);
    
    signal(SIGINT, sighandler);
    n = 0;
    while(n >= 0 && !force_exit) {
        struct timeval tv;
        gettimeofday(&tv, NULL);
        
        if(((unsigned int)tv.tv_usec - oldus) > rate_us) {
            libwebsocket_callback_on_writable_all_protocol(&protocols[0]);
            oldus = tv.tv_usec;
        }
    }
    
    libwebsocket_context_destroy(context);
    
	lwsl_notice("libwebsockets-test-chat exited cleanly\n");
    
	closelog();
    
	return;*/
    using easywsclient::WebSocket;
    WebSocket::pointer ws = WebSocket::from_url("ws://192.168.0.8:8765/chatsocket");
    //assert(ws);
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    
    [dict setValue:@"hello" forKey:@"body"];
    NSError *jsonError = nil;
    NSData * jsonData = [NSJSONSerialization dataWithJSONObject:dict options:0 error:&jsonError];
    NSString* jsonString = [[NSString alloc] initWithData:jsonData encoding:NSASCIIStringEncoding];
    std::string toSend = *new std::string([jsonString UTF8String]);
    ws->send(toSend);
    //ws->send("{'body':'goodbye'}");
    //ws->send("{'body':'hello'}");
    while (true) {
        std::string message;
        if(strncmp(sendBuf->c_str(),"0", sizeof(sendBuf->c_str()))) {
            [dict removeAllObjects];
            [dict setValue:[NSString stringWithCString:sendBuf->c_str()] forKey:@"body"];
            jsonData = [NSJSONSerialization dataWithJSONObject:dict options:0 error:&jsonError];
            jsonString = [[NSString alloc] initWithData:jsonData encoding:NSASCIIStringEncoding];
            toSend = *new std::string([jsonString UTF8String]);
            ws->send(toSend);
            sendBuf = new std::string("0");
        }
        //ws->send("{'body':'loop'}");
        
        ws->poll();
        ws->dispatch([&message](const std::string & message_) {
            printf(">>> %s\n", message_.c_str());
            message = message_;
        });
        if (message == "world") { break; }
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