//
//  WebServerVerification.h
//  Grunt Software

//
//  Created by Kerry Washington on 11/25/11.
//  Copyright (c) 2013 Grunt Software. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WebServerVerification : NSObject <NSURLConnectionDelegate> {

    NSURLConnection *testingConnection;
    NSURLRequest *testingRequest;

}


@property(nonatomic,retain) NSURLConnection *testingConnection;
@property(nonatomic,retain) NSURLRequest *testingRequest;

+(id)returnValidatedNewsURL;
+(BOOL)isValidURL:(NSURL*)url;

    
    
@end
