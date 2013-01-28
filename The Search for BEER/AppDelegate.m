//
//  AppDelegate.m
//  The Search for BEER
//
//  Created by Grunt - Kerry on 1/25/13.
//  Copyright (c) 2013 Grunt Software. All rights reserved.
//

#import "AppDelegate.h"
#import "MainViewController.h"

static NSString *kAppId = @"371566789607204";
NSString *const TSFBSessionStateChangedNotification = @"com.grunt-software.com.The-Search-for-BEER:TSFBSessionStateChangedNotification";

@implementation AppDelegate
@synthesize session = _session;
@synthesize sessionDict;
@synthesize navController = _navController;
@synthesize loginViewController = _loginViewController;


#pragma mark -
#pragma mark Facebook Login Code

- (void)createAndPresentLoginView {
    if (self.loginViewController == nil) {
        self.loginViewController = [[FBLoginViewController alloc] init];
        UIViewController *topViewController = [self.navController topViewController];
        [topViewController presentViewController:self.loginViewController animated:NO completion:nil];
    }
}

- (void)showLoginView {
    if (self.loginViewController == nil) {
        [self createAndPresentLoginView];
    } else {
        [self.loginViewController loginFailed];
    }
}

- (void)sessionStateChanged:(FBSession *)session
                      state:(FBSessionState)state
                      error:(NSError *)error
{
    NSLog(@"Session Status: FBSessionState %@",[session description]);
    
    sessionDict = (NSMutableDictionary *)session;
    
    NSLog(@"Session Dict: FBSessionState %@",[sessionDict description]);
    
    
    switch (state) {
        case FBSessionStateOpen: {
            [self.mainViewController startLocationManager];

            if (self.loginViewController != nil) {
                UIViewController *topViewController = [self.navController topViewController];
                [topViewController dismissViewControllerAnimated:YES completion:nil];
                self.loginViewController = nil;
            }
            
            FBCacheDescriptor *cacheDescriptor = [FBFriendPickerViewController cacheDescriptor];
            [cacheDescriptor prefetchAndCacheForSession:session];
        }
            break;
        case FBSessionStateClosed: {
            NSLog(@"Session Closed: FBSessionState %@",[session description]);
            
            UIViewController *topViewController = [self.navController topViewController];
            UIViewController *presentViewController = [topViewController presentedViewController];
            if (presentViewController != nil) {
                [topViewController dismissViewControllerAnimated:YES completion:nil];
            }
            [self.navController popToRootViewControllerAnimated:NO];
            [FBSession.activeSession closeAndClearTokenInformation];
            
            [self performSelector:@selector(showLoginView)
                       withObject:nil
                       afterDelay:0.5f];
        }
            break;
        case FBSessionStateClosedLoginFailed: {
            [self performSelector:@selector(showLoginView)
                       withObject:nil
                       afterDelay:0.5f];
        }
            break;
        default:
            break;
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:TSFBSessionStateChangedNotification
                                                        object:session];
    if (error) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"Error: %@",[AppDelegate FBErrorCodeDescription:error.code]]
                                                            message:error.localizedDescription
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
        [alertView show];
    }
}

- (BOOL)openSessionWithAllowLoginUI:(BOOL)allowLoginUI {
    NSLog(@"allowLoginUI :%i",allowLoginUI);
    
    return [FBSession openActiveSessionWithReadPermissions:nil
                                              allowLoginUI:allowLoginUI
                                         completionHandler:^(FBSession *session, FBSessionState state, NSError *error) {
                                             [self sessionStateChanged:session state:state error:error];
                                         }];
}


+ (NSString *)FBErrorCodeDescription:(FBErrorCode) code {
    switch(code){
        case FBErrorInvalid :{
            return @"FBErrorInvalid";
        }
        case FBErrorOperationCancelled:{
            return @"FBErrorOperationCancelled";
        }
        case FBErrorLoginFailedOrCancelled:{
            return @"FBErrorLoginFailedOrCancelled";
        }
        case FBErrorRequestConnectionApi:{
            return @"FBErrorRequestConnectionApi";
        }case FBErrorProtocolMismatch:{
            return @"FBErrorProtocolMismatch";
        }
        case FBErrorHTTPError:{
            return @"FBErrorHTTPError";
        }
        case FBErrorNonTextMimeTypeReturned:{
            return @"FBErrorNonTextMimeTypeReturned";
        }
        case FBErrorNativeDialog:{
            return @"FBErrorNativeDialog";
        }
        default:
            return @"[Unknown]";
    }
}

- (void) closeSession {
    [FBSession.activeSession closeAndClearTokenInformation];
}

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation {
    // FBSample logic
    // We need to handle URLs by passing them to FBSession in order for SSO authentication
    // to work.
    NSLog(@"FBSession URL:%@",[url description]);
    NSLog(@"FBSession URL:%@",[url description]);
    return [FBSession.activeSession handleOpenURL:url];
}


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    self.mainViewController = [[MainViewController alloc] initWithNibName:@"MainViewController" bundle:nil];
    self.navController = [[UINavigationController alloc] initWithRootViewController:self.mainViewController];
    self.navController.navigationBar.barStyle=UIBarStyleBlack;
    self.window.rootViewController = self.navController;
    [self.window makeKeyAndVisible];
    
    // FBSample logic
    // See if we have a valid token for the current state.
    if (![self openSessionWithAllowLoginUI:NO]) {
        // No? Display the login page.
        [self showLoginView];
    }
    
    [self.window makeKeyAndVisible];
    return YES;
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
    // FBSample logic
    // We need to properly handle activation of the application with regards to SSO
    //  (e.g., returning from iOS 6.0 authorization dialog or from fast app switching).
    [FBSession.activeSession handleDidBecomeActive];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // FBSample logic
    // if the app is going away, we close the session object; this is a good idea because
    // things may be hanging off the session, that need releasing (completion block, etc.) and
    // other components in the app may be awaiting close notification in order to do cleanup
    [FBSession.activeSession close];
}

+ (AppDelegate *)sharedAppDelegate
{
    return (AppDelegate *) [UIApplication sharedApplication].delegate;
}

@end
