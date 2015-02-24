//
//  ParseList.h
//  SearchTest
//
//  Created by Sergey Yuryev on 16.08.13.
//  Copyright (c) 2013 syuryev. All rights reserved.
//

#import <Foundation/Foundation.h>

/* 
 * Properly, this would be a ParseTree, as you really want to be working with operators and operands,
 * but as we're doing this really simply, it's just a list of the tokens.
 */
@interface ParseList : NSObject

@property(nonatomic, strong) NSMutableArray *tokens;

/* 
 * Collate our tokens for printing ...
 */
- (NSString *) printParseList;


@end
