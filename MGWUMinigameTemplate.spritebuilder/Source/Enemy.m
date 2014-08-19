//
//  Enemy.m
//  MGWUMinigameTemplate
//
//  Created by Pinak Shikhare on 8/19/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "Enemy.h"

@implementation Enemy


- (void)didLoadFromCCB {
    self.physicsBody.collisionType = @"enemy";
    self.physicsBody.sensor = TRUE;

}

@end
