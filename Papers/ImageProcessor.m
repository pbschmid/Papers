//
//  ImageProcessor.m
//  Papers
//
//  Created by Philippe Schmid on 25.03.15.
//  Copyright (c) 2015 Philippe Schmid. All rights reserved.
//

#import "ImageProcessor.h"
#import <GPUImage/GPUImage.h>

@implementation ImageProcessor

#pragma mark - Initializers

+ (ImageProcessor *)sharedImageProcessor
{
    static ImageProcessor *_sharedImageProcessor = nil;
    static dispatch_once_t oncePredicate = 0;
    dispatch_once(&oncePredicate, ^{
        _sharedImageProcessor = [[ImageProcessor alloc] init];
    });
    return _sharedImageProcessor;
}

#pragma mark - Image Preprocessing

- (UIImage *)preprocessSourceImage:(UIImage *)sourceImage
{
    // initialize GPUImage treshold filter
    GPUImageAdaptiveThresholdFilter *stillImageFilter = [[GPUImageAdaptiveThresholdFilter alloc] init];
    stillImageFilter.blurRadiusInPixels = 4.0; // default 4.0
    
    // retrieve filtered image
    UIImage *filteredImage = [stillImageFilter imageByFilteringImage:sourceImage];
    
    // save images to documents
    NSData *inputData = UIImagePNGRepresentation(sourceImage);
    NSData *filteredData = UIImagePNGRepresentation(filteredImage);
    
    NSString *inputPath = [Utility documentsPathForFileName:@"input.png"];
    NSString *filteredPath = [Utility documentsPathForFileName:@"filtered.png"];
    
    [inputData writeToFile:inputPath atomically:YES];
    [filteredData writeToFile:filteredPath atomically:YES];
    
    return filteredImage;
}

@end
