//
//  UITableView+Category.m
//  Papers
//
//  Created by Philippe Schmid on 08.04.15.
//  Copyright (c) 2015 Philippe Schmid. All rights reserved.
//

#import "UITableView+Category.h"

@implementation UITableView (Category)

+ (UITableView *)tableViewWithFrame:(CGRect)frame
{
    UITableView *tableView = [[UITableView alloc] init];
    tableView = [[UITableView alloc] init];
    tableView.pagingEnabled = YES;
    tableView.backgroundColor = universalBackgroundColor;
    tableView.separatorColor = [UIColor colorWithWhite:0.6 alpha:0.8];
    tableView.frame = frame;
    return tableView;
}

@end
