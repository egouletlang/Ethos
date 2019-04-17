//
//  AttributedStringCreator.m
//  EthosText
//
//  Created by Etienne Goulet-Lang on 4/16/19.
//  Copyright © 2019 egouletlang. All rights reserved.
//

#import "AttributedStringCreator.h"

@interface AttributedStringCreator()

+(NSMutableAttributedString *)build:(NSString*)raw
                                   :(int)textSize
                                   :(NSMutableArray*)links
                                   :(NSMutableArray*)linkLocations
                                   :(NSString*)baseColor;
@end

@implementation AttributedStringCreator

// MARK: - Constants

// Tag Components
static unichar const OPEN_TAG = '<';
static unichar const CLOSE_TAG = '>';
static unichar const SLASH_TAG = '/';
static unichar const DOUBLE_QUOTES_TAG = '"';
static unichar const SINGLE_QUOTES_TAG = '\'';

// Parsing State
static int const CLOSED = 0;
static int const OPEN_FOUND = 1;

// Tag character arrays
static unichar const BOLD_TAG[] = {'b'};
static unichar const ITALIC_TAG[] = {'i'};
static unichar const UNDERLINE_TAG[] = {'u'};
static unichar const BREAK_TAG[] = {'b', 'r'};
static unichar const TINY_TAG[] = {'t', 'i', 'n', 'y'};
static unichar const SMALL_TAG[] = {'s', 'm', 'a', 'l', 'l'};
static unichar const LARGE_TAG[] = {'l', 'a', 'r', 'g', 'e'};
static unichar const HUGE_TAG[] = {'h', 'u', 'g', 'e'};
static unichar const LINK_START_TAG[] = {'a', ' ', 'h', 'r', 'e','f'};
static unichar const LINK_END_TAG[] = {'a'};
static unichar const LEFT_TAG[] = {'l', 'e', 'f', 't'};
static unichar const CENTER_TAG[] = {'c', 'e', 'n', 't', 'e','r'};
static unichar const RIGHT_TAG[] = {'r', 'i', 'g', 'h', 't'};
static unichar const FONT_START_TAG[] = {'f', 'o', 'n', 't', ' ', 'c', 'o', 'l', 'o', 'r'};
static unichar const FONT_END_TAG[] = {'f', 'o', 'n', 't'};

// Tag array index
static int const BOLD_INDEX = 0;
static int const ITALIC_INDEX = 1;
static int const UNDERLINE_INDEX = 2;
static int const BREAK_INDEX __unused = 3;
static int const TINY_INDEX = 4;
static int const SMALL_INDEX = 5;
static int const LARGE_INDEX = 6;
static int const HUGE_INDEX = 7;
static int const LINK_INDEX = 8;
static int const LEFT_INDEX = 9;
static int const CENTER_INDEX = 10;
static int const RIGHT_INDEX = 11;
static int const FONT_INDEX = 12;
static int const TAG_COUNT = 13;

// MARK: - Custom Fonts
static UIFont *_main = nil;
+ (UIFont *)main {
    if (_main == nil) {
        _main = [UIFont systemFontOfSize:[UIFont systemFontSize]];
    }
    return _main;
}
+ (void)setMain:(UIFont *)newMain {
    if (newMain != _main) {
        _main = [newMain copy];
    }
}

static UIFont *_bold = nil;
+ (UIFont *)bold {
    if (_bold == nil) {
        _bold = [UIFont boldSystemFontOfSize:[UIFont systemFontSize]];
    }
    return _bold;
}
+ (void)setBold:(UIFont *)newBold {
    if (newBold != _bold) {
        _bold = [newBold copy];
    }
}

static UIFont *_italic = nil;
+ (UIFont *)italic {
    if (_italic == nil) {
        _italic = [UIFont italicSystemFontOfSize:[UIFont systemFontSize]];
    }
    return _italic;
}
+ (void)setItalic:(UIFont *)newItalic {
    if (newItalic != _italic) {
        _italic = [newItalic copy];
    }
}

// MARK: - Custom Color
/**
 This method converts a hex NString to a UIColor. The hex string can be prefixed with # or 0x.
 
 Supports #RGB, #ARGB, #RRGGBB, #AARRGGBB
 
 @param color A hex string
 @return UIColor if it can be created
 */
