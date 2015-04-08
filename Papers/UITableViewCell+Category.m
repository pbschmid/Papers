//
//  UITableViewCell+Category.m
//  Papers
//
//  Created by Philippe Schmid on 08.04.15.
//  Copyright (c) 2015 Philippe Schmid. All rights reserved.
//

#import "UITableViewCell+Category.h"

@implementation UITableViewCell (Category)

- (void)configureCellForDate:(NSDate *)date
{
    UIView *selectedView = [[UIView alloc] initWithFrame:CGRectZero];
    selectedView.backgroundColor = [UIColor colorWithWhite:1.0f alpha:0.2f];
    self.backgroundColor = [UIColor clearColor];
    self.selectedBackgroundView = selectedView;
    self.textLabel.textColor = universalTextColor;
    self.textLabel.font = [UIFont fontWithName:@"HelveticaNeue-UltraLight" size:15];
    self.textLabel.text = [NSString stringWithFormat:NSLocalizedString(@"%@", @""), date];
}

@end
