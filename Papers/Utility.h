//
//  Utility.h
//  Papers
//
//  Created by Philippe Schmid on 25.03.15.
//  Copyright (c) 2015 Philippe Schmid. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Utility : NSObject

+ (UIAlertController *)showActionSheetWithTitle:(NSString *)title name:(NSString *)name method:(SEL)method;
+ (UIAlertController *)showAlertViewWithTitle:(NSString *)title message:(NSString *)message;
+ (NSString *)documentsPathForFileName:(NSString *)name;

@end
