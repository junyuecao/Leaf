// Rect stuff
#define CGWidth(rect)                   rect.size.width
#define CGHeight(rect)                  rect.size.height
#define CGOriginX(rect)                 rect.origin.x
#define CGOriginY(rect)                 rect.origin.y
#define CGRectCenter(rect)              CGPointMake(NSOriginX(rect) + NSWidth(rect) / 2, NSOriginY(rect) + NSHeight(rect) / 2)
#define CGRectModify(rect,dx,dy,dw,dh)  CGRectMake(rect.origin.x + dx, rect.origin.y + dy, rect.size.width + dw, rect.size.height + dh)
#define NSLogRect(rect)                 NSLog(@"Rect: %@", NSStringFromCGRect(rect))
#define NSLogSize(size)                 NSLog(@"%@", NSStringFromCGSize(size))
#define NSLogPoint(point)               NSLog(@"%@", NSStringFromCGPoint(point))


// Color stuff
#define CGColorConvert(value)           value/255.0f

// Number 
#define __INT(v) [NSNumber numberWithInt:v]

// Fonts
#define kLeafFont10 [UIFont fontWithName:@"FZLTHK--GBK1-0" size:10.0f]
#define kLeafFont13 [UIFont fontWithName:@"FZLTHK--GBK1-0" size:13.0f]
#define kLeafBoldFont16 [UIFont fontWithName:@"FZLTZHK--GBK1-0" size:16.0f]