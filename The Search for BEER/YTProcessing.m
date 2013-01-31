//
//  YTProcessing.m
//  The Search for BEER
//
//  Created by Grunt - Kerry on 1/25/13.
//  Copyright (c) 2013 Grunt Software. All rights reserved.
//

#import "YTProcessing.h"

@implementation YTProcessing


+(id)cleanCategories:(NSMutableArray *)rawYTArray{
    NSSet *categorySet = [NSSet setWithArray:rawYTArray];
    NSMutableArray *array = [NSMutableArray arrayWithArray:[categorySet allObjects]];
    return array;
}

@end
