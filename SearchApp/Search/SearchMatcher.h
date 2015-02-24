//
//  SearchMatcher.h
//  SearchTest
//
//  Created by Sergey Yuryev on 17.08.13.
//  Copyright (c) 2013 syuryev. All rights reserved.
//

#import <Foundation/Foundation.h>

/* 
 * Little helper class to store a regular expression and a matcher for searching ease.
 */
@interface SearchMatcher : NSObject

-(id)initWithRegex:(NSString *)regex andMatcher:(NSMutableString *)matcher;

@property (nonatomic, strong) NSMutableString *regex;
@property (nonatomic, strong) NSMutableString *matcher;

@end
