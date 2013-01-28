//
//  AppDelegate.h
//  The Search for BEER
//
//  Created by Grunt - Kerry on 1/25/13.
//  Copyright (c) 2013 Grunt Software. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FBLoginViewController.h"
#import <FacebookSDK/FacebookSDK.h>

extern NSString *const TSFBSessionStateChangedNotification;
@class MainViewController;

@interface AppDelegate : UIResponder <UIApplicationDelegate>{


 NSMutableDictionary *sessionDict;

}

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) MainViewController *mainViewController;
@property (strong, nonatomic) FBSession *session;
@property (retain, nonatomic) NSMutableDictionary *sessionDict;
@property (strong, nonatomic) FBLoginViewController *loginViewController;
@property (strong, nonatomic) UINavigationController *navController;


// FBSample logic
// The app delegate is responsible for maintaining the current FBSession. The application requires
// the user to be logged in to Facebook in order to do anything interesting -- if there is no valid
// FBSession, a login screen is displayed.
- (BOOL)openSessionWithAllowLoginUI:(BOOL)allowLoginUI;
+ (NSString *)FBErrorCodeDescription:(FBErrorCode) code;
- (void) closeSession;
- (void)showLoginView;

@end