+(UIColor *)createColor :(NSString *) color {
    if (color == nil) { return [UIColor blackColor]; }
    
    NSString* upperCase = [[color stringByReplacingOccurrencesOfString :@"#" withString: @""]
                           stringByReplacingOccurrencesOfString :@"0x" withString: @""].uppercaseString;
    CGFloat a, r, g, b;
    
    switch (upperCase.length) {
        case 3: // #RGB
            a = 1.0f;
            r = [AttributedStringCreator getColorComponent: upperCase :0 :1];
            g = [AttributedStringCreator getColorComponent: upperCase :1 :1];
            b = [AttributedStringCreator getColorComponent: upperCase :2 :1];
            break;
        case 4: // #ARGB
            a = [AttributedStringCreator getColorComponent: upperCase :0 :1];
            r = [AttributedStringCreator getColorComponent: upperCase :1 :1];
            g = [AttributedStringCreator getColorComponent: upperCase :2 :1];
            b = [AttributedStringCreator getColorComponent: upperCase :3 :1];
            break;
        case 6: // #RRGGBB
            a = 1.0f;
            r = [AttributedStringCreator getColorComponent: upperCase :0 :2];
            g = [AttributedStringCreator getColorComponent: upperCase :2 :2];
            b = [AttributedStringCreator getColorComponent: upperCase :4 :2];
            break;
        case 8: // #AARRGGBB
            a = [AttributedStringCreator getColorComponent: upperCase :0 :2];
            r = [AttributedStringCreator getColorComponent: upperCase :2 :2];
            g = [AttributedStringCreator getColorComponent: upperCase :4 :2];
            b = [AttributedStringCreator getColorComponent: upperCase :6 :2];
            break;
        default:
            return [UIColor blackColor];
            
    }
    
    return [UIColor colorWithRed: r green: g blue: b alpha: a];
}

/**
 This method converts a string component to a color intensity.
 @param str hex string
 @param start component start index
 @param length component length
 @return a float representing the color component intensity from 0 to 1
 */
+(float)getColorComponent :(NSString *)str
                          :(int) start
                          :(int) length {
    NSString* substring = [str substringWithRange: NSMakeRange(start, length)];
    NSString* fullHex = length == 2 ? substring : [NSString stringWithFormat: @"%@%@", substring, substring];
    unsigned hexComponent;
    [[NSScanner scannerWithString: fullHex] scanHexInt: &hexComponent];
    return hexComponent / 255.0;
}


// MARK: - Tag Management
/**
 This method removes any unbalanced open and close tags
 @param index tag index
 @param opens array of open tag locations
 @param closes array of close tag locations
 */
+(void)correctTagArray :(int)index
                       :(NSMutableArray *)opens
                       :(NSMutableArray *)closes {
    int openCount = (int)[opens[index] count];
    int closeCount = (int)[closes[index] count];
    if (openCount > 0 && closeCount > 0) {
        if (opens[index][openCount - 1] == closes[index][closeCount - 1]) {
            [opens[index] removeLastObject];
            [closes[index] removeLastObject];
        }
    }
}

/**
 This method checks if the tag is a the start of a certain offset in the raw string
 @param raw current raw string
 @param tag open target tag
 @param offset current raw string index
 @param length tag length
 @param maxLength string length
 @return true if the target tag starts at the provide offset
 */
+(BOOL)checkForTag :(unichar*)raw
                   :(const unichar*)tag
                   :(int)offset
                   :(int)length
                   :(NSUInteger)maxLength {
    if (maxLength < offset + length) { return NO; }
    
    for (int i = 0; i < length; i++) {
        if (raw[offset + i] != tag[i]) {
            return NO;
        }
    }
    return YES;
}

/**
 This method checks if the tag is a the start of a certain offset in the raw string
 @param newStr new string reference
 @param raw current raw string
 @param offset current raw string index
 @param length tag length
 @param maxLength string length
 @param opens array of open tag locations
 @param closes array of close tag locations
 @param openTag tag is currently open
 @param tagLocation the effective index of the tag location
 @param colors array of color tags
 @param links array of link tags
 */
