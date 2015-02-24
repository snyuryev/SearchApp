//
//  Tokenizer.h
//  SearchTest
//
//  Created by Sergey Yuryev on 16.08.13.
//  Copyright (c) 2013 syuryev. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ParseList;

/* The Tokenizer is used to break up an input query into a ParseList
 * (properly, would break it up into a ParseTree).  For a more proper implementation, see Aho, Sethi & Ullman.
 */
@interface Tokenizer : NSObject


/* This is a stupidly simple (and easily optimized on almost any platform) tokenizer.  You could probably do
 * this better with a regex, but kept this for straightforwardness.  Of course, the *right* way to do this is
 * to write an actual, simple state tokenizer.  For all such things, see Aho, Sethi & Ullman.
 * Essentially, we scan through the string, starting a new token any time we find non-space characters.  We
 * keep track of whether or not we're between double-quotes to handle literal searches.
 */ 
- (ParseList *) tokenize: (NSString *) searchExpression;

@end
