//
//  Synonyms.m
//  SearchTest
//
//  Created by Sergey Yuryev on 17.08.13.
//  Copyright (c) 2013 syuryev. All rights reserved.
//

#import "Synonyms.h"


@implementation Synonyms

-(id)initWithSynonymsList:(NSString *)synonymsString
{
    if (!(self = [super init]))
        return nil;
    
    self.equivalencies = [[NSArray alloc] initWithArray: [synonymsString componentsSeparatedByString:@"\r\n"]];
    self.dictionary = [[NSMutableDictionary alloc] initWithCapacity:10];
    
    for (NSString *equivalency in _equivalencies)
    {
        NSArray *synonymList = [equivalency componentsSeparatedByString:@"|"];
        for (NSString *synonym in synonymList)
        {
            [_dictionary setObject:synonymList forKey:synonym];
        }
    }
    
    return self;
}

- (NSArray *) expandTerm: (NSString *) term
{
    if ([_dictionary objectForKey:term] != nil)
    {
        return [_dictionary objectForKey:term];
    }
    else
    {
        NSArray *returnArray = [NSArray arrayWithObject:term];
        return returnArray;
    }
}

@end
