# Prototype

Things that need to be done for an initial release.

## Taskbar internally needs the following:

- list (object, the main thing, will constantly be radically changed as needed)
- startMenu (this will be a custom object / reference or something, not sure exactly, don't worry about it yet)
- programs (array of objects, the programs that have been added)
- divider (an object that acts as a space to make the Taskbar stuff line up properly)
- items (array of objects, the items that have been added)
- clock (object, a reference to the main clockProgram)
  - Rewrite ClockProgram (and others that auto-add themselves to Taskbar) to not auto-add themselves to the Taskbar?

### :AddItem(item)

Needs to add item to items array, then rebuild the list object from that point, resizing the divider as needed.

### :AddProgram(program)

Adds program to programs array, then rebuilds the list object from that point, resizing divider as needed.

### :RebuildList()

(Internally used?) From specified point (in programs or items), take everything past that point out of the list. Then resize the divider. Then take everything from that point and put it back in (leaving the divider out if it is too small).

### :ResizeDivider()

(Internally used?) Goes through each array and object, getting its width, figures out the width of the divider by screen width - everything internal's width, and assigns this to the divider object. If this is 0 or less, the divider is completely removed from the list.

## StartMenu

Need to create a start menu object that can be opened from the Taskbar.

- [ ] Search files
- [ ] Most used programs
- [ ] Programs (divided into categories)

I'm basically recreating the menu object of LoveFrames without the right-click ? See if I can use that for a lot of this, because I should be doing that.

# Feature

Things that should be done for a more complete experience.

## Intro / Story Opening

Hello, <insert name here>! You have recently been hired at <company name here>.

At <company name here>, we are proud to continue a long-held tradition of <something something something>. We strive for excellence in our industry, and an important part of that is having plenty of office drones to fill our big, expensive buildings with.

We at <company name here> welcome you, <insert name here>. Please remember to always stay on task at your computer and avoid slacking off and taking breaks! Emails usually come in pretty quickly, and it is vital you respond to each one appropriately.

Sincerely, <some generated name>, <some official title>.

## Email sent to you a half hour after you fail to get an email done on time / get one wrong

Dear <insert name here>, it has come to our attention that you have failed to [respond to an email within a reasonable amount of time | adequately respond to an email in a satisfactory manner].

At <company name here>, we pride ourselves on efficient and productive work at all times. Please remember, all emails must be responded to with 1 (one) hour of their send date, and must be correctly responded to, or you will lose points on your productivity score. If your productivity score goes too low, you will be fired, and replaced with a more competent employee.

[Please remember to respond to emails on time. | Please remember to search the email text for "lorem" or "ipsum" and reply appropriately. Lorem emails should be marked Lorem. Ipsum emails should be marked Ipsum.]

## Galactose (game)

Galactose is a game where you play as the leader of a fleet of space cows under oppression from the horrid Farmer Empire. (Strategy game, simple clone of Galcon.)

- [ ] Runs in its own program window (of course).
- [ ] Has a launch screen with a title / art. Introduces the game concept and story. Press a key to start.
- [ ] Level 1 is random generation of planets, you start with ten, they start with one.
- [ ] Each level, you get one less starting planet, they get one more.
- [ ] Need to develop simple AI. Needs to target based on size of targets / distance / power of targets.
- [ ] I need to pay someone to develop simple pixely graphics for this. What's a reasonable price??

# Polish

Things that are not strictly needed.

## Shortcut keys

Ctrl+L / Ctrl+I for marking email Lorem or Ipsum.

Alt opens start menu.

## Icons for everything

Every program should have an icon on its icon in the Taskbar, as well as its own open windows, and its entry in the computer's programs.

## Office name generator.

You have been employed at prefix name suffix.

Assign these values weights and use lume.weightedchoice

### Prefixes
- Cyanide
- Simtek
- Civet
- Salvak
- TechnoFrog
- Fake

### Names
- Software
- Hardware
- Medical
- Enforcement
- Cola

### Suffixes
- LTD
- Incorporated
- Limited
- STD
- Inc.
- Solutions
