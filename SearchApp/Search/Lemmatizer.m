//
//  Lemmatizer.m
//  SearchTest
//
//  Created by Sergey Yuryev on 17.08.13.
//  Copyright (c) 2013 syuryev. All rights reserved.
//

#import "Lemmatizer.h"

@interface Lemmatizer ()

- (BOOL) isNumeric: (NSString*)inputString;
- (BOOL) isAlpha: (NSString*)inputString;

@end

@implementation Lemmatizer

- (BOOL) isNumeric: (NSString*)inputString
{
    BOOL isValid = NO;
    NSCharacterSet *alphaNumbersSet = [NSCharacterSet decimalDigitCharacterSet];
    NSCharacterSet *stringSet = [NSCharacterSet characterSetWithCharactersInString:inputString];
    isValid = [alphaNumbersSet isSupersetOfSet:stringSet];
    return isValid;
}

- (BOOL) isAlpha: (NSString*)inputString
{    
    BOOL isValid = NO;
    NSCharacterSet *alphaNumbersSet = [NSCharacterSet letterCharacterSet];
    NSCharacterSet *stringSet = [NSCharacterSet characterSetWithCharactersInString:inputString];
    isValid = [alphaNumbersSet isSupersetOfSet:stringSet];
    return isValid;
}

- (NSString *) expandEquivalencies: (NSString *) term
{
    NSMutableString *returnTerm = [[NSMutableString alloc ]initWithString:term];
    if ([returnTerm length] < 2) {
        return returnTerm;
    }
    // hardcode. this is workaround for regex in ios. flag for regex is not working correct
    NSMutableString *modLemmatized = [[NSMutableString alloc] initWithString:term];
    [modLemmatized replaceOccurrencesOfString:@"(" withString:@"\\(" options:0 range:NSMakeRange(0, modLemmatized.length)];
    [modLemmatized replaceOccurrencesOfString:@")" withString:@"\\)" options:0 range:NSMakeRange(0, modLemmatized.length)];
    [modLemmatized replaceOccurrencesOfString:@"." withString:@"\\." options:0 range:NSMakeRange(0, modLemmatized.length)];
    [modLemmatized replaceOccurrencesOfString:@"-" withString:@"\\-" options:0 range:NSMakeRange(0, modLemmatized.length)];
    [modLemmatized replaceOccurrencesOfString:@" " withString:@"\\ " options:0 range:NSMakeRange(0, modLemmatized.length)];
    [modLemmatized replaceOccurrencesOfString:@"[" withString:@"\\[" options:0 range:NSMakeRange(0, modLemmatized.length)];
    [modLemmatized replaceOccurrencesOfString:@"]" withString:@"\\]" options:0 range:NSMakeRange(0, modLemmatized.length)];
    [modLemmatized replaceOccurrencesOfString:@"$" withString:@"\\u0024" options:0 range:NSMakeRange(0, modLemmatized.length)];
    [modLemmatized replaceOccurrencesOfString:@"§" withString:@"\\u00a7" options:0 range:NSMakeRange(0, modLemmatized.length)];
    [returnTerm setString:modLemmatized];
    
    NSString *singleCharacter = [returnTerm substringWithRange:NSMakeRange(0, 1)];
    NSString *secondCharacter = [returnTerm substringWithRange:NSMakeRange(1, 1)];
    if ([singleCharacter isEqualToString:@"s"] && [self isNumeric:secondCharacter])
    {
        [returnTerm setString:[NSString stringWithFormat:@"(s|\\u00a7)%@", [returnTerm substringFromIndex:1]]];
    }
    if ([singleCharacter isEqualToString:@"p"] && [self isNumeric:secondCharacter])
    {
        [returnTerm setString:[NSString stringWithFormat:@"(p|\\u00b6)%@", [returnTerm substringFromIndex:1]]];
    }
    
    NSString *lastCharacter = [returnTerm substringFromIndex:[returnTerm length] - 1];
    
    if ([lastCharacter isEqualToString:@"s"]) {
        [returnTerm setString:[returnTerm substringToIndex:[returnTerm length] - 1]];
        [returnTerm setString:[NSString stringWithFormat:@"%@[s]*", returnTerm]];
        return returnTerm;
    }
    
    if ([self isAlpha:lastCharacter]) {
        [returnTerm setString:[NSString stringWithFormat:@"%@[s]*", returnTerm]];
        return returnTerm;
    }
    return returnTerm;
}

@end
