#import "SPAppDelegate.h"
#import "SPMainViewController.h"

@implementation SPAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];

    self.mainViewController = [[SPMainViewController alloc] init];
    self.navigationController = [[UINavigationController alloc] initWithRootViewController:self.mainViewController];
    self.navigationController.navigationBar.tintColor = [UIColor colorWithRed:0.12f green:0.12f blue:0.12f alpha:1.0f];

    self.window.rootViewController = self.navigationController;
    [self.window makeKeyAndVisible];
    return YES;
}

@end
