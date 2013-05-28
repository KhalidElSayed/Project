#import <UIKit/UIKit.h>


// Height of the view when text view is empty. Ideally, you should use this in
// -initWithFrame:.
extern CGFloat const PHFComposeBarViewInitialHeight;


// Each notification includes the view as object and a userInfo dictionary
// containing the beginning and ending view frame. Animation key/value pairs are
// only available for the PHFComposeBarViewWillChangeFrameNotification
// notification.
extern NSString *const PHFComposeBarViewDidChangeFrameNotification;
extern NSString *const PHFComposeBarViewWillChangeFrameNotification;

extern NSString *const PHFComposeBarViewAnimationDurationUserInfoKey; // NSNumber of double
extern NSString *const PHFComposeBarViewAnimationCurveUserInfoKey;    // NSNumber of NSUInteger (UIViewAnimationCurve)
extern NSString *const PHFComposeBarViewFrameBeginUserInfoKey;        // NSValue of CGRect
extern NSString *const PHFComposeBarViewFrameEndUserInfoKey;          // NSValue of CGRect


@protocol PHFComposeBarViewDelegate;


@interface PHFComposeBarView : UIView <UITextViewDelegate>

// Default is YES. When YES, the auto resizing top margin will be flexible.
// Whenever the height changes due to text length, the top offset will
// automatically be adjusted such that the view grows upwards while the bottom
// stays fixed. When NO, the top margin is not flexible. This causes the view to
// grow downwards when the height changes due to the text length. Turning this
// off can be useful in some complicated view setups.
@property (assign, nonatomic) BOOL autoAdjustTopOffset;

@property (strong, nonatomic, readonly) UIButton *button;

// Default is a blue matching that from iMessage (RGB: 19, 84, 235).
@property (strong, nonatomic) UIColor *buttonTintColor UI_APPEARANCE_SELECTOR;

// Default is "Send".
@property (strong, nonatomic) NSString *buttonTitle UI_APPEARANCE_SELECTOR;

@property (weak, nonatomic) id <PHFComposeBarViewDelegate> delegate;

// When set to NO, the text view, the utility button, and the main button are
// disabled.
@property (assign, nonatomic, getter = isEnabled) BOOL enabled;

// Default is 0. When not 0, a counter is shown in the format
// count/maxCharCount. It is placed behind the main button but with a fixed top
// margin, thus only visible if there are at least two lines of text.
@property (assign, nonatomic) NSUInteger maxCharCount;

// Default is 200.0.
@property (assign, nonatomic) CGFloat maxHeight;

// Default is 9. Merely a conversion from maxHeight property.
@property (assign, nonatomic) CGFloat maxLinesCount;

// Default is nil. This is a shortcut for the text property of placeholderLabel.
@property (strong, nonatomic) NSString *placeholder UI_APPEARANCE_SELECTOR;

@property (nonatomic, readonly) UILabel *placeholderLabel;

// Default is nil. This is a shortcut for the text property of textView.
@property (strong, nonatomic) NSString *text;

@property (strong, nonatomic, readonly) UITextView *textView;

@property (strong, nonatomic, readonly) UIButton *utilityButton;

// Default is nil. Images should be white on transparent background. The side
// length should not exceed 16 points. The button is only visible when an image
// is set. Thus, to hide the button, set this property to nil.
@property (strong, nonatomic) UIImage *utilityButtonImage UI_APPEARANCE_SELECTOR;

@end


@protocol PHFComposeBarViewDelegate <NSObject, UITextViewDelegate>

@optional
- (void)composeBarViewDidPressButton:(PHFComposeBarView *)composeBarView;
- (void)composeBarViewDidPressUtilityButton:(PHFComposeBarView *)composeBarView;
- (void) composeBarView:(PHFComposeBarView *)composeBarView
    willChangeFromFrame:(CGRect)startFrame
                toFrame:(CGRect)endFrame
               duration:(NSTimeInterval)duration
         animationCurve:(UIViewAnimationCurve)animationCurve;
- (void)composeBarView:(PHFComposeBarView *)composeBarView
    didChangeFromFrame:(CGRect)startFrame
               toFrame:(CGRect)endFrame;

@end










