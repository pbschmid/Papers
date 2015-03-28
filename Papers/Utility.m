//
//  Utility.m
//  Papers
//
//  Created by Philippe Schmid on 25.03.15.
//  Copyright (c) 2015 Philippe Schmid. All rights reserved.
//

#import "Utility.h"
#import "MBProgressHUD.h"

@implementation Utility

#pragma mark - Initializers

+ (id)alloc
{
    [NSException raise:@"Cannot be instantiated!" format:@"Static class Uitility cannot be instantiated."];
    return nil;
}

#pragma mark - MBProgressHUD

+ (MBProgressHUD *)createProgressHUDForView:(UIView *)sourceView withTitle:(NSString *)title
{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:sourceView animated:YES];
    hud.mode = MBProgressHUDModeIndeterminate;
    hud.labelColor = [UIColor colorWithWhite:0.9 alpha:0.7];
    hud.labelFont = [UIFont fontWithName:@"HelveticaNeue-Light" size:15];
    hud.labelText = [NSString stringWithFormat:NSLocalizedString(@"%@", @""), title];
    hud.backgroundColor = [UIColor colorWithWhite:0.1f alpha:0.3f];
    return hud;
}

#pragma mark - Documents Helper

+ (NSString *)documentsPathForFileName:(NSString *)name
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsPath = [paths objectAtIndex:0];
    return [documentsPath stringByAppendingPathComponent:name];
}

@end
