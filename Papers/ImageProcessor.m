//
//  ImageProcessor.m
//  Papers
//
//  Created by Philippe Schmid on 25.03.15.
//  Copyright (c) 2015 Philippe Schmid. All rights reserved.
//

#import "ImageProcessor.h"

@implementation ImageProcessor

/* 
 
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
 
 // initialize PDF client
 self.pdfClient = [PDFClient sharedPDFClient];
 
 // save images to documents
 NSData *inputData = UIImagePNGRepresentation(inputImage);
 NSData *filteredData = UIImagePNGRepresentation(filteredImage);
 
 NSString *inputPath = [self.pdfClient documentsPathForFileName:@"input.png"];
 NSString *filteredPath = [self.pdfClient documentsPathForFileName:@"filtered.png"];
 
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
 
 */

@end
