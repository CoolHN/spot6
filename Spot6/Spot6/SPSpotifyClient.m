#import "SPSpotifyClient.h"
#import "SPTrack.h"

@implementation SPSpotifyClient

- (void)searchTracksForQuery:(NSString *)query completion:(SPSpotifySearchCompletion)completion
{
    if (query.length == 0) {
        if (completion) {
            completion([NSArray array], nil);
        }
        return;
    }

    NSString *escaped = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(NULL,
                                                                                               (__bridge CFStringRef)query,
                                                                                               NULL,
                                                                                               CFSTR("!*'\"();:@&=+$,/?%#[]% "),
                                                                                               kCFStringEncodingUTF8));

    NSString *urlString = [NSString stringWithFormat:@"https://api.spotify.com/v1/search?q=%@&type=track&limit=25", escaped];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString]];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];

    if (self.accessToken.length > 0) {
        NSString *authHeader = [NSString stringWithFormat:@"Bearer %@", self.accessToken];
        [request setValue:authHeader forHTTPHeaderField:@"Authorization"];
    }

    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        if (connectionError) {
            if (completion) {
                completion(nil, connectionError);
            }
            return;
        }

        NSError *jsonError = nil;
        NSDictionary *payload = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError];
        if (jsonError || ![payload isKindOfClass:[NSDictionary class]]) {
            if (completion) {
                completion(nil, jsonError);
            }
            return;
        }

        NSDictionary *tracksNode = [payload objectForKey:@"tracks"];
        NSArray *items = [tracksNode objectForKey:@"items"];
        NSMutableArray *results = [NSMutableArray array];

        for (NSDictionary *item in items) {
            SPTrack *track = [[SPTrack alloc] init];
            track.name = [item objectForKey:@"name"];

            NSArray *artists = [item objectForKey:@"artists"];
            if (artists.count > 0) {
                track.artistName = [[artists objectAtIndex:0] objectForKey:@"name"];
            }

            NSDictionary *album = [item objectForKey:@"album"];
            track.albumName = [album objectForKey:@"name"];

            NSDictionary *externalUrls = [item objectForKey:@"external_urls"];
            track.spotifyURL = [externalUrls objectForKey:@"spotify"];
            track.previewURL = [item objectForKey:@"preview_url"];
            [results addObject:track];
        }

        if (completion) {
            completion(results, nil);
        }
    }];
}

@end
