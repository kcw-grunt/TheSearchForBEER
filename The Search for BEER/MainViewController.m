//
//  MainViewController.m
//  The Search for BEER
//
//  Created by Grunt - Kerry on 1/25/13.
//  Copyright (c) 2013 Grunt Software. All rights reserved.
//

#import "MainViewController.h"
#import "BeerCategoryTableViewController.h"
#import "YTProcessing.h"
#import "YTVideo.h"

@interface MainViewController (){
UITableView *_tableView;
UISearchBar *_searchBarView;
    
UIActivityIndicatorView *activityIndicator;
    
NSMutableArray *videos;
NSMutableArray *sectionedVideos;
NSMutableArray *videoCategories;
    
}

@property (nonatomic, retain) UITableView *_tableView;
@property (nonatomic, retain) UISearchBar *_searchBarView;
@property (nonatomic, retain) UIActivityIndicatorView *activityIndicator;

@property (nonatomic, retain) NSMutableArray *videos;
@property (nonatomic, retain) NSMutableArray *sectionedVideos;
@property (nonatomic, retain) NSMutableArray *videoCategories;


@end

@implementation MainViewController
@synthesize _tableView,_searchBarView,activityIndicator;
@synthesize videos,sectionedVideos,videoCategories;
- (void)viewDidLoad
{
    [super viewDidLoad];
    _searchBarView = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
    _searchBarView.barStyle = UIBarStyleBlackTranslucent;
    _searchBarView.placeholder = @"BEER";
    [self.view addSubview:_searchBarView];
    
    
    ////Default search of 'BEER' popluates the table.  An new query reloads the table.////
    
    
    sectionedVideos = [[NSMutableArray alloc] init];
    NSString *youTubeURL = @"http://gdata.youtube.com/feeds/api/videos?q=BEER&max-results=5&alt=json";
    NSData *data = [NSData dataWithContentsOfURL: [NSURL URLWithString:youTubeURL]];
    NSError *error;
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
    
    //NSLog(@"YT: %@",json.description);
    
    videoCategories = [[[json objectForKey:@"feed"]valueForKeyPath:@"entry.category"]valueForKeyPath:@"term"];
    videoCategories = [YTProcessing cleanCategories:videoCategories];
    
    for (int i=0; i< videoCategories.count;i++) {
        
        NSString *videoSectionTitleString = [videoCategories objectAtIndex:i];
        NSMutableArray *videoEntry = [[json objectForKey:@"feed"]valueForKeyPath:@"entry"];
        NSMutableArray *newSectionArray = [[NSMutableArray alloc] init];

            for (int k=0; k< videoEntry.count;k++) {
                
                NSString *entryCat = [[[[videoEntry objectAtIndex:k]valueForKeyPath:@"category"]valueForKeyPath:@"term"]objectAtIndex:1];

                    if([entryCat isEqualToString:videoSectionTitleString]){
                        YTVideo *aVideo = [[YTVideo alloc] init];
                        aVideo.videoID = [[videoEntry objectAtIndex:k]valueForKeyPath:@"id.$t"];
                        aVideo.title = [[[videoEntry objectAtIndex:k]valueForKey:@"title"]valueForKeyPath:@"$t"];
                        aVideo.videoCategory = entryCat;
                        aVideo.videoDescription = [[[videoEntry objectAtIndex:k]valueForKeyPath:@"media$group.media$description"]valueForKey:@"$t"];
                        //NSLog(@"Vid desc: %@",aVideo.videoDescription);
                        /// YouTube serves up a special mobile URL
                        /// Using it (index: 3) to improve preformance
                        aVideo.link = [[[[videoEntry objectAtIndex:k]valueForKey:@"link"]objectAtIndex:3]valueForKey:@"href"];
                        aVideo.videosViewCounts = [[[videoEntry objectAtIndex:k]valueForKey:@"yt$statistics"]valueForKeyPath:@"viewCount"];
                        aVideo.thumblink = [[[[videoEntry objectAtIndex:k]valueForKeyPath:@"media$group.media$thumbnail"]objectAtIndex:3]valueForKey:@"url"];

                        [newSectionArray addObject:aVideo];
                    }
            }
        [sectionedVideos addObject:newSectionArray];
    }
      

    //////Draw the table//////
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 45, 320, 640) style:UITableViewStylePlain];//UITableViewStyleGrouped
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.rowHeight = 50;
    [self.view addSubview:_tableView];
    
    activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    activityIndicator.frame = CGRectMake(130, 230, 60, 60);
    [activityIndicator setHidden:YES];
    [self.view addSubview:activityIndicator];

}



