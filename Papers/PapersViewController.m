//
//  PapersViewController.m
//  Papers
//
//  Created by Philippe Schmid on 02.02.15.
//  Copyright (c) 2015 Philippe Schmid. All rights reserved.
//

#import <AssetsLibrary/AssetsLibrary.h>
#import "PapersViewController.h"
#import "ImageDetails.h"
#import "Image.h"
#import "PDFClient.h"

@interface PapersViewController () <UINavigationControllerDelegate, UIImagePickerControllerDelegate>

@property (nonatomic, strong) UIImagePickerController *imagePicker;
@property (nonatomic, strong) UIImage *imageToRecognize;
@property (nonatomic, strong) NSMutableArray *images;
@property (nonatomic, strong) Image *recognizedImage;
@property (nonatomic, strong) Image *image;

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UIColor *backgroundColor;
@property (nonatomic, strong) UIColor *textColor;

@property (nonatomic, strong) PDFClient *pdfClient;

@end

@implementation PapersViewController

#pragma mark - Initializers

- (id)init
{
    self = [super init];
    if (self) {
    }
    return self;
}

#pragma mark - View life cycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Color configuration.
    self.backgroundColor = [UIColor colorWithRed:222/255.0f green:184/255.0f blue:135/255.0f alpha:1.0f];
    self.textColor = [UIColor colorWithWhite:0.1f alpha:0.7f];
    self.view.backgroundColor = self.backgroundColor;
    
    // Navigation-Bar.
    [self configureNavigationBar];
    
    // Table-View.
    [self configureTableView];
}

- (void)loadView
{
    CGRect applicationFrame = [[UIScreen mainScreen] applicationFrame];
    UIView *contentView = [[UIView alloc] initWithFrame:applicationFrame];
    self.view = contentView;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self fetchContext];
    [self.tableView reloadData];
}

- (void)configureNavigationBar
{
    self.navigationController.delegate = self;
    self.navigationController.navigationBar.tintColor = self.textColor;
    self.navigationController.navigationBar.barTintColor = self.backgroundColor;
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.textColor = self.textColor;
    titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-UltraLight" size:25];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.text = NSLocalizedString(@"Papers", @"");
    [titleLabel sizeToFit];
    self.navigationItem.titleView = titleLabel;
    [self.navigationController.navigationBar setShadowImage:[[UIImage alloc] init]];
    [self.navigationController.navigationBar setBackgroundImage:[[UIImage alloc] init]
                                                  forBarMetrics:UIBarMetricsDefault];
    UIBarButtonItem *add = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                                                                         target:self
                                                                         action:@selector(chooseSource)];
    UIBarButtonItem *scan = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction
                                                                          target:self
                                                                          action:@selector(chooseAction)];
    self.navigationItem.rightBarButtonItems = @[scan];
    self.navigationItem.leftBarButtonItems = @[add];
}

