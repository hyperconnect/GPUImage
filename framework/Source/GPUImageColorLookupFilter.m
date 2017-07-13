//
//  Created by haru on 2017. 7. 13..
//  Copyright © 2017 Hyperconnect. All rights reserved.
//

#import "GPUImageColorLookupFilter.h"
#import "GPUImagePicture.h"

@implementation GPUImageColorLookupFilter

- (id)initWithFragmentShaderFromString:(NSString *)fragmentShaderString
                        loopkupTexture:(GPUImagePicture *)texture
{
    if (!(self = [super initWithFragmentShaderFromString: fragmentShaderString]))
    {
        return nil;
    }

    self.lookupTexture = texture;
    [self.lookupTexture addTarget: self atTextureLocation: 1];
    [self.lookupTexture processImage];

    return self;
}

@end
