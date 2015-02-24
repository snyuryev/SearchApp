//
//  ViewController.m
//  SearchApp
//
//  Created by Sergey Yuryev on 07/10/14.
//  Copyright (c) 2014 snyuryev. All rights reserved.
//

#import "ViewController.h"

#import "Tokenizer.h"
#import "ParseList.h"
#import "SearchExecution.h"
#import "Content.h"
#import "SearchResult.h"
#import "Snippet.h"

@interface ViewController ()

@property (nonatomic) NSMutableArray *items;

@property (nonatomic) Content *content;
@property (nonatomic) Tokenizer *tokenizer;

- (void) setupGesture;
- (void) setupSearch;

@end

@implementation ViewController

- (void) viewDidLoad
{
    [super viewDidLoad];
    
    [self setupGesture];
    [self setupSearch];
    
    self.items = [NSMutableArray new];
}

- (void) didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark -  Searching

- (void) setupSearch
{
    NSString *filePath = [[NSBundle mainBundle] pathForResource:CONTENT_FILE_NAME ofType:nil];
    NSError *error = nil;
    NSString *contentString = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:&error];
    
    if (error != nil)
    {
        NSLog(@"Error:%@", error);
    }
    
    self.content = [[Content alloc] initWithString:contentString];
    self.tokenizer = [[Tokenizer alloc] init];
}

- (void) filterContentForSearchText:(NSString*)searchText
{
    ParseList *parseList = [_tokenizer tokenize:searchText];
    SearchExecution *searchExecution = [[SearchExecution alloc] init];
    SearchResult *searchResult = [searchExecution executeSearchWithParseList:parseList andContent:_content isVerbose:NO];
    
    [_items removeAllObjects];
    
    if ([searchResult.hits count])
    {
        for (NSMutableArray *hit in searchResult.hits)
        {
            Snippet *snippet =  [searchResult calculateSnippet:[NSMutableArray arrayWithArray:hit]];
            [_items addObject:snippet];
        }
    }
}

- (void) searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    [self filterContentForSearchText:searchBar.text];
    [_tableView reloadData];
}

- (void) searchBarTextDidEndEditing:(UISearchBar *)aSearchBar
{
    [aSearchBar resignFirstResponder];
}

- (void) searchBarCancelButtonClicked:(UISearchBar*)searchBar
{
    [searchBar resignFirstResponder];
    searchBar.text = @"";
    [_tableView reloadData];
}

- (void) searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];
}

#pragma mark - Table

- (void) tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath*)indexPath
{
    
}

- (UITableViewCell*) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath
{
    NSString *kCellIdentifier = @"kCellIdentifier";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier];
    
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:kCellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    UILabel *cellLabel = (UILabel *)[cell viewWithTag:100];
    
    Snippet *currentSnippet = [_items objectAtIndex:indexPath.row];
    NSString *snippetText = currentSnippet.snippetText;

    NSDictionary *attrRegularDict = [NSDictionary dictionaryWithObjectsAndKeys:[UIColor blackColor], NSForegroundColorAttributeName, nil];

    NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] initWithString:snippetText attributes:attrRegularDict];
   
    for (int i = 0; i < [currentSnippet.wordsRangesInSnippet count]; i++)
    {
        NSRange selectionRange = [[currentSnippet.wordsRangesInSnippet objectAtIndex:i] rangeValue];
        [attrString addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:selectionRange];
    }

    [cellLabel setAttributedText:attrString];
   
    return cell;
}

- (NSInteger) tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_items count];
}

- (NSInteger) numberOfSectionsInTableView:(UITableView*)tableView
{
    return 1;
}


#pragma mark - Gesture

- (void) setupGesture
{
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard)];
    tapGestureRecognizer.cancelsTouchesInView = NO;
    [self.tableView addGestureRecognizer:tapGestureRecognizer];
}

- (void) hideKeyboard
{
    [_searchBar resignFirstResponder];
}

@end
