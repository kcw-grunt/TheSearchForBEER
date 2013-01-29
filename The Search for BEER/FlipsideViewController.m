//
//  FlipsideViewController.m
//  The Search for BEER
//
//  Created by Grunt - Kerry on 1/25/13.
//  Copyright (c) 2013 Grunt Software. All rights reserved.
//

#import "FlipsideViewController.h"

@interface FlipsideViewController ()

@end

@implementation FlipsideViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    UILabel *segmentLabel =[[UILabel alloc]initWithFrame:CGRectMake(10, 45, 200, 40)];
    segmentLabel.backgroundColor = [UIColor clearColor];
    segmentLabel.font = [UIFont boldSystemFontOfSize:16];
    segmentLabel.text = @"Get results by:";
    segmentLabel.textColor = [UIColor whiteColor];

    [self.view addSubview:segmentLabel];
    
    
    UISegmentedControl *orderByPreference = [[UISegmentedControl alloc] initWithFrame:CGRectMake(14, 85, 290, 45)];
    //orderByPreference.tintColor = [UIColor colorWithRed:0.3 green:0.3 blue:0.3 alpha:1.0];
    orderByPreference.segmentedControlStyle = UISegmentedControlStyleBar;
    [orderByPreference insertSegmentWithTitle:@"Relevance" atIndex:0 animated:YES];
    [orderByPreference insertSegmentWithTitle:@"Published" atIndex:1 animated:YES];
    [orderByPreference insertSegmentWithTitle:@"Views" atIndex:2 animated:YES];
    [orderByPreference insertSegmentWithTitle:@"Rating" atIndex:3 animated:YES];
    [orderByPreference addTarget:self action:@selector(_setFeedPreference:) forControlEvents:UIControlEventValueChanged];
    [orderByPreference setSelectedSegmentIndex:0];
    
    [self.view addSubview:orderByPreference];
    
    
    UILabel *fbLabel =[[UILabel alloc]initWithFrame:CGRectMake(10, 135, 200, 40)];
    fbLabel.backgroundColor = [UIColor clearColor];
    fbLabel.font = [UIFont boldSystemFontOfSize:16];
    fbLabel.text = @"Logout:";
    fbLabel.textColor = [UIColor whiteColor];
    [self.view addSubview:fbLabel];
    
    UIImage *fbNormal = [UIImage imageNamed:@"login-button-small"];
    UIImage *fbPressed = [UIImage imageNamed:@"login-button-small-pressed"];

    UIButton *fbLogout = [[UIButton alloc] initWithFrame:CGRectMake(0, 175, 180, 45)];
    fbLogout.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
    fbLogout.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    [fbLogout setImage:fbNormal forState:UIControlStateNormal];
    [fbLogout setImage:fbPressed forState:UIControlStateSelected];

    [fbLogout addTarget:self action:@selector(logoutOfFB:) forControlEvents:UIControlEventTouchUpInside];
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


-(void)_setFeedPreference:(id)sender{




}

-(void)logoutOfFB:(id)sender{




}
- (IBAction)done:(id)sender
{
    [self.delegate flipsideViewControllerDidFinish:self];
}

@end
