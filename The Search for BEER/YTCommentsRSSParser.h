//
//  ArticleRSSParser.h
//  Grunt Software
//
//  Created by Kerry Washington on 11/1/11.
//  Copyright (c) 2013 Grunt Software. All rights reserved.
//

#import <UIKit/UIKit.h>

@class YTCommentsRSSParser, Comments;

// Protocol for the parser to communicate with its delegate.
@protocol commentsRSSParserDelegate <NSObject>

@optional
// Called by the parser when parsing is finished.
- (void)parserDidEndParsingData:(YTCommentsRSSParser *)parser;
// Called by the parser in the case of an error.
- (void)parser:(YTCommentsRSSParser *)parser didFailWithError:(NSError *)error;
// Called by the parser when one or more songs have been parsed. This method may be called multiple times.
- (void)parser:(YTCommentsRSSParser *)parser didParseComments:(NSArray *)parsedCommments;

@end


@interface YTCommentsRSSParser : NSObject {
    id <commentsRSSParserDelegate> delegate;
    NSMutableArray *parsedComments;
    NSTimeInterval startTimeReference;
    NSTimeInterval downloadStartTimeReference;
    double parseDuration;
    double downloadDuration;
    double totalDuration;
}

@property (nonatomic, assign) id <commentsRSSParserDelegate> delegate;
@property (nonatomic, retain) NSMutableArray *parsedComments;
@property NSTimeInterval startTimeReference;
@property NSTimeInterval downloadStartTimeReference;
@property double parseDuration;
@property double downloadDuration;
@property double totalDuration;

+ (NSString *)parserName;
//+ (XMLParserType)parserType;

- (void)start;

// Subclasses must implement this method. It will be invoked on a secondary thread to keep the application responsive.
// Although NSURLConnection is inherently asynchronous, the parsing can be quite CPU intensive on the device, so
// the user interface can be kept responsive by moving that work off the main thread. This does create additional
// complexity, as any code which interacts with the UI must then do so in a thread-safe manner.
- (void)downloadAndParse:(NSURL *)url;

// Subclasses should invoke these methods and let the superclass manage communication with the delegate.
// Each of these methods must be invoked on the main thread.
- (void)downloadStarted;
- (void)downloadEnded;
- (void)parseEnded;
- (void)parsedComments:(Comments *)comments;
- (void)parseError:(NSError *)error;
- (void)addToParseDuration:(NSNumber *)duration;

@end
