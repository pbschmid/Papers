//
//  PDFClient.m
//  Papers
//
//  Created by Philippe Schmid on 05.03.15.
//  Copyright (c) 2015 Philippe Schmid. All rights reserved.
//

#import "PDFClient.h"
#import <CoreText/CoreText.h>

@implementation PDFClient

#pragma mark - Initializers

+ (PDFClient *)sharedPDFClient
{
    static PDFClient *_sharedPDFClient = nil;
    static dispatch_once_t oncePredicate = 0;
    dispatch_once(&oncePredicate, ^{
        _sharedPDFClient = [[PDFClient alloc] init];
    });
    return _sharedPDFClient;
}

#pragma mark - PDF Creation

- (void)createPDFForText:(NSString *)text
{
    NSString *textToDraw = @"Hello World";
    
    // string to draw and filename
    CFStringRef stringRef = (__bridge CFStringRef)textToDraw;
    NSString *pdfFileName = [self documentsPathForFileName:@"scannedText.PDF"];
    
    // core text frameset
    CFAttributedStringRef currentText = CFAttributedStringCreate(NULL, stringRef, NULL);
    CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString(currentText);
    
    CGRect frameRect = CGRectMake(0, 0, 300, 50);
    CGMutablePathRef framePath = CGPathCreateMutable();
    CGPathAddRect(framePath, NULL, frameRect);
    
    // get the frame for rendering
    CFRange currentRange = CFRangeMake(0, 0);
    CTFrameRef frameRef = CTFramesetterCreateFrame(framesetter, currentRange, framePath, NULL);
    CGPathRelease(framePath);
    
    // create pdf context with defaul page size 612 x 792
    UIGraphicsBeginPDFContextToFile(pdfFileName, CGRectZero, nil);
    
    // new page beginning
    UIGraphicsBeginPDFPageWithInfo(CGRectMake(0, 0, 612, 792), nil);
    
    // get graphics context
    CGContextRef currentContext = UIGraphicsGetCurrentContext();
    
    // core text drawing preparation
    CGContextSetTextMatrix(currentContext, CGAffineTransformIdentity);
    CGContextTranslateCTM(currentContext, 0, 100);
    CGContextScaleCTM(currentContext, 1.0, -1.0);
    
    // draw the frame
    CTFrameDraw(frameRef, currentContext);
    
    // cleanup
    CFRelease(frameRef);
    CFRelease(stringRef);
    CFRelease(framesetter);
    
    // close context
    UIGraphicsEndPDFContext();
}

@end
