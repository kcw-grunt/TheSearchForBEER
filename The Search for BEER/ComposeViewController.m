//
//  ComposeViewController.m
//  The Search for BEER
//
//  Created by Grunt - Kerry on 1/28/13.
//  Copyright (c) 2013 Grunt Software. All rights reserved.
//

#import "ComposeViewController.h"
#import "YTDetailViewController.h"
@interface ComposeViewController ()
@end

@implementation ComposeViewController
@synthesize postView,postVideoEntry,delegate;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    //self.view.backgroundColor = [UIColor blackColor];

    UIBarButtonItem *cancelButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Cancel","") style: UIBarButtonItemStyleDone target:self action:@selector(cancelPost:)];
    self.navigationItem.leftBarButtonItem = cancelButtonItem;
    
    UIBarButtonItem *postToFB = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Post to Facebook","") style: UIBarButtonItemStyleDone target:self action:@selector(postToFacebook:)];
    self.navigationItem.rightBarButtonItem = postToFB;
    
    UIImageView *notesFrame = [[UIImageView  alloc] initWithFrame:CGRectMake(10, 20, 300, 200)];
    notesFrame.image=[UIImage imageNamed:@"notesbackground280x130"];
    [self.view addSubview:notesFrame];

    postView = [[UITextView alloc] initWithFrame:CGRectMake(20, 30, 290, 190)];
    postView.text = [NSString stringWithFormat:@"Check out this video I found using the new app 'The Search for BEER':\n %@\n", postVideoEntry.link];
    postView.backgroundColor = [UIColor clearColor];
    postView.textAlignment = NSTextAlignmentLeft;
    postView.font = [UIFont systemFontOfSize:11];
    postView.textColor = [UIColor blackColor];
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

-(void)postToFacebook:(id)sender{

    if([self.delegate respondsToSelector:@selector(composeViewController:didUpdateFBPost:)]){
        [self.delegate composeViewController:self didUpdateFBPost:postView.text];
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}


@end
