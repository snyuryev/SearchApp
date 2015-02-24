//
//  ParseList.m
//  SearchTest
//
//  Created by Sergey Yuryev on 16.08.13.
//  Copyright (c) 2013 syuryev. All rights reserved.
//

#import "ParseList.h"
#import "Token.h"

@implementation ParseList

-(id)init
{
    if (!(self = [super init]))
        return nil;
    
    self.tokens = [[NSMutableArray alloc] initWithCapacity:10];
    return self;
}

- (NSString *) printParseList
{
    NSMutableString *output =[[NSMutableString alloc] initWithString:@""];
    for (Token *token in _tokens)
    {
        [output setString:[NSString stringWithFormat:@"%@%@\n", output, [token printToken]]];
    }
    NSString *returnString = [NSString stringWithString:output];
    return returnString;
}


@end
