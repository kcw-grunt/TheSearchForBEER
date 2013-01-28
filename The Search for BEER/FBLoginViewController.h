//
//  FBLoginViewController.h
//  eneedo BETA
//
//  Created by Grunt - Kerry on 10/24/12.
//  Copyright (c) 2012 eneedo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FacebookSDK/FacebookSDK.h>

@interface FBLoginViewController : UIViewController{

    FBSession *_session;
    UIButton *_logoutButton;
	NSString *_facebookName;
    
    

}
@property (nonatomic, retain) FBSession *session;
@property (nonatomic, copy) NSString *facebookName;

-(void)loginFB:(id)sender;

// FBSample logic
// This method should be called to indicate that a login which was in progress has
// resulted in a failure.
- (void)loginFailed;
@end
