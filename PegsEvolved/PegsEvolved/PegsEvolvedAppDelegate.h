//
//  PegsEvolvedAppDelegate.h
//  PegsEvolved
//
//  Created by Billy Connolly on 4/7/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class EAGLViewController;

@interface PegsEvolvedAppDelegate : NSObject <UIApplicationDelegate> {
    EAGLViewController *eaglViewController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) EAGLViewController *eaglViewController;

@end
