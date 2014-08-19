//
//  MGWUMinigameTemplate
//
//  Created by Zachary Barryte on 6/6/14.
//  Copyright 2014 Apportable. All rights reserved.
//

#import "MyMinigame.h"
#import "CCPhysics+ObjectiveChipmunk.h"


static const CGFloat scrollSpeed = 130.f;
static const CGFloat firstEnemyPosition = 280.f;
static const CGFloat distanceBetweenEnemies = 210.f;
static const CGFloat firstStarPosition = 200.f;
static const CGFloat distanceBetweenStars = 50.f;
static const NSTimeInterval timeAllowed = 60;

@interface CGPointObject : NSObject{
    CGPoint _ratio;
    CGPoint _offset;
    CCNode *__unsafe_unretained _child; // weak ref

}
@property (nonatomic,readwrite) CGPoint ratio;
@property (nonatomic,readwrite) CGPoint offset;
@property (nonatomic,readwrite,unsafe_unretained) CCNode *child;
+(id) pointWithCGPoint:(CGPoint)point offset:(CGPoint)offset;
-(id) initWithCGPoint:(CGPoint)point offset:(CGPoint)offset;

@end

@implementation MyMinigame{
    
    CCPhysicsNode* _physicsNode;
    
    CGPoint _cloudParallaxRatio;
    CGPoint _duneParallaxRatio;
    
    CCNode *_parallaxContainer;
    CCParallaxNode *_parallaxBackground;
    
    CCNode *_dune1;
    CCNode *_dune2;
    NSArray *_dunes;
    
    CCNode *_cloud1;
    CCNode *_cloud2;
    NSArray *_clouds;

    
    NSTimeInterval _sinceTouch;
    NSTimeInterval _timeElapsed;
    
    
    NSMutableArray *_enemies;
    NSMutableArray *_stars;
    
    CCButton *_restartButton;
    
    BOOL _gameOver;
    
    
    int livesLeft;
    int starsCollected;
    
    CCLabelTTF *_starsLabel;
    CCLabelTTF *_timeLabel;
    CCLabelTTF *_livesLabel;
//
//    int points;
}

-(id)init {
    if ((self = [super init])) {
        // Initialize any arrays, dictionaries, etc in here
        self.instructions = @"These are the game instructions :D";
        livesLeft = 3;
        starsCollected = 0;
    }
    return self;
}


-(void)didLoadFromCCB {
    // Set up anything connected to Sprite Builder here
    self.userInteractionEnabled = TRUE;
    
    _dunes = @[_dune1, _dune2];
    _clouds = @[_cloud1, _cloud2];
    
    _enemies = [NSMutableArray array];
    _stars = [NSMutableArray array];
    
    _parallaxBackground = [CCParallaxNode node];
    [_parallaxContainer addChild:_parallaxBackground];
    
    // Note that the bush ratio is larger than the cloud -> want cloud to move slower
    _cloudParallaxRatio = ccp(0.5, 1);
    
    
    for (CCNode *cloud in _clouds) {
        CGPoint offset = cloud.position;
        [cloud removeFromParent];
        [_parallaxBackground addChild:cloud z:0 parallaxRatio:_cloudParallaxRatio positionOffset:offset];
        NSLog(@"first: %f",offset.y);
    }
    
    for (CCNode *dune in _dunes) {
        dune.physicsBody.collisionType = @"level";
    }
    
    
    [self spawnNewEnemy];
    [self spawnNewEnemy];
    [self spawnNewEnemy];
    
    for (int i = 0; i <10 ; ++i) {
        [self spawnNewStars];
    }
    
    self.hero.physicsBody.collisionType = @"hero";
    _physicsNode.collisionDelegate = self;

}


#pragma mark - Spawning

- (void)spawnNewEnemy {
    CCNode *previousEnemy = [_enemies lastObject];
    CGFloat previousEnemyXPosition = previousEnemy.position.x;
    if (!previousEnemy) {
        // this is the first obstacle
        previousEnemyXPosition = firstEnemyPosition;
    }
    CCNode *enemy = [CCBReader load:@"Enemy"];
    enemy.scale = 0.4;
    // generate a random number between 0.0 and 2.0
    float yPoint = [self randomFloatBetween:50.f and:250.f];

    enemy.position = ccp(previousEnemyXPosition + distanceBetweenEnemies, yPoint);
    [_physicsNode addChild:enemy];
    [_enemies addObject:enemy];
}

