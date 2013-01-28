//
//  MainViewController.m
//  The Search for BEER
//
//  Created by Grunt - Kerry on 1/25/13.
//  Copyright (c) 2013 Grunt Software. All rights reserved.
//

#import "MainViewController.h"
#import "YTDetailViewController.h"
#import "YTProcessing.h"
#import "YTVideo.h"
#import "AppDelegate.h"


@interface MainViewController ()<UINavigationControllerDelegate,CLLocationManagerDelegate>{
UITableView *_tableView;
UISearchBar *_searchBarView;
    
    
NSMutableArray *videos;
NSMutableArray *sectionedVideos;
NSMutableArray *videoCategories;

    
}
@property (strong, nonatomic) FBUserSettingsViewController *settingsViewController;
@property (strong, nonatomic) FBCacheDescriptor *placeCacheDescriptor;
@property (strong, nonatomic) FBProfilePictureView *userProfileImage;
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) UILabel   *userNameLabel;


@property (nonatomic, retain) UITableView *_tableView;
@property (nonatomic, retain) UISearchBar *_searchBarView;

@property (nonatomic, retain) NSMutableArray *videos;
@property (nonatomic, retain) NSMutableArray *sectionedVideos;
@property (nonatomic, retain) NSMutableArray *videoCategories;

@property (strong, nonatomic) YTDetailViewController *detailViewController;


-(void)grabbingYouTubeResults:(NSString *)ytQuery;
-(void)setPlaceCacheDescriptorForCoordinates:(CLLocationCoordinate2D)coordinates;
@end

@implementation MainViewController
@synthesize userNameLabel = _userNameLabel;
@synthesize placeCacheDescriptor = _placeCacheDescriptor;
@synthesize userProfileImage = _userProfileImage;
@synthesize locationManager = _locationManager;
@synthesize session;
@synthesize _tableView,_searchBarView;
@synthesize videos,sectionedVideos,videoCategories;
@synthesize detailViewController;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"Challenge", @"Challenge");

    }
    return self;
}



- (void)viewDidLoad
{
    
    [super viewDidLoad];
    
    ////////////////////FB Blocks//////////////////////
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters;
    // We don't want to be notified of small changes in location, preferring to use our
    // last cached results, if any.
    self.locationManager.distanceFilter = 50;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(sessionStateChanged:)
                                                 name:TSFBSessionStateChangedNotification
                                               object:nil];
    
    [FBSession openActiveSessionWithAllowLoginUI:NO];
    
    if(FBSession.activeSession.isOpen){
        [[FBRequest requestForMe] startWithCompletionHandler:
         ^(FBRequestConnection *connection, NSDictionary<FBGraphUser> *user, NSError *error) {
             if (!error) {
                 self.userNameLabel.text = user.name;
                 self.userProfileImage.profileID = [user objectForKey:@"id"];
             }
         }];
        
        
    }
    

    

    
    ////////////////////FB Blocks//////////////////////

    
    sectionedVideos = [[NSMutableArray alloc] init];
    videos = [[NSMutableArray alloc] init];
    videoCategories = [[NSMutableArray alloc] init];
    
    _searchBarView = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
    _searchBarView.barStyle = UIBarStyleBlackTranslucent;
    _searchBarView.placeholder = @"BEER";
    _searchBarView.showsCancelButton=YES;
    _searchBarView.delegate=self;
    [self.view addSubview:_searchBarView];
    
    ///Setting up the default search////
    [self grabbingYouTubeResults:@"http://gdata.youtube.com/feeds/api/videos?q=BEER&max-results=50&alt=json"];
    
    //////Draw the table//////
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 45, 320, 345) style:UITableViewStylePlain];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.rowHeight = 50;
    [self.view addSubview:_tableView];
    
    UILabel *appNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(185, 396, 200, 15)];//(180, 440, 200, 15)];
    appNameLabel.font = [UIFont fontWithName:@"HandOfSean" size:11];
    appNameLabel.textColor = [UIColor whiteColor];
    appNameLabel.backgroundColor = [UIColor clearColor];
    appNameLabel.text = @"The Search for BEER";
    [self.view addSubview:appNameLabel];
    
    UIImageView *fbLogo = [[UIImageView alloc] initWithFrame:CGRectMake(30, 396, 16, 16)];
    fbLogo.image = [UIImage imageNamed:@"f_logo"];
    [self.view addSubview:fbLogo];
    
    _userNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(50, 400, 175, 10)];
    _userNameLabel.font = [UIFont systemFontOfSize:8.0];
    _userNameLabel.textColor = [UIColor whiteColor];
    _userNameLabel.backgroundColor = [UIColor clearColor];
    [self.view addSubview:_userNameLabel];
}


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


