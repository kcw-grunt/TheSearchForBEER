//
//  ArticleXMLParser.h
//  Grunt Software
//
//  Created by Kerry Washington on 11/1/11.
//  Copyright (c) 2013 Grunt Software. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YTCommentsRSSParser.h"

@class Comments;

@interface ArticleXMLParser : YTCommentsRSSParser <NSXMLParserDelegate>{

    NSMutableString *currentString;
    Comments *currentComments;
    BOOL storingCharacters;
    NSMutableData *xmlData;
    BOOL done;
    NSURLConnection *rssConnection;
    NSUInteger countOfParsedComments;
}

@property (nonatomic, retain) NSMutableString *currentString;
@property (nonatomic, retain) Comments *currentComments;
@property (nonatomic, retain) NSMutableData *xmlData;
@property (nonatomic, retain) NSURLConnection *rssConnection;

- (void)downloadAndParse:(NSURL *)url;

@end