- (void)spawnNewStars {
    CCNode *previousStar = [_stars lastObject];
    CGFloat previousStarXPosition = previousStar.position.x;
    if (!previousStar) {
        // this is the first obstacle
        previousStarXPosition = firstStarPosition;
    }
    CCNode *star = [CCBReader load:@"Star"];
    // generate a random number between 0.0 and 2.0
    float yPoint = [self randomFloatBetween:70.f and:250.f];
    
    star.position = ccp(previousStarXPosition + distanceBetweenStars, yPoint);
    [_physicsNode addChild:star];
    [_stars addObject:star];
}

- (void)touchBegan:(UITouch *)touch withEvent:(UIEvent *)event {
    
    [self.hero fly];
    [self.hero.physicsBody applyImpulse:ccp(0, 800.f)];


    _sinceTouch = 0.f;

}


-(void)onEnter {
    [super onEnter];
    // Create anything you'd like to draw here
}

- (BOOL)gameOver{
    return FALSE;
}

-(void)update:(CCTime)delta {
    // Called each update cycle
    // n.b. Lag and other factors may cause it to be called more or less frequently on different devices or sessions
    // delta will tell you how much time has passed since the last cycle (in seconds)
    
    _sinceTouch += delta;
    _timeElapsed += delta;
    NSTimeInterval timeLeft = timeAllowed - _timeElapsed;
    _timeLabel.string = [NSString stringWithFormat:@"Time Left: %ds", (int)timeLeft];
   
    self.hero.physicsBody.velocity = ccp(130, self.hero.physicsBody.velocity.y);
    
    if (self.hero.position.y >=300) {
        [self.hero.physicsBody applyImpulse:ccp(0, -450.f)];

    }
    
    
    _physicsNode.position = ccp(_physicsNode.position.x - (scrollSpeed * delta), _physicsNode.position.y);
    

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
    
    _parallaxBackground.position = ccp(_parallaxBackground.position.x - (scrollSpeed * delta), _parallaxBackground.position.y);
    
    // loop the clouds
    for (CCNode *cloud in _clouds) {
        // get the world position of the cloud
        CGPoint cloudWorldPosition = [_parallaxBackground convertToWorldSpace:cloud.position];
        // get the screen position of the cloud
        CGPoint cloudScreenPosition = [self convertToNodeSpace:cloudWorldPosition];
        
        // if the left corner is one complete width off the screen,
        // move it to the right
        if (cloudScreenPosition.x <= (-1 * cloud.contentSize.width)) {
            for (CGPointObject *child in _parallaxBackground.parallaxArray) {
                if (child.child == cloud) {
                    child.offset = ccp(child.offset.x + 2*cloud.contentSize.width, child.offset.y);
                }
            }
        }
    }
    

    
    NSMutableArray *offScreenEnemies = nil;
    for (CCNode *enemy in _enemies) {
        CGPoint enemyWorldPosition = [_physicsNode convertToWorldSpace:enemy.position];
        CGPoint enemyScreenPosition = [self convertToNodeSpace:enemyWorldPosition];
        if (enemyScreenPosition.x < -enemy.contentSize.width) {
            if (!offScreenEnemies) {
                offScreenEnemies = [NSMutableArray array];
            }
            [offScreenEnemies addObject:enemy];
        }
    }
    for (CCNode *enemyToRemove in offScreenEnemies) {
        [enemyToRemove removeFromParent];
        [_enemies removeObject:enemyToRemove];
        // for each removed obstacle, add a new one
        [self spawnNewEnemy];
    }
    
    NSMutableArray *offScreenStars = nil;
    
    for (CCNode *star in _stars) {
        CGPoint starWorldPosition = [_physicsNode convertToWorldSpace:star.position];
        CGPoint starScreenPosition = [self convertToNodeSpace:starWorldPosition];
        if (starScreenPosition.x < -star.contentSize.width) {
            if (!offScreenStars) {
                offScreenStars = [NSMutableArray array];
            }
            [offScreenStars addObject:star];
        }
    }
    for (CCNode *starToRemove in offScreenStars) {
        [starToRemove removeFromParent];
        [_stars removeObject:starToRemove];
        // for each removed obstacle, add a new one
        [self spawnNewStars];
    }
    
    if ((int)timeLeft <= 0 || livesLeft == 0) {
        
        //display score
        [self endMinigame];
    }
    


}

