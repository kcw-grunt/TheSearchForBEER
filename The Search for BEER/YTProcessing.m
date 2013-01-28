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
    
    NSMutableArray *returningArray = [[NSMutableArray alloc] init];
    
    for (NSArray *catArray in rawYTArray) {
        NSString *categoryLabel;
        categoryLabel = [catArray objectAtIndex:1];
        [returningArray addObject:categoryLabel];
    }

    NSSet *categorySet = [NSSet setWithArray:returningArray];
    NSMutableArray *array = [NSMutableArray arrayWithArray:[categorySet allObjects]];
    returningArray = array;
    return returningArray;
}

@end
