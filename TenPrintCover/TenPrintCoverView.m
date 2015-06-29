//
//  TenPrintCoverView.m
//  TenPrintCoverView
//
//  Created by Mauricio Giraldo on 6/25/14.
//  Copyright (c) 2014 NYPL_Labs. All rights reserved.
//

#import "TenPrintCoverView.h"

@interface TenPrintCoverView ()

@property(nonatomic) BOOL plainStyle;
@property(nonatomic) int gridCount;
@property(nonatomic) float shapeThickness;

@end

static NSString * const c64Letters = @" qQwWeErRtTyYuUiIoOpPaAsSdDfFgGhHjJkKlL:zZxXcCvVbBnNmM1234567890.";
static float const baseSaturation = 0.9;
static float const baseBrightness = 0.8;
static float const fontSize = 14.0;
static float const baseThickness = 4.0;

static float const minTitle = 2;
static float const maxTitle = 60;
static float const titleScale = 1.3; // how much bigger the title is than the author
static float const margin = 5;
static float artworkStartX = 0;
static float artworkStartY = 75;
static float const titleHeight = 80;
static float const authorHeight = 25;

@implementation TenPrintCoverView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame withTitle:(NSString *)title withAuthor:(NSString *)author withScale:(float)scale
{
    self = [super initWithFrame:frame];
    if (self) {
		self.shapeThickness = baseThickness * scale;
        self.bookTitle = title;
        self.bookAuthor = author;
        self.viewScale = scale;
        self.plainStyle = NO;
    }
    return self;
}

-(instancetype)initWithFrame:(CGRect)frame withTitle:(NSString *)title withAuthor:(NSString *)author withScale:(float)scale andPlainStyle:(BOOL)isPlain;
{
    TenPrintCoverView *myCover = [self initWithFrame:frame withTitle:title withAuthor:author withScale:scale];
    myCover.plainStyle = isPlain;
    return myCover;
}

-(void)drawRect:(CGRect)rect
{
	artworkStartY = self.bounds.size.height - self.bounds.size.width;
	[self processColors];
	[self drawBackground];
	[self drawArtwork];
	[self drawText];
}

#pragma mark - cover setup

-(void)processColors {
	int counts = (int)self.bookTitle.length + (int)self.bookAuthor.length;
	float colorSeed = ofMap(counts, 2.0, 80.0, 0.0, 1.0, NO);
	self.shapeColor = [UIColor colorWithHue:colorSeed saturation:baseSaturation brightness:((baseBrightness*100)-(counts%20))*.1 alpha:1.0];
	float complementary = colorSeed+0.5;
	if (complementary > 1) complementary -= 1;
	self.baseColor = [UIColor colorWithHue:complementary saturation:baseSaturation brightness:baseBrightness alpha:1.0];
	if (counts%10==0) {
		UIColor *tmpColor = self.baseColor;
		self.baseColor = self.shapeColor;
		self.shapeColor = tmpColor;
	}
//	NSLog(@"counts: %d seed: %f baseColor: %@ shapeColor: %@", counts, colorSeed, self.baseColor, self.shapeColor);
}

-(void)drawBackground {
	CGContextRef context = UIGraphicsGetCurrentContext();
    if (!self.plainStyle) {
        // fill with white
        CGContextSetRGBFillColor(context, 1, 1, 1, 1);
        CGContextFillRect(context, self.bounds);
    } else {
        // fill with gray
        CGContextSetRGBFillColor(context, .9, .9, .9, 1);
        CGContextFillRect(context, self.bounds);
    }
}

float ofMap(float value, float inputMin, float inputMax, float outputMin, float outputMax, bool clamp) {
	
	if (fabs(inputMin - inputMax) < FLT_EPSILON){
		NSLog(@"ofMap(): avoiding possible divide by zero, check inputMin and inputMax: %f %f", inputMin, inputMax);
		return outputMin;
	} else {
		float outVal = ((value - inputMin) / (inputMax - inputMin) * (outputMax - outputMin) + outputMin);
		
		if( clamp ){
			if(outputMax < outputMin){
				if( outVal < outputMax )outVal = outputMax;
				else if( outVal > outputMin )outVal = outputMin;
			}else{
				if( outVal > outputMax )outVal = outputMax;
				else if( outVal < outputMin )outVal = outputMin;
			}
		}
		return outVal;
	}
	
}

