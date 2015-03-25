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

+ (MBProgressHUD *)createProgressHUDForView:(UIView *)sourceView;
+ (NSString *)documentsPathForFileName:(NSString *)name;

@end
