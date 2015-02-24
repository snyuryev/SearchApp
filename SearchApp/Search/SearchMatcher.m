//
//  SearchMatcher.m
//  SearchTest
//
//  Created by Sergey Yuryev on 17.08.13.
//  Copyright (c) 2013 syuryev. All rights reserved.
//

#import "SearchMatcher.h"


@implementation SearchMatcher

-(id)initWithRegex:(NSString *)regex andMatcher:(NSMutableString *)matcher
{
    if (!(self = [super init]))
        return nil;
    
    self.regex = [[NSMutableString alloc] initWithString:regex];
    self.matcher = [[NSMutableString alloc] initWithString:matcher];
    return self;
}

@end
