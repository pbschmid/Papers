//
//  PapersViewController.m
//  Papers
//
//  Created by Philippe Schmid on 02.02.15.
//  Copyright (c) 2015 Philippe Schmid. All rights reserved.
//

#import "PapersViewController.h"
#import "DetailViewController.h"
#import "MBProgressHUD.h"
#import "ImageProcessor.h"
#import <Photos/Photos.h>
#import "PDFClient.h"
#import "Image.h"
#import "PDF.h"


@interface PapersViewController () <UINavigationControllerDelegate, UIImagePickerControllerDelegate>

@property (nonatomic, strong) UIImagePickerController *imagePicker;
@property( nonatomic, strong) NSMutableArray *imagesToProcess;
@property (nonatomic, strong) NSMutableArray *imagesForPDF;
@property (nonatomic, strong) NSMutableArray *images;

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UIColor *backgroundColor;
@property (nonatomic, strong) UIColor *textColor;

@property (nonatomic, strong) PDFClient *pdfClient;
@property (nonatomic, strong) ImageProcessor *imageProcessor;

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
    [self configureNavigationBarWithTitle:@"Papers"];
    
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
    
    // Load all images ONCE only
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self loadAllImages];
    });
    
    [self.tableView reloadData];
}

- (void)configureNavigationBarWithTitle:(NSString *)title
{
    self.navigationController.delegate = self;
    self.navigationController.navigationBar.tintColor = self.textColor;
    self.navigationController.navigationBar.barTintColor = self.backgroundColor;
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.textColor = self.textColor;
    titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-UltraLight" size:25];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.text = [NSString stringWithFormat:NSLocalizedString(@"%@", @""), title];
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
    cell.textLabel.text = [NSString stringWithFormat:NSLocalizedString(@"Image %@", @""), image.date];
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    // Get the image to show
    Image *image = self.images[indexPath.row];
    NSString *imagePath = image.path;
    
    // Show the DetailViewController with the Image
    DetailViewController *detailVC = [[DetailViewController alloc] init];
    detailVC.imagePath = imagePath;
    [self.navigationController pushViewController:detailVC animated:YES];
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
        // Remove the image from the context
        Image *imageToRemove = self.images[indexPath.row];
        [imageToRemove MR_deleteEntity];
        [self saveContext];
        
        // Remove the image from the array of images
        // that were loaded into memory
        [self.imagesToProcess removeObjectAtIndex:indexPath.row];
        
        // Remove the image from the table view
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
    // Get the Asset URL
    NSURL *imageURL = [info valueForKey:UIImagePickerControllerReferenceURL];
    
    // Dismiss the image picker
    [self.imagePicker dismissViewControllerAnimated:YES completion:nil];
    self.imagePicker = nil;
    
    // Create the Image entity
    Image *image = [Image MR_createEntity];
    NSDate *currentDate = [NSDate date];
    image.date = currentDate;
    image.path = [imageURL absoluteString];
    
    // Load image into memory
    // And save the context
    [self loadImageForAssetURL:imageURL];
    [self saveContext];
    [self.tableView reloadData];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self.imagePicker dismissViewControllerAnimated:YES completion:nil];
    self.imagePicker = nil;
}

#pragma mark - Photos Framework

- (void)loadAllImages
{
    self.imagesToProcess = [[NSMutableArray alloc] init];
    if ([self.images count] > 0) {
        NSLog(@"LOADING IMAGES INTO MEMORY.");
        
        // Iterate over all images in context
        for (Image *img in self.images) {
            // Load every image into memory
            NSURL *imageURL = [NSURL URLWithString:img.path];
            [self loadImageForAssetURL:imageURL];
        }
    }
}

- (void)loadImageForAssetURL:(NSURL *)url
{
    // PHImageRequestOptions* options = [[PHImageRequestOptions alloc] init];
    // options.synchronous = YES;
    PHFetchResult *fetchResult = [PHAsset fetchAssetsWithALAssetURLs:@[url] options:nil];
    PHAsset *asset = [fetchResult lastObject];
    
    PHImageManager *manager = [PHImageManager defaultManager];
    [manager requestImageForAsset:asset
                       targetSize:PHImageManagerMaximumSize
                      contentMode:PHImageContentModeDefault
                          options:nil
                    resultHandler:^(UIImage *result, NSDictionary *info) {
                        // Add image to images array
                        [self.imagesToProcess addObject:result];
                        NSLog(@"IMAGE ADDED: %@", result);
                    }];
}

#pragma mark - Image Preprocessing

