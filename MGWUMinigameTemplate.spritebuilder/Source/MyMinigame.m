//
//  MGWUMinigameTemplate
//
//  Created by Zachary Barryte on 6/6/14.
//  Copyright 2014 Apportable. All rights reserved.
//

#import "MyMinigame.h"

static const CGFloat scrollSpeed = 130.f;

@implementation MyMinigame{
    
    CCPhysicsNode* _physicsNode;
    
    CGPoint _cloudParallaxRatio;
    CGPoint _bushParallaxRatio;
    
    CCNode *_parallaxContainer;
    CCParallaxNode *_parallaxBackground;
    
    CCNode *_dune1;
    CCNode *_dune2;
    NSArray *_dunes;
    
//    CCNode *_cloud1;
//    CCNode *_cloud2;
//    NSArray *_clouds;
//    
//    CCNode *_bush1;
//    CCNode *_bush2;
//    NSArray *_bushes;
    
    NSTimeInterval _sinceTouch;
    
//    NSMutableArray *_obstacles;
    
    CCButton *_restartButton;
    
    BOOL _gameOver;
//    CCLabelTTF *_scoreLabel;
//    CCLabelTTF *_nameLabel;
//    
//    int points;
}

-(id)init {
    if ((self = [super init])) {
        // Initialize any arrays, dictionaries, etc in here
        self.instructions = @"These are the game instructions :D";
    }
    return self;
}

-(void)didLoadFromCCB {
    // Set up anything connected to Sprite Builder here
    self.userInteractionEnabled = TRUE;
    
    _dunes = @[_dune1, _dune2];
    
    
    // We're calling a public method of the character that tells it to jump!
   // [self.hero fly];
}

- (void)touchBegan:(UITouch *)touch withEvent:(UIEvent *)event {
    
    [self.hero fly];
    [self.hero.physicsBody applyImpulse:ccp(0, 800.f)];

    NSLog(@"tapped");
    _sinceTouch = 0.f;

}


-(void)onEnter {
    [super onEnter];
    // Create anything you'd like to draw here
}

-(void)update:(CCTime)delta {
    // Called each update cycle
    // n.b. Lag and other factors may cause it to be called more or less frequently on different devices or sessions
    // delta will tell you how much time has passed since the last cycle (in seconds)
    
    _sinceTouch += delta;
    
    
   
    //clamp velocity
//   float yVelocity = clampf(_hero.physicsBody.velocity.y, -1 * MAXFLOAT, 200.f);
    self.hero.physicsBody.velocity = ccp(130, self.hero.physicsBody.velocity.y);
    
    if (self.hero.position.y >=300) {
        [self.hero.physicsBody applyImpulse:ccp(0, -450.f)];

    }
    

//    if ((_sinceTouch > 0.5f)) {
//        [self.hero.physicsBody applyAngularImpulse:-40000.f*delta];
//    }
    
    _physicsNode.position = ccp(_physicsNode.position.x - (scrollSpeed * delta), _physicsNode.position.y);
    
    //NSLog(@"node %f",_physicsNode.position.x);
    NSLog(@"hero %f",self.hero.position.y);
    // loop the ground
    for (CCNode *dune in _dunes) {
        // get the world position of the ground
        CGPoint groundWorldPosition = [_physicsNode convertToWorldSpace:dune.position];
        // get the screen position of the ground
        CGPoint groundScreenPosition = [self convertToNodeSpace:groundWorldPosition];
        // if the left corner is one complete width off the screen, move it to the right
        if (groundScreenPosition.x <= (-1 * dune.contentSize.width*1.5)) {
            dune.position = ccp(dune.position.x + (2 * dune.contentSize.width*1.5), dune.position.y);
        }
    }
    

    
//    NSMutableArray *offScreenObstacles = nil;
//    
//    for (CCNode *obstacle in _obstacles) {
//        CGPoint obstacleWorldPosition = [physicsNode convertToWorldSpace:obstacle.position];
//        CGPoint obstacleScreenPosition = [self convertToNodeSpace:obstacleWorldPosition];
//        if (obstacleScreenPosition.x < -obstacle.contentSize.width) {
//            if (!offScreenObstacles) {
//                offScreenObstacles = [NSMutableArray array];
//            }
//            [offScreenObstacles addObject:obstacle];
//        }
//    }
//    
//    for (CCNode *obstacleToRemove in offScreenObstacles) {
//        [obstacleToRemove removeFromParent];
//        [_obstacles removeObject:obstacleToRemove];
//    }
//    
//    if (!_gameOver)
//    {
//        @try
//        {
//            character.physicsBody.velocity = ccp(80.f, clampf(character.physicsBody.velocity.y, -MAXFLOAT, 200.f));
//            
//            [super update:delta];
//        }
//        @catch(NSException* ex)
//        {
//            
//        }
//    }
//    
//    _parallaxBackground.position = ccp(_parallaxBackground.position.x - (character.physicsBody.velocity.x * delta), _parallaxBackground.position.y);
//    
//    // loop the bushes
//    for (CCNode *bush in _bushes) {
//        // get the world position of the bush
//        CGPoint bushWorldPosition = [_parallaxBackground convertToWorldSpace:bush.position];
//        // get the screen position of the bush
//        CGPoint bushScreenPosition = [self convertToNodeSpace:bushWorldPosition];
//        
//        // if the left corner is one complete width off the screen,
//        // move it to the right
//        if (bushScreenPosition.x <= (-1 * bush.contentSize.width)) {
//            for (CGPointObject *child in _parallaxBackground.parallaxArray) {
//                if (child.child == bush) {
//                    child.offset = ccp(child.offset.x + 2*bush.contentSize.width, child.offset.y);
//                }
//            }
//        }
//    }
//    
//    // loop the clouds
//    for (CCNode *cloud in _clouds) {
//        // get the world position of the cloud
//        CGPoint cloudWorldPosition = [_parallaxBackground convertToWorldSpace:cloud.position];
//        // get the screen position of the cloud
//        CGPoint cloudScreenPosition = [self convertToNodeSpace:cloudWorldPosition];
//        
//        // if the left corner is one complete width off the screen,
//        // move it to the right
//        if (cloudScreenPosition.x <= (-1 * cloud.contentSize.width)) {
//            for (CGPointObject *child in _parallaxBackground.parallaxArray) {
//                if (child.child == cloud) {
//                    child.offset = ccp(child.offset.x + 2*cloud.contentSize.width, child.offset.y);
//                }
//            }
//        }
//    }

}

-(void)endMinigame {
    // Be sure you call this method when you end your minigame!
    // Of course you won't have a random score, but your score *must* be between 1 and 100 inclusive
    [self endMinigameWithScore:arc4random()%100 + 1];
}

// DO NOT DELETE!
-(MyCharacter *)hero {
    return (MyCharacter *)self.character;
}
// DO NOT DELETE!

@end
