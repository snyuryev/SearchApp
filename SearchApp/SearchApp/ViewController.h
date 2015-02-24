//
//  ViewController.h
//  SearchApp
//
//  Created by Sergey Yuryev on 07/10/14.
//  Copyright (c) 2014 snyuryev. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate>

@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

