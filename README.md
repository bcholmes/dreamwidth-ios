# Dreamwidth App

This codebase implements an iOS App for Dreamwidth. I really like Dreamwidth, and it bugs
me that there's no good App for it. So, I became interested in fixing that.
Unfortunately, I hit a couple of near-insurmountable opportunities:

1. The existing APIs for LiveJournal/Dreamwidth have very poor support for fetching
entries in a most-recent first way (which is the most natural way for mobile apps).
You can get your own entries most-recent first, but it's hard to get your reading list
most recent first.
2. The existing APIs have no real support for comments. There has been
[some progress](https://github.com/dreamwidth/dw-free/pull/2265)
on that front, but a solution is probably a few months off, still.

In the meantime, this app uses the so-called ["flat API"](https://www.livejournal.com/doc/server/ljp.csp.flat.protocol.html)
for login and fetching the user's entries supplemented by HTML screen-scraping
to get reading lists, entry content and comments.

## Items to Be Completed

1. ~~Reverse-engineer Dreamwidth's cookie-based session auth~~ DONE! The flat API
allows me to get a session cookie and use that for some requests, turning that session
id into the necessary cookies is pretty terrible.
2. ~~Call the [Mobile Reading Page](https://www.dreamwidth.org/mobile/read) and get the recent Reading List~~ DONE!
3. Fetch each page as format=light and scrape its content. IN PROGRESS!
4. Show a fuller entry page, with comments
5. Render more complex entry HTML
6. Compose a new entry
7. Compose a new comment
8. Better account settings management

## Screens

Here are some screenshots of work-in-progress:

![entries](etc/screenshots/entries.png "Entries") ![menu](etc/screenshots/menu.png "Menu") ![profile](etc/screenshots/profile.png "Profile")

## Building the Code

If you want to build this code, you'll need to:

1. Install [CocoaPods](https://cocoapods.org/)
2. Clone this code
3. Run `pod install` in the code source directory
4. Open the dreamwidth.xcworkspace file in XCode (**not** the dreamwidth/dreamwidth.xcodeproj)

## Ancient History

The original intention of this codebase was to serve as an implementation of the
Dreamwidth API written in Objective-C. My plan had been to include Dreamwidth integration
in another app that I work on, and this code was created as a sandbox to work on those
features. It's evolved over time.

The primary documentation for the API is part of the LiveJournal site; the same API
works for Dreamwidth.
