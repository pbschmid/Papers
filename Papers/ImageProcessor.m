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
 
 
 
 
 
 
 
 #pragma mark - Scanning
 
 - (void)checkForScanning
 {
 if (![Image MR_hasAtLeastOneEntityInContext:[NSManagedObjectContext MR_defaultContext]]) {
 // check if images are available
 [self showAlertControllerStyleAlertWithTitle:@"No image" message:@"There is no image to scan."];
 return;
 } else if ([self.recognizedImage.imageDetails.scanned boolValue] == YES) {
 // create controller
 UIAlertController *ac = [UIAlertController alertControllerWithTitle:
 NSLocalizedString(@"Already scaned.", @"")
 message:
 NSLocalizedString(@"Do you want to scan this image again?", @"")
 preferredStyle:
 UIAlertControllerStyleAlert];
 
 // create actions
 UIAlertAction *action = [UIAlertAction actionWithTitle:NSLocalizedString(@"Yes, scan", @"") style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
 // scan image
 [self scanImage];
 }];
 UIAlertAction *cancel = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", @"") style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {}];
 
 // add actions
 [ac addAction:action];
 [ac addAction:cancel];
 
 // show controller
 [self presentViewController:ac animated:YES completion:nil];
 } else {
 // create controller
 UIAlertController *ac = [UIAlertController alertControllerWithTitle:
 NSLocalizedString(@"Are you sure?", @"")
 message:
 NSLocalizedString(@"Do you want to scan this image?", @"")
 preferredStyle:
 UIAlertControllerStyleAlert];
 
 // create actions
 UIAlertAction *action = [UIAlertAction actionWithTitle:NSLocalizedString(@"Yes, scan", @"") style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
 // scan image
 [self scanImage];
 }];
 UIAlertAction *cancel = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", @"") style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {}];
 
 // add actions
 [ac addAction:action];
 [ac addAction:cancel];
 
 // show controller
 [self presentViewController:ac animated:YES completion:nil];
 }
 }
 
 - (void)scanImage
 {
 NSLog(@"Scanning image: %@", [self.imageToRecognize description]);
 
 // configure hud
 MBProgressHUD *hud = [self createProgressHUD];
 [hud show:YES];
 
 // initialize tesseract
 self.client = [TesseractClient sharedTesseractClient];
 
 // get background thread
 dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
 [self.client startScanningImage:self.imageToRecognize withCallback:^(BOOL success, NSString *response, NSError *error) {
 dispatch_async(dispatch_get_main_queue(), ^{
 if (success) {
 // hide hud
 [hud hide:YES];
 
 // save context
 self.recognizedImage.text = response;
 self.recognizedImage.imageDetails.scanned = [NSNumber numberWithBool:YES];
 [self saveContext];
 [self.tableView reloadData];
 
 // write to file
 [self writeToTextFile];
 [self cleanUp]; // free memory
 
 // show success
 [self showAlertControllerStyleAlertWithTitle:@"Success" message:@"Your image has been scanned."];
 } else {
 // hide hud
 [hud hide:YES];
 
 // show error
 [self showAlertControllerStyleAlertWithTitle:@"Error" message:@"There was an error scanning your image."];
 }
 });
 }];
 });
 }
 
 
 
 
 
 
 
 
 
 
 */

@end
