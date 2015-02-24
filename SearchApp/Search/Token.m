//
//  Token.m
//  SearchTest
//
//  Created by Sergey Yuryev on 17.08.13.
//  Copyright (c) 2013 syuryev. All rights reserved.
//

#import "Token.h"

@interface Token ()

@end

@implementation Token

-(id)initWithToken:(NSString *)token
{
    if (!(self = [super init]))
        return nil;
    
    self.token = [[NSMutableString alloc] initWithString:token];
    return self;
}

- (void) finalizeExtraction: (BOOL) inLiteral
{
    if (inLiteral)
    {
        self.isLiteral = YES;
        NSString *lastQuotes = [_token substringFromIndex:[_token length] - 1];
        if ([lastQuotes isEqualToString:@"\""]) {
            _endSpecial = @"\"";
            [_token setString: [_token substringToIndex:[_token length] - 1]];
        }
    }
    else
    {
        NSUInteger startChar = 0;
        BOOL isStillProcessing = YES;
        
        while (isStillProcessing && startChar < [_token length])
        {
            NSString *singleCharacter = [_token substringWithRange:NSMakeRange(startChar, 1)];
            if ([singleCharacter isEqualToString:@"("])
            {
                NSString *lastCharacter = [_token substringFromIndex:[_token length] - 1];
                if ([lastCharacter isEqualToString:@")"])
                {
                    // Stop processing, and keep the rest of the word
                    isStillProcessing = NO;
                }
                else
                {
                    [_token setString: [_token substringFromIndex:1]];
                    startChar -= 1;
                }
            }
            else if ([singleCharacter isEqualToString:@"\""])
            {
                NSString *lastCharacter = [_token substringFromIndex:[_token length] - 1];
                if ([lastCharacter isEqualToString:@"\""])
                {
                    self.isLiteral = YES;
                    self.startSpecial = @"\"";
                    self.endSpecial = @"\"";
                    // Trim off first and last characters and keep going ...
                    [_token setString: [_token substringToIndex:[_token length] - 1]];
                    [_token setString: [_token substringFromIndex:1]];
                }
                else
                {
                    self.startSpecial = @"\"";
                    self.isLiteral = YES;
                    // Trim off the starting character ...
                    [_token setString: [_token substringFromIndex:1]];
                    startChar -= 1;
                    // Assume the rest of the whole word is literal ...
                    isStillProcessing = NO;
                }
            }
            else if ([singleCharacter isEqualToString:@"'"] || [singleCharacter isEqualToString:@"."] || [singleCharacter isEqualToString:@":"])
            {
                // Then just remove it ...
                [_token setString: [_token substringFromIndex:1]];
                startChar -= 1;
            }
            else
            {
                isStillProcessing = NO;
            }
        }
        
        // Trim the end of the word ...
        isStillProcessing = YES;
        NSInteger endChar = [_token length] - 1;
        
        
        while (isStillProcessing && !_isLiteral && endChar >= 0)
        {
            NSString *endCharacter = [_token substringFromIndex:[_token length] - 1];
            
            if ([endCharacter isEqualToString:@")"])
            {
                NSRange range = [_token rangeOfString:@"("];
                if (range.location != NSNotFound)
                {
                    isStillProcessing = NO;
                }
                else
                {
                    [_token setString: [_token substringToIndex:endChar]];
                }
            }
            else if ([endCharacter isEqualToString:@"'"] || [endCharacter isEqualToString:@"."] || [endCharacter isEqualToString:@":"] || [endCharacter isEqualToString:@"\""])
            {
                [_token setString: [_token substringToIndex:endChar]];
            }
            else
            {
                isStillProcessing = NO;
            }
            endChar -= 1;
        }
        
        
        // If the user is trying to force a boolean search, rather than mysteriously failing for them
        // (which it probably would do), just erase the token -- it'll search AND by default, anyhow ...
        if ([_token isEqualToString:@"AND"] && !_isLiteral)
        {
            [_token setString:  @""];
        }
        if ([_token isEqualToString:@"OR"] && !_isLiteral)
        {
            [_token setString: @""];
        }
    }
}

-(NSString *) printToken
{
    NSMutableString *output =[[NSMutableString alloc] initWithString:@""];
    
    if (_isLiteral) {
        [output appendString:@"<LITERAL>"];
    }
    if (_startSpecial != nil) {
        [output appendString:[NSString stringWithFormat:@"[%@]",_startSpecial]];
    }
    [output appendString:_token];
    if (_endSpecial != nil) {
        [output appendString:[NSString stringWithFormat:@"[%@]",_endSpecial]];
    }
    NSString *returnString = [NSString stringWithString:output];
    return returnString;
}

@end
