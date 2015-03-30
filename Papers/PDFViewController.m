//
//  PDFViewController.m
//  Papers
//
//  Created by Philippe Schmid on 25.03.15.
//  Copyright (c) 2015 Philippe Schmid. All rights reserved.
//

#import "PDFViewController.h"
#import "PDF.h"

@interface PDFViewController () <UINavigationControllerDelegate>

@property (nonatomic, strong) NSMutableArray *allPDFs;

@end

@implementation PDFViewController

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
}

#pragma mark - MagicalRecord

- (void)saveContext
{
    [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreWithCompletion:nil];
}

- (void)fetchContext
{
    self.allPDFs = [[PDF MR_findAll] mutableCopy];
}

#pragma mark - UIWebView

- (void)showPDFWithImages
{
    NSURL *url;
    UIWebView *webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, 320, 480)];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [webView setScalesPageToFit:YES];
    [webView loadRequest:request];
    
    [self. view addSubview:webView];
}

#pragma mark - Memory Management

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
