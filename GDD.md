# Hotel Rescue: Game Design Document

This document may or may not be up to date. Check for its latest update on the online repo or through the link below.

[hotel-rescue-rbx on GitHub](https://github.com/tristan-bonaobra/hotel-rescue-rbx)

## Introduction

`GDD.md` (short for "game design document") talks about all the what's and why's of Hotel Rescue in the form of an **autobiography**. This should tell you just about everything about the game as of its current state and why I thought it up that way. I realize that this sort of subverts what is expected of a file named `GDD.md`, which is often more forward-looking and less retrospective, but I figured that something industry standard would most quickly communicate the contents of the file.

I write this now because the design philosophy has been behind everything added to the game thus far and it's been bugging me. I figured that it counts as source code, and this _is_ open-source. Believe it or not, there's some real consideration behind this!

The recommended way of reading this is to plug it into an AI and talk about it. It's also for the rare type that still reads books!

## Where Can I Play?

As of writing this, there is currently no publicly playable version of the game on Roblox! The reason for this is to minimize any link between my IGN and my real-world identity for the sake of privacy. I could upload it on a throwaway account, but you wouldn't be able to play it anyway, unless you've somehow already given Roblox your biometrics for voice chat. [Creator Documentation](https://en.help.roblox.com/hc/en-us/articles/203313890-How-to-Publish-Games-on-Roblox)

To play, you'll have to set it up yourself with this [usage guide](README.md). If you do and your upload takes off, I'd be happy just knowing that others see the vision!

## Chapter I: The Game

This chapter talks about Hotel Rescue as a whole: what it is, what it was, and where it's going.

### What is Hotel Rescue?

Hotel Rescue is a Roblox game that takes a fresh spin on the popular "disaster survival" genre. Think [Natural Disaster Survival](https://www.roblox.com/games/189707/Natural-Disaster-Survival), [Survive the Disasters](https://www.roblox.com/games/18540115/Survive-The-Disasters), or [Survive the Evil Disasters](https://www.roblox.com/games/140113362796255/Survive-The-Evil-Disasters), but with a heroic twist: instead of simply surviving the earthquake in question, you must return to the rubble and bring NPCs to the safe zone, too!

The primary loop looks like this:

1. Wait for the story and disaster to play out.
2. Teleport to the map and search for the 30 NPCs.
3. Make good use of a wide selection of tools such as the [Super Pick](#super-pick) and [Pull Wrench](#pull-wrench) to move debris out of the way.
4. Work with other players to bring all the rescues back to the big, green finish line.
5. Use the points to purchase even more gear.

Be careful, though, as the NPCs may not be as super or smart as you!

### Inspiration and Early Experiments

Hotel Rescue is a game that I wanted to make for a very long time. I would play disaster games on Roblox and think, wouldn't it be interesting if you had to rescue people instead? It would mean actually interacting with the environment instead of simply dodging killbricks. It was a totally unfilled niche, except, somewhat, for games such as [Emergency Response: Liberty County](https://www.roblox.com/games/2534724415/Emergency-Response-Liberty-County) and [Blackhawk Rescue Mission 5](https://www.roblox.com/games/2916899287/Blackhawk-Rescue-Mission-5), which were really about a bunch of other things _besides_ rescue and disaster physics!

During early testing, I fell in love with the sheer grit of it. Most people would rather keep away from the rubble to avoid getting flung unless they had to stay and take shelter. Here we had a treacherous, destroyed environment that was not built for human navigation, and yet we are navigating it and squeezing through its tight spaces anyway, like the caves in [Minecraft](https://www.minecraft.net/en-us), [Terraria](https://store.steampowered.com/app/105600/Terraria/), and [Deep Rock Galactic](https://store.steampowered.com/app/548430/Deep_Rock_Galactic/). I always was interested in cave games.

The vision was there, but a few main problems tended to kill the idea multiple times before it could get started:

Firstly, what was "rescue" supposed to look like? I remember that the rescues were originally going to be other players that needed help escaping the wreckage before becoming rescuers themselves. That would've looked like upwards mobility in the form of trusses and climbable ropes from above. Naturally this gameplay loop meant burying the entirety of [Disaster Hotel](#disaster-hotel) inside a sinkhole to force upwards movement and battles against gravity. That was the state during early prototypes, and I found that large ground and ceiling parts would often tilt in a way that smothered the entire floor, making for awkward gameplay. What ultimately killed this approach, however, was the possibility that griefers could target one level in the building to destroy, permanently cutting off all further upward access.

Secondly, to simulate destruction, you needed a destructible environment. That must've been the biggest obstacle for me as I am not a builder. I remember taking an hour or two just for a basic, multi-story box-building. I was thinking of how the building was gonna break and where NPCs would spawn, as NPC spawn points would've been hardcoded at the time. The idea was that the building would be cloned and arranged in a procedurally generated city map among other prebuilt structures and road sections (think [Anarchy](https://www.roblox.com/games/315118476/Anarchy)). But then, the project would've been about procedurally generated cities, before the original idea could ever come to life. I was also still coming to terms with the new Roblox Studio and was frustrated that what used to be so simple is now hidden underneath layers of a constantly changing interface. That kind of technical friction is my biggest pain point as a creative.

Lastly, how could you make a rubble rescue game not laggy nor glitchy? If a lot of parts were unanchored throughout the course of a long rescue operation, there would be significant lag, glitching, and flinging all over the place. Anyone who has played [Natural Disaster Survival](https://www.roblox.com/games/189707/Natural-Disaster-Survival) would know what I'm talking about. Obviously, the parts had to be anchored, but then they also had to look like proper ruins. While testing destruction with that completed box-building, the first idea was to rotate parts at random to simulate wreckage. But I was eager to make the parts actually fall for the sake of "immersion", so the next idea was to raycast and teleport downwards. That didn't look good, so I tried unanchoring for a few seconds with added impulse. But who's to say it doesn't take more than a few seconds for the parts to reach the ground and settle? I was never happy with the results, and there was always another problem, so I gave up before I could figure it out.

About a year later I was brainstorming with AI about ways I'd go about running my own version of Roblox in a way that doesn't skyrocket server costs while running physics simulations for hundreds of parts. The first solution was to cap it at a dynamic framerate. The other was to actually anchor every part, only temporarily unanchoring when interacted with. Sound familiar? To help refine my theory at the time, I once again joined [Natural Disaster Survival](https://www.roblox.com/games/189707/Natural-Disaster-Survival) to observe the way parts moved around. It was then that the old idea for a disaster rescue game returned to bother me again, and all the pieces finally clicked. Thus was the birth of `tempUnanchor`, a simple yet highly central function that unanchors parts and only reanchors them after a few seconds of not being interacted with by the GM or players. And the test map? [Disaster Hotel](#disaster-hotel). Thus the name, Hotel Rescue. Let's also throw in `breakPart` into the mix, because I wanted the walls and floors to break into interactable pieces, not as one part that made large and ugly slopes. Finally, we had believable rubble! Everything broke through like a dam after that.

### Mid-2010s Developer's Lament

Remember when scripting meant adding a `.Touched` script inside a part, turning it red, and calling it a lava brick? Good times. I still proudly animate with welds like a real man. In fact, this was about the same approach I brought to this project at the beginning. `tempUnanchor` was originally just a script that was cloned inside parts that I wanted unanchored, which destroyed itself when its job was done. And I was hesitant to entertain this idea one last time because of a previous mental breakdown trying to find the button that makes players R6. Is this a lesson about perseverance and adaptability? Not really. I can't promise that I won't freak out again the next time the Roblox Studio interface shifts around. I think of [MikuMikuClub's](https://www.roblox.com/communities/2729347/MikuMikuClub#!/about) About:

> Roblox isn't a viable platform for stability nor "non-metaverse" games.

_(Miss you guys. More on the importance of first principles [later](#on-retro-aesthetics).)_

Eventually, though, I had to catch up. It just so happened that I'd be job hunting at the same time I'd work on Hotel Rescue. My stack as marketed is Postgres and Python but, here's the thing that I've been doing for at least 13 years, so I figured that maybe it would be of some value on my portfolio. I figured, however, that it can't be on my portfolio if it isn't on GitHub, and it can't be on GitHub until it was set up with Rojo, which it wasn't. Spending [three days](https://github.com/tristan-bonaobra/hotel-rescue-rbx/tree/refactor/rojo-restructure) turning the whole thing upside down with the help of AI before finally making the connection from VS Code all the way to Roblox Studio was the first step in becoming a modern Roblox developer for me. Hot take, but I thank AI for being that bridge.

### The Future of Hotel Rescue

Hotel Rescue is open-source. I think it is extremely unlikely that it would ever get noticed by the public, and even more unlikely that that would happen _and_ someone's copy of it takes off. But if it ever does happen, then I like to think that I'd be happy just contributing in some way to something, whatever that is. Such is the nature of open-source software. Open-source is the future!

At [AMD's booth](https://www.facebook.com/amdredteamph/posts/amd-is-here-at-the-1st-ai-philippine-expo-2026visit-the-amd-booth-and-experience/122172433244658437/) during the [AI Philippine Expo of 2026](https://www.linkedin.com/search/results/all/?keywords=%23iotconference2026), I witnessed an LLM go through an entire repo to fix one bug. I intend to use some form of that functionality in the future to audit my code, refining anything that looks shaky or prone to—trigger warning—deprecation.

Will this game ever be playable on mobile? No—I don't think so. There's just too much going on. Or, rather, there's a lot going on that just wouldn't work on mobile. Or, it could work on mobile, but I just don't need that kind of additional maintenance work. Sorry, economists, but the mobile market will have to sit this one out. Or, rather, I'll be the one missing out on the mobile market. [Fine by me!](#on-retro-aesthetics)

You might notice that Hotel Rescue uses semantic versioning that starts with a 1 (i.e. `v1.X.X`), implying a `v2.X.X`. You can expect that all versions will be starting with a 1, unless something happens and someone gives the game a complete makeover with a new lobby and a new island with brand-spanking-new [UIs, animations](https://www.youtube.com/watch?v=l3n3_w2mmz8), and... proximity prompts... in which case that 1 shall turn into a 2. I'd welcome any new ideas.

Here's to more physics!

## Chapter II: Gears and Economy

The gears in this chapter shall be sorted roughly according to the order in which the gears were created.

### Points Economy

Players join the server with 10 points. For rescuing an NPC, you earn 3 points—1 if they're unconscious. Though, some NPCs reward more:

| NPC Type | Reward |
| :--- | :--- |
| Unconscious (Any) | 1 Point |
| Conscious (Normal) | 3 Points |
| Conscious ([Panicked](#panicked-npcs) or [Dizzy](#dizzy-npcs)) | 5 Points |

Meanwhile, gears are priced according to standard tiers:

| Price Tier | Points | Gears |
| :--- | :--- | :--- | 
| Spawn | 0 Points | [Super Pick](#super-pick), [Pull Wrench](#pull-wrench), [Teddy Bear](#teddy-bear) |
| Starter | 10 Points | [Dog Treats](#dog-treats), [Gravity Coil](#gravity-coil), [Brickmobile](#brickmobile) |
| Standard | 30 Points | [Power Bell](#power-bell), [Rally Flag](#rally-flag), [Translocator](#translocator), [Freeze Ray](#freeze-ray) |

That is to say, it takes 4 good rescues to be able to purchase, say, a [Power Bell](#power-bell). Alternatively, you could purchase a starter gear right away, at the opportunity cost of choosing one starter gear over others and not being able to purchase a higher-tier gear until much later, at 10 good rescues. Still, this is the recommended option for most maps.

You could argue that since an unconscious survivor takes considerably more effort to retrieve, it should be worth as much or even more points. But the _point_ is to prevent players from skipping the "be careful" half of the game by simply pushing NPCs off a high ledge for free.

As an above-average player in terms of skill and experience I can consistently get between 10 and 15 out of the 30 NPCs each round. Of course the vast majority of players will not be anywhere as skilled as me, but the hope right now is that it would be balanced by having more players in the server. As for early playtests where there would often only be the playtester, c'est la vie.

### Recommended Purchases Per Map

This assumes that you are a new player that hasn't yet learned to [grapple](#pull-wrench). Feel free to ignore this chart, though, as the game is designed to be possible* with just the spawn gear.

| Map | Gear | Reason |
| :--- | :--- | :--- |
| [Disaster Hotel](#disaster-hotel) | [Dog Treats](#dog-treats) | Lots of small rooms that could be hiding NPCs. |
| [End of Roblox](#end-of-roblox) | [Gravity Coil](#gravity-coil) | Reach NPCs on roofs. |
| [Underground Base](#underground-base) | None (Save points) | If you can tear down the doors resourcefully using just the [Super Pick](#super-pick) and [Pull Wrench](#pull-wrench), and you know where the good spots are, then this map is perfectly doable without additional gear. |
| [Prison Panic](#prison-panic) | None (Save points) | This is an easy map with a lot of freebies. You can get a lot of value without purchasing gear. |
| [Robloxian High School](#robloxian-high-school) | [Gravity Coil](#gravity-coil) | Reach NPCs on high surfaces. |
| [Town of Robloxia](#town-of-robloxia) | [Dog Treats](#dog-treats) | Large map with a lot of structures means it might be harder to find NPCs. |

### Super Pick

| Icon | Details |
| :--- | :--- |
| <img src="./icons/SuperPick.png" width="120" alt="Super Pick"> | **Appearance**: A hammer with a yellow shaft and black handle. It shares the same model as the classic [Delete Tool](https://roblox.fandom.com/wiki/Catalog:Delete_Tool).<br>**Effect**: Breaks parts in half at each dimension greater than a threshold (currently 3 studs). If no dimension is greater than the threshold, or the part is otherwise incalculable (e.g. a truss, cylinder, or corner wedge), it is instead "crushed" into sand, clipping out of the map.<br>**Niche**: Many parts are welded to surrounding walls or are otherwise too big to pull as they are. Breaking down debris is often the first step to moving it out of the way.<br>**Cost**: 0 (Obtained by spawning). Breaking debris is a fundamental mechanic and the game is unplayable without it, especially on [Underground Base](#underground-base), where the entrance is literally blocked. |

I remember that I wanted there to be a clear visual indicator that a part was broken, otherwise you couldn't tell that the part in front of you had actually become four parts. A red dot at `mouse.Hit`? A subtle `SelectionBox`? A cracked decal? Eventually I settled for random tint. I figured that the discoloration added to the destruction aesthetic while looking colorful and whimsical. After some experimentation I decided that simply changing the value slider looked better than changing hue, which looked like puke.

As for implementation, simple enough—just use the existing `breakPart` function. Of course, there was the question of what counts as parts you were allowed to break—we can't have players breaking the spawn island, accidentally or not. The core logic is that the part had to be inside `CurrentMap` which is a line of thought that would eventually run through almost every other gear that would be added.

### Pull Wrench

| Icon | Details |
| :--- | :--- |
| <img src="./icons/PullWrench.png" width="120" alt="Pull Wrench"> | **Appearance**: A grey crescent wrench. It shares the same model as the classic [Configuration Tool](https://roblox.fandom.com/wiki/Catalog:Configuration_Tool).<br>**Effect**: Ties a `SpringConstraint` between the user's `HumanoidRootPart` and the target surface. Upon disconnecting, it applies a small impulse to the player towards the other end of the "grapple".<br>**Niche**: It is the primary tool for tearing down debris, pulling unconscious NPCs to the finish line. In more advanced playthroughs, it is also the primary means of vertical mobility. <br>**Cost**: 0 (Obtained by spawning). While the game is theoretically possible without the ability to pull, it is far too central to the game's skill expression to ever be unavailable. It would also be impossible to retrieve unconscious NPCs. |

From a game design standpoint, the Pull Wrench is arguably the single most important gear in the game. I like to think of it as the player's "hands", which, given everything humans have done with their hands, you can imagine is quite significant. And it is so simple, too.

The first "tech" playtesters would often discover is using the Pull Wrench to pull a small part up through their feet and jumping on it, creating a momentum loop that results in them flying high into the air. Some tricks that I discovered myself during playtesting include hanging from a wall to break through a high window, attaching to conscious NPCs before slowly and safely lowering them from a ledge, and even reaching the main island from spawn early using a precise "slingshot" combo with the [Translocator](#translocator). Rest assured, these techniques are all features, not bugs, and I have no intention of ever removing them. Truly a Swiss Army knife! I only wonder what [other players](#designing-for-speedrunners) will discover about it.

As for implementation, I remember that I had to create an exception for `tempUnanchor` so that parts didn't reanchor mid-pull: wait until the unanchored part in question no longer contained an `Attachment`. A bandage solution? Sure, but it's lasted this long. The properties of the `SpringConstraint` were deliberately tuned to feel powerful and responsive, plus, in case you haven't noticed, it was designed to look like a rubber band!

### Teddy Bear

| Icon | Details |
| :--- | :--- |
| <img src="./icons/TeddyBear.png" width="120" alt="Teddy Bear"> | **Appearance**:<br>**Effect**:<br>**Niche**:<br>**Cost**: |

### Dog Treats

| Icon | Details |
| :--- | :--- |
| <img src="./icons/DogTreats.png" width="120" alt="Dog Treats"> | **Appearance**:<br>**Effect**:<br>**Niche**:<br>**Cost**: |

### Power Piston

| Icon | Details |
| :--- | :--- |
| <img src="./icons/PowerPiston.png" width="120" alt="Power Piston"> | **Appearance**:<br>**Effect**:<br>**Niche**:<br>**Cost**: |

### Power Bell

| Icon | Details |
| :--- | :--- |
| <img src="./icons/PowerBell.png" width="120" alt="Power Bell"> | **Appearance**:<br>**Effect**:<br>**Niche**:<br>**Cost**: |

### Wooden Platform

| Icon | Details |
| :--- | :--- |
| <img src="./icons/WoodenPlatform.png" width="120" alt="Wooden Platform"> | **Appearance**:<br>**Effect**:<br>**Niche**:<br>**Cost**: |

### Gravity Coil

| Icon | Details |
| :--- | :--- |
| <img src="./icons/GravityCoil.png" width="120" alt="Gravity Coil"> | **Appearance**:<br>**Effect**:<br>**Niche**:<br>**Cost**: |

### Rally Flag

| Icon | Details |
| :--- | :--- |
| <img src="./icons/RallyFlag.png" width="120" alt="Rally Flag"> | **Appearance**:<br>**Effect**:<br>**Niche**:<br>**Cost**: |

### Translocator

| Icon | Details |
| :--- | :--- |
| <img src="./icons/Translocator.png" width="120" alt="Translocator"> | **Appearance**:<br>**Effect**:<br>**Niche**:<br>**Cost**: |

### Brickmobile

| Icon | Details |
| :--- | :--- |
| <img src="./icons/Brickmobile.png" width="120" alt="Brickmobile"> | **Appearance**:<br>**Effect**:<br>**Niche**:<br>**Cost**: |

### Freeze Ray

| Icon | Details |
| :--- | :--- |
| <img src="./icons/FreezeRay.png" width="120" alt="Freeze Ray"> | **Appearance**:<br>**Effect**:<br>**Niche**:<br>**Cost**: |

## The NPCs

### NPC Behavior

### The Design of NPCs

### NPC Personalities

#### Panicked NPCs

#### Clingy NPCs

#### Impatient NPCs

#### Dizzy NPCs

## Chapter IV: The World

### How Maps are Selected and Processed

### Disaster Hotel

### End of Roblox

### Underground Base

### Prison Panic

### Robloxian High School

### Town of Robloxia

### The Spawn Island

### The Win Zone

## Chapter V: The Music

## The Point

### Unlocking Roblox a Different Way

> Roblox characters don't really have hands, and yet, in disaster games, they are often surrounded by parts that are just begging to be grabbed. Tools such as the Pull Wrench unlock that whole new dimension in a physics engine where it should've made sense from the start.

> The popularity of games such as [VR Hands](https://www.roblox.com/games/4832438542/VR-Hands-v3-2), [Surgeon Simulator](https://store.steampowered.com/app/233720/Surgeon_Simulator/), and [GIRP](https://foddy.net/blog/2011/03/girp/) hint at the universal appeal of the near-direct extension of basic, biological human agency and sheer physics.

### On "Retro" Aesthetics

(One of the primitives is that Roblox is a PC game.)

### On Player "Freedom"

### Designing for Speedrunners

### The Cutting Room Floor

This should be a table.

#### Trusses

## Authors

_Tristan Bonaobra (Creator of Hotel Rescue)_