#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [videoCategories count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    NSString *categoryTitle;
    categoryTitle = [videoCategories objectAtIndex:section];
    return categoryTitle;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    
    return 20;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 44;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray *videosInSection = [sectionedVideos objectAtIndex:section];
    return [videosInSection count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
        static NSUInteger const kVideoImageTag = 1;
        static NSUInteger const kVideoTitleTag = 2;
        static NSUInteger const kVideoDescriptionTag = 3; 
        static NSString *kYTVideosCellID = @"YTVideosCellID";
    
        UIImageView *videoImageThumb;
        UILabel *videoTitle = nil;
        UILabel *videoDescription = nil;
    
        UIFont *specialFont = [UIFont fontWithName:@"Arial-ItalicMT" size:11];
    
    
    /*NSString *key = [imageURL.absoluteString MD5Hash];
    NSData *data = [FTWCache objectForKey:key];
    if (data) {
        UIImage *image = [UIImage imageWithData:data];
        cell.imageView.image = image;
    } else {
        cell.imageView.image = [UIImage imageNamed:@"icn_default"];
        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0ul);
        dispatch_async(queue, ^{
            NSData *data = [NSData dataWithContentsOfURL:imageURL];
            [FTWCache setObject:data forKey:key];
            UIImage *image = [UIImage imageWithData:data];
            dispatch_async(dispatch_get_main_queue(), ^{
                [tableView cellForRowAtIndexPath:indexPath].imageView.image = image;
            });
        });
    }*/
    
    
    
    
    
    
    
  	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCommentsListCellID];
	if (cell == nil) {
        // No reusable cell was available, so we create a new cell and configure its subviews.
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellAccessoryDetailDisclosureButton
                                      reuseIdentifier:kCommentsListCellID];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        //        productImage = [[[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 63.5, 63.5)] autorelease];
        //        productName.tag = kProductImageTag;
        //        productImage.contentMode = UIViewContentModeScaleAspectFit;
        //        [cell.contentView addSubview:productImage];
        //
        //        productName = [[[UILabel alloc] initWithFrame:CGRectMake(68, 5, 200, 14)] autorelease];
        //        productName.tag = kProductNameTag;
        //        productName.backgroundColor = [UIColor clearColor];
        //        productName.textColor = [UIColor whiteColor];
        //        productName.font = [UIFont boldSystemFontOfSize:14];
        //        [cell.contentView addSubview:productName];
        //
        //        shortDescription = [[[UILabel alloc] initWithFrame:CGRectMake(68, 20, 65, 12)] autorelease];
        //        shortDescription.tag = kShortDescriptionTag;
        //        shortDescription.backgroundColor = [UIColor clearColor];
        //        shortDescription.textColor = [UIColor whiteColor];
        //        shortDescription.font = [UIFont systemFontOfSize:12];
        //        [cell.contentView addSubview:shortDescription];
        //
        //        storeName = [[[UILabel alloc] initWithFrame:CGRectMake(68, 46, 260, 11)] autorelease];
        //        storeName.tag = kStoreNameTag;
        //        storeName.backgroundColor = [UIColor clearColor];
        //        storeName.textColor = [UIColor whiteColor];
        //        storeName.font = [UIFont systemFontOfSize:11];
        //        [cell.contentView addSubview:storeName];
        //
        //
        //        listName = [[[UILabel alloc] initWithFrame:CGRectMake(210, 28, 80, 11)] autorelease];
        //        listName.tag = kListNameTag;
        //        listName.backgroundColor = [UIColor clearColor];
        //        listName.textColor = [UIColor whiteColor];
        //        listName.font = specialFont;
        //        [cell.contentView addSubview:listName];
        
    }else{
        
        //        productImage = (UIImageView *)[cell.contentView viewWithTag:kProductImageTag];
        //        productName = (UILabel *)[cell.contentView viewWithTag:kProductNameTag];
        //        shortDescription = (UILabel *)[cell.contentView viewWithTag:kShortDescriptionTag];
        //        storeName = (UILabel *)[cell.contentView viewWithTag:kStoreNameTag];
        //        listName = (UILabel *)[cell.contentView viewWithTag:kListNameTag];
    }
    
    //    productImage.image = [[UIImage alloc] initWithData:[[myProducts objectAtIndex:indexPath.row] valueForKey:@"imageData"]];
    //    productName.text = [[myProducts objectAtIndex:indexPath.row] valueForKey:@"name"];
    //    shortDescription.text = [[myProducts objectAtIndex:indexPath.row] valueForKey:@"shortDescription"];
    //    // storeName.text = [NSString stringWithFormat:@"from %@",[[myProducts objectAtIndex:indexPath.row] valueForKey:@"storeName"]];
    //    listName.text = [[myProducts objectAtIndex:indexPath.row] valueForKey:@"list"];
    
    return cell;
}



#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
        BeerCategoryTableViewController *bctv = [[BeerCategoryTableViewController alloc] initWithNibName:@"BeerCategoryTableViewController" bundle:nil];
        [self.navigationController pushViewController:bctv animated:YES];
    
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
