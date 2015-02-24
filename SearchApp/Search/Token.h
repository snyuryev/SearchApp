//
//  Token.h
//  SearchTest
//
//  Created by Sergey Yuryev on 17.08.13.
//  Copyright (c) 2013 syuryev. All rights reserved.
//

#import <Foundation/Foundation.h>

/*
 * Token represents an individual "term" extracted from the input query.
 * A Token may also be a literal string (a clause) as defined by double-quotes.
 */
@interface Token : NSObject

@property (nonatomic, strong) NSMutableString *token; // Records the string that makes up this token
@property (nonatomic) BOOL isLiteral; // Is this token to be literally (exactly) searched?
@property (nonatomic, strong) NSString *startSpecial; // Did it start specially?  (For us, just double-quote.)
@property (nonatomic, strong) NSString *endSpecial;  // Did it end specially?  (For us, just double-quote.)

/* Init
 */
-(id)initWithToken:(NSString *)token;

/* Return a print-happy string representation of ourselves ...
 */
-(NSString *) printToken;

/*
 * We're going to do some simple clean-up, here.  But if we're already in a literal string, just check
 * to see if we complete it ...
 * If we started or ended with a special character, record it.
 * 1. If the token starts with a parenthesis:
 * a.  If it ends with a parenthesis, keep the parens:  (a)(2)
 * b.  Otherwise, remove the parens.
 * 2. If the token ends with a parenthesis:
 * a.  If there is a start-paren in the word, keep the parens:  168(a)
 * b.  Otherwise, remove the parens.
 * 3. If the token starts with a double-quote:
 * a.  If it ends with a double-quote, remove the quotes, mark as literal, and stop further processing:  "sec.(192)"
 * b.  Otherwise, remove the double-quote and store it as a starting special character.
 * 4. If the token ends with a double-quote, and we haven't already picked it up, remove it.
 * 5. If the token starts with a period, colon or single-quote, remove.
 * 6. If the token ends with a period, colon or single-quote, remove.
 * If the token is an uppercase OR or AND, assume that the user is trying to use boolean, and throw
 * out the entire token (as the search will default to AND, anyhow).
 */
- (void) finalizeExtraction: (BOOL) inLiteral;


@end
