//
//  AppDelegate.m
//  Papers
//
//  Created by Philippe Schmid on 02.02.15.
//  Copyright (c) 2015 Philippe Schmid. All rights reserved.
//

#import "AppDelegate.h"
#import "PapersViewController.h"
#import "PDFViewController.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    // TabBarController
    UITabBarController *tabBarController = [[UITabBarController alloc] init];
    
    // NavigationControllers
    UINavigationController *nvc1 = [[UINavigationController alloc] init];
    UINavigationController *nvc2 = [[UINavigationController alloc] init];
    tabBarController.viewControllers = @[nvc1, nvc2];
    tabBarController.selectedViewController = nvc1;
    
    // ViewControllers
    PapersViewController *pvc1 = [[PapersViewController alloc] init];
    PDFViewController *pvc2 = [[PDFViewController alloc] init];
    nvc1.viewControllers = @[pvc1];
    nvc2.viewControllers = @[pvc2];
    
    // TabBarControllerDelegate
    tabBarController.delegate = pvc1;
    
    // RootViewController
    self.window.rootViewController = tabBarController;
    [self customizeAppearance];
    
    // MagicalRecord
    [MagicalRecord setupCoreDataStackWithStoreNamed:@"ImageModel"];
    
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)customizeAppearance
{
    // UITabBar Appearance
    [[UITabBar appearance] setBarTintColor:universalBackgroundColor];
    [[UITabBar appearance] setTintColor:universalTextColor];
    [[UITabBar appearance] setTranslucent:YES];
    
    // NavigationBar Appearance
    [[UINavigationBar appearance] setBarTintColor:universalBackgroundColor];
    [[UINavigationBar appearance] setTintColor:universalTextColor];
    [[UINavigationBar appearance] setShadowImage:[[UIImage alloc] init]];
    [[UINavigationBar appearance] setBackgroundImage:[[UIImage alloc] init]
                                       forBarMetrics:UIBarMetricsDefault];
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
