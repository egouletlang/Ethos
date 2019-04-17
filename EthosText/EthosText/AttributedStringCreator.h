//
//  AttributedStringCreator.h
//  EthosText
//
//  Created by Etienne Goulet-Lang on 4/16/19.
//  Copyright © 2019 egouletlang. All rights reserved.
//

#ifndef AttributedStringCreator_h
#define AttributedStringCreator_h

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface AttributedStringCreator: NSObject

@property (class, retain) UIFont *regular;
@property (class, retain) UIFont *bold;
@property (class, retain) UIFont *italic;

+(NSMutableAttributedString *)build:(NSString*)raw
                                   :(int)textSize
                                   :(NSMutableArray*)links
                                   :(NSMutableArray*)linkLocations
                                   :(NSString*)baseColor;
@end


#endif /* AttributedStringCreator_h */
