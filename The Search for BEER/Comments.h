//
//  Comments.h
//  The Search for BEER
//
//  Created by Grunt - Kerry on 1/27/13.
//  Copyright (c) 2013 Grunt Software. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Comments : NSObject{

    NSString    *content;
    NSString    *author;


}

@property (nonatomic, copy) NSString    *content;
@property (nonatomic, copy) NSString    *author;


@end