#pragma mark -
#pragma mark CLLocationManagerDelegate methods

- (void)startLocationManager {
    [self.locationManager startUpdatingLocation];
}

- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation {
    if (!oldLocation ||
        (oldLocation.coordinate.latitude != newLocation.coordinate.latitude &&
         oldLocation.coordinate.longitude != newLocation.coordinate.longitude &&
         newLocation.horizontalAccuracy <= 100.0)) {
            // Fetch data at this new location, and remember the cache descriptor.
            [self setPlaceCacheDescriptorForCoordinates:newLocation.coordinate];
            [self.placeCacheDescriptor prefetchAndCacheForSession:FBSession.activeSession];
        }
}

- (void)setPlaceCacheDescriptorForCoordinates:(CLLocationCoordinate2D)coordinates {
    //    self.placeCacheDescriptor =
    //    [FBPlacePickerViewController cacheDescriptorWithLocationCoordinate:coordinates
    //                                                        radiusInMeters:1000
    //                                                            searchText:@"restaurant"
    //                                                          resultsLimit:50
    //                                                      fieldsForRequest:nil];
}

- (void)locationManager:(CLLocationManager *)manager
       didFailWithError:(NSError *)error {
	NSLog(@"%@", error);
}


#pragma mark - Grab YT Data

