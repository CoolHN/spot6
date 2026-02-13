#import "SPYouTubeFallbackClient.h"

@implementation SPYouTubeFallbackClient

- (NSURL *)searchURLForTrackQuery:(NSString *)query
{
    NSString *safeQuery = query ? query : @"";
    NSString *escaped = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(NULL,
                                                                                               (__bridge CFStringRef)safeQuery,
                                                                                               NULL,
                                                                                               CFSTR("!*'\"();:@&=+$,/?%#[]% "),
                                                                                               kCFStringEncodingUTF8));
    NSString *urlString = [NSString stringWithFormat:@"https://m.youtube.com/results?search_query=%@", escaped];
    return [NSURL URLWithString:urlString];
}

@end
