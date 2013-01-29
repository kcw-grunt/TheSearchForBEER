//
//  ComposeViewController.h
//  The Search for BEER
//
//  Created by Grunt - Kerry on 1/28/13.
//  Copyright (c) 2013 Grunt Software. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YTVideo.h"

@interface ComposeViewController : UIViewController<UITextViewDelegate>{
    UITextView *postView;

    YTVideo *postVideoEntry;

}
@property (nonatomic,strong) YTVideo *postVideoEntry;
@property (nonatomic,retain) UITextView *postView;

@end
