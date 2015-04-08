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