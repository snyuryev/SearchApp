//
//  SearchResult.m
//  SearchTest
//
//  Created by Sergey Yuryev on 16.08.13.
//  Copyright (c) 2013 syuryev. All rights reserved.
//

#import "SearchResult.h"
#import "Content.h"
#import "HitPosition.h"
#import "Snippet.h"

@interface SearchResult ()

- (NSString *) replaceAllNewlines:(NSString *) originalString;

@end

@implementation SearchResult

-(id)initWithContent:(Content *) content
{
    if (!(self = [super init]))
        return nil;
    
    self.content = content;
    self.hits = [[NSMutableArray alloc] initWithCapacity:10];
    return self;
}

- (NSString *) replaceAllNewlines:(NSString *) originalString
{
    NSString *newString = [[originalString componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]] componentsJoinedByString:@" "];
    NSString *returnString = [[NSString alloc] initWithString:newString];
    return returnString;
}


- (Snippet *) calculateSnippet:(NSMutableArray *) hit
{
    Snippet *snippet = [[Snippet alloc] init];
    
    for (HitPosition *highlight in hit)
    {
        NSRange rangeFromContent = NSMakeRange(highlight.start, highlight.end - highlight.start);
        NSString *wordFromContent = [NSString stringWithFormat:@"%@", [_content.content substringWithRange:rangeFromContent]];
        // collect ranges in content
        [snippet.wordsRangesInContent addObject:[NSValue valueWithRange:rangeFromContent]];
        // collect highlighted words
        [snippet.wordsToHighlight addObject:wordFromContent];
    }
    
    HitPosition *hitObj = [hit objectAtIndex:0];
    NSInteger startKWIC = hitObj.start - PRECEDING_CHARS;
    NSInteger endKWIC = 0;
    
    NSMutableString *kwicText = [[NSMutableString alloc] initWithString:@""];
    
    if (startKWIC < 0)
    {
        startKWIC = 0;
    }
    
    while (startKWIC > 0)
    {
        NSString *singleCharacter = [NSString stringWithFormat:@"%@", [_content.content substringWithRange:NSMakeRange(startKWIC - 1, 1)]];
        if ([singleCharacter isEqualToString:@" "])
        {
            break;
        }
        startKWIC -= 1;
    }
    
    NSUInteger snippetShift = 0;
    
    for (HitPosition *highlight in hit)
    {
        NSInteger start = highlight.start;
        NSInteger end   = highlight.end;
        if (start > startKWIC)
        {
            NSString *startTest = [NSString stringWithFormat:@"%@",[self replaceAllNewlines:[_content.content substringWithRange:NSMakeRange(startKWIC, start - startKWIC)]]];
            [kwicText setString:[NSString stringWithFormat:@"%@%@", kwicText, startTest]];
            snippetShift = [kwicText length];
            NSRange rangeForSnippet = NSMakeRange(snippetShift, end - start);
            [snippet.wordsRangesInSnippet addObject:[NSValue valueWithRange:rangeForSnippet]];
        }
        else if (start == 0)
        {
            NSString *startTest = [NSString stringWithFormat:@"%@",[self replaceAllNewlines:[_content.content substringWithRange:NSMakeRange(startKWIC, start - startKWIC)]]];
            [kwicText setString:[NSString stringWithFormat:@"%@%@", kwicText, startTest]];
            snippetShift = [kwicText length];
            NSRange rangeForSnippet = NSMakeRange(snippetShift, end - start);
            [snippet.wordsRangesInSnippet addObject:[NSValue valueWithRange:rangeForSnippet]];
        }
        NSString *highTest = [NSString stringWithFormat:@"%@", [_content.content substringWithRange:NSMakeRange(start, end - start)]];
        [kwicText setString:[NSString stringWithFormat:@"%@%@ ", kwicText, highTest]];
        
        startKWIC = end;
        
        if ([kwicText length] > MAX_KWIC_CHARS) {
            break;
        }
    }
    
    endKWIC = startKWIC + FOLLOWING_CHARS;
    
    if (endKWIC > [_content.content length])
    {
        NSUInteger diff = endKWIC - [_content.content length];
        endKWIC = endKWIC - diff;
    }
    
    while (endKWIC < [_content.content length])
    {
        NSString *singleCharacter = [NSString stringWithFormat:@"%@", [_content.content substringWithRange:NSMakeRange(endKWIC - 1, 1)]];
        if ([singleCharacter isEqualToString:@" "])
        {
            break;
        }
        endKWIC += 1;
    }
    NSString *lastString = [NSString stringWithFormat:@"%@", [self replaceAllNewlines:[_content.content substringWithRange:NSMakeRange(startKWIC, endKWIC - startKWIC)]]];
    
    [kwicText setString:[NSString stringWithFormat:@"%@%@", kwicText, lastString]];
    
    [snippet.snippetText setString:[NSString stringWithString:kwicText]];
    return snippet;
}

