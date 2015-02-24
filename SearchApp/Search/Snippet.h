//
//  Snippet.h
//  SearchTest
//
//  Created by Sergey Yuryev on 20.08.13.
//  Copyright (c) 2013 syuryev. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Snippet : NSObject

@property (nonatomic, strong) NSMutableString *snippetText;          // text 
@property (nonatomic, strong) NSMutableArray *wordsRangesInContent;  // ranges in content
@property (nonatomic, strong) NSMutableArray *wordsRangesInSnippet;  // ranges in snipped
@property (nonatomic, strong) NSMutableArray *wordsToHighlight;      // words

@end