+(int)checkTags :(unichar*)newStr
                :(unichar*)raw
                :(int)offset
                :(int)length
                :(NSUInteger)maxLength
                :(NSMutableArray *)opens
                :(NSMutableArray *)closes
                :(BOOL) openTag
                :(int)tagLocation
                :(NSMutableArray *)colors
                :(NSMutableArray *)links {
    switch (length) {
        case 1:
            if ([AttributedStringCreator checkForTag:raw:BOLD_TAG:offset:length:maxLength]) {
                if (openTag == YES) {
                    [opens[BOLD_INDEX] addObject:[NSNumber numberWithInt:tagLocation]];
                    [AttributedStringCreator correctTagArray: BOLD_INDEX :opens :closes];
                } else {
                    [closes[BOLD_INDEX] addObject:[NSNumber numberWithInt:tagLocation]];
                }
                return 0;
            }
            if ([AttributedStringCreator checkForTag:raw:ITALIC_TAG:offset:length:maxLength]) {
                if (openTag == YES) {
                    [opens[ITALIC_INDEX] addObject:[NSNumber numberWithInt:tagLocation]];
                    [AttributedStringCreator correctTagArray: ITALIC_INDEX :opens :closes];
                } else {
                    [closes[ITALIC_INDEX] addObject:[NSNumber numberWithInt:tagLocation]];
                }
                return 0;
            }
            if ([AttributedStringCreator checkForTag:raw:UNDERLINE_TAG:offset:length:maxLength]) {
                if (openTag == YES) {
                    [opens[UNDERLINE_INDEX] addObject:[NSNumber numberWithInt:tagLocation]];
                } else {
                    [closes[UNDERLINE_INDEX] addObject:[NSNumber numberWithInt:tagLocation]];
                }
                return 0;
            }
            if ([AttributedStringCreator checkForTag:raw:LINK_END_TAG:offset:length:maxLength]) {
                if (openTag == NO) {
                    [closes[LINK_INDEX] addObject:[NSNumber numberWithInt:tagLocation]];
                }
                return 0;
            }
            break;
        case 2:
            if ([AttributedStringCreator checkForTag:raw:BREAK_TAG:offset:length:maxLength]) {
                newStr[tagLocation] = '\n';
                if ([opens[LEFT_INDEX] count] != [closes[LEFT_INDEX] count]) {
                    [closes[LEFT_INDEX] addObject:[NSNumber numberWithInt:tagLocation]];
                    [opens[LEFT_INDEX] addObject:[NSNumber numberWithInt:tagLocation + 1]];
                }
                if ([opens[CENTER_INDEX] count] != [closes[CENTER_INDEX] count]) {
                    [closes[CENTER_INDEX] addObject:[NSNumber numberWithInt:tagLocation]];
                    [opens[CENTER_INDEX] addObject:[NSNumber numberWithInt:tagLocation + 1]];
                }
                if ([opens[RIGHT_INDEX] count] != [closes[RIGHT_INDEX] count]) {
                    [closes[RIGHT_INDEX] addObject:[NSNumber numberWithInt:tagLocation]];
                    [opens[RIGHT_INDEX] addObject:[NSNumber numberWithInt:tagLocation + 1]];
                }
                return 1;
            }
        case 4:
            if ([AttributedStringCreator checkForTag:raw:HUGE_TAG:offset:length:maxLength]) {
                if (openTag == YES) {
                    [opens[HUGE_INDEX] addObject:[NSNumber numberWithInt:tagLocation]];
                    [AttributedStringCreator correctTagArray: HUGE_INDEX :opens :closes];
                } else {
                    [closes[HUGE_INDEX] addObject:[NSNumber numberWithInt:tagLocation]];
                }
                return 0;
            }
            if ([AttributedStringCreator checkForTag:raw:TINY_TAG:offset:length:maxLength]) {
                if (openTag == YES) {
                    [opens[TINY_INDEX] addObject:[NSNumber numberWithInt:tagLocation]];
                    [AttributedStringCreator correctTagArray: TINY_INDEX :opens :closes];
                } else {
                    [closes[TINY_INDEX] addObject:[NSNumber numberWithInt:tagLocation]];
                }
                return 0;
            }
            if ([AttributedStringCreator checkForTag:raw:LEFT_TAG:offset:length:maxLength]) {
                if (openTag == YES) {
                    [opens[LEFT_INDEX] addObject:[NSNumber numberWithInt:tagLocation]];
                } else {
                    [closes[LEFT_INDEX] addObject:[NSNumber numberWithInt:tagLocation]];
                }
                return 0;
            }
            if ([AttributedStringCreator checkForTag:raw:FONT_END_TAG:offset:length:maxLength]) {
                if (openTag == YES) {
                    [opens[FONT_INDEX] addObject:[NSNumber numberWithInt:tagLocation]];
                } else {
                    [closes[FONT_INDEX] addObject:[NSNumber numberWithInt:tagLocation]];
                }
                return 0;
            }
            break;
        case 5:
            if ([AttributedStringCreator checkForTag:raw:SMALL_TAG:offset:length:maxLength]) {
                if (openTag == YES) {
                    [opens[SMALL_INDEX] addObject:[NSNumber numberWithInt:tagLocation]];
                    [AttributedStringCreator correctTagArray: SMALL_INDEX :opens :closes];
                } else {
                    [closes[SMALL_INDEX] addObject:[NSNumber numberWithInt:tagLocation]];
                }
                return 0;
            }
            if ([AttributedStringCreator checkForTag:raw:LARGE_TAG:offset:length:maxLength]) {
                if (openTag == YES) {
                    [opens[LARGE_INDEX] addObject:[NSNumber numberWithInt:tagLocation]];
                    [AttributedStringCreator correctTagArray: LARGE_INDEX :opens :closes];
                } else {
                    [closes[LARGE_INDEX] addObject:[NSNumber numberWithInt:tagLocation]];
                }
                return 0;
            }
            if ([AttributedStringCreator checkForTag:raw:RIGHT_TAG:offset:length:maxLength]) {
                if (openTag == YES) {
                    [opens[RIGHT_INDEX] addObject:[NSNumber numberWithInt:tagLocation]];
                } else {
                    [closes[RIGHT_INDEX] addObject:[NSNumber numberWithInt:tagLocation]];
                }
                return 0;
            }
            break;
        case 6:
            if ([AttributedStringCreator checkForTag:raw:CENTER_TAG:offset:length:maxLength]) {
                if (openTag == YES) {
                    [opens[CENTER_INDEX] addObject:[NSNumber numberWithInt:tagLocation]];
                } else {
                    [closes[CENTER_INDEX] addObject:[NSNumber numberWithInt:tagLocation]];
                }
                return 0;
            }
            break;
    }
    if (length >= 5) {
        if ([AttributedStringCreator checkForTag:raw:LINK_START_TAG:offset:6:maxLength]) {
            if (openTag == YES) {
                BOOL startFound = NO;
                unichar buffer[length];
                int index = 0;
                
                for (int i = 0; i <length; i++) {
                    if (raw[offset + i] == DOUBLE_QUOTES_TAG || raw[offset + i] == SINGLE_QUOTES_TAG) {
                        startFound = !startFound;
                        if (!startFound) { break; }
                    } else if (startFound) {
                        buffer[index++] = raw[offset + i];
                    }
                }
                
                if (index > 0) {
                    [links addObject:[NSString stringWithCharacters:buffer length:index]];
                }
                
                [opens[LINK_INDEX] addObject:[NSNumber numberWithInt:tagLocation]];
            }
            return 0;
        }
        if ([AttributedStringCreator checkForTag:raw:FONT_START_TAG:offset:4:maxLength]) {
            if (openTag == YES) {
                BOOL startFound = NO;
                unichar buffer[length];
                int index = 0;
                
                for (int i = 0; i <length; i++) {
                    if (raw[offset + i] == DOUBLE_QUOTES_TAG || raw[offset + i] == SINGLE_QUOTES_TAG) {
                        startFound = !startFound;
                        if (!startFound) { break; }
                    } else if (startFound) {
                        buffer[index++] = raw[offset + i];
                    }
                }
                
                if (index > 0) {
                    [colors addObject:[NSString stringWithCharacters:buffer length:index]];
                }
                
                [opens[FONT_INDEX] addObject:[NSNumber numberWithInt:tagLocation]];
            }
            return 0;
        }
    }
    return -1;
}

