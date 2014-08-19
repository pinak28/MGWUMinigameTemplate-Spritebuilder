//
//  Star.m
//  MGWUMinigameTemplate
//
//  Created by Pinak Shikhare on 8/19/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "Star.h"

@implementation Star

- (void)didLoadFromCCB {
    self.physicsBody.collisionType = @"star";
    self.physicsBody.sensor = TRUE;
    
}

@end
