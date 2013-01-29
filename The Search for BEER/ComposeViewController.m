//
//  ComposeViewController.m
//  The Search for BEER
//
//  Created by Grunt - Kerry on 1/28/13.
//  Copyright (c) 2013 Grunt Software. All rights reserved.
//

#import "ComposeViewController.h"

@interface ComposeViewController ()
@end

@implementation ComposeViewController
@synthesize postView,postVideoEntry;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
        self.view.backgroundColor = [UIColor blackColor];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIBarButtonItem *cancelButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Cancel","") style: UIBarButtonItemStyleDone target:self action:@selector(cancelPost:)];
    self.navigationItem.leftBarButtonItem = cancelButtonItem;
    
    UIBarButtonItem *postToFB = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Post to Facebook","") style: UIBarButtonItemStyleDone target:self action:@selector(postToFacebook:)];
    self.navigationItem.rightBarButtonItem = postToFB;

    postView = [[UITextView alloc] initWithFrame:CGRectMake(10, 40, 300, 200)];
    postView.text = [NSString stringWithFormat:@"Check out this video I found using the new app 'The Search for BEER':\n %@\n", postVideoEntry.link];
    postView.backgroundColor = [UIColor clearColor];
    postView.textAlignment = NSTextAlignmentLeft;
    postView.font = [UIFont boldSystemFontOfSize:13];
    postView.textColor = [UIColor whiteColor];
    postView.scrollEnabled = YES;
    postView.editable = YES;
    [self.view addSubview:postView];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)cancelPost:(id)sender{
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
}
@end