/**
 This method compares the string location stored in the `currValue` parameter with the string location targeted and
 udpate `currTagIndex` and `currValue` if requried.
 
 @param tags open or close tag array
 @param currTagIndex a reference to a tag type index
 @param currValue reference to a location in the raw string
 @param tagIndex target tag type index in the `tags` array
 @param tagArrayIndex target tag instance index in the `tags` array
 @param tagArrayCount number of tag instances
 */
+(void)examineTag :(NSMutableArray *)tags
                  :(int *) currTagIndex
                  :(int *) currValue
                  :(int) tagIndex
                  :(int) tagArrayIndex
                  :(int) tagArrayCount {
    if (tagArrayIndex < tagArrayCount) {
        int value = ((NSNumber *)tags[tagIndex][tagArrayIndex]).intValue;
        *currValue = MIN(*currValue, value);
        if (*currValue == value) {
            *currTagIndex = tagIndex;
        }
    }
}

/**
 This method sets three parameters (index, location, isOpen) by examining the tag array state.
 @param opens array of open tag locations
 @param closes array of close tag locations
 @param index a reference to a tag type index
 @param location a reference to a location in the raw string
 @param isOpen a reference that determines whether the resulting `index` and `location` represents an open tag
 @param boldOpenIndex current instance index for bold open tags
 @param boldCloseIndex current instance index for bold close tags
 @param boldCount number of bold pairs
 @param italicsOpenIndex current instance index for italics open tags
 @param italicsCloseIndex current instance index for italics close tags
 @param italicsCount number of italics pairs
 @param tinyOpenIndex current instance index for tiny open tags
 @param tinyCloseIndex current instance index for tiny close tags
 @param tinyCount number of tiny pairs
 @param smallOpenIndex current instance index for small open tags
 @param smallCloseIndex current instance index for small close tags
 @param smallCount number of small pairs
 @param largeOpenIndex current instance index for large open tags
 @param largeCloseIndex current instance index for large close tags
 @param largeCount number of large pairs
 @param hugeOpenIndex current instance index for huge open tags
 @param hugeCloseIndex current instance index for huge close tags
 @param hugeCount number of huge pairs
 */
