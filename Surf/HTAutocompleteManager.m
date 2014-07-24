//
//  HTAutocompleteManager.m
//  HotelTonight
//
//  Created by Jonathan Sibley on 12/6/12.
//  Copyright (c) 2012 Hotel Tonight. All rights reserved.
//

#import "HTAutocompleteManager.h"

static HTAutocompleteManager *sharedManager;

@implementation HTAutocompleteManager

+ (HTAutocompleteManager *)sharedManager
{
	static dispatch_once_t done;
	dispatch_once(&done, ^{ sharedManager = [[HTAutocompleteManager alloc] init]; });
	return sharedManager;
}

#pragma mark - HTAutocompleteTextFieldDelegate

- (NSString *)textField:(HTAutocompleteTextField *)textField
    completionForPrefix:(NSString *)prefix
             ignoreCase:(BOOL)ignoreCase
{
    if (textField.autocompleteType == HTAutocompleteTypeWebSearch)
    {
        static dispatch_once_t colorOnceToken;
        static NSArray *top500;
//        static NSArray *searchTerms;

        dispatch_once(&colorOnceToken, ^
        {
            top500 =
            @[
              @"facebook.com",
              @"twitter.com",
              @"google.com",
              @"youtube.com",
              @"wordpress.org",
              @"adobe.com",
              @"blogspot.com",
              @"wikipedia.org",
              @"linkedin.com",
              @"wordpress.com",
              @"yahoo.com",
              @"amazon.com",
              @"flickr.com",
              @"pinterest.com",
              @"tumblr.com",
              @"w3.org",
              @"apple.com",
              @"myspace.com",
              @"vimeo.com",
              @"microsoft.com",
              @"youtu.be",
              @"qq.com",
              @"digg.com",
              @"baidu.com",
              @"stumbleupon.com",
              @"addthis.com",
              @"statcounter.com",
              @"feedburner.com",
              @"miibeian.gov.cn",
              @"delicious.com",
              @"nytimes.com",
              @"reddit.com",
              @"weebly.com",
              @"bbc.co.uk",
              @"blogger.com",
              @"msn.com",
              @"macromedia.com",
              @"goo.gl",
              @"instagram.com",
              @"gov.uk",
              @"icio.us",
              @"yandex.ru",
              @"cnn.com",
              @"webs.com",
              @"google.de",
              @"t.co",
              @"livejournal.com",
              @"imdb.com",
              @"mail.ru",
              @"techcrunch.com",
              @"producthunt.com",
              @"theverge.com",
              @"jimdo.com",
              @"sourceforge.net",
              @"go.com",
              @"tinyurl.com",
              @"vk.com",
              @"google.co.jp",
              @"fc2.com",
              @"free.fr",
              @"joomla.org",
              @"creativecommons.org",
              @"typepad.com",
              @"networkadvertising.org",
              @"technorati.com",
              @"sina.com.cn",
              @"hugedomains.com",
              @"about.com",
              @"theguardian.com",
              @"yahoo.co.jp",
              @"nih.gov",
              @"huffingtonpost.com",
              @"google.co.uk",
              @"mozilla.org",
              @"51.la",
              @"aol.com",
              @"ebay.com",
              @"ameblo.jp",
              @"wsj.com",
              @"europa.eu",
              @"taobao.com",
              @"bing.com",
              @"rambler.ru",
              @"guardian.co.uk",
              @"tripod.com",
              @"godaddy.com",
              @"issuu.com",
              @"gnu.org",
              @"geocities.com",
              @"slideshare.net",
              @"wix.com",
              @"mapquest.com",
              @"washingtonpost.com",
              @"homestead.com",
              @"reuters.com",
              @"163.com",
              @"photobucket.com",
              @"forbes.com",
              @"clickbank.net",
              @"weibo.com",
              @"etsy.com",
              @"amazon.co.uk",
              @"dailymotion.com",
              @"soundcloud.com",
              @"usatoday.com",
              @"yelp.com",
              @"cnet.com",
              @"posterous.com",
              @"telegraph.co.uk",
              @"archive.org",
              @"google.fr",
              @"constantcontact.com",
              @"phoca.cz",
              @"phpbb.com",
              @"latimes.com",
              @"e-recht24.de",
              @"rakuten.co.jp",
              @"amazon.de",
              @"opera.com",
              @"miitbeian.gov.cn",
              @"php.net",
              @"scribd.com",
              @"bbb.org",
              @"parallels.com",
              @"ning.com",
              @"dailymail.co.uk",
              @"cdc.gov",
              @"sohu.com",
              @"wikimedia.org",
              @"deviantart.com",
              @"mit.edu",
              @"sakura.ne.jp",
              @"altervista.org",
              @"addtoany.com",
              @"time.com",
              @"google.it",
              @"stanford.edu",
              @"live.com",
              @"alibaba.com",
              @"squidoo.com",
              @"harvard.edu",
              @"gravatar.com",
              @"histats.com",
              @"nasa.gov",
              @"npr.org",
              @"ca.gov",
              @"eventbrite.com",
              @"wired.com",
              @"amazon.co.jp",
              @"nbcnews.com",
              @"blog.com",
              @"amazonaws.com",
              @"bloomberg.com",
              @"narod.ru",
              @"blinklist.com",
              @"imageshack.us",
              @"kickstarter.com",
              @"hatena.ne.jp",
              @"nifty.com",
              @"angelfire.com",
              @"google.es",
              @"ocn.ne.jp",
              @"over-blog.com",
              @"dedecms.com",
              @"google.ca",
              @"a8.net",
              @"weather.com",
              @"pbs.org",
              @"ibm.com",
              @"cpanel.net",
              @"prweb.com",
              @"bandcamp.com",
              @"barnesandnoble.com",
              @"mozilla.com",
              @"noaa.gov",
              @"goo.ne.jp",
              @"comsenz.com",
              @"xrea.com",
              @"cbsnews.com",
              @"foxnews.com",
              @"discuz.net",
              @"eepurl.com",
              @"businessweek.com",
              @"berkeley.edu",
              @"newsvine.com",
              @"bluehost.com",
              @"geocities.jp",
              @"loc.gov",
              @"yolasite.com",
              @"apache.org",
              @"mashable.com",
              @"usda.gov",
              @"nationalgeographic.com",
              @"whitehouse.gov",
              @"tripadvisor.com",
              @"ted.com",
              @"sfgate.com",
              @"biglobe.ne.jp",
              @"epa.gov",
              @"vkontakte.ru",
              @"oracle.com",
              @"seesaa.net",
              @"examiner.com",
              @"cornell.edu",
              @"hp.com",
              @"nps.gov",
              @"disqus.com",
              @"alexa.com",
              @"mysql.com",
              @"house.gov",
              @"sphinn.com",
              @"boston.com",
              @"un.org",
              @"squarespace.com",
              @"icq.com",
              @"freewebs.com",
              @"ezinearticles.com",
              @"ucoz.ru",
              @"independent.co.uk",
              @"mediafire.com",
              @"xinhuanet.com",
              @"google.nl",
              @"reverbnation.com",
              @"imgur.com",
              @"irs.gov",
              @"webnode.com",
              @"wunderground.com",
              @"bizjournals.com",
              @"who.int",
              @"soup.io",
              @"cloudflare.com",
              @"people.com.cn",
              @"ustream.tv",
              @"senate.gov",
              @"cbslocal.com",
              @"ycombinator.com",
              @"opensource.org",
              @"spiegel.de",
              @"oaic.gov.au",
              @"nature.com",
              @"businessinsider.com",
              @"drupal.org",
              @"last.fm",
              @"privacy.gov.au",
              @"skype.com",
              @"wikia.com",
              @"about.me",
              @"webmd.com",
              @"youku.com",
              @"gmpg.org",
              @"fda.gov",
              @"redcross.org",
              @"github.com",
              @"cbc.ca",
              @"umich.edu",
              @"jugem.jp",
              @"shinystat.com",
              @"google.com.br",
              @"ifeng.com",
              @"mac.com",
              @"wiley.com",
              @"discovery.com",
              @"topsy.com",
              @"paypal.com",
              @"google.cn",
              @"surveymonkey.com",
              @"moonfruit.com",
              @"dropbox.com",
              @"exblog.jp",
              @"google.pl",
              @"prnewswire.com",
              @"ft.com",
              @"uol.com.br",
              @"behance.net",
              @"goodreads.com",
              @"netvibes.com",
              @"auda.org.au",
              @"marketwatch.com",
              @"ed.gov",
              @"networksolutions.com",
              @"state.gov",
              @"sitemeter.com",
              @"liveinternet.ru",
              @"ftc.gov",
              @"census.gov",
              @"quantcast.com",
              @"economist.com",
              @"nydailynews.com",
              @"zdnet.com",
              @"cafepress.com",
              @"ow.ly",
              @"meetup.com",
              @"netscape.com",
              @"chicagotribune.com",
              @"theatlantic.com",
              @"google.com.au",
              @"1688.com",
              @"skyrock.com",
              @"list-manage.com",
              @"pagesperso-orange.fr",
              @"cdbaby.com",
              @"friendfeed.com",
              @"ehow.com",
              @"patch.com",
              @"upenn.edu",
              @"engadget.com",
              @"diigo.com",
              @"com.com",
              @"slashdot.org",
              @"washington.edu",
              @"columbia.edu",
              @"nhs.uk",
              @"abc.net.au",
              @"elegantthemes.com",
              @"utexas.edu",
              @"yale.edu",
              @"marriott.com",
              @"bigcartel.com",
              @"ucla.edu",
              @"usgs.gov",
              @"jigsy.com",
              @"hexun.com",
              @"hubpages.com",
              @"slate.com",
              @"purevolume.com",
              @"umn.edu",
              @"bloglines.com",
              @"so-net.ne.jp",
              @"wikispaces.com",
              @"cargocollective.com",
              @"howstuffworks.com",
              @"plala.or.jp",
              @"infoseek.co.jp",
              @"jiathis.com",
              @"usnews.com",
              @"xing.com",
              @"flavors.me",
              @"desdev.cn",
              @"hc360.com",
              @"usa.gov",
              @"edublogs.org",
              @"lycos.com",
              @"wisc.edu",
              @"thetimes.co.uk",
              @"state.tx.us",
              @"example.com",
              @"shareasale.com",
              @"biblegateway.com",
              @"is.gd",
              @"yellowbook.com",
              @"samsung.com",
              @"businesswire.com",
              @"g.co",
              @"dion.ne.jp",
              @"dagondesign.com",
              @"theglobeandmail.com",
              @"booking.com",
              @"storify.com",
              @"salon.com",
              @"ucoz.com",
              @"gizmodo.com",
              @"psu.edu",
              @"smh.com.au",
              @"reference.com",
              @"sun.com",
              @"unicef.org",
              @"devhub.com",
              @"artisteer.com",
              @"unesco.org",
              @"istockphoto.com",
              @"answers.com",
              @"trellian.com",
              @"cocolog-nifty.com",
              @"i2i.jp",
              @"t-online.de",
              @"intel.com",
              @"1und1.de",
              @"ebay.co.uk",
              @"sciencedaily.com",
              @"paginegialle.it",
              @"ask.com",
              @"springer.com",
              @"canalblog.com",
              @"timesonline.co.uk",
              @"de.vu",
              @"deliciousdays.com",
              @"smugmug.com",
              @"wufoo.com",
              @"globo.com",
              @"cmu.edu",
              @"domainmarket.com",
              @"odnoklassniki.ru",
              @"twitpic.com",
              @"ovh.net",
              @"home.pl",
              @"naver.com",
              @"google.ru",
              @"si.edu",
              @"newyorker.com",
              @"blogs.com",
              @"sciencedirect.com",
              @"hibu.com",
              @"hud.gov",
              @"hhs.gov",
              @"dmoz.org",
              @"dot.gov",
              @"cyberchimps.com",
              @"google.com.hk",
              @"jalbum.net",
              @"craigslist.org",
              @"zimbio.com",
              @"chronoengine.com",
              @"cnbc.com",
              @"uiuc.edu",
              @"vistaprint.com",
              @"symantec.com",
              @"prlog.org",
              @"360.cn",
              @"indiatimes.com",
              @"mtv.com",
              @"webeden.co.uk",
              @"java.com",
              @"cisco.com",
              @"japanpost.jp",
              @"4shared.com",
              @"github.io",
              @"mayoclinic.com",
              @"studiopress.com",
              @"admin.ch",
              @"virginia.edu",
              @"printfriendly.com",
              @"mlb.com",
              @"omniture.com",
              @"simplemachines.org",
              @"dell.com",
              @"accuweather.com",
              @"princeton.edu",
              @"fotki.com",
              @"comcast.net",
              @"chron.com",
              @"nyu.edu",
              @"wp.com",
              @"merriam-webster.com",
              @"nba.com",
              @"shop-pro.jp",
              @"lulu.com",
              @"furl.net",
              @"indiegogo.com",
              @"buzzfeed.com",
              @"tuttocitta.it",
              @"ox.ac.uk",
              @"mapy.cz",
              @"army.mil",
              @"csmonitor.com",
              @"bravesites.com",
              @"tamu.edu",
              @"rediff.com",
              @"toplist.cz",
              @"yellowpages.com",
              @"va.gov",
              @"tiny.cc",
              @"netlog.com",
              @"elpais.com",
              @"oakley.com",
              @"multiply.com",
              @"tmall.com",
              @"hostgator.com",
              @"nymag.com",
              @"fema.gov",
              @"blogtalkradio.com",
              @"china.com.cn",
              @"unblog.fr",
              @"fastcompany.com",
              @"earthlink.net",
              @"vinaora.com",
              @"msu.edu",
              @"aboutads.info",
              @"ucsd.edu",
              @"sogou.com",
              @"seattletimes.com",
              @"dyndns.org",
              @"123-reg.co.uk",
              @"sbwire.com",
              @"tinypic.com",
              @"acquirethisname.com",
              @"shutterfly.com",
              @"walmart.com",
              @"pen.io",
              @"arizona.edu",
              @"woothemes.com",
              @"scientificamerican.com",
              @"themeforest.net",
              @"spotify.com",
              @"cam.ac.uk",
              @"unc.edu",
              @"arstechnica.com",
              @"hao123.com",
              @"illinois.edu",
              @"bloglovin.com",
              @"nsw.gov.au",
              @"ihg.com",
              @"pcworld.com",
             ];

//            NSMutableArray *history;
//            for (NSDictionary *site in [[NSUserDefaults standardUserDefaults] objectForKey:@"history"])
//            {
//                NSString *url = site[@"url"];
//                if ([url hasPrefix:@"http://www."])
//                {
//                    url = [url substringFromIndex:[@"http://www." length]];
//                }
//                else if ([url hasPrefix:@"https://www."])
//                {
//                    url = [url substringFromIndex:[@"https://www." length]];
//                }
//                else if ([url hasPrefix:@"http://"])
//                {
//                    url = [url substringFromIndex:[@"http://" length]];
//                }
//                else if ([url hasPrefix:@"https://"])
//                {
//                    url = [url substringFromIndex:[@"https://" length]];
//                }
//                [history addObject:url];
//                NSLog(@"%@",url);
//            }
//            NSLog(@"%@",history);
//            searchTerms = [top500 arrayByAddingObjectsFromArray:[NSArray arrayWithArray:history]];
//            NSLog(@"%@",searchTerms);
        });

        NSString *stringToLookFor;
		NSArray *componentsString = [prefix componentsSeparatedByString:@","];
        NSString *prefixLastComponent = [componentsString.lastObject stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        if (ignoreCase)
        {
            stringToLookFor = [prefixLastComponent lowercaseString];
        }
        else
        {
            stringToLookFor = prefixLastComponent;
        }
        
        for (NSString *stringFromReference in top500)
        {
            NSString *stringToCompare;
            if (ignoreCase)
            {
                stringToCompare = [stringFromReference lowercaseString];
            }
            else
            {
                stringToCompare = stringFromReference;
            }
            
            if ([stringToCompare hasPrefix:stringToLookFor])
            {
                return [stringFromReference stringByReplacingCharactersInRange:[stringToCompare rangeOfString:stringToLookFor] withString:@""];
            }
            
        }
    }
    
    return @"";
}

@end



//self.data = [[NSUserDefaults standardUserDefaults] objectForKey:@"history"];

