//
//  AppDelegate.m
//  pixnetfunapp
//
//  Created by Green on 13/7/24.
//  Copyright (c) 2013年 greenchiu. All rights reserved.
//

#import "AppDelegate.h"

#import "ViewController.h"
#import "FBManager.h"
NSString* const RequestFailureNotification = @"RequestFailureNotification";
@interface AppDelegate () <UIAlertViewDelegate>
- (void)handleRequestFailureNotification:(NSNotification*)notify;
@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleRequestFailureNotification:)
                                                 name:RequestFailureNotification
                                               object:nil];
    
    
    [FBManager startSession];
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.viewController = [[ViewController alloc] initWithNibName:@"ViewController" bundle:nil];
    UINavigationController* navigationController = [[UINavigationController alloc] initWithRootViewController:self.viewController];
    self.viewController = nil;
    
    self.window.rootViewController = navigationController;
    [self.window makeKeyAndVisible];
    return YES;
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
    return [FBManager handleOpenURL:url];
}

- (void)handleRequestFailureNotification:(NSNotification *)notify {
    UIAlertView* alert;
    alert = [[UIAlertView alloc] initWithTitle:@"request error"
                                       message:notify.object
                                      delegate:self
                             cancelButtonTitle:@"OK"
                             otherButtonTitles:nil];
    [alert show];
    alert = nil;
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"dismissalert"
                                                        object:nil];
}

@end
