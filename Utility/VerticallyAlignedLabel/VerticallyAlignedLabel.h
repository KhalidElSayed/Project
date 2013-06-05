//
//  VerticallyAlignedLabel.h
//  Recalls Pro
//
//  Created by Alok on 04/06/13.
//  Copyright (c) 2013 Konstant Info Private Limited. All rights reserved.
//


//
// VerticallyAlignedLabel.h
//

#import <Foundation/Foundation.h>


typedef enum VerticalAlignment {
    VerticalAlignmentTop,
    VerticalAlignmentMiddle,
    VerticalAlignmentBottom,
} VerticalAlignment;

@interface VerticallyAlignedLabel : UILabel {
@private
    VerticalAlignment verticalAlignment_;
}

@property (nonatomic, assign) VerticalAlignment verticalAlignment;

@end