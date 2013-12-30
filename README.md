# Warehouse Keeper

This repository is a simple recreation of [Sokoban](http://en.wikipedia.org/wiki/Sokoban) using [Ruby Gosu](http://www.libgosu.org/).  It makes use of [the "Original & Extra" levels](http://www.sourcecode.se/sokoban/levels) and the amazing free tileset [PlanetCute](http://www.lostgarden.com/2007/05/dancs-miraculously-flexible-game.html).

## Process

I think the process of how this repository reached its current from is worth discussing.

It got started [a good friend](https://github.com/piisalie) and myself built the first working version one day, just to get a feel for working with Ruby Gosu.  To a player, that version would feel pretty close to the game it is today, but the interface code was very thrown together.

I decided to refactor what we had built, but I wanted to use some heavy restraints to keep myself from over building it.  These are the rules I used:

* Only extract systems for core game needs that seem almost universally applicable
* Keep the maximum class size around 100 lines of code

These weren't super rigid limits.  Obviously the needs of a game like Sokoban are different from a 3D first person shooter.  I'm mainly focused on games that show a few screens and primarily respond to user input.

If you look, you'll also find a couple of classes with a hair over 100 lines.  I treated this at a soft limit where I started asking myself hard questions when it was reached.  ("Do I absolutely need to add this new thing?" and "Is there another component hiding in here?" for example.)  I do feel this kept me from building in too much.

## The needs of the Game

Because I followed this process so closely, I feel I've landed on an almost minimal set of needs for what I would need to build these types of games with Ruby Gosu.  That's why I think this repository may be useful to others who want to try similar things.

The main components are:

* [A control mapper](#holding-down-keys)
* [A screen manager](#changing-the-view)
* [An animation tool](#the-flow-of-time)

### Holding Down Keys

In our initial version of the game you couldn't just hold down the left arrow.  If you wanted to move left eight times, you needed to press the key eight times.  I'm sure you can imagine how annoying that got when we were playing or testing.

When I went to fix this, I realized that mapping keys (or controls in general) will pretty much always need to happen in a game.  You need to be able to say which key does what and you often want to be able to specify variations like whether or not a key can be held.

This led to the first general extraction:  a [`KeyMap`](https://github.com/JEG2/warehouse_keeper/blob/master/lib/warehouse_keeper/key_map.rb).  This is a super simple mapping of key codes to some code to run when they are pressed.

I resisted adding several features to this class, because this game didn't need them, but I could see other games needing to address concerns like:

* The use of modifier keys
* Globally available keystrokes added to screen local mappings
* Dynamically altering key mappings

### Changing the View

Originally, I couldn't imagine a minimal game needing to show more than a level screen.  While our early versions did just that, it's not too ideal.  It makes it hard to keep track of which level you're on, unless you incorporate some text into the level screen and that's [a different challenge](#what-i-still-want).

Also, what do you do when the game ends?  Just quit?  Bigger games may need things like menus.  It goes on and on.

You need some way to be able to switch out the screen that the user is currently viewing.  Again, I took about the most basic approach imaginable here.  There's a trivial [`ScreenManager`](https://github.com/JEG2/warehouse_keeper/blob/master/lib/warehouse_keeper/screen_manager.rb) that manages a list of screens and can activate one from that list as needed.  Those screens inherit from a base [`Screen`](https://github.com/JEG2/warehouse_keeper/blob/master/lib/warehouse_keeper/screen.rb) class to gain access to a few hooks and helper methods.

I could definitely see this tool being expanded in several ways:

* You may want to reuse some screens instead of recreating them each time
* I can see a big need for dialog-like functionality in many games
* There's probably a need for screens-inside-screens in a lot of games
* The helpers provided by the base `Screen` are a sea of infinite possibilities

### The Flow of Time

Another thing I couldn't imagine my simple game needing was animation.  I thought redrawing the changed board would be enough.  Here's just one thing you see when you do that though:  you finish a level and find yourself at the start of the next level before you even have time to notice the final piece in its place.

Controlling how things appear over time in game terms is animation.  Adding a simple [`Animation`](https://github.com/JEG2/warehouse_keeper/blob/master/lib/warehouse_keeper/animation.rb) tool allowed me to do traditional things like [fade out a title](https://github.com/JEG2/warehouse_keeper/blob/master/lib/warehouse_keeper/announce_screen.rb#L20) but also just [delay the flow of time](https://github.com/JEG2/warehouse_keeper/blob/master/lib/warehouse_keeper/play_screen.rb#L89).

The main thing I debated adding here was simple helpers for things like delays or repeating tasks.  These tricks are already doable with the code I built, but the API could be smoothed out a little for them.  I didn't have a big enough need here to justify it, but I could see someone wanting to do these things in the future.

## What I Still Want

This game does some super crude [scaling of the tileset down to an arbitrary window size](https://github.com/JEG2/warehouse_keeper/blob/master/lib/warehouse_keeper/play_screen.rb#L70) that was chosen for fitting some maps well.  Even that was a total nightmare to get right.  In hindsight, I should have just shrank the tiles down to a workable fixed size and saved myself a big headache.

That said, if you want to remotely attempt to make use of the space available on a player's monitor, you will have to do something like this.  For that, I would sure love a tool that helps me handle the trickier parts.  I believe Gosu provides enough of what you need to get this right.

Another thing I really struggled with in Gosu was working with text.  It's easy to get the height of some arbitrary string, but getting the width is trickier. I think I found a way to do it with `Gosu::Image.from_text()`, but I haven't had time to dig into this yet.

Knowing the dimensions of some text is very helpful if you want to combine it with the use of sprites, at least how I do things.  Gosu does have a relative drawing method that can help with some of these cases.  In the end, I think I just need to play with these options more to figure this stuff out.

## The Testing Balance

Confession time:  I didn't test everything in this code.  I don't even think it's right to do so.

If I tried to test [PlayScreen](https://github.com/JEG2/warehouse_keeper/blob/master/lib/warehouse_keeper/play_screen.rb) for example, I would probably just end up mocking out most of the interface calls.  In doing so, I bet I would defeat 90% or more of the value in having it covered by tests.  The game tools and engine it uses are covered and that feels like the proper amount of paranoia to employ, at least to me.

I think there's definitely some balance to find of what's worth testing and what's not, in interface heavy applications like games, even if you don't agree with the specific one I chose.
