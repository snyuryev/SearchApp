//
//  Tokenizer.m
//  SearchTest
//
//  Created by Sergey Yuryev on 16.08.13.
//  Copyright (c) 2013 syuryev. All rights reserved.
//

#import "Tokenizer.h"
#import "ParseList.h"
#import "Token.h"

@interface Tokenizer ()


@end


@implementation Tokenizer


- (ParseList *) tokenize: (NSString *) searchExpression
{
    ParseList *parseList = [[ParseList alloc] init];
    Token *currToken = nil;
    BOOL inLiteral = NO;
    NSCharacterSet * set = [NSCharacterSet characterSetWithCharactersInString:@" ,;\n\r\t"];
    
    for (int i = 0; i < [searchExpression length]; i++)
    {
        NSString *currChar = [searchExpression substringWithRange:NSMakeRange(i, 1)];
        // Then it's space character ...
        
        
        if ([currChar rangeOfCharacterFromSet:set].location != NSNotFound)
        {
            if (currToken != nil)
            {
                [currToken finalizeExtraction:inLiteral];
                if (currToken.isLiteral)
                {
                    if ([currToken.endSpecial isEqualToString:@"\""])
                    {
                        inLiteral = NO;
                    }
                    else
                    {
                        inLiteral = YES;
                    }
                }
                else
                {
                    inLiteral = NO;
                }
                
                if ([currToken.token length] > 0) {
                    [parseList.tokens addObject:currToken];
                    currToken = nil;
                }
            }
            else
            {
                continue;
            }
        }
        else if (currToken != nil)
        {
            [currToken.token appendString:currChar];
        }
        else
        {
            // We're starting a new word ...
            currToken = [[Token alloc] initWithToken:currChar];
        }
    }
    
    if (currToken != nil) {
        [currToken finalizeExtraction:inLiteral];
        if ([currToken.token length] > 0) {
            [parseList.tokens addObject:currToken];
        }
    }

    return parseList;
}

@end
