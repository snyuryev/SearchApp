//
//  SearchResult.h
//  SearchTest
//
//  Created by Sergey Yuryev on 16.08.13.
//  Copyright (c) 2013 syuryev. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Content;
@class Snippet;

/* 
 * The results of a search.  Each hit consists of a set of
 * HitPositions indicating the word hits.  We use
 * that for highlighting.
 */
@interface SearchResult : NSObject

/*
 * Given a hit (list of matches), calculate the KWIC (keyword in context) text for it ...
 */
- (NSString *) calculateKWIC:(NSMutableArray *) hit;

- (Snippet *) calculateSnippet:(NSMutableArray *) hit;

-(id)initWithContent:(Content *) content;

-(NSString *) printSearchResult;


@property (nonatomic, strong) Content *content;
@property (nonatomic, strong) NSMutableArray *hits;

@end
