//
//  YTDetailViewController.m
//  The Search for BEER
//
//  Created by Grunt - Kerry on 1/27/13.
//  Copyright (c) 2013 Grunt Software. All rights reserved.
//

#import "YTDetailViewController.h"
#import "Comments.h"
#import "CommentsXMLParser.h"
#import "AppDelegate.h"
#import "ComposeViewController.h"


@interface YTDetailViewController ()

@property (strong, nonatomic) FBUserSettingsViewController *settingsViewController;
@property (strong, nonatomic) FBCacheDescriptor *placeCacheDescriptor;
@property (strong, nonatomic) FBProfilePictureView *userProfileImage;
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) UILabel   *userNameLabel;

@end

@implementation YTDetailViewController
@synthesize entryDetail,mainWebView,ythtml,vidTitle,_tableView,commentPosts,commentAuthor,commentText;
@synthesize parser;
@synthesize userNameLabel = _userNameLabel;
@synthesize placeCacheDescriptor = _placeCacheDescriptor;
@synthesize userProfileImage = _userProfileImage;
@synthesize locationManager = _locationManager;
@synthesize session;
@synthesize ytCommentData,commentsFeedConnection,parseQueue;


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
    
    
   // NSLog(@"YT HTML:%@",ythtml);
    NSLog(@"Raw Vid:%@",entryDetail.rawID);
    NSLog(@"Commenst Vid:%@",entryDetail.videoCommentsLink);

    
    NSString *feedURLString = entryDetail.videoCommentsLink;
    
    NSURLRequest *commentsURLRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:feedURLString]];
    self.commentsFeedConnection = [[NSURLConnection alloc] initWithRequest:commentsURLRequest delegate:self];
    // Test the validity of the connection object. The most likely reason for the connection object
    // to be nil is a malformed URL, which is a programmatic error easily detected during development.
    // If the URL is more dynamic, then you should implement a more flexible validation technique,
    // and be able to both recover from errors and communicate problems to the user in an
    // unobtrusive manner.
    NSAssert(self.commentsFeedConnection != nil, @"Failure to create URL connection.");
    
    // Start the status bar network activity indicator. We'll turn it off when the connection
    // finishes or experiences an error.
    
       
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
    videoTitleLabel.font = [UIFont boldSystemFontOfSize:14];
    videoTitleLabel.textColor = [UIColor blackColor];
    [self.view addSubview:videoTitleLabel];
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(5, 210, 310, 190) style:UITableViewStylePlain
                     ];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.rowHeight = 60;
    _tableView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:_tableView];
        
    if(FBSession.activeSession.isOpen){
        [[FBRequest requestForMe] startWithCompletionHandler:
         ^(FBRequestConnection *connection, NSDictionary<FBGraphUser> *user, NSError *error) {
             if (!error) {
                 self.userNameLabel.text = user.name;
                 self.userProfileImage.profileID = [user objectForKey:@"id"];
             }else{
             
             }
         }];
    }
        
     
    
    UIView *fbFrameStatusView = [[UIView alloc] initWithFrame:CGRectMake(2, 400, 180, 44)];
    
    _userNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(34, 18, 200, 10)];
    _userNameLabel.font = [UIFont systemFontOfSize:8.0];
    _userNameLabel.textColor = [UIColor whiteColor];
    _userNameLabel.backgroundColor = [UIColor clearColor];
    [fbFrameStatusView addSubview:_userNameLabel];
    
    
    _userProfileImage = [[FBProfilePictureView alloc] init];
    _userProfileImage.frame = CGRectMake(0, 7, 30, 30);
    [fbFrameStatusView addSubview:_userProfileImage];
    
    UIImageView *fbLogo = [[UIImageView alloc] initWithFrame:CGRectMake(20, 26, 13, 13)];
    fbLogo.image = [UIImage imageNamed:@"f_logo"];
    [fbFrameStatusView addSubview:fbLogo];
    
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 135, 44)];
    label.backgroundColor = [UIColor clearColor];
    
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithCustomView:label];    
    label.text = @"Share to Facebook";
    label.textAlignment=NSTextAlignmentRight;
    label.textColor = [UIColor whiteColor];
    label.font = [UIFont boldSystemFontOfSize:12];
    
    
        
    UIBarButtonItem *fbUser = [[UIBarButtonItem alloc] initWithCustomView:fbFrameStatusView];
    UIBarButtonItem *compose = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(shareYTonUserFBWallClick:)];
    UIBarButtonItem *flexspace2 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    
    NSArray *toolbarItems = [[NSArray alloc] initWithObjects:fbUser,flexspace2,item,compose, nil];
    UIToolbar *shareToolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 380, 320, 44)];
    shareToolbar.items = toolbarItems;
    shareToolbar.tintColor = [UIColor blackColor];
    shareToolbar.translucent = NO;
    [self.view addSubview:shareToolbar];
    
    [self parseWithParserType:XMLParserTypeNSXMLParser];
    
    
  }

