//
//  EAGLView.m
//  PegsEvolved
//
//  Created by Billy Connolly on 4/7/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.

#import <QuartzCore/QuartzCore.h>
#import <OpenGLES/EAGLDrawable.h>
#import "EAGLView.h"
#import "EAGLViewController.h"

// A class extension to declare private methods
@interface EAGLView ()

@property (nonatomic, retain) EAGLContext *context;
@property (nonatomic, assign) NSTimer *animationTimer;

- (BOOL) createFramebuffer;
- (void) destroyFramebuffer;

@end

@implementation EAGLView

@synthesize context;
@synthesize animationTimer;
@synthesize animationInterval;
@synthesize eaglViewController;

// You must implement this method
+ (Class)layerClass {
    return [CAEAGLLayer class];
}

- (id)initWithFrame:(CGRect)frame EAGLViewController:(EAGLViewController *)_eaglViewController{
    if ((self = [super initWithFrame:frame])){
        self.eaglViewController = _eaglViewController;
        CAEAGLLayer *eaglLayer = (CAEAGLLayer *)self.layer;
        
        eaglLayer.opaque = YES;
        eaglLayer.drawableProperties = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:NO], kEAGLDrawablePropertyRetainedBacking, kEAGLColorFormatRGBA8, kEAGLDrawablePropertyColorFormat, nil];
        
        context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES1];
        
        if (!context || ![EAGLContext setCurrentContext:context]) {
            [self release];
            return nil;
        }
		
		glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
        self.contentScaleFactor = 2.0f;
        
        animationInterval = 1.0 / 60.0;
        [self LoadContent];
        [self startAnimation];
        
        [EAGLContext setCurrentContext:context];
        [self destroyFramebuffer];
        [self createFramebuffer];
        [self Update];
	}
    return self;
}
- (void)LoadContent{
    glGenTextures(7, &textures[0]);
    for(int x = 0; x < 8; x++){
        [self createTexture:textures[x] fileName: [NSString stringWithFormat: @"Original%i", x]];
    }
    
    glGenTextures(1, &guiTextures[0]);
    [self createTexture:guiTextures[0] fileName:@"DirectionalPadFWX"];
    for(int x = 0; x < 5; x++){
        buttonTexCoordsLeft[x] = (x * 128.0f) / 1024.0f;
    }
    
}

- (void)Update{
	[self Draw];
}

- (void)Draw{
	[EAGLContext setCurrentContext:context];
    
    glBindFramebufferOES(GL_FRAMEBUFFER_OES, viewFramebuffer);
    glViewport(0, 0, backingWidth, backingHeight);
    
	glMatrixMode(GL_PROJECTION);
    glLoadIdentity();
	glRotatef(-90.0, 0, 0, 1);
    glOrthof(0.0f, 480.0f, 0.0f, 320.0f, -1.0f, 1.0f);
    glMatrixMode(GL_MODELVIEW);
    glLoadIdentity();
    
    glClearColor(0.2f, 0.3f, 0.4f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT);
	
    glEnable(GL_BLEND);
    glEnable(GL_TEXTURE_2D);
	glEnableClientState(GL_VERTEX_ARRAY);
    glEnableClientState(GL_TEXTURE_COORD_ARRAY);
	//////////////////////Drawing Code////////////////////////
    
    static const GLfloat texCoords[] = {
        0.0f, 0.625f,
        0.625f, 0.625f,
        0.0f, 0.0f,
        0.625f, 0.0f
    };
	static const GLfloat verts[] = {
		-20.0f, 20.0f,
		20.0f, 20.0f,
		-20.0f, -20.0f,
		20.0f, -20.0f
	};
    
    for(int x = 0; x < 12; x++){
        for(int y = 0; y < 8; y++){
            glPushMatrix();
                glTranslatef(x * 40.0f + 20.0f, (8 - y) * 40.0f - 20.0f, 0.0f);
                glBindTexture(GL_TEXTURE_2D, textures[[eaglViewController getMapNumberWithCGPointLocation: CGPointMake(x, y)]]);
                //glBindTexture(GL_TEXTURE_2D, textures[]);
                glVertexPointer(2, GL_FLOAT, 0, verts);
                glTexCoordPointer(2, GL_FLOAT, 0, texCoords);	
                glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
            glPopMatrix();
        }
    }
    
    glPushMatrix();
        CGPoint loc = [eaglViewController getPlayerLocationGL];
        glTranslatef(loc.x, loc.y, 0.0f);
        glBindTexture(GL_TEXTURE_2D, textures[3]);
        glVertexPointer(2, GL_FLOAT, 0, verts);
        glTexCoordPointer(2, GL_FLOAT, 0, texCoords);
        glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
    glPopMatrix();
    
    int whichButton = [eaglViewController getWhichButtonDown];
    float left = buttonTexCoordsLeft[whichButton];
    
    const GLfloat guiTexCoords[] = {
        left, 1.0f,
        left + .125f, 1.0f,
        left, 0.0f,
        left + .125f, 0.0f
    };
	static const GLfloat guiVerts[] = {
		-64.0f, 64.0f,
		64.0f, 64.0f,
		-64.0f, -64.0f,
		64.0f, -64.0f
	};
    
    glPushMatrix();
        glTranslatef(412.0f, 68.0f, 0.0f);
        glBindTexture(GL_TEXTURE_2D, guiTextures[0]);
        glVertexPointer(2, GL_FLOAT, 0, guiVerts);
        glTexCoordPointer(2, GL_FLOAT, 0, guiTexCoords);
        glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
    glPopMatrix();
    
	//////////////////////////////////////////////////////////
    glDisable(GL_TEXTURE_2D);
	glDisable(GL_BLEND);
	glDisableClientState(GL_VERTEX_ARRAY);
    glDisableClientState(GL_TEXTURE_COORD_ARRAY);
	
	glBindRenderbufferOES(GL_RENDERBUFFER_OES, viewRenderbuffer);
    [context presentRenderbuffer:GL_RENDERBUFFER_OES];
}