-(void)endMinigame {
    // Be sure you call this method when you end your minigame!
    // Of course you won't have a random score, but your score *must* be between 1 and 100 inclusive
    [self endMinigameWithScore:arc4random()%100 + 1];
}

#pragma mark - Collisions

-(BOOL)ccPhysicsCollisionBegin:(CCPhysicsCollisionPair *)pair hero:(CCNode *)hero star:(CCNode *)star {
    NSLog(@"star Collected");
    [self starRemoved:star];
    return TRUE;
}

-(BOOL)ccPhysicsCollisionBegin:(CCPhysicsCollisionPair *)pair hero:(CCNode *)hero enemy:(CCNode *)enemy {
    NSLog(@"died by enemy");
    [self removeLife:enemy andreposition:hero];
    return TRUE;
}

-(BOOL)ccPhysicsCollisionPostSolve:(CCPhysicsCollisionPair *)pair hero:(CCNode *)hero level:(CCNode *)level {
    float energy = [pair totalKineticEnergy];
    NSLog(@"%f",energy);
    if (energy > 10000.f) {
        [self removeLifeByCollisionOnFloor:hero];
        NSLog(@"died by collision");

    }
    return TRUE;
}



- (void)removeLifeByCollisionOnFloor:(CCNode*)hero{
    if (![self gameOver]) {
        // load particle effect
        CCParticleSystem *explosion = (CCParticleSystem *)[CCBReader load:@"enemyCollisionDeath"];
        // make the particle effect clean itself up, once it is completed
        explosion.autoRemoveOnFinish = TRUE;
        // place the particle effect on the collision spot position
        explosion.position = hero.position;
        // add the particle effect to the same node the seal is on
        [hero.parent addChild:explosion];
        
        livesLeft--;
        _livesLabel.string = [NSString stringWithFormat:@"Lives: %d",livesLeft];
        
    }
    else{
        [self endMinigame];
    }
}


- (void) removeLife:(CCNode *)enemy andreposition:(CCNode *)hero{
    if (![self gameOver]){
        // load particle effect
        CCParticleSystem *explosion = (CCParticleSystem *)[CCBReader load:@"enemyCollisionDeath"];
        // make the particle effect clean itself up, once it is completed
        explosion.autoRemoveOnFinish = TRUE;
        // place the particle effect on the enemy's position
        explosion.position = enemy.position;
        // add the particle effect to the same node the seal is on
        [enemy.parent addChild:explosion];
        
        // finally, remove the destroyed seal
        [enemy removeFromParent];
        [_enemies removeObject:enemy];
        [self spawnNewEnemy];
        livesLeft--;
        _livesLabel.string = [NSString stringWithFormat:@"Lives: %d",livesLeft];
    }
    else{
        [self endMinigame];
    }
}

- (void)starRemoved:(CCNode *)star{

    // load particle effect
    CCParticleSystem *explosion = (CCParticleSystem *)[CCBReader load:@"starCollection"];
    // make the particle effect clean itself up, once it is completed
    explosion.autoRemoveOnFinish = TRUE;
    // place the particle effect on the seals position
    explosion.position = star.position;
    // add the particle effect to the same node the seal is on
    [star.parent addChild:explosion];
    
    // finally, remove the destroyed seal
    [star removeFromParent];
    [_stars removeObject:star];
    [self spawnNewStars];
    
    // update stars counter
    starsCollected++;
    _starsLabel.string = [NSString stringWithFormat:@"Stars: %d", starsCollected];
    
}

// DO NOT DELETE!
-(MyCharacter *)hero {
    return (MyCharacter *)self.character;
}
// DO NOT DELETE!

- (float)randomFloatBetween:(float)smallNumber and:(float)bigNumber {
    float diff = bigNumber - smallNumber;
    return (((float) (arc4random() % ((unsigned)RAND_MAX + 1)) / RAND_MAX) * diff) + smallNumber;
}

@end