#pragma mark - artwork creation

-(void)drawText {
	// black
	CGColorRef color = [UIColor colorWithRed:0 green:0 blue:0 alpha:1].CGColor;

	// fonts
    CTFontRef boldFont = CTFontCreateWithName(CFSTR("AvenirNext-Bold"), fontSize * titleScale * self.viewScale, NULL);
	
    // Set the lineSpacing.
	CGFloat lineHeight = fontSize * self.viewScale * titleScale;
	CGFloat lineSpacing = 0;
//	NSLog(@"font: %f scale: %f", fontSize, viewScale);
	
	// Create the paragraph style settings.
	CTParagraphStyleSetting setting[4] = {
		{kCTParagraphStyleSpecifierMaximumLineHeight, sizeof(CGFloat), &lineHeight},
		{kCTParagraphStyleSpecifierMinimumLineHeight, sizeof(CGFloat), &lineHeight},
		{kCTParagraphStyleSpecifierMaximumLineSpacing, sizeof(CGFloat), &lineSpacing},
		{kCTParagraphStyleSpecifierMinimumLineSpacing, sizeof(CGFloat), &lineSpacing}
	};
	
    CTParagraphStyleRef paragraphStyle = CTParagraphStyleCreate(setting, 4);

	// pack it into attributes dictionary
	NSDictionary *boldAttributesDict = [NSDictionary dictionaryWithObjectsAndKeys:
								(__bridge id)boldFont, (id)kCTFontAttributeName,
								(__bridge id)paragraphStyle, (id)kCTParagraphStyleAttributeName,
								color, (id)kCTForegroundColorAttributeName,
								nil];
		
	// make the attributed string
	NSAttributedString *boldStringToDraw = [[NSAttributedString alloc] initWithString:self.bookTitle
																	   attributes:boldAttributesDict];

	CTFontRef regularFont = CTFontCreateWithName(CFSTR("AvenirNext-Regular"), fontSize * self.viewScale, NULL);
	
	NSDictionary *regularAttributesDict = [NSDictionary dictionaryWithObjectsAndKeys:
										   (__bridge id)regularFont, (id)kCTFontAttributeName,
										   color, (id)kCTForegroundColorAttributeName,
										   nil];
	
	NSAttributedString *regularStringToDraw = [[NSAttributedString alloc] initWithString:self.bookAuthor
																	 attributes:regularAttributesDict];
	
	// now for the actual drawing
	CGContextRef context = UIGraphicsGetCurrentContext();
	
	// draw
	[self drawString:(__bridge CFAttributedStringRef)(boldStringToDraw) inRect:CGRectMake(
					(artworkStartX+margin) * self.viewScale,
					margin*2 * self.viewScale,
					self.bounds.size.width-(2*margin * self.viewScale),
					titleHeight*self.viewScale) inContext:context];

	[self drawString:(__bridge CFAttributedStringRef)(regularStringToDraw) inRect:CGRectMake(
				  (artworkStartX+margin) * self.viewScale,
				  titleHeight*self.viewScale,
				  self.bounds.size.width-(2*margin * self.viewScale),
				  authorHeight * self.viewScale) inContext:context];

	// clean up
	CFRelease(paragraphStyle);
	CFRelease(boldFont);
	CFRelease(regularFont);
}

