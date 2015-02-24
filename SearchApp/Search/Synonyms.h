//
//  Synonyms.h
//  SearchTest
//
//  Created by Sergey Yuryev on 17.08.13.
//  Copyright (c) 2013 syuryev. All rights reserved.
//

#import <Foundation/Foundation.h>

/* Let's just do some fairly stupid synonym expansion for grins.
 * This is just to show how you could extend this fairly easily to handle common cases.
 * NOTE:  Because we do synonyms before we do lemma expansion, you MUST include all variants in the list
 * in order to get good matches.  This is cheap and sleazy.  You should fix this processing!
 * Also, be sure to put things in the list in the form that they'll match tokenized terms.
 * E.g., remove the trailing period.
 */
@interface Synonyms : NSObject

-(id)initWithSynonymsList:(NSString *)synonymsString;

/* Load up from an equivalencies file with each equivalency separated by a pipe.
 */
- (NSArray *) expandTerm: (NSString *) term;

@property (nonatomic, strong) NSMutableDictionary *dictionary; 
@property (nonatomic, strong) NSArray *equivalencies;

@end
