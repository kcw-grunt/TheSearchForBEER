//
//  ArticleRSSParser.m
//
//  Grunt Software
//
//  Created by Grunt Software on 6/30/11.
//  Copyright (c) 2013 Grunt Software. All rights reserved.
//

#import "YTCommentsRSSParser.h"
#import "Comments.h"
//#import "WebServerVerification.h"
static NSUInteger kCountForNotification = 15;

@implementation YTCommentsRSSParser

@synthesize delegate;
@synthesize parsedComments;
@synthesize startTimeReference;
@synthesize downloadStartTimeReference;
@synthesize parseDuration;
@synthesize downloadDuration;
@synthesize totalDuration;

+ (NSString *)parserName {
    NSAssert((self != [YTCommentsRSSParser class]), @"Class method parserName not valid for abstract base class iTunesRSSParser");
    return @"Base Class";
}

+ (XMLParserType)parserType {
    NSAssert((self != [YTCommentsRSSParser class]), @"Class method parserType not valid for abstract base class iTunesRSSParser");
    return XMLParserTypeAbstract;
}

- (void)start {
//    self.startTimeReference = [NSDate timeIntervalSinceReferenceDate];
//    [[NSURLCache sharedURLCache] removeAllCachedResponses];
//    self.parsedSongs = [NSMutableArray array];
//    // NSURL *url = [NSURL URLWithString:@"http://ax.phobos.apple.com.edgesuite.net/WebObjects/MZStore.woa/wpa/MRSS/newreleases/limit=300/rss.xml"];
//    
//    NSURL *url = [NSURL URLWithString:@"http://gdata.youtube.com/feeds/api/videos/SCgX4ixCRcQ/comments"];
//    
//    [NSThread detachNewThreadSelector:@selector(downloadAndParse:) toTarget:self withObject:url];
}

- (void)start:(NSString *)linkString{
    self.startTimeReference = [NSDate timeIntervalSinceReferenceDate];
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
    self.parsedComments = [NSMutableArray array];
    
    NSURL *ytVidComments = [NSURL URLWithString:linkString];
    [NSThread detachNewThreadSelector:@selector(downloadAndParse:) toTarget:self withObject:ytVidComments];
}

- (void)downloadAndParse:(NSURL *)url {
    NSAssert([self isMemberOfClass:[YTCommentsRSSParser class]] == NO, @"Object is of abstract base class iTunesRSSParser");
}

- (void)downloadStarted {
    NSAssert2([NSThread isMainThread], @"%s at line %d called on secondary thread", __FUNCTION__, __LINE__);
    self.downloadStartTimeReference = [NSDate timeIntervalSinceReferenceDate];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}

- (void)downloadEnded {
    NSAssert2([NSThread isMainThread], @"%s at line %d called on secondary thread", __FUNCTION__, __LINE__);
    NSTimeInterval duration = [NSDate timeIntervalSinceReferenceDate] - self.downloadStartTimeReference;
    downloadDuration += duration;
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

- (void)parseEnded {
    NSAssert2([NSThread isMainThread], @"%s at line %d called on secondary thread", __FUNCTION__, __LINE__);
    if (self.delegate != nil && [self.delegate respondsToSelector:@selector(parser:didParseComments:)] && [parsedComments count] > 0) {
        [self.delegate parser:self didParseComments:parsedComments];
    }
    [self.parsedComments removeAllObjects];
    if (self.delegate != nil && [self.delegate respondsToSelector:@selector(parserDidEndParsingData:)]) {
        [self.delegate parserDidEndParsingData:self];
    }
    NSTimeInterval duration = [NSDate timeIntervalSinceReferenceDate] - self.startTimeReference;
    totalDuration = duration;
    // WriteStatisticToDatabase([[self class] parserType], downloadDuration, parseDuration, totalDuration);
}

- (void)parsedComments:(Comments *)comments{
    NSAssert2([NSThread isMainThread], @"%s at line %d called on secondary thread", __FUNCTION__, __LINE__);
    [self.parsedComments addObject:comments];
    if (self.parsedComments.count > kCountForNotification) {
        if (self.delegate != nil && [self.delegate respondsToSelector:@selector(parser:didParseComments:)]) {
            [self.delegate parser:self didParseComments:parsedComments];
        }
        [self.parsedComments removeAllObjects];
    }
}

- (void)parseError:(NSError *)error {
    NSAssert2([NSThread isMainThread], @"%s at line %d called on secondary thread", __FUNCTION__, __LINE__);
    if (self.delegate != nil && [self.delegate respondsToSelector:@selector(parser:didFailWithError:)]) {
        [self.delegate parser:self didFailWithError:error];
    }
}

- (void)addToParseDuration:(NSNumber *)duration {
    NSAssert2([NSThread isMainThread], @"%s at line %d called on secondary thread", __FUNCTION__, __LINE__);
    parseDuration += [duration doubleValue];
}

@end
