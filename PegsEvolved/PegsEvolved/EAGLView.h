//
//  EAGLView.h
//  PegsEvolved
//
//  Created by Billy Connolly on 4/7/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <OpenGLES/EAGL.h>
#import <OpenGLES/ES1/gl.h>
#import <OpenGLES/ES1/glext.h>

@class EAGLViewController;

@interface EAGLView : UIView {
    
@private
    /* The pixel dimensions of the backbuffer */
    GLint backingWidth;
    GLint backingHeight;
    
    EAGLContext *context;
    
    GLuint viewRenderbuffer, viewFramebuffer;
    
    GLuint textures[8];
    GLuint guiTextures[2];
    
    float buttonTexCoordsLeft[5];
    
    NSTimer *animationTimer;
    NSTimeInterval animationInterval;
    
    EAGLViewController *eaglViewController;
}

@property NSTimeInterval animationInterval;
@property (nonatomic, retain) EAGLViewController *eaglViewController;

- (id)initWithFrame:(CGRect)frame EAGLViewController:(EAGLViewController *)_eaglViewController themeName:(NSString *)themeName;

- (void)startAnimation;
- (void)stopAnimation;

- (void)Update;
- (void)Draw;
- (void)LoadContent:(NSString *)themeName;

- (void)createTexture: (GLuint)location fileName: (NSString *)fileName;

@end