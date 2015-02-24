//
//  Snippet.m
//  SearchTest
//
//  Created by Sergey Yuryev on 20.08.13.
//  Copyright (c) 2013 syuryev. All rights reserved.
//

#import "Snippet.h"

@implementation Snippet

-(id)init
{
    if (!(self = [super init]))
        return nil;
    
    self.wordsToHighlight = [[NSMutableArray alloc] initWithCapacity:10];
    self.wordsRangesInSnippet = [[NSMutableArray alloc] initWithCapacity:10];
    self.wordsRangesInContent = [[NSMutableArray alloc] initWithCapacity:10];
    self.snippetText = [[NSMutableString alloc] initWithCapacity:10];
    

    return self;
}

- (NSString *)description
{
    return self.snippetText;
}

@end
