//
//  DetailViewController.m
//  Papers
//
//  Created by Philippe Schmid on 25.03.15.
//  Copyright (c) 2015 Philippe Schmid. All rights reserved.
//

#import "DetailViewController.h"

@interface DetailViewController () <UINavigationControllerDelegate>

@end

@implementation DetailViewController

#pragma mark - Initializers

- (id)init
{
    self = [super init];
    if (self) {
    }
    return self;
}

#pragma mark - View life cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Set the image to show
    UIImage *imageToShow = [[UIImage alloc] initWithContentsOfFile:self.imagePath];
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame]];
    [imageView setImage:imageToShow];
    [self.view addSubview:imageView];
}

- (void)loadView
{
    CGRect applicationFrame = [[UIScreen mainScreen] applicationFrame];
    UIView *contentView = [[UIView alloc] initWithFrame:applicationFrame];
    self.view = contentView;
}

#pragma mark - Memory Management

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