- (BOOL)createFramebuffer {
    
    glGenFramebuffersOES(1, &viewFramebuffer);
    glGenRenderbuffersOES(1, &viewRenderbuffer);
    
    glBindFramebufferOES(GL_FRAMEBUFFER_OES, viewFramebuffer);
    glBindRenderbufferOES(GL_RENDERBUFFER_OES, viewRenderbuffer);
    [context renderbufferStorage:GL_RENDERBUFFER_OES fromDrawable:(CAEAGLLayer*)self.layer];
    glFramebufferRenderbufferOES(GL_FRAMEBUFFER_OES, GL_COLOR_ATTACHMENT0_OES, GL_RENDERBUFFER_OES, viewRenderbuffer);
    
    glGetRenderbufferParameterivOES(GL_RENDERBUFFER_OES, GL_RENDERBUFFER_WIDTH_OES, &backingWidth);
    glGetRenderbufferParameterivOES(GL_RENDERBUFFER_OES, GL_RENDERBUFFER_HEIGHT_OES, &backingHeight);
    
    if(glCheckFramebufferStatusOES(GL_FRAMEBUFFER_OES) != GL_FRAMEBUFFER_COMPLETE_OES) {
        NSLog(@"failed to make complete framebuffer object %x", glCheckFramebufferStatusOES(GL_FRAMEBUFFER_OES));
        return NO;
    }
    
    return YES;
}


- (void)destroyFramebuffer {
    
    glDeleteFramebuffersOES(1, &viewFramebuffer);
    viewFramebuffer = 0;
    glDeleteRenderbuffersOES(1, &viewRenderbuffer);
    viewRenderbuffer = 0;
}

- (void)pauseGame{
	[animationTimer invalidate];
	[self stopAnimation];
	self.userInteractionEnabled = NO;
}

- (void)unpauseGame{
	[self startAnimation];
	self.userInteractionEnabled = YES;
}

- (void)startAnimation {
    self.animationTimer = [NSTimer scheduledTimerWithTimeInterval:animationInterval target:self selector:@selector(Update) userInfo:nil repeats:YES];
}

- (void)stopAnimation {
    self.animationTimer = nil;
}

- (void)setAnimationTimer:(NSTimer *)newTimer {
    [animationTimer invalidate];
    animationTimer = newTimer;
}

- (void)dealloc {
    
	[self stopAnimation];
    
    if ([EAGLContext currentContext] == context) {
        [EAGLContext setCurrentContext:nil];
    }
    
    [context release];  
    [super dealloc];
}

- (void)createTexture: (GLuint)location fileName: (NSString *)fileName{
	
	glBindTexture(GL_TEXTURE_2D, location);
	glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MIN_FILTER, GL_NEAREST); 
    glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MAG_FILTER, GL_NEAREST);
	NSString *path = [[NSBundle mainBundle] pathForResource:fileName ofType:@"png"];
    NSData *texData = [[NSData alloc] initWithContentsOfFile:path];
    UIImage *image = [[UIImage alloc] initWithData:texData];
    if (image == nil)
        NSLog(@"Do real error checking here");
	
    GLuint width = CGImageGetWidth(image.CGImage);
    GLuint height = CGImageGetHeight(image.CGImage);
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    void *imageData = malloc( height * width * 4 );
    CGContextRef contextt = CGBitmapContextCreate( imageData, width, height, 8, 4 * width, colorSpace, kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big );
	CGContextTranslateCTM(contextt, 0, height);
	CGContextScaleCTM(contextt, 1.0, -1.0);
    CGColorSpaceRelease( colorSpace );
    CGContextClearRect( contextt, CGRectMake( 0, 0, width, height ) );
    CGContextTranslateCTM( contextt, 0, height - height );
    CGContextDrawImage( contextt, CGRectMake( 0, 0, width, height ), image.CGImage );
	
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, width, height, 0, GL_RGBA, GL_UNSIGNED_BYTE, imageData);
	
    CGContextRelease(contextt);
	
    free(imageData);
    [image release];
    [texData release];
}

- (BOOL) isMultipleTouchEnabled {return YES;}

@end