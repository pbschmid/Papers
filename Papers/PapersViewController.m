//
//  PapersViewController.m
//  Papers
//
//  Created by Philippe Schmid on 02.02.15.
//  Copyright (c) 2015 Philippe Schmid. All rights reserved.
//

#import <AssetsLibrary/AssetsLibrary.h>
#import "PapersViewController.h"
#import "TesseractClient.h"
#import "MBProgressHUD.h"
#import "ImageDetails.h"
#import "Image.h"

@interface PapersViewController () <UINavigationControllerDelegate, UIImagePickerControllerDelegate>

@property (nonatomic, strong) UIImagePickerController *imagePicker;
@property (nonatomic, strong) UIImage *imageToRecognize;
@property (nonatomic, strong) NSMutableArray *images;
@property (nonatomic, strong) TesseractClient *client;
@property (nonatomic, strong) Image *recognizedImage;
@property (nonatomic, strong) Image *image;

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UIColor *backgroundColor;
@property (nonatomic, strong) UIColor *textColor;

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
    
    // color configuration
    self.backgroundColor = [UIColor colorWithRed:222/255.0f green:184/255.0f blue:135/255.0f alpha:1.0f];
    self.textColor = [UIColor colorWithWhite:0.1f alpha:0.7f];
    self.view.backgroundColor = self.backgroundColor;
    
    // navigation bar
    [self configureNavigationBar];
    
    // table view
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
    
    // set image to recognize
    Image *image = self.images[indexPath.row];
    self.recognizedImage = image;
    NSString *imageURL = image.imageDetails.path;
    [self loadImageForAssetURL:[NSURL URLWithString:imageURL]];
    // start scanning process
    [self checkForScanning];
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
    NSURL *imageURL = info[UIImagePickerControllerReferenceURL];
    [self.imagePicker dismissViewControllerAnimated:YES completion:nil];
    self.imagePicker = nil;
    
    // save asset URL to context
    Image *image = [Image MR_createEntity];
    image.imageDetails = [ImageDetails MR_createEntity];
    image.text = [NSString stringWithFormat:@""];
    image.imageDetails.scanned = [NSNumber numberWithBool:NO];
    image.imageDetails.date = currentDate;
    image.imageDetails.path = imageURL.absoluteString;
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

#pragma mark - SendingClient

- (void)sendText
{
    NSLog(@"Sending text...");
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

#pragma mark - Quartz 2D

- (void)createPDFFile
{
    
}

#pragma mark - Source

- (void)chooseSource
{
    // create controller
    UIAlertController *ac = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Source", @"")
                                                                message:nil
                                                         preferredStyle:UIAlertControllerStyleActionSheet];
    
    //create actions
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        // only show camera option if available
        UIAlertAction *camera = [UIAlertAction actionWithTitle:NSLocalizedString(@"Camera", @"") style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            [self takePhoto];
        }];
        [ac addAction:camera];
    }
    UIAlertAction *library = [UIAlertAction actionWithTitle:NSLocalizedString(@"Library", @"") style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self openLibrary];
    }];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", @"") style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {}];
    
    // add actions
    [ac addAction:library];
    [ac addAction:cancel];
    
    // show controller
    [self presentViewController:ac animated:YES completion:nil];
}

- (void)chooseAction
{
    // create controller
    UIAlertController *ac = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Action", @"")
                                                                message:nil
                                                         preferredStyle:UIAlertControllerStyleActionSheet];
    
    // create actions
    UIAlertAction *scan = [UIAlertAction actionWithTitle:NSLocalizedString(@"Scan", @"") style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        NSLog(@"Scan all images.");
    }];
    UIAlertAction *send = [UIAlertAction actionWithTitle:NSLocalizedString(@"Send", @"") style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self sendText];
    }];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", @"") style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {}];
    
    // add actions
    [ac addAction:scan];
    [ac addAction:send];
    [ac addAction:cancel];
    
    // show controller
    [self presentViewController:ac animated:YES completion:nil];
}

- (void)openLibrary
{
    self.imagePicker = [[UIImagePickerController alloc] init];
    self.imagePicker.delegate = self;
    self.imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    [self presentViewController:self.imagePicker animated:YES completion:nil];
}

- (void)takePhoto
{
    self.imagePicker = [[UIImagePickerController alloc] init];
    self.imagePicker.delegate = self;
    self.imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
    [self presentViewController:self.imagePicker animated:YES completion:nil];
}

#pragma mark - UIAlertController

- (void)showAlertControllerStyleAlertWithTitle:(NSString *)title message:(NSString *)message
{
    // create controller
    UIAlertController *ac = [UIAlertController alertControllerWithTitle:
                             [NSString stringWithFormat:NSLocalizedString(@"%@", @""), title]
                                                                message:
                             [NSString stringWithFormat:NSLocalizedString(@"%@", @""), message]
                                                         preferredStyle:
                             UIAlertControllerStyleAlert];
    
    // create action
    UIAlertAction *action = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK", @"") style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {}];
    
    // add action
    [ac addAction:action];
    
    // show controller
    [self presentViewController:ac animated:YES completion:nil];
}

#pragma mark - MBProgressHUD

- (MBProgressHUD *)createProgressHUD
{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.mode = MBProgressHUDModeIndeterminate;
    hud.labelColor = [UIColor colorWithWhite:0.9 alpha:0.7];
    hud.labelFont = [UIFont fontWithName:@"HelveticaNeue-Light" size:15];
    hud.labelText = NSLocalizedString(@"Scanning...", @"");
    hud.backgroundColor = [UIColor colorWithWhite:0.1f alpha:0.3f];
    return hud;
}

#pragma mark - Memory Management

- (void)cleanUp
{
    // free memory
    self.imageToRecognize = nil;
    self.recognizedImage = nil;
    self.imagePicker = nil;
    self.client = nil;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    [self cleanUp];
}

@end
