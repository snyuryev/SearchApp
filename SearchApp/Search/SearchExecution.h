//
//  SearchExecution.h
//  SearchTest
//
//  Created by Sergey Yuryev on 16.08.13.
//  Copyright (c) 2013 syuryev. All rights reserved.
//

@class ParseList;
@class SearchResult;
@class Lemmatizer;
@class Synonyms;
@class SearchResult;
@class Content;

#import <Foundation/Foundation.h>

/* 
 * The SearchExecution class takes a ParseList and executes the search, generating
 * a SearchResult
 */
@interface SearchExecution : NSObject

- (SearchResult *) executeSearchWithParseList:(ParseList *) parseList andContent:(Content *) content isVerbose:(BOOL) isVerbose;

@property (nonatomic, strong) Lemmatizer *lemmatizer;
@property (nonatomic, strong) Synonyms *synonyms;
@property (nonatomic, strong) SearchResult *searchResult;
@property (nonatomic, strong) NSString *wordBoundaries;
@property (nonatomic, strong) NSMutableArray *andClauses;
@property (nonatomic, strong) NSMutableArray *searchClauses;

- (NSRegularExpression *)regularExpressionWithString:(NSString *)string ;

@end