-(void)grabbingYouTubeResults:(NSString *)ytQuery{
    
    NSLog(@"vidCat 0:%@",videoCategories.description);    
    ////Default search of 'BEER' popluates the table.  An new query reloads the table.////
    NSString *youTubeURL = ytQuery;
    NSData *data = [NSData dataWithContentsOfURL: [NSURL URLWithString:youTubeURL]];
    NSError *error;
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
    videos = [[json objectForKey:@"feed"]valueForKeyPath:@"entry"];
    videoCategories = [[[json objectForKey:@"feed"]valueForKeyPath:@"entry.category"]valueForKeyPath:@"term"];
    videoCategories = [YTProcessing cleanCategories:videoCategories];
    
    [_tableView beginUpdates];
    NSLog(@"vidCat 1:%@",videoCategories.description);
    for (int i=0; i< videoCategories.count;i++) {
        
        NSString *videoSectionTitleString = [videoCategories objectAtIndex:i];
        NSLog(@"vidCat Title:%@",videoSectionTitleString);
        NSMutableArray *newSectionArray = [[NSMutableArray alloc] init];
        
        NSLog(@"Videos Count:%i",videos.count);
        for (int k=0; k< videos.count;k++) {
            
            NSString *entryCat = [[[[videos objectAtIndex:k]valueForKeyPath:@"category"]valueForKeyPath:@"term"]objectAtIndex:1];
           NSLog(@"Videos Entry Cat:%@",entryCat);

            if([entryCat isEqualToString:videoSectionTitleString]){
                YTVideo *aVideo = [[YTVideo alloc] init];
                aVideo.videoID = [[videos objectAtIndex:k]valueForKeyPath:@"id.$t"];
                NSArray *videoIDComponents = [aVideo.videoID componentsSeparatedByString: @"/"];
                aVideo.rawID = [videoIDComponents objectAtIndex:6];
                aVideo.title = [[[videos objectAtIndex:k]valueForKey:@"title"]valueForKeyPath:@"$t"];
                aVideo.videoCategory = entryCat;
                aVideo.videoDescription = [[[videos objectAtIndex:k]valueForKeyPath:@"media$group.media$description"]valueForKey:@"$t"];
                aVideo.videoCommentsLink =[[videos objectAtIndex:k]valueForKeyPath:@"gd$comments.gd$feedLink.href"];
                //NSLog(@"Vid desc: %@",aVideo.videoDescription);
                /// YouTube serves up a special mobile URL
                /// Using it (index: 3) to improve preformance
                aVideo.link = [[[[videos objectAtIndex:k]valueForKey:@"link"]objectAtIndex:3]valueForKey:@"href"];
                aVideo.videosViewCounts = [[[videos objectAtIndex:k]valueForKey:@"yt$statistics"]valueForKeyPath:@"viewCount"];
                aVideo.thumblink = [[[[videos objectAtIndex:k]valueForKeyPath:@"media$group.media$thumbnail"]objectAtIndex:3]valueForKey:@"url"];
                //NSLog(@"video thumblink:%i %@",k,aVideo.thumblink);
                [newSectionArray addObject:aVideo];
            }

        }
        NSLog(@"newSectionArray:%@",newSectionArray.description);
        [sectionedVideos addObject:newSectionArray];
        
        //
//        //[_tableView reloadRowsAtIndexPaths:[NSArray arrayWithArray:indexPath] withRowAnimation:UITableViewRowAnimationFade];
//        [self._tableView reloadRowsAtIndexPaths:[NSArray arrayWithArray:indexPath] withRowAnimation:UITableViewRowAnimationFade];
       
    }
    
    [_tableView reloadData];
    [_tableView endUpdates];
}

