//
//  WebServerVerification.m
//  Grunt Software
//
//  Created by Kerry Washington on 11/25/11.
//  Copyright (c) 2013 Grunt Software. All rights reserved.
//

#import "WebServerVerification.h"

@implementation WebServerVerification
@synthesize testingConnection;
@synthesize testingRequest;

- (id)init{
    if( (self = [super init]) ) {
                
        NSLog(@"Init started");
    }
    
    return self;
}

+(id)returnValidatedNewsURL{
        
    NSURL *validatedURL = [[NSURL alloc] init];
    validatedURL = [NSURL URLWithString:@"http://newsdeskfeeds.moreover.com/feed/b51c403f433b1298.rss"];
    return validatedURL;
}

+ (BOOL)isValidURL:(NSURL*)url
{
    NSURLRequest *req = [NSURLRequest requestWithURL:url];
    NSHTTPURLResponse *res = nil;
    NSError *err = nil;
    [NSURLConnection sendSynchronousRequest:req returningResponse:&res error:&err];

    NSLog(@"Reponse Code: %i",[res statusCode]);
    NSLog(@"Error:%@",err);
    
    if((!err) && ([res statusCode]!= 404)&&([res statusCode]!= 400)){
        
        ///URL is valid
        return YES;
    
    }else{
        
        return NO;
    }
}

@end