- (void)configureTableView
{
    self.tableView = [[UITableView alloc] init];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.pagingEnabled = YES;
    self.tableView.backgroundColor = self.backgroundColor;
    self.tableView.separatorColor = [UIColor colorWithWhite:0.6 alpha:0.8];
    self.tableView.frame = self.view.bounds;
    [self.view addSubview:self.tableView];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if ([Image MR_hasAtLeastOneEntityInContext:[NSManagedObjectContext MR_defaultContext]]) {
        return [self.images count];
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
    
    if ([Image MR_hasAtLeastOneEntityInContext:[NSManagedObjectContext MR_defaultContext]]) {
        [self configureCell:cell atIndexPath:indexPath];
    }
    
    return cell;
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    Image *image = self.images[indexPath.row];
    UIView *selectedView = [[UIView alloc] initWithFrame:CGRectZero];
    selectedView.backgroundColor = [UIColor colorWithWhite:1.0f alpha:0.2f];
    cell.backgroundColor = [UIColor clearColor];
    cell.selectedBackgroundView = selectedView;
    cell.textLabel.textColor = self.textColor;
    cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue-UltraLight" size:15];
    cell.textLabel.text = [NSString stringWithFormat:NSLocalizedString(@"Image %@", @""),
                           image.imageDetails.date];
    cell.detailTextLabel.textColor = self.textColor;
    cell.detailTextLabel.font = [UIFont fontWithName:@"HelveticaNeue-UltraLight" size:10];
    if ([image.imageDetails.scanned boolValue] == YES) {
        cell.detailTextLabel.text = NSLocalizedString(@"Scanned", @"");
    } else {
        cell.detailTextLabel.text = nil; // set nil for cell reuse
    }
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    // Get the image.
    Image *image = self.images[indexPath.row];
    self.recognizedImage = image;
    NSString *imageURL = image.imageDetails.path;
    [self loadImageForAssetURL:[NSURL URLWithString:imageURL]];
    
    // TODO: Show the image in the DetailViewController.
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([Image MR_hasAtLeastOneEntityInContext:[NSManagedObjectContext MR_defaultContext]]) {
        return UITableViewCellEditingStyleDelete;
    } else {
        return UITableViewCellEditingStyleNone;
    }
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // delete from context
        Image *imageToRemove = self.images[indexPath.row];
        [imageToRemove MR_deleteEntity];
        [self saveContext];
        
        // delete from tableview
        [self.images removeObjectAtIndex:indexPath.row];
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
    self.images = [[Image MR_findAll] mutableCopy];
}

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    // get asset URL from image picker
    NSDate *currentDate = [NSDate date];
    NSURL *imageURL = [info valueForKey:UIImagePickerControllerReferenceURL];
    
    // dismiss image picker
    [self.imagePicker dismissViewControllerAnimated:YES completion:nil];
    self.imagePicker = nil;
    
    // save asset URL to context
    Image *image = [Image MR_createEntity];
    image.imageDetails = [ImageDetails MR_createEntity];
    image.text = [NSString stringWithFormat:@""];
    image.imageDetails.scanned = [NSNumber numberWithBool:NO];
    image.imageDetails.date = currentDate;
    image.imageDetails.path = [imageURL absoluteString];
    [self saveContext];
    [self.tableView reloadData];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self.imagePicker dismissViewControllerAnimated:YES completion:nil];
    self.imagePicker = nil;
}

#pragma mark - ALAssetsLibrary

- (void)loadImageForAssetURL:(NSURL *)url
{
    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
    [library assetForURL:url resultBlock:^(ALAsset *asset) {
        // set image to scan
        self.imageToRecognize = [UIImage imageWithCGImage:asset.defaultRepresentation.fullResolutionImage];
    } failureBlock:^(NSError *error) {
        if (error) {
            NSLog(@"Error loading image: %@", [error userInfo]);
        }
    }];
}

#pragma mark - Create the PDF with Quartz 2D

- (void)writeToTextFile
{
    // initialize pdf client
    self.pdfClient = [PDFClient sharedPDFClient];
    
    // write to text file
    NSError *error;
    NSString *textPath = [Utility documentsPathForFileName:@"scanned.txt"];
    [self.recognizedImage.text writeToFile:textPath atomically:YES encoding:NSUTF8StringEncoding error:&error];
    
    // write to pdf file
    [self.pdfClient createPDFForText:self.recognizedImage.text];
}

#pragma mark - Source

- (void)openLibrary
{
    self.imagePicker = [[UIImagePickerController alloc] init];
    self.imagePicker.delegate = self;
    self.imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    [self presentViewController:self.imagePicker animated:YES completion:nil];
}

- (void)chooseSource
{
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
        // Show the ActionSheet with the library option
        UIAlertController *alertController = [Utility showActionSheetWithTitle:@"Source" name:@"Library" method:@selector(openLibrary)];
        [self presentViewController:alertController animated:YES completion:nil];
    }
    
}

- (void)chooseAction
{
    // Show the ActionSheet with the option to create the PDF
    UIAlertController *alertController = [Utility showActionSheetWithTitle:@"Action" name:@"Create PDF" method:@selector(writeToTextFile)];
    [self presentViewController:alertController animated:YES completion:nil];
}

#pragma mark - Memory Management

- (void)cleanUp
{
    // Free the memory, free it!
    self.imageToRecognize = nil;
    self.recognizedImage = nil;
    self.imagePicker = nil;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    [self cleanUp];
}

@end
