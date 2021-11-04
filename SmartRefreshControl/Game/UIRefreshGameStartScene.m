//
//  UIRefreshGameStartScene.m
//  Refresh
//
//  Created by SCWANG on 2021/6/8.
//  Copyright © 2021 Teeyun. All rights reserved.
//

#import "UIRefreshGameStartScene.h"

@interface UIRefreshGameStartScene ()

@property (nonatomic, strong) SKLabelNode *nodeTitle;
@property (nonatomic, strong) SKLabelNode *nodeDetail;
@property (nonatomic, strong) SKShapeNode *nodeFrame;

@end

@implementation UIRefreshGameStartScene

- (SKLabelNode *)nodeTitle {
    if (_nodeTitle == nil) {
        _nodeTitle = [SKLabelNode new];
        _nodeTitle.fontSize = 20;
        _nodeTitle.fontName = @"AvenirNext-Bold";
        _nodeTitle.text = @"Pull to Break Out!";
        [self addChild:_nodeTitle];
    }
    return _nodeTitle;
}

- (SKLabelNode *)nodeDetail {
    if (_nodeDetail == nil) {
        _nodeDetail = [SKLabelNode new];
        _nodeDetail.fontSize = 17;
        _nodeDetail.fontName = @"AvenirNext-Bold";
        _nodeDetail.text = @"Scroll to move handle";
        [self addChild:_nodeDetail];
    }
    return _nodeDetail;
}

- (SKShapeNode *)nodeFrame {
    if (_nodeFrame == nil) {
        _nodeFrame = [SKShapeNode new];
        _nodeFrame.lineWidth = 1;
        [self addChild:_nodeFrame];
    }
    return _nodeFrame;
}

- (void)didMoveToView:(SKView *)view {
    [super didMoveToView:view];
    [self setBackgroundColor:self.colorAccent];
    [self setScaleMode:SKSceneScaleModeAspectFit];
    [self.nodeTitle setFontColor:self.colorPrimary];
    [self.nodeDetail setFontColor:self.colorPrimary];
    [self.nodeFrame setStrokeColor:self.colorPrimary];
}

- (void)setSize:(CGSize)size {
    [super setSize:size];
    [self.nodeTitle setPosition:CGPointMake(size.width/2, size.height/2 + 5)];
    [self.nodeDetail setPosition:CGPointMake(size.width/2, size.height/2 - 15)];
    [self.nodeFrame setPath:CGPathCreateWithRect(CGRectMake(0, 0, size.width, size.height), nil)];
}

@end
