//
//  DetailViewController.m
//  Papers
//
//  Created by Philippe Schmid on 25.03.15.
//  Copyright (c) 2015 Philippe Schmid. All rights reserved.
//

#import "DetailViewController.h"
#import <Photos/Photos.h>
#import "Utility.h"

@interface DetailViewController () <UINavigationControllerDelegate>

@end

@implementation DetailViewController

#pragma mark - Initializers

- (id)init
{
    self = [super init];
    if (self) {
        self.navigationController.delegate = self;
    }
    return self;
}

#pragma mark - View life cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Configure the view
    self.view.backgroundColor = universalBackgroundColor;
    [self configureNavigationBar];
    
    // Fetch the image to show in the detail view
    PHFetchResult *fetchResult = [PHAsset fetchAssetsWithALAssetURLs:@[self.imagePath] options:nil];
    PHAsset *asset = [fetchResult lastObject];
    
    PHImageManager *manager = [PHImageManager defaultManager];
    [manager requestImageForAsset:asset
                       targetSize:PHImageManagerMaximumSize
                      contentMode:PHImageContentModeDefault
                          options:nil
                    resultHandler:^(UIImage *result, NSDictionary *info) {
                        // Set the image to show
                        [self setImageViewForResult:result];
                    }];
}

- (void)loadView
{
    CGRect applicationFrame = [[UIScreen mainScreen] applicationFrame];
    UIView *contentView = [[UIView alloc] initWithFrame:applicationFrame];
    self.view = contentView;
}

- (void)configureNavigationBar
{
    // UINavigationItemTitleView
    UILabel *titleLabel = [Utility createTitleViewForTitle:@"Image" textColor:universalTextColor];
    self.navigationItem.titleView = titleLabel;
}

#pragma mark - Set the ImageView

- (void)setImageViewForResult:(UIImage *)result
{
    // Get the bounds of the main frame
    CGRect frame = [[UIScreen mainScreen] bounds];
    CGFloat oldHeight = frame.size.height;
    CGFloat navHeight = self.navigationController.navigationBar.frame.size.height;
    CGFloat statHeight = [UIApplication sharedApplication].statusBarFrame.size.height;
    
    // Set a frame for the image view
    CGFloat newHeight = oldHeight-navHeight-statHeight;
    CGRect newFrame = CGRectMake(0, navHeight+statHeight, frame.size.width, newHeight);
    
    // Set the image for the image view
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:newFrame];
    imageView.image = result;
    // TODO: Format image size to look nice in image view!
    [self.view addSubview:imageView];
}

#pragma mark - Memory Management

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
