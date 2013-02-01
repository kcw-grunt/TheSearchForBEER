//
//  FlipsideViewController.m
//  The Search for BEER
//
//  Created by Grunt - Kerry on 1/25/13.
//  Copyright (c) 2013 Grunt Software. All rights reserved.
//

#import "FlipsideViewController.h"
#import "AppDelegate.h"

@interface FlipsideViewController ()
{

    UISegmentedControl *orderSegmentedControl;

}

@property(nonatomic,strong) UISegmentedControl *orderSegmentedControl;
@end

@implementation FlipsideViewController
@synthesize orderSegmentedControl;

- (void)viewDidLoad
{
    [super viewDidLoad];
       
        
    UIImage *fbNormal = [UIImage imageNamed:@"login-button-small"];
    UIImage *fbPressed = [UIImage imageNamed:@"login-button-small-pressed"];

    UIButton *fbLogout = [[UIButton alloc] initWithFrame:CGRectMake(70, 60, 180, 45)];
    fbLogout.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
    fbLogout.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    [fbLogout setImage:fbNormal forState:UIControlStateNormal];
    [fbLogout setImage:fbPressed forState:UIControlStateSelected];
    
    
    UILabel *fbText =[[UILabel alloc]initWithFrame:CGRectMake(85, 12, 80, 20)];
    fbText.backgroundColor = [UIColor clearColor];
    fbText.font = [UIFont boldSystemFontOfSize:16];
    fbText.text = @"Logout";
    fbText.textColor = [UIColor whiteColor];
    [fbLogout addSubview:fbText];
    [fbLogout addTarget:self action:@selector(logoffFB:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:fbLogout];
    
    UIImageView *gruntLogoView = [[UIImageView alloc] initWithFrame:CGRectMake(180, 434, 175, 20)];
    gruntLogoView.contentMode = UIViewContentModeScaleAspectFit;
    gruntLogoView.image = [UIImage imageNamed:@"gruntsoftwarelogo"];
    [self.view addSubview:gruntLogoView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Actions

-(void)logoffFB:(id)sender{
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    if (FBSession.activeSession.isOpen) {
        [appDelegate closeSession];
    } else {
        [appDelegate openSessionWithAllowLoginUI:YES];
    }
    
}


- (IBAction)done:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
