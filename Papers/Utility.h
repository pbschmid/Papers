//
//  Utility.h
//  Papers
//
//  Created by Philippe Schmid on 25.03.15.
//  Copyright (c) 2015 Philippe Schmid. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MBProgressHUD;

@interface Utility : NSObject

+ (UILabel *)createTitleViewForTitle:(NSString *)title textColor:(UIColor *)color;
+ (MBProgressHUD *)createProgressHUDForView:(UIView *)sourceView withTitle:(NSString *)title;
+ (NSString *)documentsPathForFileName:(NSString *)name;

@end

/*

 + (UITableView *)configureTableView:(UITableView *)tableView forFrame:(CGRect)frame inView:(UIView *)view;
 
 + (UITableView *)configureTableView:(UITableView *)tableView forFrame:(CGRect)frame inView:(UIView *)view
 {
 tableView = [[UITableView alloc] init];
 tableView.pagingEnabled = YES;
 tableView.backgroundColor = universalBackgroundColor;
 tableView.separatorColor = [UIColor colorWithWhite:0.6 alpha:0.8];
 tableView.frame = frame;
 return tableView;
 }
 
*/