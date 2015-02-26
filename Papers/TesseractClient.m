//
//  TesseractClient.m
//  Papers
//
//  Created by Philippe Schmid on 02.02.15.
//  Copyright (c) 2015 Philippe Schmid. All rights reserved.
//

#import "TesseractClient.h"
#import <GPUImage/GPUImage.h>
#import <TesseractOCR/TesseractOCR.h>

@interface TesseractClient () <G8TesseractDelegate>

@end

@implementation TesseractClient

#pragma mark - Initializers

+ (TesseractClient *)sharedTesseractClient
{
    static TesseractClient *_sharedTesseractClient = nil;
    static dispatch_once_t oncePredicate = 0;
    dispatch_once(&oncePredicate, ^{
        _sharedTesseractClient = [[TesseractClient alloc] init];
    });
    return _sharedTesseractClient;
}

#pragma mark - TesseractClient

- (void)startScanningImage:(UIImage *)image withCallback:(CompletionBlock)block
{
    // initialize tesseract
    G8Tesseract *tesseract = [[G8Tesseract alloc] initWithLanguage:@"eng"];
    tesseract.delegate = self;
    
    // recognize text from image
    [tesseract setVariableValue:@"0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ" forKey:@"tessedit_char_whitelist"];
    [tesseract setImage:[image g8_blackAndWhite]];
    [tesseract recognize];
    
    NSString *recognizedText = [tesseract recognizedText];
    NSLog(@"%@", recognizedText);
    
    tesseract = nil; // free memory
    
    if (recognizedText) {
        block(YES, recognizedText, nil);
    } else {
        block(NO, nil, nil);
    }
}

#pragma mark - TesseractDelegate

- (UIImage *)preprocessedImageForTesseract:(G8Tesseract *)tesseract sourceImage:(UIImage *)sourceImage
{
    // image sent to tesseract above
    UIImage *inputImage = sourceImage;
    
    // initialize GPUImage treshold filter
    GPUImageAdaptiveThresholdFilter *stillImageFilter = [[GPUImageAdaptiveThresholdFilter alloc] init];
    stillImageFilter.blurRadiusInPixels = 4.0; // default 4.0
    
    // retrieve filtered image
    UIImage *filteredImage = [stillImageFilter imageByFilteringImage:inputImage];
    
    // save images to documents
    NSData *inputData = UIImagePNGRepresentation(inputImage);
    NSData *filteredData = UIImagePNGRepresentation(filteredImage);
    
    NSString *inputPath = [self documentsPathForFileName:@"input.png"];
    NSString *filteredPath = [self documentsPathForFileName:@"filtered.png"];
    
    [inputData writeToFile:inputPath atomically:YES];
    [filteredData writeToFile:filteredPath atomically:YES];

    // bypass tesseract tresholding
    // by returning filtered image
    return filteredImage;
}

- (void)progressImageRecognitionForTesseract:(G8Tesseract *)tesseract
{
    NSLog(@"Progress: %lu", (unsigned long)tesseract.progress);
}

- (BOOL)shouldCancelImageRecognitionForTesseract:(G8Tesseract *)tesseract
{
    return NO;
}

#pragma mark - Helpers

- (NSString *)documentsPathForFileName:(NSString *)name
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsPath = [paths objectAtIndex:0];
    return [documentsPath stringByAppendingPathComponent:name];
}

@end
