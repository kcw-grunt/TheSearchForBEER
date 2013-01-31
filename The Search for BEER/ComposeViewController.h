//
//  ComposeViewController.h
//  The Search for BEER
//
//  Created by Grunt - Kerry on 1/28/13.
//  Copyright (c) 2013 Grunt Software. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YTVideo.h"

@protocol ComposeViewControllerDelegate;

@interface ComposeViewController : UIViewController<UITextViewDelegate>{
    UITextView *postView;

    YTVideo *postVideoEntry;
    
    __weak id <ComposeViewControllerDelegate> delegate;

}
@property (nonatomic,retain) YTVideo *postVideoEntry;
@property (nonatomic,retain) UITextView *postView;
@property (weak,nonatomic) id <ComposeViewControllerDelegate> delegate;
@end

@protocol ComposeViewControllerDelegate <NSObject>
@optional
-(void)composeViewController:(ComposeViewController *)controller didUpdateFBPost:(NSString *)fbPost;
@end
