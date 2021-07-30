# Interface to Dreamwidth

I'm not going to lie: Dreamwidth does not make it easy to build a mobile app that allows for reading. 
There are a few "APIs" available for Dreamwidth, but none of them are feature-complete. Dream Balloon
uses five APIs:

## The Flat API

The [Flat API](https://stat.livejournal.com/doc/server/ljp.csp.flat.protocol.html) is very old, and was 
built as part of LiveJournal (the mitocondrial Eve to Dreamwidth). At the moment, we use the following
functions:

- login: we use the login to validate userid/password information
- sessiongenerate: since we do a lot with the web interface and screen-scraping, we end up having
  to emulate the session-cookie-based security model, after we login. The sessiongenerate function
  makes this possible.

The Flat API supports a few security models, but the one I use just feeds the userid/password back with every request.

## The Mobile-friendly Web Interface

Dreamwidth provides a web interface called the ["Mobile Friendly Reading Page"](https://www.dreamwidth.org/mobile/read), which
provides a very simple web UI for a user's reading page. This UI can give me quick access to see which journals that a user reads
have been updated recently.

In order to use the page, I have to set up the web session security (because that's how Dreamwidth knows what "user" is viewing it),
and I need to parse the HTML response (it's a very simple page, but HTML is often surprisingly badly formatted. For this purpose,
I use a component called HTMLKit).

The Mobile Friendly Reading Page is paginated, and I usually traverse a few pages to get a fairly full list. I suspect that a user who
is subscribed to a very large number of journals may present problems, but I'm trying to work through the basic cases before taking
on exceptions.

## The Atom Feed API

If I have a list of journals with recent activity that the user subscribes to, then I can fetch a list of recent entries
from that journal using their ATOM feed. The ATOM feed URL is essentially: https://{journal}.dreamwidth.org/data/atom .
So, for example, the ATOM feed for the dw-dev community is https://dw_dev.dreamwidth.org/data/atom (note how there's a 
common translation of hyphens to underscores).

I can also get the user's recent entries via their own ATOM feed.

ATOM is a fairly standardized format, although Dreamwidth extends it with a few (useful) extensions such as number of comments.
In particular, ATOM is one of the few ways of accessing the entries that produces entry timestamps in a useable format (the
web interface, for example, formats the timestamps in the entry author's timezone which is kinda hard to determine).

ATOM will generally only give you partial entry content, and will not give you some important metadata (such as information
about which avatar is used or the text or authors of any comments).

In order to see private entries in the ATOM feed, the web session security must be set up.

One complication for the ATOM feeds: some of the journals on my reading list are, themselves, feeds from other sites. For example,
I often read XKCD on Dreamwidth. If I try to follow the XKCD ATOM Feed link at https://xkcd_feed.dreamwidth.org/data/atom, I
will be redirected to the source feed at https://xkcd.com/rss.xml . Note, especially, that the source feed is not ATOM, but is instead
RSS.

## The Standard Web Interface

I can view the web page for a specific entry using the standard web UI. If I view it using the parameters "format=light&expand_all=1",
then I get a predictable look-and-feel for the site (and predictable HTML structure) and I don't need to worry about comments having been 
collapsed.

AT THE MOMENT, THE STANDARD WEB INTERFACE IS THE ONLY WAY TO VIEW COMMENTS ON AN ENTRY. There is no other API that can get comments for an
entry, and it's very sad. I sometimes sob in my room for hours over this very point.

A thing I don't think I currently support: any entry with more than 250 comments will become paginated. 

## The REST API

The REST API is very new, and supports very few functions. At the time of this writing, [the OpenAPI spec](https://www.dreamwidth.org/api/v1/spec) 
for the REST API basically only provides access to user avatars/icons.

The REST API also uses a different security model, involving "API Keys". Unfortunately, the only way to get an API key is via 
a [web interface](https://www.dreamwidth.org/manage/emailpost). I can screen scrape that interface and generate an API key, but
it feels to me like it should be easier than it currently is. 

The REST API hasn't really evolved in a couple of years, so it might be abandonware.