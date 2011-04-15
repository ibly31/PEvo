//
//  EAGLViewController.m
//  PegsEvolved
//
//  Created by Billy Connolly on 4/7/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "EAGLViewController.h"

@implementation EAGLViewController
@synthesize eaglView;

- (id)initWithTheme:(NSString *)theme repeatRate:(NSTimeInterval)repeatRate{
    self = [super init];
    if(self){
        self.eaglView = [[EAGLView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, 480.0f) EAGLViewController:self themeName: theme];
        [self.view addSubview: eaglView];
        
        movementInterval = repeatRate;
    }
    return self; 
}

- (void)loadLevel:(NSString *)fileName{
    [self resetVariables];
    [self readFile: fileName];
}

- (void)resetVariables{
    characterLocationX = 0;
    characterLocationY = 0;
    whichButtonDown = B_NONE;
    isSelectingPeg = NO;
}

- (void)readFile:(NSString *)fileName{
	NSString *path = [[NSBundle mainBundle] pathForResource:fileName ofType:@"txt"];
	NSData *data = [NSData dataWithContentsOfFile: path];
	NSString *string = [[NSString alloc] initWithData:data encoding: NSUTF8StringEncoding];
	if(!string){
		NSLog(@"Could not load file %@", fileName);
	}
	string = [string stringByReplacingOccurrencesOfString:@"\n" withString:@","];
    char *cstring = (char *)[string UTF8String];
	BOOL going = YES;
	//int n = 1;
	strtok(cstring, ",");
	mapLocations = [[NSMutableArray alloc] init];
    NSNumber *mapNum = [[NSNumber alloc] initWithInt: atoi(cstring)];
    [mapLocations addObject: mapNum];
    [mapNum release];
	while(going){
		char *result = strtok(NULL, ",");
		if(result != NULL){
			NSNumber *mapNum = [[NSNumber alloc] initWithInt: atoi(result)];
			[mapLocations addObject: mapNum];
			[mapNum release];
			if([mapNum intValue] == 3){
                characterLocationX = ([mapLocations count] % 12) - 1;
                characterLocationY = ((int)([mapLocations count] / 12));
				[mapLocations replaceObjectAtIndex: [mapLocations count] - 1 withObject: [NSNumber numberWithInt: 0]];
			}
		}else{
			going = NO;
		}
	}
}