/////////Load the Comments

- (void)parseWithParserType:(XMLParserType)parserType{
    
    if (commentPosts == nil) {
        self.commentPosts = [NSMutableArray array];
    } else {
        [commentPosts removeAllObjects];
        [self._tableView reloadData];
    }
    // Determine the Class for the parser
    Class parserClass = nil;

    parserClass = [CommentsXMLParser class];
    
    // Create the parser, set its delegate, and start it.
    self.parser = [[parserClass alloc] init];
    parser.delegate = self;
    [parser start:entryDetail.videoCommentsLink];
    
}

#pragma mark <RSSParserDelegate> Implementation

- (void)parserDidEndParsingData:(YTCommentsRSSParser *)parser {
    [self._tableView reloadData];
    self.parser = nil;
   // [loadingIndicator stopAnimating];
}

- (void)parser:(YTCommentsRSSParser *)parser didParseComments:(NSArray *)parsedCommments{
    [commentPosts addObjectsFromArray:parsedCommments];
    if(_tableView.dragging && !self._tableView.tracking && !self._tableView.decelerating){
        [self._tableView reloadData];
    }
}

- (void)parser:(YTCommentsRSSParser *)parser didFailWithError:(NSError *)error {
    
    NSString *titleString = @"Connection Error:";
    NSString *messageString = @"Please check Internet access.";
    //    NSString *moreString = [error localizedFailureReason] ?
    //    [error localizedFailureReason] :
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:titleString
                                                        message:messageString delegate:self
                                              cancelButtonTitle:@"Cancel" otherButtonTitles:nil];
    [alertView show]; 
}


#pragma mark -
#pragma mark - FBUserSettingsDelegate methods

- (void)sessionStateChanged:(NSNotification*)notification {
}

- (void)loginViewController:(id)sender receivedError:(NSError *)error{
    if (error) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"Error: %@",
                                                                     [AppDelegate FBErrorCodeDescription:error.code]]
                                                            message:error.localizedDescription
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
        [alertView show];
    }
}
// Convenience method to perform some action that requires the "publish_actions" permissions.
- (void) performPublishAction:(void (^)(void)) action {
    // we defer request for permission to post to the moment of post, then we check for the permission
    if ([FBSession.activeSession.permissions indexOfObject:@"publish_actions"] == NSNotFound) {
        // if we don't already have the permission, then we request it now
        [FBSession.activeSession reauthorizeWithPublishPermissions:[NSArray arrayWithObject:@"publish_actions"]
                                                   defaultAudience:FBSessionDefaultAudienceFriends
                                                 completionHandler:^(FBSession *session, NSError *error) {
                                                     if (!error) {
                                                         action();
                                                     }
                                                     //For this example, ignore errors (such as if user cancels).
                                                 }];
    } else {
        action();
    }
    
}


-(void)composeMessageForFB:(UIButton *)sender{
      
        ComposeViewController *cvc = [[ComposeViewController alloc] initWithNibName:@"ComposeViewController" bundle:nil];
        cvc.postVideoEntry = entryDetail;
        NSLog(@"cvc: %@",cvc.postVideoEntry.link);
    
        UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:cvc];
        [navController setNavigationBarHidden: NO];
        navController.navigationBar.barStyle = UIBarStyleBlack;
        navController.navigationBar.tintColor = [UIColor blackColor];
        
        navController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
        [self presentViewController:navController animated:YES completion:nil];
}



