//
//  DetailViewController.m
//  Papers
//
//  Created by Philippe Schmid on 25.03.15.
//  Copyright (c) 2015 Philippe Schmid. All rights reserved.
//

#import "DetailViewController.h"

@interface DetailViewController ()

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
}

#pragma mark - UIWebView

- (void)showPDFWithImages
{
    UIWebView *webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, 320, 480)];
    NSURL *url = [NSURL fileURLWithPath:self.filePath];
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
