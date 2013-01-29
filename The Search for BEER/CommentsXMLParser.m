//
//  ArticleXMLParser.m
//  Grunt Software
//
//  Created by Grunt Software on 6/30/11.
//  Copyright (c) 2013 Grunt Software. All rights reserved.
//

#import "CommentsXMLParser.h"
#import "Comments.h"

@implementation CommentsXMLParser

+ (NSString *)parserName {
    return @"NSXMLParser";
}
+ (XMLParserType)parserType {
    return XMLParserTypeNSXMLParser;
}

@synthesize currentString;
@synthesize rssConnection;
@synthesize xmlData;
@synthesize currentComments;


- (void)downloadAndParse:(NSURL *)url {
    
    NSLog(@"URL: %@",url);
    self.xmlData = [NSMutableData data];
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
    NSURLRequest *theRequest = [NSURLRequest requestWithURL:url];
    rssConnection = [[NSURLConnection alloc] initWithRequest:theRequest delegate:self];
    [self performSelectorOnMainThread:@selector(downloadStarted) withObject:nil waitUntilDone:NO];
    if (rssConnection != nil) {
        do {
            [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
        } while (!done);
    }
    self.rssConnection = nil;
    self.currentComments = nil;
    
}




#pragma mark NSURLConnection Delegate methods

- (NSCachedURLResponse *)connection:(NSURLConnection *)connection willCacheResponse:(NSCachedURLResponse *)cachedResponse {
    return nil;
}

// Forward errors to the delegate.
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    done = YES;
    [self performSelectorOnMainThread:@selector(parseError:) withObject:error waitUntilDone:NO];
}

// Called when a chunk of data has been downloaded.
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    // Append the downloaded chunk of data.
    [xmlData appendData:data];
    
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    [self performSelectorOnMainThread:@selector(downloadEnded) withObject:nil waitUntilDone:NO];
    NSXMLParser *parser = [[NSXMLParser alloc] initWithData:xmlData];
    parser.delegate = self;
    self.currentString = [NSMutableString string];
    NSTimeInterval start = [NSDate timeIntervalSinceReferenceDate];
    [parser parse];
    NSTimeInterval duration = [NSDate timeIntervalSinceReferenceDate] - start;
    [self performSelectorOnMainThread:@selector(addToParseDuration:) withObject:[NSNumber numberWithDouble:duration] waitUntilDone:NO];
    [self performSelectorOnMainThread:@selector(parseEnded) withObject:nil waitUntilDone:NO];
    self.currentString = nil;
    self.xmlData = nil;
    // Set the condition which ends the run loop.
    done = YES; 
}

#pragma mark Parsing support methods

static const NSUInteger kAutoreleasePoolPurgeFrequency = 50;

- (void)finishedcurrentComments {
    [self performSelectorOnMainThread:@selector(parsedComments:) withObject:currentComments waitUntilDone:NO];
    // performSelectorOnMainThread: will retain the object until the selector has been performed
    // setting the local reference to nil ensures that the local reference will be released
    self.currentComments = nil;
    countOfParsedComments++;
    // Periodically purge the autorelease pool. The frequency of this action may need to be tuned according to the 
    // size of the objects being parsed. The goal is to keep the autorelease pool from growing too large, but 
    // taking this action too frequently would be wasteful and reduce performance.

}

#pragma mark NSXMLParser Parsing Callbacks

// Constants for the XML element names that will be considered during the parse. 
// Declaring these as static constants reduces the number of objects created during the run
// and is less prone to programmer error.

static NSString *kEntryElementName = @"entry";
static NSString *kContentElementName = @"content";
static NSString *kAuthorElementName = @"author";

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *) qualifiedName attributes:(NSDictionary *)attributeDict {
    if ([elementName isEqualToString:kEntryElementName]) {
        self.currentComments = [[Comments alloc] init];
    } else if ([elementName isEqualToString:kContentElementName] || [elementName isEqualToString:kAuthorElementName]) {
        [currentString setString:@""];
        storingCharacters = YES;
    }
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
    if ([elementName isEqualToString:kEntryElementName]) {
        [self finishedcurrentComments];
    } else if ([elementName isEqualToString:kAuthorElementName]) {
        currentComments.author = currentString;
       
    } else if ([elementName isEqualToString:kContentElementName]) {
        currentComments.content = currentString;
    } 
    storingCharacters = NO;
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
    if (storingCharacters) [currentString appendString:string];
}

- (void)parserDidEndDocument:(NSXMLParser *)parser{
    
}
- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError {
    // Handle errors as appropriate for your application.
}


@end
