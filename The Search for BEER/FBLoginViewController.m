//
//  FBLoginViewController.m
//  eneedo BETA
//
//  Created by Grunt - Kerry on 10/24/12.
//  Copyright (c) 2012 eneedo. All rights reserved.
//

#import "FBLoginViewController.h"
#import "AppDelegate.h"

@interface FBLoginViewController ()
@property (strong, nonatomic) UIActivityIndicatorView *activityIndicator;

@end

@implementation FBLoginViewController
@synthesize activityIndicator = _activityIndicator;
@synthesize session = _session;
@synthesize facebookName = _facebookName;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)loadView
{

    UIView *view = [[UIView alloc] initWithFrame:[UIScreen
                                                  mainScreen].applicationFrame];
    UIImageView *posterView = [[UIImageView alloc] initWithFrame:[UIScreen
                                                                 mainScreen].applicationFrame];
    posterView.image = [UIImage imageNamed:@"launch320x4802"];
    
    [view addSubview:posterView];
    
    UIButton *fbLoginButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    fbLoginButton.frame = CGRectMake(60, 240, 200, 43);
    [fbLoginButton setTitle:@"Connect with Facebook" forState:UIControlStateNormal];
    [fbLoginButton addTarget:self action:@selector(loginFB:) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:fbLoginButton];
    
    
    _activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    _activityIndicator.frame = CGRectMake(140, 380, 40, 40);
    [view addSubview:_activityIndicator];
    
    
    self.view = view;
    
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.activityIndicator stopAnimating];
}

- (void)loginFailed {
    // FBSample logic
    // Our UI is quite simple, so all we need to do in the case of the user getting
    // back to this screen without having been successfully authorized is to
    // stop showing our activity indicator. The user can initiate another login
    // attempt by clicking the Login button again.
    [self.activityIndicator stopAnimating];
}



-(void)loginFB:(id)sender{
    
    [self.activityIndicator startAnimating];
    
    // FBSample logic
    // The user has initiated a login, so call the openSession method.
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate openSessionWithAllowLoginUI:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
