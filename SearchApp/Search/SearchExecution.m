//
//  SearchExecution.m
//  SearchTest
//
//  Created by Sergey Yuryev on 16.08.13.
//  Copyright (c) 2013 syuryev. All rights reserved.
//

#import "SearchExecution.h"
#import "ParseList.h"
#import "SearchResult.h"
#import "Lemmatizer.h"
#import "Synonyms.h"
#import "Content.h"
#import "Token.h"
#import "HitPosition.h"

@interface SearchExecution ()

@property (nonatomic, strong) NSCharacterSet *charSet;

@end


@implementation SearchExecution

-(id)init
{
    if (!(self = [super init]))
        return nil;
    
    self.lemmatizer = [[Lemmatizer alloc] init];
    
    NSString *synonymsFilePath = [[NSBundle mainBundle] pathForResource:SYNONYM_FILE_NAME ofType:nil];
    NSError *error;
    self.synonyms = [[Synonyms alloc] initWithSynonymsList:[NSString stringWithContentsOfFile: synonymsFilePath encoding: NSUTF8StringEncoding error: &error]];
    
    self.wordBoundaries = @"[  .,:;\\b\\n\\r\\t\\(\\)\\[\\]]";
    self.charSet = [NSCharacterSet characterSetWithCharactersInString:@"  .,;:\n\r\t[]()"];
    self.andClauses = [[NSMutableArray alloc] initWithCapacity:10];
    self.searchClauses = [[NSMutableArray alloc] initWithCapacity:10];
    
    return self;
}

// Create a regular expression with given string and options
- (NSRegularExpression *)regularExpressionWithString:(NSString *)string
{
    
    NSError *error = NULL;
    NSRegularExpressionOptions regexOptions = NSRegularExpressionCaseInsensitive|NSRegularExpressionDotMatchesLineSeparators|NSRegularExpressionAnchorsMatchLines;
    
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:string options:regexOptions error:&error];
    if (error)
    {
        NSLog(@"Couldn't create regex with given string and options");
    }
    
    return regex;
}

