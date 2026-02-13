#import <Foundation/Foundation.h>

@class SPTrack;

typedef void (^SPSpotifySearchCompletion)(NSArray *tracks, NSError *error);

@interface SPSpotifyClient : NSObject

@property (nonatomic, copy) NSString *accessToken;

- (void)searchTracksForQuery:(NSString *)query completion:(SPSpotifySearchCompletion)completion;

@end