- (NSString *) calculateKWIC:(NSMutableArray *) hit
{
    HitPosition *hitObj = [hit objectAtIndex:0];
    NSInteger startKWIC = hitObj.start - PRECEDING_CHARS;
    NSInteger endKWIC = 0;
    
    NSMutableString *kwicText = [[NSMutableString alloc] initWithString:@""];
    
    if (startKWIC < 0)
    {
        startKWIC = 0;
    }
    
    while (startKWIC > 0)
    {
        NSString *singleCharacter = [NSString stringWithFormat:@"%@", [_content.content substringWithRange:NSMakeRange(startKWIC - 1, 1)]];
        if ([singleCharacter isEqualToString:@" "])
        {
            break;
        }
        startKWIC -= 1;
    }
    
    for (HitPosition *highlight in hit)
    {
        NSInteger start = highlight.start;
        NSInteger end   = highlight.end;
        if (start > startKWIC)
        {
            NSString *startTest = [NSString stringWithFormat:@"%@", [_content.content substringWithRange:NSMakeRange(startKWIC, start - startKWIC)]];
            [kwicText setString:[NSString stringWithFormat:@"%@%@", kwicText, startTest]];
        }
        
        NSString *highTest = [NSString stringWithFormat:@"%@", [_content.content substringWithRange:NSMakeRange(start, end -start)]];
        [kwicText setString:[NSString stringWithFormat:@"%@%@ ", kwicText, highTest]];
        startKWIC = end;
        
        if ([kwicText length] > MAX_KWIC_CHARS) {
            break;
        }
    }
    
    endKWIC = startKWIC + FOLLOWING_CHARS;
    
    if (endKWIC > [_content.content length])
    {
        NSUInteger diff = endKWIC - [_content.content length];
        endKWIC = endKWIC - diff;
    }
    
    while (endKWIC < [_content.content length])
    {
        NSString *singleCharacter = [NSString stringWithFormat:@"%@", [_content.content substringWithRange:NSMakeRange(endKWIC - 1, 1)]];
        if ([singleCharacter isEqualToString:@" "])
        {
            break;
        }
        endKWIC += 1;
    }
    NSString *lastString = [NSString stringWithFormat:@"%@", [_content.content substringWithRange:NSMakeRange(startKWIC, endKWIC - startKWIC)]];
    
    [kwicText setString:[NSString stringWithFormat:@"%@%@", kwicText, lastString]];
    
    NSString *returnString = [NSString stringWithString:kwicText];
    return returnString;
}


- (NSString *) printSearchResult
{
    NSMutableString *output =[[NSMutableString alloc] initWithString:@""];
    
    for (NSMutableArray *hit in _hits)
    {
        NSArray *sortedArray = [hit sortedArrayUsingSelector:@selector(compare:)];
        [output appendString:@"\n---\n"];
        [output appendString:[self calculateKWIC:[NSMutableArray arrayWithArray:sortedArray]]];
    }
    
    NSString *returnString = [NSString stringWithString:output];
    return returnString;
}

@end
