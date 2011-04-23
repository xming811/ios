/*

Copyright (C) 2010  CycleStreets Ltd

This program is free software; you can redistribute it and/or
modify it under the terms of the GNU General Public License
as published by the Free Software Foundation; either version 2
of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.

*/

//  CycleStreetsAppDelegate.m
//  CycleStreets
//
//  Created by Alan Paxton on 02/03/2010.
//

#import "CycleStreetsAppDelegate.h"
#import "CycleStreets.h"
#import "SettingsViewController.h"
#import "RouteTableViewController.h"
#import "MapViewController.h"
#import "PhotoMapViewController.h"
#import "FavouritesViewController.h"
#import "PhotosViewContoller.h"
#import "CreditsViewController.h"
#import "Query.h"
#import "Route.h"
#import "Stage.h"
#import "BusyAlert.h"
#import <UIKit/UIKit.h>
#import "XMLRequest.h"
#import "Files.h"
#import "Reachability.h"
#import "Common.h"
#import "CategoryLoader.h"
#import "StartupManager.h"
#import "UserSettingsManager.h"
#import "AppConstants.h"

@implementation CycleStreetsAppDelegate
@synthesize window;
@synthesize tabBarController;
@synthesize firstAlert;
@synthesize secondAlert;
@synthesize optionsAlert;
@synthesize networkAlert;
@synthesize stage;
@synthesize busyAlert;
@synthesize errorAlert;
@synthesize startupmanager;
@synthesize favourites;
@synthesize routeTable;
@synthesize map;

/***********************************************************/
// dealloc
/***********************************************************/
- (void)dealloc
{
    [window release], window = nil;
    [tabBarController release], tabBarController = nil;
    [firstAlert release], firstAlert = nil;
    [secondAlert release], secondAlert = nil;
    [optionsAlert release], optionsAlert = nil;
    [networkAlert release], networkAlert = nil;
    [stage release], stage = nil;
    [busyAlert release], busyAlert = nil;
    [errorAlert release], errorAlert = nil;
    [startupmanager release], startupmanager = nil;
    [favourites release], favourites = nil;
    [routeTable release], routeTable = nil;
    [map release], map = nil;
	
    [super dealloc];
}



- (void)loadContext {
	DLog(@">>>");
	CycleStreets *cycleStreets = [CycleStreets sharedInstance];
	Files *files = cycleStreets.files;
	NSString *saveIndex = [files miscValueForKey:@"selectedTabIndex"];
	if (saveIndex != nil && [saveIndex length] > 0) {
		self.tabBarController.selectedIndex = [saveIndex intValue];
	}
}

- (void)saveContext {
	DLog(@">>>");
	if (self.tabBarController != nil && self.tabBarController.selectedIndex != NSNotFound) {
		CycleStreets *cycleStreets = [CycleStreets sharedInstance];
		Files *files = cycleStreets.files;
		NSString *saveIndex = [[NSNumber numberWithInt:self.tabBarController.selectedIndex] stringValue];
		[files setMiscValue:saveIndex forKey:@"selectedTabIndex"];
		
	}
}

