#import <UIKit/UIKit.h>

typedef enum {
    THLabelStrokePositionOutside,
    THLabelStrokePositionCenter,
    THLabelStrokePositionInside
} THLabelStrokePosition;

@interface THLabel : UILabel

@property (nonatomic, assign) CGFloat shadowBlur;
@property (nonatomic, assign) CGFloat strokeSize;
@property (nonatomic, strong) UIColor *strokeColor;
@property (nonatomic, assign) THLabelStrokePosition strokePosition;
@property (nonatomic, strong) UIColor *gradientStartColor;
@property (nonatomic, strong) UIColor *gradientEndColor;
@property (nonatomic, copy)   NSArray *gradientColors;
@property (nonatomic, assign) CGPoint gradientStartPoint;
@property (nonatomic, assign) CGPoint gradientEndPoint;
@property (nonatomic, assign) UIEdgeInsets textInsets;

@end

/**
 __________

 HOW TO USE
 __________

 
 // Demonstrate shadow blur.
 [self.label1 setShadowColor:[UIColor blackColor]];
 [self.label1 setShadowOffset:CGSizeMake(0.0f,kShadowOffsetY)];
 [self.label1 setShadowBlur:kShadowBlur];

 // Demonstrate stroke.
 [self.label2 setStrokeColor:[UIColor blackColor]];
 [self.label2 setStrokeSize:kStrokeSize];

 // Demonstrate fill gradient.
 [self.label3 setGradientStartColor:[UIColor colorWithRed:255.0f / 255.0f green:193.0f / 255.0f blue:127.0f / 255.0f alpha:1.0f]];
 [self.label3 setGradientEndColor:[UIColor colorWithRed:255.0f / 255.0f green:163.0f / 255.0f blue:64.0f / 255.0f alpha:1.0f]];

 // Demonstrate everything.
 [self.label4 setShadowColor:[UIColor colorWithWhite:0.0f alpha:0.75f]];
 [self.label4 setShadowOffset:CGSizeMake(0.0f, kShadowOffsetY)];
 [self.label4 setShadowBlur:kShadowBlur];
 [self.label4 setStrokeColor:[UIColor blackColor]];
 [self.label4 setStrokeSize:kStrokeSize];
 [self.label4 setGradientStartColor:[UIColor colorWithRed:255.0f / 255.0f green:193.0f / 255.0f blue:127.0f / 255.0f alpha:1.0f]];
 [self.label4 setGradientEndColor:[UIColor colorWithRed:255.0f / 255.0f green:163.0f / 255.0f blue:64.0f / 255.0f alpha:1.0f]];
 
 */





