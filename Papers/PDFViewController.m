//
//  PDFViewController.m
//  Papers
//
//  Created by Philippe Schmid on 25.03.15.
//  Copyright (c) 2015 Philippe Schmid. All rights reserved.
//

#import "PDFViewController.h"
#import "UITableViewCell+Category.h"
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
        self.navigationController.delegate = self;
    }
    return self;
}

- (void)dealloc
{
    NSLog(@"DEALLOC PDFViewController.");
}

#pragma mark - View life cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = universalBackgroundColor;
    
}

- (void)loadView
{
    CGRect applicationFrame = [[UIScreen mainScreen] applicationFrame];
    UIView *contentView = [[UIView alloc] initWithFrame:applicationFrame];
    self.view = contentView;
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if ([PDF MR_hasAtLeastOneEntityInContext:[NSManagedObjectContext MR_defaultContext]]) {
        return [self.allPDFs count];
    } else {
        return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"CellIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    if ([PDF MR_hasAtLeastOneEntityInContext:[NSManagedObjectContext MR_defaultContext]]) {
        // Configure the cell
        PDF *pdf = self.allPDFs[indexPath.row];
        [cell configureCellForDate:pdf.date];
    }
    
    return cell;
}

#pragma mark - UITableViewDelegate

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