+(void)findNextCombinedTag :(NSMutableArray *)opens
                           :(NSMutableArray *)closes
                           :(int *) index
                           :(int *) location
                           :(BOOL *) isOpen
                           :(int) boldOpenIndex
                           :(int) boldCloseIndex
                           :(int) boldCount
                           :(int) italicsOpenIndex
                           :(int) italicsCloseIndex
                           :(int) italicsCount
                           :(int) tinyOpenIndex
                           :(int) tinyCloseIndex
                           :(int) tinyCount
                           :(int) smallOpenIndex
                           :(int) smallCloseIndex
                           :(int) smallCount
                           :(int) largeOpenIndex
                           :(int) largeCloseIndex
                           :(int) largeCount
                           :(int) hugeOpenIndex
                           :(int) hugeCloseIndex
                           :(int) hugeCount {
    
    *location = INT32_MAX;
    [AttributedStringCreator examineTag:opens :index :location :BOLD_INDEX :boldOpenIndex :boldCount];
    [AttributedStringCreator examineTag:opens :index :location :ITALIC_INDEX :italicsOpenIndex :italicsCount];
    [AttributedStringCreator examineTag:opens :index :location :TINY_INDEX :tinyOpenIndex :tinyCount];
    [AttributedStringCreator examineTag:opens :index :location :SMALL_INDEX :smallOpenIndex :smallCount];
    [AttributedStringCreator examineTag:opens :index :location :LARGE_INDEX :largeOpenIndex :largeCount];
    [AttributedStringCreator examineTag:opens :index :location :HUGE_INDEX :hugeOpenIndex :hugeCount];
    
    int openValue = *location;
    [AttributedStringCreator examineTag:closes :index :location :BOLD_INDEX :boldCloseIndex :boldCount];
    [AttributedStringCreator examineTag:closes :index :location :ITALIC_INDEX :italicsCloseIndex :italicsCount];
    [AttributedStringCreator examineTag:closes :index :location :TINY_INDEX :tinyCloseIndex :tinyCount];
    [AttributedStringCreator examineTag:closes :index :location :SMALL_INDEX :smallCloseIndex :smallCount];
    [AttributedStringCreator examineTag:closes :index :location :LARGE_INDEX :largeCloseIndex :largeCount];
    [AttributedStringCreator examineTag:closes :index :location :HUGE_INDEX :hugeCloseIndex :hugeCount];
    
    *isOpen = (openValue <= *location);
    
}

/**
 This method finds the tags, applies the necessary fonts and styles and creates a NSMutableAttributedString
 @param newStr new string buffer
 @param newStrLength new string length
 @param opens array of open tag locations
 @param closes array of close tag locations
 @param textSize default text size
 @param colors array of color tags
 @param baseColor default text color
 @return A stylized attributed string
 */
