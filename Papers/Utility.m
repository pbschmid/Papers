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

#pragma mark - UIAlertController

+ (UIAlertController *)showActionSheetWithTitle:(NSString *)title name:(NSString *)name method:(SEL)method
{
    // Ask the controller for the C function pointer of the specified SEL
    // stackoverflow.com/questions/7017281/performselector-may-cause-a-leak-because-its-selector-is-unknown
    // Thanks to SO user wbyoung!
    IMP imp = [self methodForSelector:method];
    void (*func)(id, SEL) = (void *)imp;
    
    // Create the AlertController
    UIAlertController *ac = [UIAlertController alertControllerWithTitle:[NSString stringWithFormat:
                                                                         NSLocalizedString(@"%@", @""),
                                                                         title]
                                                                message:nil
                                                         preferredStyle:UIAlertControllerStyleActionSheet];
    
    // Create the action for the AlertController
    UIAlertAction *alertAction = [UIAlertAction actionWithTitle:[NSString stringWithFormat:
                                                                 NSLocalizedString(@"%@", @""),
                                                                 name]
                                                          style:UIAlertActionStyleDefault
                                                        handler:^(UIAlertAction *action) {
                                                            func(self, method);
                                                        }];
    
    // Cancel action
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", @"") style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {}];
    
    // Add the actions
    [ac addAction:alertAction];
    [ac addAction:cancel];
    
    return ac;
}

+ (UIAlertController *)showAlertViewWithTitle:(NSString *)title message:(NSString *)message
{
    // Create the controller
    UIAlertController *ac = [UIAlertController alertControllerWithTitle:
                             [NSString stringWithFormat:NSLocalizedString(@"%@", @""), title]
                                                                message:
                             [NSString stringWithFormat:NSLocalizedString(@"%@", @""), message]
                                                         preferredStyle:
                             UIAlertControllerStyleAlert];
    
    // Create the action
    UIAlertAction *action = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK", @"") style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {}];
    
    // Add the action
    [ac addAction:action];
    
    return ac;
}

#pragma mark - MBProgressHUD

+ (MBProgressHUD *)createProgressHUDForView:(UIView *)sourceView
{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:sourceView animated:YES];
    hud.mode = MBProgressHUDModeIndeterminate;
    hud.labelColor = [UIColor colorWithWhite:0.9 alpha:0.7];
    hud.labelFont = [UIFont fontWithName:@"HelveticaNeue-Light" size:15];
    hud.labelText = NSLocalizedString(@"Scanning...", @"");
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