- (void)shareYTonUserFBWallClick:(UIButton *)sender {
    ///still debugging the post view controller composeMessage forFB.  For now it is a static post.
    
    // Post a status update to the user's feed via the Graph API, and display an alert view
    // with the results or an error.
        
    NSString *message = [NSString stringWithFormat:@"Check out this video I found using the new app 'The Search for BEER': %@",entryDetail.link];
    NSString *messageTitle =[NSString stringWithFormat:@"posted: '%@' to Facebook.",entryDetail.title];
    // if it is available to us, we will post using the native dialog
    BOOL displayedNativeDialog = [FBNativeDialogs presentShareDialogModallyFrom:self
                                                                    initialText:nil
                                                                          image:nil
                                                                            url:nil
                                                                        handler:nil];
    if (!displayedNativeDialog) {
        
        [self performPublishAction:^{
            // otherwise fall back on a request for permissions and a direct post
            [FBRequestConnection startForPostStatusUpdate:message
                                        completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
                                            
                                            [self showAlert:messageTitle result:result error:error];
                                        }];
            
        }];
    }
}

// UIAlertView helper for post buttons
- (void)showAlert:(NSString *)message
           result:(id)result
            error:(NSError *)error {
    
    NSString *alertMsg;
    NSString *alertTitle;
    if (error) {
        alertMsg = error.localizedDescription;
        alertTitle = @"Error";
    } else {
        alertMsg = [NSString stringWithFormat:@"Successfully %@",
                    message];
        alertTitle = @"Success";
    }
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:alertTitle
                                                        message:alertMsg
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
    [alertView show];
}


#pragma mark -
#pragma mark UITableViewDelegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return [commentPosts count];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    NSString *vC = @"Video Comments:";
    return vC;
}


//
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    // Each subview in the cell will be identified by a unique tag.
    static NSUInteger const kAuthorLabelTag = 2;
    static NSUInteger const kCommentLabelTag = 3;
    // Declare references to the subviews which will display the earthquake data.
    UILabel *authorLabel = nil;
    UILabel *commentLabel = nil;
    
	static NSString *kCommentsCellID = @"CommentsCellID";
  	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCommentsCellID];
	if (cell == nil) {
        // No reusable cell was available, so we create a new cell and configure its subviews.
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                       reuseIdentifier:kCommentsCellID];
        
        authorLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 3, 130, 12)];
        authorLabel.tag = kAuthorLabelTag;
        authorLabel.font = [UIFont systemFontOfSize:10];
        authorLabel.textColor = [UIColor grayColor];
        authorLabel.textAlignment = NSTextAlignmentLeft;
        authorLabel.backgroundColor = [UIColor clearColor];
        [cell.contentView addSubview:authorLabel];
        
        commentLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 14, 290, 40)];
        commentLabel.tag = kCommentLabelTag;
        commentLabel.font = [UIFont systemFontOfSize:10.5];
        commentLabel.textAlignment = NSTextAlignmentLeft;
        commentLabel.numberOfLines = 3;
        commentLabel.backgroundColor = [UIColor clearColor];
        [cell.contentView addSubview:commentLabel];
    
    } else {
        // A reusable cell was available, so we just need to get a reference to the subviews
        // using their tags.
        //
        authorLabel = (UILabel *)[cell.contentView viewWithTag:kAuthorLabelTag];
        commentLabel = (UILabel *)[cell.contentView viewWithTag:kCommentLabelTag];
        
    }
    
    // Get the specific newslines for this row.
    // Set the relevant data for each subview in the cell.
    authorLabel.text = [NSString stringWithFormat:@"%@:",[[commentPosts objectAtIndex:indexPath.row] author]];
    commentLabel.text = [[commentPosts objectAtIndex:indexPath.row] content];
    	
    return cell;
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