+(NSMutableAttributedString *)create :(unichar*)newStr
                                     :(int)newStrLength
                                     :(NSMutableArray *)opens
                                     :(NSMutableArray *)closes
                                     :(int)textSize
                                     :(NSMutableArray *)colors
                                     :(NSString*)baseColor {
    
    UIFont* font = [UIFont systemFontOfSize:textSize];
    if (AttributedStringCreator.main != nil) {
        font = [UIFont fontWithName:[AttributedStringCreator.main fontName] size:textSize];
    }
    
    NSMutableParagraphStyle * paragraph = [[NSMutableParagraphStyle alloc] init];
    paragraph.lineHeightMultiple = 1.0;
    paragraph.minimumLineHeight = font.lineHeight;
    paragraph.maximumLineHeight = font.lineHeight;
    
    NSMutableAttributedString *ret = [[NSMutableAttributedString alloc]
                                      initWithString:[NSString stringWithCharacters:newStr length:newStrLength]
                                      attributes:@{
                                                   NSFontAttributeName: font,
                                                   NSParagraphStyleAttributeName: paragraph}];
    
    int boldIndex = 0;
    int italicsIndex = 0;
    int tinyIndex = 0;
    int smallIndex = 0;
    int largeIndex = 0;
    int hugeIndex = 0;
    
    int boldCount = (int) MIN([opens[BOLD_INDEX] count], [closes[BOLD_INDEX] count]);
    int italicsCount = (int) MIN([opens[ITALIC_INDEX] count], [closes[ITALIC_INDEX] count]);
    int tinyCount = (int) MIN([opens[TINY_INDEX] count], [closes[TINY_INDEX] count]);
    int smallCount = (int) MIN([opens[SMALL_INDEX] count], [closes[SMALL_INDEX] count]);
    int largeCount = (int) MIN([opens[LARGE_INDEX] count], [closes[LARGE_INDEX] count]);
    int hugeCount = (int) MIN([opens[HUGE_INDEX] count], [closes[HUGE_INDEX] count]);
    
    int boldOpen = 0;
    int italicsOpen = 0;
    int tinyOpen = 0;
    int smallOpen = 0;
    int largeOpen = 0;
    int hugeOpen = 0;
    
    int previousTagLocation = 0;
    
    int tagIndex = -1;
    int tagLocation = -1;
    BOOL isOpen = NO;
    
    // Iterate through BOLD, ITALICS and the size Tags
    while (boldIndex < boldCount || italicsIndex < italicsCount || tinyIndex < tinyCount || smallIndex < smallCount || largeIndex < largeCount || hugeIndex < hugeCount) {
        [AttributedStringCreator findNextCombinedTag:opens :closes :&tagIndex :&tagLocation :&isOpen
                                                   :(boldIndex + boldOpen) :boldIndex :boldCount
                                                   :(italicsIndex + italicsOpen) :italicsIndex :italicsCount
                                                   :(tinyIndex + tinyOpen) :tinyIndex :tinyCount
                                                   :(smallIndex + smallOpen) :smallIndex :smallCount
                                                   :(largeIndex + largeOpen) :largeIndex :largeCount
                                                   :(hugeIndex + hugeOpen) :hugeIndex :hugeCount];
        
        if (tagLocation > previousTagLocation) {
            int fontSize = textSize;
            
            if (tinyOpen > 0) {
                fontSize -= 4;
            } else if (smallOpen > 0) {
                fontSize -= 2;
            } else if (largeOpen > 0) {
                fontSize += 2;
            } else if (hugeOpen > 0) {
                fontSize += 4;
            }
            
            if (boldOpen > 0 && italicsOpen > 0) {
                UIFont* font = [UIFont italicSystemFontOfSize:fontSize];
                if (AttributedStringCreator.italic != nil) {
                    font = [UIFont fontWithName:[AttributedStringCreator.italic fontName] size:textSize];
                }
            } else if (boldOpen > 0) {
                UIFont* font = [UIFont boldSystemFontOfSize:fontSize];
                if (AttributedStringCreator.italic != nil) {
                    font = [UIFont fontWithName:[AttributedStringCreator.bold fontName] size:textSize];
                }
            } else if (italicsOpen > 0) {
                UIFont* font = [UIFont italicSystemFontOfSize:fontSize];
                if (AttributedStringCreator.italic != nil) {
                    font = [UIFont fontWithName:[AttributedStringCreator.italic fontName] size:textSize];
                }
            } else {
                UIFont* font = [UIFont systemFontOfSize:textSize];
                if (AttributedStringCreator.main != nil) {
                    font = [UIFont fontWithName:[AttributedStringCreator.main fontName] size:textSize];
                }
            }
            
            paragraph = [[NSMutableParagraphStyle alloc] init];
            paragraph.lineHeightMultiple = 1.0;
            paragraph.minimumLineHeight = font.lineHeight;
            paragraph.maximumLineHeight = font.lineHeight;
            
            [ret setAttributes:
             @{
               NSFontAttributeName: font,
               NSParagraphStyleAttributeName: paragraph}
                         range:NSMakeRange(previousTagLocation, tagLocation - previousTagLocation)];
        }
        previousTagLocation = tagLocation;
        
        
        if (isOpen) {
            switch (tagIndex) {
                case BOLD_INDEX:
                    boldOpen++;
                    break;
                case ITALIC_INDEX:
                    italicsOpen++;
                    break;
                case TINY_INDEX:
                    tinyOpen++;
                    break;
                case SMALL_INDEX:
                    smallOpen++;
                    break;
                case LARGE_INDEX:
                    largeOpen++;
                    break;
                case HUGE_INDEX:
                    hugeOpen++;
                    break;
            }
        } else {
            switch (tagIndex) {
                case BOLD_INDEX:
                    boldOpen--;
                    boldIndex++;
                    break;
                case ITALIC_INDEX:
                    italicsOpen--;
                    italicsIndex++;
                    break;
                case TINY_INDEX:
                    tinyOpen--;
                    tinyIndex++;
                    break;
                case SMALL_INDEX:
                    smallOpen--;
                    smallIndex++;
                    break;
                case LARGE_INDEX:
                    largeOpen--;
                    largeIndex++;
                    break;
                case HUGE_INDEX:
                    hugeOpen--;
                    hugeIndex++;
                    break;
            }
        }
        
        
        
    }
    
    
    int count = (int) MIN([opens[UNDERLINE_INDEX] count], [closes[UNDERLINE_INDEX] count]);
    for (int i = 0; i < count; i++) {
        [ret addAttributes:
         @{ NSUnderlineStyleAttributeName: @(NSUnderlineStyleSingle) }
                     range:NSMakeRange(
                                       ((NSNumber *)opens[UNDERLINE_INDEX][i]).intValue,
                                       ((NSNumber *)closes[UNDERLINE_INDEX][i]).intValue - ((NSNumber *)opens[UNDERLINE_INDEX][i]).intValue)];
    }
    
    count = (int) MIN([opens[LINK_INDEX] count], [closes[LINK_INDEX] count]);
    for (int i = 0; i < count; i++) {
        [ret addAttributes:
         @{ NSUnderlineStyleAttributeName: @(NSUnderlineStyleSingle),
            NSForegroundColorAttributeName: [UIColor blueColor]}
                     range:NSMakeRange(
                                       ((NSNumber *)opens[LINK_INDEX][i]).intValue,
                                       ((NSNumber *)closes[LINK_INDEX][i]).intValue - ((NSNumber *)opens[LINK_INDEX][i]).intValue)];
        
        
    }
    
    count = (int) MIN([opens[LEFT_INDEX] count], [closes[LEFT_INDEX] count]);
    paragraph = [[NSMutableParagraphStyle alloc] init];
    paragraph.alignment = NSTextAlignmentLeft;
    
    for (int i = 0; i < count; i++) {
        [ret addAttributes:
         @{ NSParagraphStyleAttributeName: paragraph }
                     range:NSMakeRange(
                                       ((NSNumber *)opens[LEFT_INDEX][i]).intValue,
                                       ((NSNumber *)closes[LEFT_INDEX][i]).intValue - ((NSNumber *)opens[LEFT_INDEX][i]).intValue)];
    }
    
    count = (int) MIN([opens[CENTER_INDEX] count], [closes[CENTER_INDEX] count]);
    paragraph = [[NSMutableParagraphStyle alloc] init];
    paragraph.alignment = NSTextAlignmentCenter;
    
    for (int i = 0; i < count; i++) {
        [ret addAttributes:
         @{ NSParagraphStyleAttributeName: paragraph }
                     range:NSMakeRange(
                                       ((NSNumber *)opens[CENTER_INDEX][i]).intValue,
                                       ((NSNumber *)closes[CENTER_INDEX][i]).intValue - ((NSNumber *)opens[CENTER_INDEX][i]).intValue)];
    }
    
    count = (int) MIN([opens[RIGHT_INDEX] count], [closes[RIGHT_INDEX] count]);
    paragraph = [[NSMutableParagraphStyle alloc] init];
    paragraph.alignment = NSTextAlignmentRight;
    
    for (int i = 0; i < count; i++) {
        [ret addAttributes:
         @{ NSParagraphStyleAttributeName: paragraph }
                     range:NSMakeRange(
                                       ((NSNumber *)opens[RIGHT_INDEX][i]).intValue,
                                       ((NSNumber *)closes[RIGHT_INDEX][i]).intValue - ((NSNumber *)opens[RIGHT_INDEX][i]).intValue)];
    }
    
    
    if (baseColor != nil) {
        [ret addAttributes:
         @{ NSForegroundColorAttributeName: [AttributedStringCreator createColor: baseColor] }
                     range:NSMakeRange(0, ret.length)];
    }
    
    count = (int) MIN([opens[FONT_INDEX] count], [closes[FONT_INDEX] count]);
    paragraph = [[NSMutableParagraphStyle alloc] init];
    paragraph.alignment = NSTextAlignmentRight;
    
    for (int i = 0; i < count; i++) {
        [ret addAttributes:
         @{ NSForegroundColorAttributeName: [AttributedStringCreator createColor: colors[i]] }
                     range:NSMakeRange(
                                       ((NSNumber *)opens[FONT_INDEX][i]).intValue,
                                       ((NSNumber *)closes[FONT_INDEX][i]).intValue - ((NSNumber *)opens[FONT_INDEX][i]).intValue)];
    }
    
    return ret;
}

