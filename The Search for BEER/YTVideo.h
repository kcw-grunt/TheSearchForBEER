//
//  YTVideo.h
//  The Search for BEER
//
//  Created by Grunt - Kerry on 1/26/13.
//  Copyright (c) 2013 Grunt Software. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface YTVideo : NSObject{

NSString    *videoID;
NSString    *rawID;
NSString    *title;
NSString    *videoDescription;
NSString    *videoCommentsLink;
NSString    *link;
NSString    *mobileLink;
    
NSString    *thumblink;
UIImage     *thumbImage;
NSData      *thumbImageData;
NSString    *videosViewCounts;
NSString    *videoCategory;
NSNumber    *videoRating;
NSNumber    *videoCommentsCount;
NSDate      *videoPublishDate;


}

@property (nonatomic, copy) NSString    *videoID;
@property (nonatomic, copy) NSString    *rawID;
@property (nonatomic, copy) NSString    *title;
@property (nonatomic, copy) NSString    *videoDescription;
@property (nonatomic, copy) NSString    *videoCommentsLink;
@property (nonatomic, copy) NSString    *link;
@property (nonatomic, copy) NSString    *mobileLink;
@property (nonatomic, copy) NSString    *thumblink;
@property (nonatomic, copy) UIImage     *thumbImage;
@property (nonatomic, copy) NSData      *thumbImageData;
@property (nonatomic, copy) NSString    *videosViewCounts;
@property (nonatomic, copy) NSString    *videoCategory;
@property (nonatomic, copy) NSNumber    *videoRating;
@property (nonatomic, copy) NSNumber    *videoCommentsCount;
@property (nonatomic, copy) NSDate      *videoPublishDate;



@end
