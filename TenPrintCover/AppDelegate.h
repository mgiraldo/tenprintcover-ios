//
//  AppDelegate.h
//  TenPrintCover
//
//  Created by Mauricio Giraldo on 6/25/14.
//  Copyright (c) 2014 NYPL_Labs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TenPrintCoverView.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate> {

NSTimer *t;
	
}

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) NSString *bookTitle;
@property (strong, nonatomic) NSString *bookAuthor;
@property (strong, nonatomic) NSArray *bookList;
@property (strong, nonatomic) TenPrintCoverView *coverView;
@property (strong, nonatomic) TenPrintCoverView *smallCoverView;
@property (strong, nonatomic) TenPrintCoverView *blankCoverView;

@end