/**
 This method sets up the resources required to parse the style tags and creates a NSMutableAttributedString
 @param raw string that should be stylized
 @param textSize default text size
 @param links a reference to an array that will contain any links found while parsing the style
 @param linkLocations a reference to an array that will contain the location of the links found while parsing the style
 @param baseColor default text color
 @return A stylized attributed string
 */
+(NSMutableAttributedString *)build:(NSString*)raw
                                   :(int)textSize
                                   :(NSMutableArray*) links
                                   :(NSMutableArray*) linkLocations
                                   :(NSString*)baseColor {
    NSUInteger length = raw.length;
    unichar buffer[length+1];
    unichar newStringBuffer[length+1];
    [raw getCharacters:buffer range:NSMakeRange(0, length)];
    
    unichar currChar;
    
    int state = CLOSED;
    BOOL openTag = YES;
    
    int tagLocation = 0;
    int tagStart = 0;
    int currentSize = 0;
    
    NSMutableArray *tagOpens = [NSMutableArray array];
    for (int i = 0; i < TAG_COUNT; i++) {
        [tagOpens addObject:[NSMutableArray array]];
    }
    NSMutableArray *tagCloses = [NSMutableArray array];
    for (int i = 0; i < TAG_COUNT; i++) {
        [tagCloses addObject:[NSMutableArray array]];
    }
    NSMutableArray *colors = [NSMutableArray array];
    
    for(int i = 0; i < length; i++) {
        currChar = buffer[i];
        newStringBuffer[currentSize++] = currChar;
        
        switch (state) {
            case CLOSED:
                if (currChar == OPEN_TAG) {
                    openTag = YES;
                    state = OPEN_FOUND;
                    tagLocation = currentSize - 1;
                    tagStart = i + 1;
                }
                break;
            case OPEN_FOUND:
                if (currChar == SLASH_TAG) {
                    if (openTag == YES && tagStart == i) {
                        tagStart = i + 1;
                        openTag = NO;
                    }
                } else if (currChar == CLOSE_TAG) {
                    int proc = [AttributedStringCreator checkTags:newStringBuffer :buffer :tagStart:(i - tagStart):length :tagOpens :tagCloses :openTag :tagLocation :colors :links];
                    if (proc >= 0) {
                        currentSize = tagLocation + proc;
                    }
                    state = CLOSED;
                }
                break;
        }
    }
    
    int count = (int) MIN([tagOpens[LINK_INDEX] count], [tagCloses[LINK_INDEX] count]);
    for (int i = 0; i < count; i++) {
        [linkLocations addObject: [NSValue valueWithRange:NSMakeRange(((NSNumber *)tagOpens[LINK_INDEX][i]).intValue, (((NSNumber *)tagCloses[LINK_INDEX][i]).intValue - ((NSNumber *)tagOpens[LINK_INDEX][i]).intValue))]];
    }
    
    return [AttributedStringCreator create:newStringBuffer :currentSize :tagOpens :tagCloses :textSize :colors :baseColor];
}

@end