- (void)preprocessImagesWithGPUImage
{
    // Initialize the ImageProcessor
    self.imageProcessor = [ImageProcessor sharedImageProcessor];
    self.imagesForPDF = [[NSMutableArray alloc] init];
    
    // Prepare the images with GPUImage Tresholding
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self.imageProcessor preprocessImages:self.imagesToProcess withCallback:^(BOOL success, NSArray *results, NSError *error) {
            if (success) {
                self.imagesForPDF = (NSMutableArray *)results;
                NSLog(@"SUCCESS PROCESSING IMAGES: %@", self.imagesForPDF.description);
                
                // Start creating PDF!!!
                NSLog(@"START CREATING PDF...");
                [self startCreatingPDFFromImages];
                
            } else {
                NSLog(@"Error: %@", error.userInfo);
            }
        }];
    });
}

#pragma mark - Create the PDF with Quartz 2D

- (void)startCreatingPDFFromImages
{
    // Initialize the PDF client
    self.pdfClient = [PDFClient sharedPDFClient];
    NSString *filePath = [Utility documentsPathForFileName:@"paper.pdf"];
    
    // get background thread
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self.pdfClient createPDFForTitle:filePath withImages:self.imagesForPDF callback:^(BOOL success,  NSError *error) {
            if (success) {
                NSLog(@"SUCCESS CREATING PDF!!!");
                
                // get main thread
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    // Create the PDF entity
                    PDF *pdf = [PDF MR_createEntity];
                    NSDate *currentDate = [NSDate date];
                    pdf.date = currentDate;
                    pdf.path = filePath;
                    
                    // Save the context
                    [self saveContext];
                    [self.tableView reloadData];
                    
                });
                
                
            } else {
                NSLog(@"Error creating PDF: %@", error.userInfo);
            }
        }];
    });
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
        UIAlertController *alertController = [self showActionSheetWithTitle:@"Source" name:@"Library" method:@selector(openLibrary)];
        [self presentViewController:alertController animated:YES completion:nil];
    }
    
}

- (void)chooseAction
{
    // Show the ActionSheet with the option to create the PDF
    UIAlertController *alertController = [self showActionSheetWithTitle:@"Action" name:@"Create PDF" method:@selector(preprocessImagesWithGPUImage)];
    [self presentViewController:alertController animated:YES completion:nil];
}

#pragma mark - UIAlertController

- (UIAlertController *)showActionSheetWithTitle:(NSString *)title name:(NSString *)name method:(SEL)method
{
    // Ask the controller for the C function pointer of the specified SEL
    // stackoverflow.com/questions/7017281/performselector-may-cause-a-leak-because-its-selector-is-unknown
    // Thanks to SO user wbyoung!
    IMP imp = [self methodForSelector:method];
    void (*func)(id, SEL) = (void *)imp;
    
    // Create the AlertController
    UIAlertController *ac = [UIAlertController alertControllerWithTitle:[NSString stringWithFormat:
                                                                         NSLocalizedString(@"%@", @""),
                                                                         title]
                                                                message:nil
                                                         preferredStyle:UIAlertControllerStyleActionSheet];
    
    // Create the action for the AlertController
    UIAlertAction *alertAction = [UIAlertAction actionWithTitle:[NSString stringWithFormat:
                                                                 NSLocalizedString(@"%@", @""),
                                                                 name]
                                                          style:UIAlertActionStyleDefault
                                                        handler:^(UIAlertAction *action) {
                                                            func(self, method);
                                                        }];
    
    // Cancel action
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", @"") style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {}];
    
    // Add the actions
    [ac addAction:alertAction];
    [ac addAction:cancel];
    
    return ac;
}

- (UIAlertController *)showAlertViewWithTitle:(NSString *)title message:(NSString *)message
{
    // Create the controller
    UIAlertController *ac = [UIAlertController alertControllerWithTitle:
                             [NSString stringWithFormat:NSLocalizedString(@"%@", @""), title]
                                                                message:
                             [NSString stringWithFormat:NSLocalizedString(@"%@", @""), message]
                                                         preferredStyle:
                             UIAlertControllerStyleAlert];
    
    // Create the action
    UIAlertAction *action = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK", @"") style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {}];
    
    // Add the action
    [ac addAction:action];
    
    return ac;
}

#pragma mark - Memory Management

- (void)cleanUp
{
    // Free memory
    self.imagePicker = nil;
    self.imageProcessor = nil;
    self.pdfClient = nil;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    [self cleanUp];
}

@end
