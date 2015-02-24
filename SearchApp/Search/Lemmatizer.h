//
//  Lemmatizer.h
//  SearchTest
//
//  Created by Sergey Yuryev on 17.08.13.
//  Copyright (c) 2013 syuryev. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface Lemmatizer : NSObject

/*
 * We're just going to handle some very simple cases ...
 * horses --> horse[s]*
 * horse --> horse[s]*
 
 * This has nothing to do with lemmatization, but because in theory we could be splitting up the term, here
 * (properly, all of that should go into a parse tree ...), we're going to add equivalencies for S/section symbol
 * and P/paragraph symbol at the start of words.
 */
- (NSString *) expandEquivalencies: (NSString *) term;

@end