/**

 __________

 HOW TO USE
 __________




 #import "ViewController.h"

 @interface ViewController ()
 @property (readonly, nonatomic) UIView *container;
 @property (readonly, nonatomic) PHFComposeBarView *composeBarView;
 @end

 CGRect const kInitialViewFrame = { 0.0f, 0.0f, 320.0f, 480.0f };

 @implementation ViewController

 - (id)init {
 self = [super init];
 if (self) {
 [[NSNotificationCenter defaultCenter] addObserver:self
 selector:@selector(composeBarViewWillChangeFrame:)
 name:PHFComposeBarViewWillChangeFrameNotification
 object:nil];
 [[NSNotificationCenter defaultCenter] addObserver:self
 selector:@selector(keyboardWillToggle:)
 name:UIKeyboardWillShowNotification
 object:nil];
 [[NSNotificationCenter defaultCenter] addObserver:self
 selector:@selector(keyboardWillToggle:)
 name:UIKeyboardWillHideNotification
 object:nil];
 }
 return self;
 }

 - (void)dealloc {
 [[NSNotificationCenter defaultCenter] removeObserver:self
 name:UIKeyboardWillShowNotification
 object:nil];
 [[NSNotificationCenter defaultCenter] removeObserver:self
 name:UIKeyboardWillHideNotification
 object:nil];
 [[NSNotificationCenter defaultCenter] removeObserver:self
 name:PHFComposeBarViewWillChangeFrameNotification
 object:nil];
 }

 - (void)loadView {
 UIView *view = [[UIView alloc] initWithFrame:kInitialViewFrame];
 [view setBackgroundColor:[UIColor colorWithHue:220 / 360.0 saturation:0.08 brightness:0.93 alpha:1]];

 UIView *container = [self container];
 [container addSubview:[self composeBarView]];
 [view addSubview:container];

 [self setView:view];
 }

 - (void)keyboardWillToggle:(NSNotification *)notification {
 NSDictionary *userInfo = [notification userInfo];
 NSTimeInterval duration;
 UIViewAnimationCurve animationCurve;
 CGRect startFrame;
 CGRect endFrame;
 [[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] getValue:&duration];
 [[userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] getValue:&animationCurve];
 [[userInfo objectForKey:UIKeyboardFrameBeginUserInfoKey] getValue:&startFrame];
 [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] getValue:&endFrame];

 NSInteger signCorrection = 1;
 if (startFrame.origin.y < 0 || startFrame.origin.x < 0 || endFrame.origin.y < 0 || endFrame.origin.x < 0) signCorrection = -1;

 CGFloat widthChange  = (endFrame.origin.x - startFrame.origin.x) * signCorrection;
 CGFloat heightChange = (endFrame.origin.y - startFrame.origin.y) * signCorrection;

 CGFloat sizeChange = UIInterfaceOrientationIsLandscape([self interfaceOrientation]) ? widthChange : heightChange;

 CGRect newContainerFrame = [[self container] frame];
 newContainerFrame.size.height += sizeChange;


 [UIView animateWithDuration:duration
 delay:0
 options:animationCurve | UIViewAnimationOptionBeginFromCurrentState
 animations:^{
 [[self container] setFrame:newContainerFrame];
 }

 completion:NULL];
 }

 - (void)composeBarViewWillChangeFrame:(NSNotification *)notification {
 }

 - (void)composeBarViewDidPressButton:(PHFComposeBarView *)composeBarView {
 [composeBarView setText:@""];
 [composeBarView resignFirstResponder];
 }

 - (void)composeBarViewDidPressUtilityButton:(PHFComposeBarView *)composeBarView {
 }

 - (void) composeBarView:(PHFComposeBarView *)composeBarView
 willChangeFromFrame:(CGRect)startFrame
 toFrame:(CGRect)endFrame
 duration:(NSTimeInterval)duration
 animationCurve:(UIViewAnimationCurve)animationCurve {
 }

 - (void)composeBarView:(PHFComposeBarView *)composeBarView
 didChangeFromFrame:(CGRect)startFrame
 toFrame:(CGRect)endFrame {
 }

 @synthesize container = _container;
 - (UIView *)container {
 if (!_container) {
 _container = [[UIView alloc] initWithFrame:kInitialViewFrame];
 [_container setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
 }
 return _container;
 }

 @synthesize composeBarView = _composeBarView;
 - (PHFComposeBarView *)composeBarView {
 if (!_composeBarView) {
 CGRect frame = CGRectMake(0.0f,
 kInitialViewFrame.size.height - PHFComposeBarViewInitialHeight,
 kInitialViewFrame.size.width,
 PHFComposeBarViewInitialHeight);
 _composeBarView = [[PHFComposeBarView alloc] initWithFrame:frame];
 [_composeBarView setMaxCharCount:160];
 [_composeBarView setMaxLinesCount:5];
 [_composeBarView setPlaceholder:@"Type something..."];
 [_composeBarView setUtilityButtonImage:[UIImage imageNamed:@"Camera"]];
 [_composeBarView setDelegate:self];
 }
 return _composeBarView;
 }

 @end

 */
