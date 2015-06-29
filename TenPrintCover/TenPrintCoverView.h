//
//  TenPrintCoverView.h
//  TenPrintCoverView
//
//  Created by Mauricio Giraldo on 6/25/14.
//  Copyright (c) 2014 NYPL_Labs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreText/CoreText.h>

@interface TenPrintCoverView : UIView

-(instancetype)initWithFrame:(CGRect)frame NS_UNAVAILABLE;
-(instancetype)initWithFrame:(CGRect)frame withTitle:(NSString *)title withAuthor:(NSString *)author withScale:(float)scale;
-(instancetype)initWithFrame:(CGRect)frame withTitle:(NSString *)title withAuthor:(NSString *)author withScale:(float)scale andPlainStyle:(BOOL)isPlain;
-(void)saveToDisk;

@property(nonatomic, readwrite) NSString* bookTitle;
@property(nonatomic, readwrite) NSString* bookAuthor;
@property(nonatomic, readwrite) NSString* bookId;
@property(nonatomic, readwrite) UIColor* baseColor;
@property(nonatomic, readwrite) UIColor* shapeColor;
@property(nonatomic) float viewScale;

@end
