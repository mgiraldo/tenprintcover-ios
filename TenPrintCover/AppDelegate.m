//
//  AppDelegate.m
//  TenPrintCover
//
//  Created by Mauricio Giraldo on 6/25/14.
//  Copyright (c) 2014 NYPL_Labs. All rights reserved.
//

#import "AppDelegate.h"

@implementation AppDelegate

@synthesize bookList, bookTitle, bookAuthor, coverView, smallCoverView;

int currentBook = -1;
int lastCheck = 0;
BOOL isDown = NO;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    self.window.backgroundColor = [UIColor colorWithRed:.9 green:.9 blue:.9 alpha:1];
	
	// books
	NSError* error;
	NSString* path = [[NSBundle mainBundle] pathForResource:@"covers"
													 ofType:@"json2"];
	NSData *file = [NSData dataWithContentsOfFile:path];
	NSDictionary *json = [NSJSONSerialization JSONObjectWithData:file options:kNilOptions error:&error];
	self.bookList = [json objectForKey:@"books"];
	NSLog(@"books: %lu", (unsigned long)self.bookList.count);
	
	UITapGestureRecognizer *singleFingerTap =
	[[UITapGestureRecognizer alloc] initWithTarget:self
											action:@selector(handleSingleTap:)];
	[self.window addGestureRecognizer:singleFingerTap];
	
	UILongPressGestureRecognizer *longPress =
	[[UILongPressGestureRecognizer alloc] initWithTarget:self
												  action:@selector(handleLongPress:)];
	[self.window addGestureRecognizer:longPress];
	
//	t = [NSTimer scheduledTimerWithTimeInterval:0.0 target:self selector:@selector(getCover) userInfo:nil repeats:YES];
	[self getCover];
	
	[self.window makeKeyAndVisible];
    return YES;
}

-(void)getCover {
	currentBook++;
	if (currentBook >= self.bookList.count) {
		currentBook = 0;
		
		if (t) [t invalidate];
	}

	self.bookTitle = [[self.bookList objectAtIndex:currentBook] objectForKey:@"title"];
	self.bookAuthor = [[self.bookList objectAtIndex:currentBook] objectForKey:@"authors"];
	
//	NSLog(@"title: %@ author: %@", self.bookTitle, self.bookAuthor);
	
    // BIG Cover bounds.
    CGRect bounds = CGRectMake(5,30,200,300);
    
    // Create a view and add it to the window.
//	NSLog(@"cover: %@", self.coverView);
	if (self.coverView != nil) {
		[self.coverView removeFromSuperview];
		self.coverView = nil;
	}
    self.coverView = [[TenPrintCoverView alloc] initWithFrame:bounds
													withTitle:self.bookTitle
												   withAuthor:self.bookAuthor
												 withScale:1.0];
    [self.window addSubview: self.coverView];
	
	/*********
	 SAVING IMAGE AS PNG
	***********/
	if (NO) { // this will never execute. remove to enable saving
		self.coverView.bookId = [[self.bookList objectAtIndex:currentBook] objectForKey:@"identifier"];// first set the id
		[self.coverView saveToDisk];
	}
	/*********
	 END SAVING IMAGE
	 ***********/
	
	
    // SMALL Cover bounds.
    CGRect smallBounds = CGRectMake(160,100,150,225);
    
    // Create a view and add it to the window.
	//	NSLog(@"cover: %@", self.coverView);
	if (self.smallCoverView != nil) {
		[self.smallCoverView removeFromSuperview];
		self.smallCoverView = nil;
	}
    self.smallCoverView = [[TenPrintCoverView alloc] initWithFrame:smallBounds
														 withTitle:self.bookTitle
														withAuthor:self.bookAuthor
													  withScale:0.75];
    [self.window addSubview: self.smallCoverView];
}

- (void)handleSingleTap:(UITapGestureRecognizer *)recognizer {
//	NSLog(@"single tap");
	[self getCover];
}

- (void)handleLongPress:(UILongPressGestureRecognizer *)recognizer {
//	NSLog(@"long press");
	[self getCover];
}

- (void)applicationWillResignActive:(UIApplication *)application
{
	// Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
	// Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
	// Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
	// If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
	// Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
	// Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
	// Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