-(void)drawArtwork {
	CGContextRef context = UIGraphicsGetCurrentContext();
    if (!self.plainStyle) {
        [self breakGrid];
        int i,j;
        int gridSize = self.bounds.size.width/self.gridCount;
        int item = 0;
        CGContextSetFillColorWithColor(context, self.baseColor.CGColor);
        // top color rectangle
        CGContextFillRect(context, CGRectMake(artworkStartX, 0, self.bounds.size.width, ceil(margin * self.viewScale * .3)));
        CGContextFillRect(context, CGRectMake(artworkStartX, 0, ceil(margin * self.viewScale * .3), artworkStartY));
        CGContextFillRect(context, CGRectMake(artworkStartX+self.bounds.size.width-ceil(margin*self.viewScale*.3), 0, ceil(margin * self.viewScale * .3), artworkStartY));
        CGContextFillRect(context, CGRectMake(artworkStartX, artworkStartY, self.bounds.size.width, self.bounds.size.width));
        //	NSLog(@"grid: %d %f", gridSize, self.bounds.size.width);
        NSString *c64Title = [self c64Convert];
        // println("c64Title.length(): "+c64Title.length());
        int offset = (self.bounds.size.width - (gridSize * self.gridCount)) * .5;
        self.shapeThickness = baseThickness * self.viewScale;
        for (i=0; i<self.gridCount; i++) {
            for (j=0; j<self.gridCount; j++) {
                char character = [c64Title characterAtIndex:(item%c64Title.length)];
                [self drawShape:character xPos:offset+artworkStartX+(j*gridSize) yPos:offset+artworkStartY+(i*gridSize) size:gridSize];
                item++;
            }
        }
    }
}