- (SearchResult *) executeSearchWithParseList:(ParseList *) parseList andContent:(Content *) content isVerbose:(BOOL) isVerbose
{
    SearchResult *searchResult = [[SearchResult alloc] initWithContent:content];
    
    
    [_andClauses removeAllObjects];
    
    NSMutableString *literalClause = [[NSMutableString alloc] initWithString:@""];
    
    for (Token *token in parseList.tokens)
    {
        if ([token isLiteral])
        {
            if ([literalClause length] > 0)
            {
                [literalClause setString:[NSString stringWithFormat:@"%@ ", literalClause]];
            }
            [literalClause setString:[NSString stringWithFormat:@"%@%@", literalClause, token.token]];
            
            if (token.endSpecial)
            {
                [_andClauses addObject:[[NSString alloc] initWithString:literalClause] ];
                [literalClause setString:@""];
            }
        }
        else
        {
            if ([token.token isEqualToString:@"§"])
            {
                [_andClauses addObject:@"\\u00a7"];
            }
            else if ([token.token isEqualToString:@"$"])
            {
                [_andClauses addObject:@"\\u0024"];
            }
            else
            {
                [_andClauses addObject:token.token];
            }
        }
    }
    
    if ([literalClause length] > 0)
    {
        [_andClauses addObject:literalClause];
    }
    
    NSSortDescriptor* sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"length" ascending:NO];
    NSArray *sortedArray = [_andClauses sortedArrayUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];
    [_andClauses setArray:sortedArray];
    
    for (NSString *clause in _andClauses)
    {
        BOOL isFirst = YES;
        NSMutableString *regex = [[NSMutableString alloc] initWithString:@""];
        
        for (NSString *synonym in [_synonyms expandTerm:[clause lowercaseString]])
        {
            NSString *lemmatized = [_lemmatizer expandEquivalencies:synonym];
            if (isFirst) {
                isFirst = NO;
            }
            else
            {
                [regex setString:[NSString stringWithFormat:@"%@|", regex]];
                
            }
            [regex setString:[NSString stringWithFormat:@"%@(^|%@)%@($|%@)", regex, _wordBoundaries, lemmatized, _wordBoundaries]];
        }
        if (isVerbose)
        {
             NSLog(@"%@", regex);
        }
        [_searchClauses addObject:[self regularExpressionWithString:regex]];
    }
    
    if ([_searchClauses count] < 1)
    {
        return searchResult;
    }
    
    NSUInteger scanStart = 0;
    BOOL shouldBeRescaned = YES;
    
    while (scanStart < [content.content length] && [searchResult.hits count] < MAX_HITS)
    {
        
        NSMutableArray *highlights= [[NSMutableArray alloc] initWithCapacity:10];
        NSMutableArray *allHighlights= [[NSMutableArray alloc] initWithCapacity:10];
        
        NSTextCheckingResult *match = [[_searchClauses objectAtIndex:0] firstMatchInString:content.content
                                                                                   options:0
                                                                                     range:NSMakeRange(scanStart, [content.content length] - scanStart)];
        if (match)
        {
            HitPosition *hitPosition = [[HitPosition alloc] initWithStart:match.range.location andEnd:match.range.location + match.range.length ];
            hitPosition.regex = [_searchClauses objectAtIndex:0];
            
            if (hitPosition.start != 0)
            {
                NSRange range = NSMakeRange(hitPosition.start, 1);
                NSString *startCharacter = [content.content substringWithRange:range];
                if ([startCharacter rangeOfCharacterFromSet:_charSet].location != NSNotFound)
                {
                    hitPosition.start += 1;
                }
            }
            if (hitPosition.end != [content.content length] - 1)
            {
                NSRange range = NSMakeRange(hitPosition.end - 1, 1);
                NSString *endCharacter = [content.content substringWithRange:range];
                if ([endCharacter rangeOfCharacterFromSet:_charSet].location != NSNotFound)
                {
                    hitPosition.end -= 1;
                }
            }
            
            [highlights addObject:hitPosition];
            [allHighlights addObject:hitPosition];
            
            NSInteger startBracket = hitPosition.start - MATCH_WINDOW;
            NSInteger endBracket   = hitPosition.end   + MATCH_WINDOW;
            
            if (startBracket < 0)
            {
                startBracket = 0;
            }
            if (startBracket <= scanStart)
            {
                startBracket = scanStart;
            }
            if (endBracket >= [content.content length])
            {
                endBracket = [content.content length];
            }
            
            BOOL skipFirst = YES;
            BOOL failed = NO;
            NSInteger lastPosition = hitPosition.end;
            
            for (NSRegularExpression *clause in _searchClauses)
            {
                if (skipFirst)
                {
                    skipFirst = NO;
                }
                else
                {
                    NSInteger nextStart = startBracket;
                    NSTextCheckingResult *bestMatch = nil;
                    NSInteger minDistance = 999999;
                    
                    while (YES)
                    {
                        NSTextCheckingResult *otherMatch = [clause firstMatchInString:content.content
                                                                              options:0
                                                                                range:NSMakeRange(nextStart, endBracket - nextStart)];
                        NSInteger ourDistance = 0;
                        if (otherMatch)
                        {
                            HitPosition *otherHitPosition = [[HitPosition alloc] initWithStart:otherMatch.range.location andEnd:otherMatch.range.location + otherMatch.range.length ];
                            otherHitPosition.regex = [_searchClauses objectAtIndex:0];
                            
                            if (otherHitPosition.start != 0)
                            {
                                NSRange range = NSMakeRange(otherHitPosition.start, 1);
                                NSString *startCharacter = [content.content substringWithRange:range];
                                if ([startCharacter rangeOfCharacterFromSet:_charSet].location != NSNotFound)
                                {
                                    otherHitPosition.start += 1;
                                }
                            }
                            if (otherHitPosition.end != [content.content length] - 1)
                            {
                                NSRange range = NSMakeRange(otherHitPosition.end - 1, 1);
                                NSString *endCharacter = [content.content substringWithRange:range];
                                if ([endCharacter rangeOfCharacterFromSet:_charSet].location != NSNotFound)
                                {
                                    otherHitPosition.end -= 1;
                                }
                            }
                            
                            if (otherMatch.range.location < match.range.location)
                            {
                                ourDistance = match.range.location - otherMatch.range.location - otherMatch.range.length;
                            }
                            else
                            {
                                ourDistance = otherMatch.range.location - match.range.location - match.range.length;
                            }
                            if (ourDistance < minDistance)
                            {
                                // do not add the same match to the array
                                if (![allHighlights containsObject:otherHitPosition])
                                {
                                    bestMatch = otherMatch;
                                    minDistance = ourDistance;
                                    [allHighlights addObject:otherHitPosition];
                                }
                                else
                                {
                                    // if we have this match we don't have to rescan for closest one - because this one is the closest
                                    shouldBeRescaned = NO;
                                }
                                
                            }
                            nextStart = otherMatch.range.location + otherMatch.range.length + 1;
                            if (nextStart >= [content.content length] || nextStart >= endBracket)
                            {
                                break;
                            }
                        }
                        else
                        {
                            break;
                        }
                        
                        otherMatch = nil;
                    }
                    if (bestMatch == nil)
                    {
                        failed = YES;
                        break;
                    }
                    
                    HitPosition *bestHitPosition = [[HitPosition alloc] initWithStart:bestMatch.range.location andEnd:bestMatch.range.location + bestMatch.range.length ];
                    bestHitPosition.regex = clause;
                    
                    if (bestHitPosition.start != 0)
                    {
                        NSRange range = NSMakeRange(bestHitPosition.start, 1);
                        NSString *startCharacter = [content.content substringWithRange:range];
                        if ([startCharacter rangeOfCharacterFromSet:_charSet].location != NSNotFound)
                        {
                            bestHitPosition.start += 1;
                        }
                    }
                    if (bestHitPosition.end != [content.content length] - 1)
                    {
                        NSRange range = NSMakeRange(bestHitPosition.end - 1, 1);
                        NSString *endCharacter = [content.content substringWithRange:range];
                        if ([endCharacter rangeOfCharacterFromSet:_charSet].location != NSNotFound)
                        {
                            bestHitPosition.end -= 1;
                        }
                    }
                    
                    
                    [highlights addObject:bestHitPosition];
                    if (bestMatch.range.location + bestMatch.range.length > lastPosition)
                    {
                        lastPosition = bestMatch.range.location + bestMatch.range.length;
                    }
                }
            }
            if (failed)
            {
                if ([highlights count] < [_searchClauses count]) {
                    [highlights removeAllObjects];
                }
                NSMutableArray *sortedHighlights = [[NSMutableArray alloc] initWithArray:[highlights sortedArrayUsingSelector:@selector(compare:)]];
                if ([sortedHighlights count]) {
                    [searchResult.hits addObject:sortedHighlights];
                }
            }
            else
            {
                NSMutableArray *sortedHighlights = [[NSMutableArray alloc] initWithArray:[highlights sortedArrayUsingSelector:@selector(compare:)]];
                if ([sortedHighlights count]) {
                    [searchResult.hits addObject:sortedHighlights];
                }
                
            }
            scanStart = lastPosition + 1;
        }
        else
        {
            break;
        }
        
        match = nil;
    }
    
    
    // rescan for first clause - we should find the closest one hit
    if ([searchResult.hits count] && [_searchClauses count] > 1 && shouldBeRescaned)
    {
        for (int i =0; i < [searchResult.hits count]; i++)
        {
            NSMutableArray *hit = [searchResult.hits objectAtIndex:i];
            while (YES)
            {
                HitPosition *firstHit = [hit objectAtIndex:0];
                HitPosition *lastHit = [hit objectAtIndex:[hit count] - 1];
                NSUInteger rescanStart = firstHit.end;
                NSUInteger rescanEnd = lastHit.start;
                
                if ((rescanEnd - rescanStart) == 1)
                {
                    break;
                }
                
                NSTextCheckingResult *closestMatch = [firstHit.regex firstMatchInString:content.content
                                                                                options:0
                                                                                  range:NSMakeRange(rescanStart, rescanEnd - rescanStart)];
                if (closestMatch)
                {
                    HitPosition *hitPosition = [[HitPosition alloc] initWithStart:closestMatch.range.location andEnd:closestMatch.range.location + closestMatch.range.length ];
                    hitPosition.regex = firstHit.regex;
                    
                    if (hitPosition.start != 0)
                    {
                        NSRange range = NSMakeRange(hitPosition.start, 1);
                        NSString *startCharacter = [content.content substringWithRange:range];
                        if ([startCharacter rangeOfCharacterFromSet:_charSet].location != NSNotFound)
                        {
                            hitPosition.start += 1;
                        }
                    }
                    if (hitPosition.end != [content.content length] - 1)
                    {
                        NSRange range = NSMakeRange(hitPosition.end - 1, 1);
                        NSString *endCharacter = [content.content substringWithRange:range];
                        if ([endCharacter rangeOfCharacterFromSet:_charSet].location != NSNotFound)
                        {
                            hitPosition.end -= 1;
                        }
                    }

                    
                    [hit replaceObjectAtIndex:0 withObject:hitPosition];
                    
                    NSMutableArray *sortedHighlights = [[NSMutableArray alloc] initWithArray:[hit sortedArrayUsingSelector:@selector(compare:)]];
                    [searchResult.hits removeObjectAtIndex:i];
                    [searchResult.hits insertObject:sortedHighlights atIndex:i];
                    
                }
                else
                {
                    break;
                }
            }
        }
    }
    
    return searchResult;
}

@end
