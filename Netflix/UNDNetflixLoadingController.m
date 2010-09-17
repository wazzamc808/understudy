#import "UNDNetflixLoadingController.h"

@implementation UNDNetflixLoadingController

- (id)init
{
  return [super initWithTitle:@"Loading" text:@"Loading"];
}

- (void)assetUpdated:(NetflixAsset*)asset
{
  // If the user got tired of waiting for the asset to finish loading and
  // popped this controller then don't attempt to push the asset's controller.
  if ([self active])
    [[self stack] swapController:[asset controller]];
}

@end
