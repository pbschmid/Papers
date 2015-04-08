//
//  PDFViewController.m
//  Papers
//
//  Created by Philippe Schmid on 25.03.15.
//  Copyright (c) 2015 Philippe Schmid. All rights reserved.
//

#import "PDFViewController.h"
#import "UITableViewCell+Category.h"
#import "UITableView+Category.h"
#import "PDF.h"

@interface PDFViewController () <UINavigationControllerDelegate>

@property (nonatomic, strong) NSMutableArray *allPDFs;
@property (nonatomic, strong) UITableView *tableView;

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

#pragma mark - View life cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Background color
    self.view.backgroundColor = universalBackgroundColor;
    
    // Navigation-Bar
    [self configureNavigationBar];
    
    // Table-View
    self.tableView = [UITableView tableViewWithFrame:self.view.bounds];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.view addSubview:self.tableView];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self fetchContext];
    [self.tableView reloadData];
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
    UILabel *titleLabel = [Utility createTitleViewForTitle:@"PDF" textColor:universalTextColor];
    self.navigationItem.titleView = titleLabel;
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    // Get the image to show
    PDF *pdf = self.allPDFs[indexPath.row];
    //NSURL *imagePath = [NSURL URLWithString:pdf.path];
    
    // Show the DetailViewController with the Image
    //DetailViewController *detailVC = [[DetailViewController alloc] init];
    //detailVC.imagePath = imagePath;
    
    //[self.navigationController pushViewController:detailVC animated:YES];
    NSLog(@"PDF %@ CLICKED.", pdf.description);
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([PDF MR_hasAtLeastOneEntityInContext:[NSManagedObjectContext MR_defaultContext]]) {
        return UITableViewCellEditingStyleDelete;
    } else {
        return UITableViewCellEditingStyleNone;
    }
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Remove the image from the context
        PDF *pdfToRemove = self.allPDFs[indexPath.row];
        [pdfToRemove MR_deleteEntity];
        [self saveContext];
        
        // Remove the image from the array of images
        // that were loaded into memory
        // [self.imagesToProcess removeObjectAtIndex:indexPath.row];
        
        // Remove the image from the table view
        [self.allPDFs removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
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
