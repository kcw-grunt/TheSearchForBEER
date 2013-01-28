//
//  MainViewController.h
//  The Search for BEER
//
//  Created by Grunt - Kerry on 1/25/13.
//  Copyright (c) 2013 Grunt Software. All rights reserved.
//

#import "FlipsideViewController.h"
#import "FTWCache.h"
#import "NSString+MD5.h"
#import <FacebookSDK/FacebookSDK.h>

@interface MainViewController : UIViewController <FlipsideViewControllerDelegate, UITableViewDataSource, UITableViewDelegate,UISearchBarDelegate,UISearchDisplayDelegate>{
FBSession *session;
}
@property (strong, nonatomic) FBSession *session;

- (void)startLocationManager;
- (IBAction)showInfo:(id)sender;

@end