-(void)saveToDisk {
	if(self.bookId == nil) {
		NSLog(@"Error: could not save PNG. Set book id first!");
		return;
	}
	UIGraphicsBeginImageContext(self.bounds.size);
    [self.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage* image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
	
	// Create paths to output images
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	NSString *path = [NSString stringWithFormat:@"%@/%@.png", documentsDirectory, self.bookId];
	NSLog(@"saving to: %@", path);
	
	// Write image to PNG
	[UIImagePNGRepresentation(image) writeToFile:path atomically:YES];
}

-(void)drawShape:(char)k xPos:(int)x yPos:(int)y size:(int)s {
	CGContextRef context = UIGraphicsGetCurrentContext();
	CGContextSetFillColorWithColor(context, self.shapeColor.CGColor);
//	NSLog(@"draw %c %d %d %d", k, x, y, s);
	switch (k) {
		case 'q':
		case 'Q':
			CGContextFillEllipseInRect(context, CGRectMake(x, y, s, s));
			break;
		case 'w':
		case 'W':
			CGContextFillEllipseInRect(context, CGRectMake(x, y, s, s));
			s = s-(self.shapeThickness*2);
			CGContextSetFillColorWithColor(context, self.baseColor.CGColor);
			CGContextFillEllipseInRect(context, CGRectMake(x+self.shapeThickness, y+self.shapeThickness, s, s));
			break;
		case 'e':
		case 'E':
			CGContextFillRect(context, CGRectMake(x, y+self.shapeThickness, s, self.shapeThickness));
			break;
		case 'r':
		case 'R':
			CGContextFillRect(context, CGRectMake(x, y+s-(self.shapeThickness*2), s, self.shapeThickness));
			break;
		case 't':
		case 'T':
			CGContextFillRect(context, CGRectMake(x+self.shapeThickness, y, self.shapeThickness, s));
			break;
		case 'y':
		case 'Y':
			CGContextFillRect(context, CGRectMake(x+s-(self.shapeThickness*2), y, self.shapeThickness, s));
			break;
		case 'u':
		case 'U':
			CGContextMoveToPoint(context, x, y+s);
			CGContextAddArc(context, x+s, y+s, s, M_PI, M_PI+M_PI_2, 0);
			CGContextAddLineToPoint(context, x+s, y+s);
			CGContextClosePath(context);
			CGContextDrawPath(context, 0);

			CGContextSetFillColorWithColor(context, self.baseColor.CGColor);
			CGContextMoveToPoint(context, x+self.shapeThickness, y+s+self.shapeThickness);
			CGContextAddArc(context, x+s, y+s, s-self.shapeThickness, M_PI, M_PI+M_PI_2, 0);
			CGContextAddLineToPoint(context, x+s, y+s);
			CGContextClosePath(context);
			CGContextDrawPath(context, 0);
			break;
		case 'i':
		case 'I':
			CGContextMoveToPoint(context, x, y);
			CGContextAddArc(context, x, y+s, s, M_PI+M_PI_2, 0, 0);
			CGContextAddLineToPoint(context, x, y+s);
			CGContextClosePath(context);
			CGContextDrawPath(context, 0);
			
			CGContextSetFillColorWithColor(context, self.baseColor.CGColor);
			CGContextMoveToPoint(context, x, y+self.shapeThickness);
			CGContextAddArc(context, x, y+s, s-self.shapeThickness, M_PI+M_PI_2, 0, 0);
			CGContextAddLineToPoint(context, x, y+s);
			CGContextClosePath(context);
			CGContextDrawPath(context, 0);
			break;
		case 'o':
		case 'O':
			CGContextFillRect(context, CGRectMake(x, y, s, self.shapeThickness));
			CGContextFillRect(context, CGRectMake(x, y, self.shapeThickness, s));
			break;
		case 'p':
		case 'P':
			CGContextFillRect(context, CGRectMake(x, y, s, self.shapeThickness));
			CGContextFillRect(context, CGRectMake(x+s-self.shapeThickness, y, self.shapeThickness, s));
			break;
		case 'a':
		case 'A':
			[self drawTriangle:x y1:y+s x2:x+(s/2) y2:y x3:x+s y3:y+s inContext:context];
			break;
		case 's':
		case 'S':
			[self drawTriangle:x y1:y x2:x+(s/2) y2:y+s x3:x+s y3:y inContext:context];
			break;
		case 'd':
		case 'D':
			CGContextFillRect(context, CGRectMake(x, y+(self.shapeThickness*2), s, self.shapeThickness));
			break;
		case 'f':
		case 'F':
			CGContextFillRect(context, CGRectMake(x, y+s-(self.shapeThickness*3), s, self.shapeThickness));
			break;
		case 'g':
		case 'G':
			CGContextFillRect(context, CGRectMake(x+(self.shapeThickness*2), y, self.shapeThickness, s));
			break;
		case 'h':
		case 'H':
			CGContextFillRect(context, CGRectMake(x+s-(self.shapeThickness*3), y, self.shapeThickness, s));
			break;
		case 'j':
		case 'J':
			CGContextMoveToPoint(context, x+s, y+s);
			CGContextAddArc(context, x+s, y, s, M_PI_2, M_PI, 0);
			CGContextAddLineToPoint(context, x+s, y);
			CGContextClosePath(context);
			CGContextDrawPath(context, 0);
			
			CGContextSetFillColorWithColor(context, self.baseColor.CGColor);
			CGContextMoveToPoint(context, x+s, y+s-self.shapeThickness);
			CGContextAddArc(context, x+s, y, s-self.shapeThickness, M_PI_2, M_PI, 0);
			CGContextAddLineToPoint(context, x+s, y);
			CGContextClosePath(context);
			CGContextDrawPath(context, 0);
			break;
		case 'k':
		case 'K':
			CGContextMoveToPoint(context, x+s, y);
			CGContextAddArc(context, x, y, s, 0, M_PI_2, 0);
			CGContextAddLineToPoint(context, x, y);
			CGContextClosePath(context);
			CGContextDrawPath(context, 0);
			
			CGContextSetFillColorWithColor(context, self.baseColor.CGColor);
			CGContextMoveToPoint(context, x+s-self.shapeThickness, y);
			CGContextAddArc(context, x, y, s-self.shapeThickness, 0, M_PI_2, 0);
			CGContextAddLineToPoint(context, x, y);
			CGContextClosePath(context);
			CGContextDrawPath(context, 0);
			break;
		case 'l':
		case 'L':
			CGContextFillRect(context, CGRectMake(x, y, self.shapeThickness, s));
			CGContextFillRect(context, CGRectMake(x, y+s-self.shapeThickness, s, self.shapeThickness));
			break;
		case ':':
			CGContextFillRect(context, CGRectMake(x+s-self.shapeThickness, y, self.shapeThickness, s));
			CGContextFillRect(context, CGRectMake(x, y+s-self.shapeThickness, s, self.shapeThickness));
			break;
		case 'z':
		case 'Z':
			[self drawTriangle:x y1:y+(s/2) x2:x+(s/2) y2:y x3:x+s y3:y+(s/2) inContext:context];
			[self drawTriangle:x y1:y+(s/2) x2:x+(s/2) y2:y+s x3:x+s y3:y+(s/2) inContext:context];
			break;
		case 'x':
		case 'X':
			CGContextFillEllipseInRect(context, CGRectMake(x+(s/2)-self.shapeThickness, y+(s/3)-self.shapeThickness, self.shapeThickness*2, self.shapeThickness*2));
			CGContextFillEllipseInRect(context, CGRectMake(x+(s/3)-self.shapeThickness, y+s-(s/3)-self.shapeThickness, self.shapeThickness*2, self.shapeThickness*2));
			CGContextFillEllipseInRect(context, CGRectMake(x+s-(s/3)-self.shapeThickness, y+s-(s/3)-self.shapeThickness, self.shapeThickness*2, self.shapeThickness*2));
			break;
		case 'c':
		case 'C':
			CGContextFillRect(context, CGRectMake(x, y+(self.shapeThickness*3), s, self.shapeThickness));
			break;
		case 'v':
		case 'V':
			CGContextFillRect(context, CGRectMake(x, y, s, s));
			CGContextSetFillColorWithColor(context, self.baseColor.CGColor);
			[self drawTriangle:x+self.shapeThickness y1:y x2:x+(s/2) y2:y+(s/2)-self.shapeThickness x3:x+s-self.shapeThickness y3:y inContext:context];
			[self drawTriangle:x y1:y+self.shapeThickness x2:x+(s/2)-self.shapeThickness y2:y+(s/2) x3:x y3:y+s-self.shapeThickness inContext:context];
			[self drawTriangle:x+self.shapeThickness y1:y+s x2:x+(s/2) y2:y+(s/2)+self.shapeThickness x3:x+s-self.shapeThickness y3:y+s inContext:context];
			[self drawTriangle:x+s y1:y+self.shapeThickness x2:x+s y2:y+s-self.shapeThickness x3:x+(s/2)+self.shapeThickness y3:y+(s/2) inContext:context];
			break;
		case 'b':
		case 'B':
			CGContextFillRect(context, CGRectMake(x+(self.shapeThickness*3), y, self.shapeThickness, s));
			break;
		case 'n':
		case 'N':
			CGContextFillRect(context, CGRectMake(x, y, s, s));
			CGContextSetFillColorWithColor(context, self.baseColor.CGColor);
			[self drawTriangle:x y1:y x2:x+s-self.shapeThickness y2:y x3:x y3:y+s-self.shapeThickness inContext:context];
			[self drawTriangle:x+self.shapeThickness y1:y+s x2:x+s y2:y+s x3:x+s y3:y+self.shapeThickness inContext:context];
			break;
		case 'm':
		case 'M':
			CGContextFillRect(context, CGRectMake(x, y, s, s));
			CGContextSetFillColorWithColor(context, self.baseColor.CGColor);
			[self drawTriangle:x+self.shapeThickness y1:y x2:x+s y2:y x3:x+s y3:y+s-self.shapeThickness inContext:context];
			[self drawTriangle:x y1:y+self.shapeThickness x2:x y2:y+s x3:x+s-self.shapeThickness y3:y+s inContext:context];
			break;
		case '7':
			CGContextFillRect(context, CGRectMake(x, y, s, self.shapeThickness));
			break;
		case '8':
			CGContextFillRect(context, CGRectMake(x, y, s, self.shapeThickness*2));
			break;
		case '9':
			CGContextFillRect(context, CGRectMake(x, y+s-(self.shapeThickness*2), s, self.shapeThickness*2));
			break;
		case '4':
			CGContextFillRect(context, CGRectMake(x, y, self.shapeThickness, s));
			break;
		case '5':
			CGContextFillRect(context, CGRectMake(x, y, self.shapeThickness*2, s));
			break;
		case '6':
			CGContextFillRect(context, CGRectMake(x+s-(self.shapeThickness*3), y, self.shapeThickness*2, s));
			break;
		case '1':
			CGContextFillRect(context, CGRectMake(x, y+(s/2)-(self.shapeThickness/2), s, self.shapeThickness));
			CGContextFillRect(context, CGRectMake(x+(s/2)-(self.shapeThickness/2), y, self.shapeThickness, s/2+self.shapeThickness/2));
			break;
		case '2':
			CGContextFillRect(context, CGRectMake(x, y+(s/2)-(self.shapeThickness/2), s, self.shapeThickness));
			CGContextFillRect(context, CGRectMake(x+(s/2)-(self.shapeThickness/2), y+(s/2)-(self.shapeThickness/2), self.shapeThickness, s/2+self.shapeThickness/2));
			break;
		case '3':
			CGContextFillRect(context, CGRectMake(x, y+(s/2)-(self.shapeThickness/2), s/2+self.shapeThickness/2, self.shapeThickness));
			CGContextFillRect(context, CGRectMake(x+(s/2)-(self.shapeThickness/2), y, self.shapeThickness, s));
			break;
		case '0':
			CGContextFillRect(context, CGRectMake(x+(s/2)-(self.shapeThickness/2), y+(s/2)-(self.shapeThickness/2), self.shapeThickness, s/2+self.shapeThickness/2));
			CGContextFillRect(context, CGRectMake(x+(s/2)-(self.shapeThickness/2), y+(s/2)-(self.shapeThickness/2), s/2+self.shapeThickness/2, self.shapeThickness));
			break;
		case '.':
			CGContextFillRect(context, CGRectMake(x+(s/2)-(self.shapeThickness/2), y+(s/2)-(self.shapeThickness/2), self.shapeThickness, s/2+self.shapeThickness/2));
			CGContextFillRect(context, CGRectMake(x, y+(s/2)-(self.shapeThickness/2), s/2+self.shapeThickness/2, self.shapeThickness));
			break;
		default:
			CGContextSetFillColorWithColor(context, self.baseColor.CGColor);
			CGContextFillRect(context, CGRectMake(x, y, s, s));
			break;
	}
}

#pragma mark - utils

-(NSString *)c64Convert {
	// returns a string with all the c64-letter available in the title or a random set if none
	int i, len = (int)self.bookTitle.length;
	NSMutableString *result = [NSMutableString stringWithCapacity:len];
	char letter;
	for (i=0; i<len; i++) {
		letter = [self.bookTitle characterAtIndex:i];
		NSRange range = [self indexOf:letter inString:c64Letters];
		if (range.length == 0) {
			int anIndex = (int)(letter%c64Letters.length);
			letter = [c64Letters characterAtIndex:anIndex];
//			NSLog(@"letter: %c num: %d idx: %d len: %d orig:%d mod:%d", letter, (int)letter, anIndex, c64Letters.length, (char)[self.bookTitle characterAtIndex:i], (int)(((char)[self.bookTitle characterAtIndex:i])%c64Letters.length));
		}
		[result appendString:[NSString stringWithFormat:@"%c", letter]];
	}
	//	NSLog(@"result: %@", result);
	return [NSString stringWithString:result];
}

-(NSRange) indexOf:(char) searchChar inString:(NSString *)string {
	NSRange searchRange;
	searchRange.location=(unsigned int)searchChar;
	searchRange.length=1;
	NSRange foundRange = [string rangeOfCharacterFromSet:[NSCharacterSet characterSetWithRange:searchRange]];
	return foundRange;
}

-(void)breakGrid {
	int len = (int)self.bookTitle.length;
	if (len < minTitle) len = minTitle;
	if (len > maxTitle) len = maxTitle;
	self.gridCount = (int)ofMap(len, minTitle, maxTitle, 2, 11, NO);
}

-(void)drawTriangle:(float)x1 y1:(float)y1 x2:(float)x2 y2:(float)y2 x3:(float)x3 y3:(float)y3 inContext:(CGContextRef)context {
	CGContextMoveToPoint(context, x1, y1);
	CGContextAddLineToPoint(context, x2, y2);
	CGContextAddLineToPoint(context, x3, y3);
	CGContextAddLineToPoint(context, x1, y1);
	CGContextClosePath(context);
	CGContextDrawPath(context, 0);
}

- (void)drawString:(CFAttributedStringRef)attString inRect:(CGRect)frameRect inContext:(CGContextRef)context
{
	CGContextSaveGState(context);
	
	// Flip the coordinate system
	CGContextSetTextMatrix(context, CGAffineTransformIdentity);
	CGContextTranslateCTM(context, 0, self.bounds.size.height);
	CGContextScaleCTM(context, 1.0, -1.0);
	
	CGFloat height = self.frame.size.height;
	frameRect.origin.y = (height - frameRect.origin.y)  - frameRect.size.height ;
	
	// Create a path to render text in
	// don't set any line break modes, etc, just let the frame draw as many full lines as will fit
	CGMutablePathRef framePath = CGPathCreateMutable();
	CGPathAddRect(framePath, nil, frameRect);
	CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString(attString);
	CFRange fullStringRange = CFRangeMake(0, CFAttributedStringGetLength(attString));
	CTFrameRef aFrame = CTFramesetterCreateFrame(framesetter, fullStringRange, framePath, NULL);
	CFRelease(framePath);
	
	CFArrayRef lines = CTFrameGetLines(aFrame);
	CFIndex count = CFArrayGetCount(lines);
	CGPoint *origins = malloc(sizeof(CGPoint)*count);
	CTFrameGetLineOrigins(aFrame, CFRangeMake(0, count), origins);
	
	// note that we only enumerate to count-1 in here-- we draw the last line separately
	for (CFIndex i = 0; i < count-1; i++)
	{
		// draw each line in the correct position as-is
		CGContextSetTextPosition(context, origins[i].x + frameRect.origin.x, origins[i].y + frameRect.origin.y);
		CTLineRef line = (CTLineRef)CFArrayGetValueAtIndex(lines, i);
		CTLineDraw(line, context);
	}
	
	// truncate the last line before drawing it
	if (count) {
		CGPoint lastOrigin = origins[count-1];
		CTLineRef lastLine = CFArrayGetValueAtIndex(lines, count-1);
		
		// truncation token is a CTLineRef itself
		CFRange effectiveRange;
		CFDictionaryRef stringAttrs = CFAttributedStringGetAttributes(attString, 0, &effectiveRange);
		
		CFAttributedStringRef truncationString = CFAttributedStringCreate(NULL, CFSTR("\u2026"), stringAttrs);
		CTLineRef truncationToken = CTLineCreateWithAttributedString(truncationString);
		CFRelease(truncationString);
		
		// now create the truncated line -- need to grab extra characters from the source string,
		// or else the system will see the line as already fitting within the given width and
		// will not truncate it.
		
		// range to cover everything from the start of lastLine to the end of the string
		CFRange rng = CFRangeMake(CTLineGetStringRange(lastLine).location, 0);
		rng.length = CFAttributedStringGetLength(attString) - rng.location;
		
		// substring with that range
		CFAttributedStringRef longString = CFAttributedStringCreateWithSubstring(NULL, attString, rng);
		// line for that string
		CTLineRef longLine = CTLineCreateWithAttributedString(longString);
		CFRelease(longString);
		
		CTLineRef truncated = CTLineCreateTruncatedLine(longLine, frameRect.size.width, kCTLineTruncationEnd, truncationToken);
		CFRelease(longLine);
		CFRelease(truncationToken);
		
		// if 'truncated' is NULL, then no truncation was required to fit it
		if (truncated == NULL)
			truncated = (CTLineRef)CFRetain(lastLine);
		
		// draw it at the same offset as the non-truncated version
		CGContextSetTextPosition(context, lastOrigin.x + frameRect.origin.x, lastOrigin.y + frameRect.origin.y);
		CTLineDraw(truncated, context);
		CFRelease(truncated);
	}
	free(origins);
	
	CFRelease(aFrame);
	CFRelease(framesetter);
	
	CGContextRestoreGState(context);
}

@end
