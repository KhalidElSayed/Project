//
//  Project Template
//
//  Created by Alok on 2/04/13.
//  Copyright (c) 2013 Konstant Info Private Limited. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AksAnimations : NSObject
+(AksAnimations*)sharedAksAnimations;
-(void)movingAnimationForViews:(NSArray *)views isLeftToRight:(bool)isLeftToRight;
-(void)animateWobbleEffect:(UIView*)view forDuration:(int) seconds;
-(void)breathAnimationSlow:(UIView*)view RepeatCount:(int)RepeatCount;
-(void)breathAnimation:(UIView*)view;
-(void)animationArrayOfWidgets:(NSArray *)Objects;
-(void)animationAsIfErrorfor:(UIView*)object;
-(void)showAnimationAsIfMoving:(UIView*)Object IsLeftToRight:(bool) IsLeftToRight;
-(void)aksDivertSubviewsAnimation:(UIView*)object With :(BOOL)AnimateOutWards;
-(void)bounceAnimation:(UIView*)view;
-(void)moveThis:(UIView*)view ToPoint:(CGPoint)point InDuration:(int)duration;
-(void)rotateThis:(UIView*)view ToAngle:(float)angle;
-(void)runSpinAnimationOnView:(UIView*)view duration:(CGFloat)duration rotations:(CGFloat)rotations repeat:(float)repeat;
-(void)blink:(UIView*) view;
-(void)makeThisViewGlossy:(UIView*)view;
-(void)fadeInThisView:(NSArray*)views duration:(float)dur;
-(void)fadeOutThisView:(NSArray*)views duration:(float)dur;
-(void)performSlideFromBottomToTopForViews:(NSArray *)views;
-(void)pushViewControllerWithFlipAnimation:(UIViewController*)viewController fromViewController:(UIViewController*)currentViewController;
-(void)popViewControllerWithFlipAnimation:(UIViewController*)viewController;
-(void)popBySlidingToBottomForViewController:(UIViewController *)viewsController;
@end
