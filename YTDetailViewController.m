//
//  YTDetailViewController.m
//  The Search for BEER
//
//  Created by Grunt - Kerry on 1/27/13.
//  Copyright (c) 2013 Grunt Software. All rights reserved.
//

#import "YTDetailViewController.h"
#import "YTVideo.h"
#import "Comments.h"
#import "CommentsXMLParser.h"

@interface YTDetailViewController ()

@end

@implementation YTDetailViewController
@synthesize entryDetail,mainWebView,ythtml,vidTitle,_tableView,commentPosts,commentAuthor,commentText;
@synthesize parser;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
        [self.navigationController.navigationBar setHidden:NO];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    NSLog(@"YT HTML:%@",ythtml);
    NSLog(@"Raw Vid:%@",entryDetail.rawID);
    NSLog(@"Commenst Vid:%@",entryDetail.videoCommentsLink);

    
    
    
    NSString *youTubeCommentsURL = entryDetail.videoCommentsLink;
    NSData *data = [NSData dataWithContentsOfURL: [NSURL URLWithString:youTubeCommentsURL]];
    NSError *error;
    NSArray *json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
    
    NSLog(@"JSON Comments:%@",json);
    
    CGRect frame = CGRectMake(0, 0, 180, 44);
    UILabel *label = [[UILabel alloc] initWithFrame:frame];
    label.backgroundColor = [UIColor clearColor];
    label.font = [UIFont boldSystemFontOfSize:14];
    
    label.textColor = [UIColor whiteColor];
    label.shadowOffset = CGSizeMake(0,-1);
    label.shadowColor = [UIColor grayColor];
    
    label.textAlignment = NSTextAlignmentCenter;
    
    self.navigationItem.titleView = label;
    label.text = NSLocalizedString(@"In Search of BEER","");
    
    self.navigationController.navigationBar.tintColor = [UIColor blackColor];
    
    mainWebView = [[UIWebView alloc] initWithFrame:CGRectMake(40, 10, 240, 160)];
    mainWebView.opaque = NO;
    mainWebView.delegate = self;
    mainWebView.scalesPageToFit = YES;
    mainWebView.allowsInlineMediaPlayback = NO;
    [mainWebView loadHTMLString:ythtml baseURL:nil];
    
    [self.view addSubview:mainWebView];
    
    
    UILabel *videoTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 170, 300, 40)];
    videoTitleLabel.text = entryDetail.title;
    videoTitleLabel.numberOfLines = 2;
    videoTitleLabel.backgroundColor = [UIColor clearColor];
    videoTitleLabel.textAlignment = NSTextAlignmentCenter;
    videoTitleLabel.font = [UIFont fontWithName:@"HandOfSean" size:15];
    videoTitleLabel.textColor = [UIColor blackColor];
    [self.view addSubview:videoTitleLabel];
    
    UITextView *commentsView = [[UITextView alloc] initWithFrame:CGRectMake(10, 190, 300, 200)];
    
    commentsView = [[UITextView alloc] initWithFrame:CGRectMake(15, 490, 290, 140)];
    commentsView.backgroundColor = [UIColor clearColor];
    commentsView.font = [UIFont fontWithName:@"Arial" size:10];
    //commentsView.text = entryDetail.vi
    commentsView.editable = NO;
    commentsView.delegate = self;
    [self.view addSubview:commentsView];
    
    [self parseWithParserType];
    
    
  }

/////////Load the Comments



- (void)parseWithParserType{
    
    if (commentPosts == nil) {
        self.commentPosts = [NSMutableArray array];
    } else {
        [commentPosts removeAllObjects];
        [self._tableView reloadData];
    }
    // Determine the Class for the parser
    Class parserClass = [YTCommentsRSSParser class];
    //Class parserClass = [CommentsXMLParser class];
    
    // Create the parser, set its delegate, and start it.
    self.parser = [[parserClass alloc] init];
    parser.delegate = self;
    [parser start];
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