#pragma mark - Search Bar Methods

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar{
    [searchBar resignFirstResponder];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    
    NSLog(@"Search Text:%@",searchBar.text);
    NSString *q = searchBar.text;
    NSString *qNewSearch =[NSString stringWithFormat:@"http://gdata.youtube.com/feeds/api/videos?q=%@&max-results=50&alt=json",q];
    [self grabbingYouTubeResults:qNewSearch];
    [searchBar resignFirstResponder];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    NSLog(@"VideoCategories Count:%i",[videoCategories count]);
    return [videoCategories count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    NSString *categoryTitle;
    categoryTitle = [videoCategories objectAtIndex:section];
    NSLog(@"Category Title:%@",categoryTitle);
    return categoryTitle;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 20;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 50;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSMutableArray *videosInSection = [sectionedVideos objectAtIndex:section];
    NSLog(@"videoInSection Count:%i",[videosInSection count]);
    return [videosInSection count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
        static NSUInteger const kVideoImageTag = 1;
        static NSUInteger const kVideoTitleTag = 2;
        static NSUInteger const kVideoDescriptionTag = 3; 
        static NSString *kYTVideosCellID = @"YTVideosCellID";
    
        YTVideo *cellVideoData;
        UIImageView *videoImageThumb;
        UILabel *videoTitle = nil;
        UILabel *videoDescription = nil;
    
        UIFont *specialFont = [UIFont fontWithName:@"HandOfSean" size:11];

        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kYTVideosCellID];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellAccessoryDetailDisclosureButton
                                          reuseIdentifier:kYTVideosCellID];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
            
            
            /////////////Setting Up the Custom Cell subviews//////////
            videoImageThumb = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 50, 50)];
            videoImageThumb.tag = kVideoImageTag;
            videoImageThumb.contentMode = UIViewContentModeScaleAspectFit;
            [cell.contentView addSubview:videoImageThumb];
            
            videoTitle = [[UILabel alloc] initWithFrame:CGRectMake(55, 2, 230, 18)];
            videoTitle.tag = kVideoTitleTag;
            videoTitle.backgroundColor = [UIColor clearColor];
            videoTitle.textColor = [UIColor blackColor];
            videoTitle.font = specialFont;
            [cell.contentView addSubview:videoTitle];
            
            videoDescription = [[UILabel alloc] initWithFrame:CGRectMake(55, 18, 220, 33)];
            videoDescription.tag = kVideoDescriptionTag;
            videoDescription.backgroundColor = [UIColor clearColor];
            videoDescription.textColor = [UIColor blackColor];
            videoDescription.font = [UIFont systemFontOfSize:9];
            videoDescription.numberOfLines = 2;
            [cell.contentView addSubview:videoDescription];
      }
    
    /////////////Locating and filling the YTVideo with per the categories array  and or the videos within//////////

    NSMutableArray *videosInSection = [sectionedVideos objectAtIndex:indexPath.section];
    cellVideoData = [videosInSection objectAtIndex:indexPath.row];
        
    /////Bonus!: Using FTWCache and a NSString Categories NSString+MD5. Open-Source Classes that improve scrolling with dynamic d/led images////
    NSString *key = [cellVideoData.thumblink MD5Hash] ;
    NSData *data = [FTWCache objectForKey:key];
    
        if (data) {
            UIImage *image = [UIImage imageWithData:data];
            videoImageThumb.image =image;
        } else {
            videoImageThumb.image = [UIImage imageNamed:@"grunt_G"];
            dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0ul);
            dispatch_async(queue, ^{
                NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:cellVideoData.thumblink]];
                [FTWCache setObject:data forKey:key];
                UIImage *image = [UIImage imageWithData:data];
                dispatch_async(dispatch_get_main_queue(), ^{
                    videoImageThumb.image = image;
                });
            });
        }
     
        videoTitle.text = cellVideoData.title;
        videoDescription.text = cellVideoData.videoDescription;
    
    return cell;
}



#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{

    
}
-(void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath{
    
    detailViewController = [[YTDetailViewController alloc] initWithNibName:@"YTDetailViewController" bundle:nil];
    YTVideo *selectedEntry = [[sectionedVideos objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    detailViewController.entryDetail = selectedEntry;
        
    NSString *htmlString;
    htmlString = [NSString stringWithFormat:@"<html><head><meta name = \"viewport\" content = \"initial-scale = 1.0, user-scalable = no, width = 240\"/></head><body style=\"background:#FF;margin-top:0px;margin-left:0px\"><div><object width=\"240\" height=\"160\"><param name=\"movie\" value=\"https://gdata.youtube.com/feeds/api/videos?q=oHg5SJYRHA0&key=AI39si4GV0fedGqKcdtl6AN-udUI4SvHuOygPf8f8OgRN0okeWpHoMqcB2_zI40A91yR0b0dkYgFOXJO3yrZ2nwtWxrz8cfsBA\"></param><param name=\"wmode\" value=\"transparent\"></param><embed src=\"http://www.youtube.com/v/%@&f=gdata_videos&c=ytapi-my-clientID&d=nGF83uyVrg8eD4rfEkk22mDOl3qUImVMV6ramM\"type=\"application/x-shockwave-flash\" wmode=\"transparent\" width=\"240\" height=\"160\"></embed></object></div></body></html>",selectedEntry.videoID];

    detailViewController.ythtml=htmlString;

    [self.navigationController pushViewController:detailViewController animated:YES];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Flipside View

- (void)flipsideViewControllerDidFinish:(FlipsideViewController *)controller
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)showInfo:(id)sender
{    
    FlipsideViewController *controller = [[FlipsideViewController alloc] initWithNibName:@"FlipsideViewController" bundle:nil];
    controller.delegate = self;
    controller.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    [self presentViewController:controller animated:YES completion:nil];
}

@end
