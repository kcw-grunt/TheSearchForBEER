//
//  YTDetailViewController.h
//  The Search for BEER
//
//  Created by Grunt - Kerry on 1/27/13.
//  Copyright (c) 2013 Grunt Software. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YTVideo.h"
#import "YTCommentsRSSParser.h"
#import <FacebookSDK/FacebookSDK.h>

@interface YTDetailViewController : UIViewController  <UIWebViewDelegate,UITextViewDelegate,commentsRSSParserDelegate,UITableViewDataSource,UITableViewDelegate,commentsRSSParserDelegate>{

        
    YTCommentsRSSParser *parser;
    
    NSMutableArray  *commentPosts;
    NSString        *commentAuthor;
    NSString        *commentText;
    
    
    UITableView     *_tableView;
    
    YTVideo *entryDetail;
    UIWebView *mainWebView;
    NSString *ythtml;
    NSString *vidTitle;
    
    FBSession *session;
    
    
//@private
//    // for downloading the xml data
//    NSURLConnection *commentsFeedConnection;
//    NSMutableData *ytCommentData;    
//    NSOperationQueue *parseQueue;
}
//
//@property (nonatomic, retain)NSURLConnection *commentsFeedConnection;
//@property (nonatomic, retain)NSMutableData *ytCommentData;
//@property (nonatomic, retain)NSOperationQueue *parseQueue;


@property (nonatomic, retain) UIWebView *mainWebView;

@property (nonatomic, retain)UITableView *_tableView;

@property (nonatomic, retain) YTCommentsRSSParser *parser;
@property (nonatomic, retain) NSMutableArray  *commentPosts;
@property (nonatomic, retain) NSString        *commentAuthor;
@property (nonatomic, retain) NSString        *commentText;


@property (nonatomic, retain) NSString *ythtml;
@property (nonatomic, retain) NSString *vidTitle;
@property (nonatomic, retain) YTVideo *entryDetail;

@property (strong, nonatomic) FBSession *session;

- (void)parseWithParserType:(XMLParserType)parserType;
@end
