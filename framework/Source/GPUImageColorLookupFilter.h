//
//  Created by haru on 2017. 7. 13..
//  Copyright © 2017 Hyperconnect. All rights reserved.
//

#import "GPUImageTwoInputFilter.h"

@class GPUImagePicture;

@interface GPUImageColorLookupFilter : GPUImageTwoInputFilter

@property (nonatomic, strong) GPUImagePicture *lookupTexture;

- (id)initWithFragmentShaderFromString:(NSString *)fragmentShaderString
                        loopkupTexture:(GPUImagePicture *)texture;

@end