- (void)move{
    if(whichButtonDown == B_UP){
        if(characterLocationY != 0){
            int whatsThere = [self getMapNumberWithCGPointLocation: CGPointMake(characterLocationX, characterLocationY - 1)];
            if(whatsThere == P_BLANK){
                characterLocationY--;
            }else if(whatsThere == P_SQUARE || whatsThere == P_CIRCLE || whatsThere == P_TRIANGLE || whatsThere == P_PLUS){
                int whatsBehindWhatsThere = [self getMapNumberWithCGPointLocation: CGPointMake(characterLocationX, characterLocationY - 2)];
                if(whatsBehindWhatsThere == 0){
                    [self setMapNumberWithCGPointLocation: CGPointMake(characterLocationX, characterLocationY - 2) newNumber: whatsThere];
                    [self setMapNumberWithCGPointLocation: CGPointMake(characterLocationX, characterLocationY - 1) newNumber: 0];
                    characterLocationY--;
                }else if(whatsBehindWhatsThere == whatsThere){
                    if(whatsThere == P_SQUARE || whatsThere == P_CIRCLE){
                        [self setMapNumberWithCGPointLocation: CGPointMake(characterLocationX, characterLocationY - 2) newNumber: 0];
                        [self setMapNumberWithCGPointLocation: CGPointMake(characterLocationX, characterLocationY - 1) newNumber: 0];
                        characterLocationY--;
                    }else if(whatsThere == P_TRIANGLE){
                        [self setMapNumberWithCGPointLocation: CGPointMake(characterLocationX, characterLocationY - 2) newNumber: 1];
                        [self setMapNumberWithCGPointLocation: CGPointMake(characterLocationX, characterLocationY - 1) newNumber: 0];
                        characterLocationY--;
                    }else if(whatsThere == P_PLUS){
                        isSelectingPeg = YES;
                        selectPegOffset = CGPointMake(0, -2);
                        whichButtonDown = B_NONE;
                    }
                }else if(whatsBehindWhatsThere == 2){
                    if(whatsThere == P_SQUARE){
                        [self setMapNumberWithCGPointLocation: CGPointMake(characterLocationX, characterLocationY - 2) newNumber: 0];
                        [self setMapNumberWithCGPointLocation: CGPointMake(characterLocationX, characterLocationY - 1) newNumber: 0];
                        characterLocationY--;
                    }else{
                        [self setMapNumberWithCGPointLocation: CGPointMake(characterLocationX, characterLocationY - 1) newNumber: 0];
                        characterLocationY--;
                    }
                }
            }
        }
    }else if(whichButtonDown == B_DOWN){
        if(characterLocationY != 7){
            int whatsThere = [self getMapNumberWithCGPointLocation: CGPointMake(characterLocationX, characterLocationY + 1)];
            if(whatsThere == P_BLANK){
                characterLocationY++;
            }else if(whatsThere == P_SQUARE || whatsThere == P_CIRCLE || whatsThere == P_TRIANGLE || whatsThere == P_PLUS){
                int whatsBehindWhatsThere = [self getMapNumberWithCGPointLocation: CGPointMake(characterLocationX, characterLocationY + 2)];
                if(whatsBehindWhatsThere == 0){
                    [self setMapNumberWithCGPointLocation: CGPointMake(characterLocationX, characterLocationY + 2) newNumber: whatsThere];
                    [self setMapNumberWithCGPointLocation: CGPointMake(characterLocationX, characterLocationY + 1) newNumber: 0];
                    characterLocationY++;
                }else if(whatsBehindWhatsThere == whatsThere){
                    if(whatsThere == P_SQUARE || whatsThere == P_CIRCLE){
                        [self setMapNumberWithCGPointLocation: CGPointMake(characterLocationX, characterLocationY + 2) newNumber: 0];
                        [self setMapNumberWithCGPointLocation: CGPointMake(characterLocationX, characterLocationY + 1) newNumber: 0];
                        characterLocationY++;
                    }else if(whatsThere == P_TRIANGLE){
                        [self setMapNumberWithCGPointLocation: CGPointMake(characterLocationX, characterLocationY + 2) newNumber: 1];
                        [self setMapNumberWithCGPointLocation: CGPointMake(characterLocationX, characterLocationY + 1) newNumber: 0];
                        characterLocationY++;
                    }else if(whatsThere == P_PLUS){
                        isSelectingPeg = YES;
                        selectPegOffset = CGPointMake(0, 2);
                        whichButtonDown = B_NONE;
                    }
                }else if(whatsBehindWhatsThere == 2){
                    if(whatsThere == P_SQUARE){
                        [self setMapNumberWithCGPointLocation: CGPointMake(characterLocationX, characterLocationY + 2) newNumber: 0];
                        [self setMapNumberWithCGPointLocation: CGPointMake(characterLocationX, characterLocationY + 1) newNumber: 0];
                        characterLocationY++;
                    }else{
                        [self setMapNumberWithCGPointLocation: CGPointMake(characterLocationX, characterLocationY + 1) newNumber: 0];
                        characterLocationY++;
                    }
                }
            }
            
        }
    }else if(whichButtonDown == B_LEFT){
        if(characterLocationX != 0){
            int whatsThere = [self getMapNumberWithCGPointLocation: CGPointMake(characterLocationX - 1, characterLocationY)];
            if(whatsThere == P_BLANK){
                characterLocationX--;
            }else if(whatsThere == P_SQUARE || whatsThere == P_CIRCLE || whatsThere == P_TRIANGLE || whatsThere == P_PLUS){
                int whatsBehindWhatsThere = [self getMapNumberWithCGPointLocation: CGPointMake(characterLocationX - 2, characterLocationY)];
                if(whatsBehindWhatsThere == 0){
                    [self setMapNumberWithCGPointLocation: CGPointMake(characterLocationX - 2, characterLocationY) newNumber: whatsThere];
                    [self setMapNumberWithCGPointLocation: CGPointMake(characterLocationX - 1, characterLocationY) newNumber: 0];
                    characterLocationX--;
                }else if(whatsBehindWhatsThere == whatsThere){
                    if(whatsThere == P_SQUARE || whatsThere == P_CIRCLE){
                        [self setMapNumberWithCGPointLocation: CGPointMake(characterLocationX - 2, characterLocationY) newNumber: 0];
                        [self setMapNumberWithCGPointLocation: CGPointMake(characterLocationX - 1, characterLocationY) newNumber: 0];
                        characterLocationX--;
                    }else if(whatsThere == P_TRIANGLE){
                        [self setMapNumberWithCGPointLocation: CGPointMake(characterLocationX - 2, characterLocationY) newNumber: 1];
                        [self setMapNumberWithCGPointLocation: CGPointMake(characterLocationX - 1, characterLocationY) newNumber: 0];
                        characterLocationX--;
                    }else if(whatsThere == P_PLUS){
                        isSelectingPeg = YES;
                        selectPegOffset = CGPointMake(-2, 0);
                        whichButtonDown = B_NONE;
                    }
                }else if(whatsBehindWhatsThere == 2){
                    if(whatsThere == P_SQUARE){
                        [self setMapNumberWithCGPointLocation: CGPointMake(characterLocationX - 2, characterLocationY) newNumber: 0];
                        [self setMapNumberWithCGPointLocation: CGPointMake(characterLocationX - 1, characterLocationY) newNumber: 0];
                        characterLocationX--;
                    }else{
                        [self setMapNumberWithCGPointLocation: CGPointMake(characterLocationX - 1, characterLocationY) newNumber: 0];
                        characterLocationX--;
                    }
                }
            }
        }
    }else if(whichButtonDown == B_RIGHT){
        if(characterLocationX != 11){
            int whatsThere = [self getMapNumberWithCGPointLocation: CGPointMake(characterLocationX + 1, characterLocationY)];
            if(whatsThere == P_BLANK){
                characterLocationX++;
            }else if(whatsThere == P_SQUARE || whatsThere == P_CIRCLE || whatsThere == P_TRIANGLE || whatsThere == P_PLUS){
                int whatsBehindWhatsThere = [self getMapNumberWithCGPointLocation: CGPointMake(characterLocationX + 2, characterLocationY)];
                if(whatsBehindWhatsThere == 0){
                    [self setMapNumberWithCGPointLocation: CGPointMake(characterLocationX + 2, characterLocationY) newNumber: whatsThere];
                    [self setMapNumberWithCGPointLocation: CGPointMake(characterLocationX + 1, characterLocationY) newNumber: 0];
                    characterLocationX++;
                }else if(whatsBehindWhatsThere == whatsThere){
                    if(whatsThere == P_SQUARE || whatsThere == P_CIRCLE){
                        [self setMapNumberWithCGPointLocation: CGPointMake(characterLocationX + 2, characterLocationY) newNumber: 0];
                        [self setMapNumberWithCGPointLocation: CGPointMake(characterLocationX + 1, characterLocationY) newNumber: 0];
                        characterLocationX++;
                    }else if(whatsThere == P_TRIANGLE){
                        [self setMapNumberWithCGPointLocation: CGPointMake(characterLocationX + 2, characterLocationY) newNumber: 1];
                        [self setMapNumberWithCGPointLocation: CGPointMake(characterLocationX + 1, characterLocationY) newNumber: 0];
                        characterLocationX++;
                    }else if(whatsThere == P_PLUS){
                        isSelectingPeg = YES;
                        selectPegOffset = CGPointMake(2, 0);
                        whichButtonDown = B_NONE;
                    }
                }else if(whatsBehindWhatsThere == 2){
                    if(whatsThere == P_SQUARE){
                        [self setMapNumberWithCGPointLocation: CGPointMake(characterLocationX + 2, characterLocationY) newNumber: 0];
                        [self setMapNumberWithCGPointLocation: CGPointMake(characterLocationX + 1, characterLocationY) newNumber: 0];
                        characterLocationX++;
                    }else{
                        [self setMapNumberWithCGPointLocation: CGPointMake(characterLocationX + 1, characterLocationY) newNumber: 0];
                        characterLocationX++;
                    }
                }
            }
        }
    }
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    
	CGPoint notLocation = [[touches anyObject] locationInView: self.view];
	CGPoint loc = CGPointMake(notLocation.y, notLocation.x);
    printf("\nTouch at: (%i, %i)", (int)loc.x, (int)loc.y);
    
    if(loc.x > 350.0f && loc.y < 150.0f){
        float locationLeft = loc.x - 412.0f;
        float locationUp = 68.0f - loc.y;
        if(movementTimer == nil){
            if(locationLeft < -24.0f){
                whichButtonDown = B_LEFT;
            }else if(locationLeft > 24.0f){
                whichButtonDown = B_RIGHT;
            }else if(locationUp < -24.0f){
                whichButtonDown = B_UP;
            }else if(locationUp > 24.0f){
                whichButtonDown = B_DOWN;
            }
            [self move];
            movementTimer = [NSTimer scheduledTimerWithTimeInterval:movementInterval target:self selector:@selector(move) userInfo:nil repeats:YES];
        }
    }else{
        if(isSelectingPeg && loc.x > 112.0f && loc.x < 368.0f && loc.y > 128.0f && loc.y < 192.0f){
            if(loc.x < 176.0f){             //Square
                [self setMapNumberWithCGPointLocation: CGPointMake(characterLocationX + selectPegOffset.x, characterLocationY + selectPegOffset.y) newNumber: P_SQUARE];
                [self setMapNumberWithCGPointLocation: CGPointMake(characterLocationX + selectPegOffset.x / 2, characterLocationY + selectPegOffset.y / 2) newNumber: 0];
                characterLocationX += selectPegOffset.x / 2;
                characterLocationY += selectPegOffset.y / 2;
                isSelectingPeg = NO;
            }else if(loc.x < 240.0f){       //Circle
                [self setMapNumberWithCGPointLocation: CGPointMake(characterLocationX + selectPegOffset.x, characterLocationY + selectPegOffset.y) newNumber: P_CIRCLE];
                [self setMapNumberWithCGPointLocation: CGPointMake(characterLocationX + selectPegOffset.x / 2, characterLocationY + selectPegOffset.y / 2) newNumber: 0];
                characterLocationX += selectPegOffset.x / 2;
                characterLocationY += selectPegOffset.y / 2;
                isSelectingPeg = NO;
            }else if(loc.x < 304.0f){       //Triangle
                [self setMapNumberWithCGPointLocation: CGPointMake(characterLocationX + selectPegOffset.x, characterLocationY + selectPegOffset.y) newNumber: P_TRIANGLE];
                [self setMapNumberWithCGPointLocation: CGPointMake(characterLocationX + selectPegOffset.x / 2, characterLocationY + selectPegOffset.y / 2) newNumber: 0];
                characterLocationX += selectPegOffset.x / 2;
                characterLocationY += selectPegOffset.y / 2;
                isSelectingPeg = NO;
            }else{                          //Plus
                [self setMapNumberWithCGPointLocation: CGPointMake(characterLocationX + selectPegOffset.x, characterLocationY + selectPegOffset.y) newNumber: P_PLUS];
                [self setMapNumberWithCGPointLocation: CGPointMake(characterLocationX + selectPegOffset.x / 2, characterLocationY + selectPegOffset.y / 2) newNumber: 0];
                characterLocationX += selectPegOffset.x / 2;
                characterLocationY += selectPegOffset.y / 2;
                isSelectingPeg = NO;
            }
        }
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
	if(movementTimer != nil){
		[movementTimer invalidate];
		movementTimer = nil;
        whichButtonDown = B_NONE;
	}
}

- (int)getMapNumberWithCGPointLocation: (CGPoint)location{
    if(!(location.x < 0 || location.x > 11 || location.y < 0 || location.y > 7)){
        int search = (location.y * 12) + location.x;
        if(!(search < 0 || search > 95)){
            return [[mapLocations objectAtIndex: search] intValue];
        }
    }
    return -1;
}
- (void)setMapNumberWithCGPointLocation: (CGPoint)location newNumber:(int)newNumber{
    if(!(location.x < 0 || location.x > 11 || location.y < 0 || location.y > 7)){
        int search = (location.y * 12) + location.x;
        if(!(search < 0 || search > 95)){
            [mapLocations replaceObjectAtIndex: search withObject: [NSNumber numberWithInt: newNumber]];
        }
    }
}

- (CGPoint)getPlayerLocationGL{
    return CGPointMake(40.0f * characterLocationX + 20.0f, (8 - characterLocationY) * 40.0f - 20.0f);
}

- (CGPoint)getPlayerLocation{
    return CGPointMake(characterLocationX, characterLocationY);
}

- (int)getWhichButtonDown{
    return whichButtonDown;
}

- (BOOL)getIsSelectingPeg{
    return isSelectingPeg;
}

- (void)dealloc
{
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