- (UINavigationController *)setupNavigationTab:(UIViewController *)controller withTitle:(NSString *)title imageNamed:(NSString *)imageName tag:(int)tag {

	UINavigationController *navigation = [[[UINavigationController alloc] initWithRootViewController:controller] autorelease];
	navigation.navigationBar.tintColor=UIColorFromRGB(0x008000);
	UITabBarItem *tabBarItem = [[UITabBarItem alloc] initWithTitle:title image:[UIImage imageNamed:imageName] tag:tag];
	[navigation setTabBarItem:tabBarItem];
	controller.navigationItem.title = title;
	[tabBarItem release];
	
	return navigation;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {  
	
	DLog(@"application didFinishLaunchingWithOptions");

	
	startupmanager=[[StartupManager alloc]init];
	startupmanager.delegate=self;
	[startupmanager doStartupSequence];
	
	return YES;
}



# pragma Model Delegate methods

//
/***********************************************
 * @description			Callbacks from StartupManager when all startup sequences have completed
 ***********************************************/
//
-(void)startupComplete{
	
	BetterLog(@"");
	
	startupmanager.delegate=nil;
	[startupmanager release];
	startupmanager=nil;
	
	tabBarController = [[UITabBarController alloc] init];
	[self buildTabbarController:[UserSettingsManager sharedInstance].navigation];
	
	[window addSubview:tabBarController.view];
	tabBarController.selectedIndex=[[UserSettingsManager sharedInstance] getSavedSection];
	
	// Stage popover
	stage = [[Stage alloc] initWithNibName:@"Stage" bundle:nil];
	
	//have a busy alert ready to use
	//busyAlert = [[BusyAlert alloc] initWithTitle:@"Obtaining route" message:nil];
	
	// error alert too
	errorAlert = [[UIAlertView alloc]
				  initWithTitle:@"Error"
				  message:nil
				  delegate:self
				  cancelButtonTitle:@"OK"
				  otherButtonTitles:nil];
	
	CycleStreets *cycleStreets = [CycleStreets sharedInstance];
	cycleStreets.appDelegate = self;
	
	[window makeKeyAndVisible];	
	
	[self performSelector:@selector(backgroundSetup) withObject:nil afterDelay:0.0];
	
}



- (void)applicationWillTerminate:(UIApplication *)application {
	[self saveContext];
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
	[self saveContext];
}




//
/***********************************************
 * @description			create Tabbar order based on saved user context, handles More Tabbar reording
 ***********************************************/
//
- (void)buildTabbarController:(NSArray*)viewcontrollers {
	
	NSMutableArray	*navControllers=[[NSMutableArray alloc]init];
	
	
	if ([viewcontrollers count] > 0 ) {
		for (int i = 0; i < [viewcontrollers count]; i++){
			NSDictionary *navitem=[viewcontrollers objectAtIndex:i];
			NSString  *vcClass=[navitem objectForKey:@"class"];
			NSString  *nibName=[navitem objectForKey:@"nib"];
			
			BetterLog(@"vcClass=%@  nibName=%@",vcClass,nibName);
			
			UIViewController *vccontroller= (UIViewController*)[[NSClassFromString(vcClass) alloc] initWithNibName:nibName bundle:nil];
			if(vccontroller!=nil){
				
				//OLD STYLE SUPPORT: DEPRECATE THIS SOON!
				if ([vcClass isEqualToString:@"FavouritesViewController"]) {
					favourites=(FavouritesViewController*)vccontroller;
				}
				if ([vcClass isEqualToString:@"MapViewController"]) {
					map=(MapViewController*)vccontroller;
				}
				/*
				if ([vcClass isEqualToString:@"RouteTableViewController"]) {
					routeTable=(RouteTableViewController*)vccontroller;
				}
				 */
				//
				
				BOOL isVC=[[navitem objectForKey:@"isVC"] boolValue];
				if (isVC==YES) {
					UITabBarItem *tabBarItem = [[UITabBarItem alloc] initWithTitle:[navitem objectForKey:@"title"] image:[UIImage imageNamed:[navitem objectForKey:@"tabimage"]] tag:i];
					[vccontroller setTabBarItem:tabBarItem];
					[tabBarItem release];
					[navControllers addObject:vccontroller];
				}else {
					UINavigationController *nav = [self setupNavigationTab:vccontroller withTitle:[navitem objectForKey:@"title"] imageNamed:[navitem objectForKey:@"tabimage"] tag:i];
					[navControllers addObject:nav];
				}

				[vccontroller release];
			}
			
		}
		tabBarController.viewControllers = navControllers;
	}
	
	[navControllers release];
	
	// only add tabbar delegate if we can save the state
	if([[UserSettingsManager sharedInstance] userStateWritable]==YES){
		tabBarController.delegate = self;
	}
	
	[self setBarStyle:UIBarStyleDefault andTintColor:UIColorFromRGB(0x008000) forNavigationBar:tabBarController.moreNavigationController.navigationBar];
	
	
}





- (void) backgroundSetup {
	
	//load the default categories
	CycleStreets *cycleStreets = [CycleStreets sharedInstance];
	[cycleStreets.categoryLoader setupCategories];
	
	[self loadContext];
	
	// Check we have network
    Reachability *internetReach = [Reachability reachabilityForInternetConnection];
	NetworkStatus internetStatus = [internetReach currentReachabilityStatus];	
	
	// Warn that we can't download new maps
	if (internetStatus == NotReachable) {
		self.networkAlert = [[UIAlertView alloc] initWithTitle:@"Warning"
													   message:@"No network. You may be able to follow a previously planned route, if you have already viewed the maps."
													  delegate:self
											 cancelButtonTitle:@"OK"
											 otherButtonTitles:nil];
		[networkAlert show];				
	}	
}


- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
	DLog(@">>>");
	if (alertView == firstAlert) {
		self.firstAlert = nil;
		self.secondAlert = [[[UIAlertView alloc] initWithTitle:@"CycleStreets"
													   message:@"Click on 'Itinerary' to view full details. The route has also been saved to the 'More' section."
													  delegate:self
											 cancelButtonTitle:@"OK"
											 otherButtonTitles:nil]
							autorelease];
		//[self.secondAlert show];
		[self.secondAlert performSelector:@selector(show) withObject:nil afterDelay:0.1];
	}
	if (alertView == secondAlert) {
		self.secondAlert = nil;
	}
	if (alertView == optionsAlert) {
		self.optionsAlert = nil;
	}
	if (alertView == networkAlert) {
		self.networkAlert = nil;
	}
}


-(void)showTabBarViewControllerByName:(NSString*)viewname{
	
	int count=[tabBarController.viewControllers count];
	int index=-1;
	for (int i=0;i<count;i++) {
		UIViewController *navcontroller=[tabBarController.viewControllers objectAtIndex:i];
		if([navcontroller.tabBarItem.title isEqualToString:viewname]){
			index=i;
			break;
		}
	}
	
	if(index!=-1){
		[tabBarController setSelectedIndex:index];
	}else {
		BetterLog(@"[ERROR] unable to find tabbarItem with name %@",viewname);
	}

	
}


//
/***********************************************
 * Utility method to set the navigationBar colors
 ***********************************************/
//
- (void)setBarStyle:(UIBarStyle)style andTintColor:(UIColor *)color forNavigationBar:(UINavigationBar *)bar {
    bar.barStyle = style;
	bar.tintColor = color;	
}

@end
