//
//  EAGLViewController.h
//  PegsEvolved
//
//  Created by Billy Connolly on 4/7/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EAGLView.h"

enum{
    P_BLANK=0,
    P_BRICK,
    P_HOLE,
    P_PLAYER,
    P_SQUARE,
    P_CIRCLE,
    P_TRIANGLE,
    P_PLUS
};

enum{
    B_NONE=0,
    B_UP,
    B_DOWN,
    B_LEFT,
    B_RIGHT
};

@interface EAGLViewController : UIViewController {
    EAGLView *eaglView;
    
    // Map Data //
    int characterLocationX;
    int characterLocationY;
    NSMutableArray *mapLocations;
    
    int whichButtonDown;
    NSTimer *movementTimer;
    NSTimeInterval movementInterval;
    
    BOOL isSelectingPeg;
    CGPoint selectPegOffset;
}

@property (nonatomic, retain) EAGLView *eaglView;

- (id)initWithTheme:(NSString *)theme repeatRate:(NSTimeInterval)repeatRate;

- (void)resetVariables;
- (void)loadLevel:(NSString *)fileName;

- (void)readFile:(NSString *)fileName;

- (void)move;

- (int)getMapNumberWithCGPointLocation: (CGPoint)location;
- (void)setMapNumberWithCGPointLocation: (CGPoint)location newNumber:(int)newNumber;
- (CGPoint)getPlayerLocationGL;
- (CGPoint)getPlayerLocation;
- (int)getWhichButtonDown;
- (BOOL)getIsSelectingPeg;

@end
