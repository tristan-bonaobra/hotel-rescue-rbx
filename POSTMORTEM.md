# Hotel Rescue: Postmortem

The recommended way of reading this is to plug it into an AI and talk about it. It's also for the rare type that still reads books!

This document is for players first, nerds second. I shall start with the what's before the why's.

This document may or may not be up to date. Check for its latest update on the online repo or through the link below.

[hotel-rescue-rbx on GitHub](https://github.com/tristan-bonaobra/hotel-rescue-rbx)

## Introduction

`POSTMORTEM.md` talks about all the features and design decisions behind Hotel Rescue in the form of a **retrospective**. This should tell you just about everything about the game as of its current state and why I thought it up that way.

I write this now because the design philosophy has been behind everything added to the game thus far and it's been bugging me. I figured that it counts as source code, and this _is_ open-source. Believe it or not, there's some real consideration behind this!

## Where Can I Play?

As of writing this, there is currently no publicly playable version of the game on Roblox! The reason for this is to minimize any link between my IGN and my real-world identity for the sake of privacy. I could upload it on a throwaway account, but you wouldn't be able to play it anyway, unless you've somehow already given Roblox your biometrics for voice chat. [Creator Documentation](https://en.help.roblox.com/hc/en-us/articles/203313890-How-to-Publish-Games-on-Roblox)

To play, you'll have to set it up yourself with this [usage guide](README.md). If you do and your upload takes off, I'd be happy just knowing that others see the vision!

## Chapter I: The Game

### What is Hotel Rescue?

Hotel Rescue is a Roblox game that takes a fresh spin on the popular "disaster survival" genre. Think [Natural Disaster Survival](https://www.roblox.com/games/189707/Natural-Disaster-Survival), [Survive the Disasters](https://www.roblox.com/games/18540115/Survive-The-Disasters), or [Survive the Evil Disasters](https://www.roblox.com/games/140113362796255/Survive-The-Evil-Disasters), but with a heroic twist: instead of simply surviving the earthquake in question, you must return to the rubble and bring NPCs to the safe zone, too!

The primary loop looks like this:

1. Wait for the story and disaster to play out.
2. Teleport to the map and search for the 30 NPCs.
3. Make good use of a wide selection of tools such as the [Super Pick](#super-pick) and [Pull Wrench](#pull-wrench) to move debris out of the way.
4. Work with other players to bring all the rescues back to the big, green finish line.
5. Use the points to purchase even more gear.

Be careful, though, as the NPCs may not be as super or smart as you!

### Opening Sequence and In-Game Lore

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
| Substandard | 20 Points | [Power Piston](#power-piston), [Wooden Platform](#wooden-platform) |
| Standard | 30 Points | [Power Bell](#power-bell), [Rally Flag](#rally-flag), [Translocator](#translocator), [Freeze Ray](#freeze-ray) |

That is to say, it takes 4 good rescues to be able to purchase, say, a [Power Bell](#power-bell). Alternatively, you could purchase a starter gear right away, at the opportunity cost of choosing one starter gear over others and not being able to purchase a higher-tier gear until much later, at 10 good rescues. Still, this is the recommended option for most maps.

| Map | Recommended Gear | Reason |
| :--- | :--- | :--- |
| [Disaster Hotel](#disaster-hotel) | [Dog Treats](#dog-treats) | Lots of small rooms that could be hiding NPCs. |
| [End of Roblox](#end-of-roblox) | [Gravity Coil](#gravity-coil) | Reach NPCs on roofs. |
| [Underground Base](#underground-base) | None (Save points) | If you can tear down the doors resourcefully using just the [Super Pick](#super-pick) and [Pull Wrench](#pull-wrench), and you know where the good spots are, then this map is perfectly doable without additional gear. |
| [Prison Panic](#prison-panic) | None (Save points) | This is an easy map with a lot of freebies. You can get a lot of value without purchasing gear. |
| [Robloxian High School](#robloxian-high-school) | [Gravity Coil](#gravity-coil) | Reach NPCs on high surfaces. |
| [Town of Robloxia](#town-of-robloxia) | [Dog Treats](#dog-treats) | Large map with a lot of structures means it might be harder to find NPCs. |

The above chart assumes that you are a new player that hasn't yet mastered the [grapple](#pull-wrench). Feel free to ignore it, though, as the game is designed to be possible* with just the spawn gear.

You could argue that since an unconscious survivor takes considerably more effort to retrieve, it should be worth as much or even more points. But the _point_ is to prevent players from skipping the "be careful" half of the game by simply pushing NPCs off a high ledge for free.

As an above-average player in terms of skill and experience I can consistently get between 10 and 15 out of the 30 NPCs each round. Of course the vast majority of players will not be anywhere as skilled as me, but the hope right now is that it would be balanced by having more players in the server. As for early playtests where there would often only be the playtester, c'est la vie.

### Super Pick

| Icon | Details |
| :--- | :--- |
| <img src="./icons/SuperPick.png" width="120" alt="Super Pick"> | **Appearance**: A hammer with a yellow shaft and black handle. It shares the same model as the classic [Delete Tool](https://roblox.fandom.com/wiki/Catalog:Delete_Tool).<br>**Effect**: Breaks parts in half at each dimension greater than a threshold (currently 3 studs). If no dimension is greater than the threshold, or the part is otherwise incalculable (e.g. a truss, cylinder, or corner wedge), it is instead "crushed" into sand, clipping out of the map. If the Super Pick misses or otherwise tries to interact with an invalid part, a windy swing can be heard, similar to the [Linked Sword](https://www.roblox.com/catalog/125013769/Linked-Sword).<br>**Niche**: Many parts are welded to surrounding walls or are otherwise too big to pull as they are. Breaking down debris is often the first step to moving it out of the way.<br>**Cost**: 0 (Obtained by spawning). Breaking debris is a fundamental mechanic and the game is unplayable without it, especially on [Underground Base](#underground-base), where the entrance is literally blocked. |

I remember that I wanted there to be a clear visual indicator that a part was broken, otherwise you couldn't tell that the part in front of you had actually become four parts. A red dot at `mouse.Hit`? Too vague. A subtle `SelectionBox`? Varies with lighting. A cracked decal? Too ugly. Eventually I settled for random tint. I figured that the discoloration added to the destruction aesthetic while looking colorful and whimsical. After some experimentation I decided that simply changing the value slider looked better than changing hue, which looked like puke.

As for implementation, simple enough—just use the existing `breakPart` function. Of course, there was the question of what counts as parts you were allowed to break—we can't have players breaking the spawn island, accidentally or not. The core logic is that the part had to be inside `CurrentMap` which is a line of thought that would eventually run through almost every other gear that would be added.

### Pull Wrench

| Icon | Details |
| :--- | :--- |
| <img src="./icons/PullWrench.png" width="120" alt="Pull Wrench"> | **Appearance**: A grey crescent wrench. It shares the same model as the classic [Configuration Tool](https://roblox.fandom.com/wiki/Catalog:Configuration_Tool).<br>**Effect**: Ties a `SpringConstraint` between the user's `HumanoidRootPart` and the target surface. Upon disconnecting, it applies a small impulse to the player towards the other end of the "grapple".<br>**Niche**: It is the primary tool for tearing down debris, pulling unconscious NPCs to the finish line. In more advanced playthroughs, it is also the primary means of vertical mobility. <br>**Cost**: 0 (Obtained by spawning). While the game is theoretically possible without the ability to pull, it is far too central to the game's skill expression to ever be unavailable. It would also be impossible to retrieve unconscious NPCs. |

From a game design standpoint, the Pull Wrench is arguably the single most important gear in the game. I like to think of it as the player's "hands", which, given everything humans have done with their hands, you can imagine is quite significant. And it is so simple, too.

The first "tech" playtesters would often discover is using the Pull Wrench to pull a small part up through their feet and jumping on it, creating a momentum loop that results in them flying high into the air. Some tricks that I discovered myself during playtesting include hanging from a wall to break through a high window, attaching to conscious NPCs before slowly and safely lowering them from a ledge, slingshotting to the top of [Hotel Rescue](#what-is-hotel-rescue), and even reaching the main island from spawn early using a precise "slingshot" combo with the [Translocator](#translocator). Rest assured, these techniques are all features, not bugs, and I have no intention of ever removing them. I only wonder what [other players](#designing-for-speedrunners) will discover about it.

As for implementation, I remember that I had to create an exception for `tempUnanchor` so that parts didn't reanchor mid-pull: wait until the unanchored part in question no longer contained an `Attachment`. A bandage solution? Sure, but it's lasted this long. The properties of the `SpringConstraint` were deliberately tuned to feel powerful and responsive, plus, in case you haven't noticed, it was designed to look like a rubber band!

### Teddy Bear

| Icon | Details |
| :--- | :--- |
| <img src="./icons/TeddyBear.png" width="120" alt="Teddy Bear"> | **Appearance**: A yellowish-brown teddy bear. It shares the same model, animations, and sounds as the [Teddy Bloxpin](https://www.roblox.com/catalog/12848902/Teddy-Bloxpin) and [Teddy Trap](https://www.roblox.com/catalog/12890798/Teddy-Trap).<br>**Effect**: Commands nearby NPCs to start following the player, including jumps. If all nearby NPCs are already following a player, they are instead commanded to stop. If no NPCs are nearby, the player instead hugs the Teddy Bear, and a squeak can be heard. Following NPCs have a delayed reaction time and will keep a respectable distance from the player, unless they are [Clingy](#clingy-npcs). When commanding, a speech bubble appears above the player, saying either _"Follow me!"_ or _"Stay here!"_<br>**Niche**: Given the objective of the game, the Teddy Bear serves as the primary win condition.<br>**Cost**: 0 (Obtained by spawning). Should it ever become unavailable, the alternative would be painstakingly pulling heavy NPCs by rope. |

In case you missed it, the survivor in the opening dialog cries for their teddy bear after the disaster, hinting at its function. I find it funny funny that when you try to tell a [Clingy](#clingy-npcs) NPC to stop following, the player character will repeatedly exclaim _"Stay here!_ to no effect.

What it really does is clone a script called `NpcFollowScript` into the NPC, which other things in the game can check for and sometimes remove, like the [Brickmobile](#brickmobile) upon mounting. It uses the convenient and therefore deprecated service `Chat` for speech bubbles and I remember that I wanted it to have `Enum.ChatColor`, but it no longer worked so I settled for emojis, which then also broke when I migrated the project to Rojo. Might fix that soon.

### Dog Treats

| Icon | Details |
| :--- | :--- |
| <img src="./icons/DogTreats.png" width="120" alt="Dog Treats"> | **Appearance**: A bag of dog food labelled, _"Sacred Snack's Dog, 8kg"_. Despite the labelled weight, it is tiny and appears no heavier than a few pounds. It has a crimped top seal, blue and yellow color blocking, and a white cartoon dog sitting in a red bowl and wearing a crown with its tongue out. The original model was uploaded by [dgonlinebr on Sketchfab](https://sketchfab.com/3d-models/sacred-snacks-dog-3d-f2aa252f7f444f42812335e15f40d72a).<br>**Effect**: Summons a dog that runs and bunnyhops straight toward the nearest NPC, often into walls and holes in the ground. It prioritizes high-value, "undiscovered" conscious NPCs, ignoring others such as rescued, follower, mounted, and unconscious NPCs.<br>**Niche**: It saves time locating NPCs in maps where it would otherwise not be as straightforward, such as [Disaster Hotel](#disaster-hotel), which has a lot of rooms that could be hiding NPCs. <br>**Cost**: 10 (Can be purchased immediately). Not every map is a Dog Treats map, but when it is, it is often inconvenient not to have it. |
| <img src="./icons/Dog.png" width="120" alt="Dog"> | The dog itself is very small, at only about 2 studs long. It is reddish brown and tilts its head towards its target, indicating whether they're currently above, below, or in front of the player. It runs slightly slower than a player that is [rallied](#rally-flag) but much faster than a player walking at normal speed. It is gear-attachable, which means you can put, say, a [piston](#power-piston) on it, if for some reason you need to do that. As far as I know, it is the [dog morph used in Robloxville](https://roblox.fandom.com/wiki/Player:Playrobot/Robloxaville?file=Robloxville.png) and therefore any other game that used [Morph Magic](https://www.reddit.com/r/roblox/comments/1smsiar/youre_not_an_og_roblox_player_if_you_dont_know/), such as, in fact, the original [Welcome to the Town of Robloxia](https://roblox.fandom.com/wiki/Player:1dev2/Welcome_to_the_Town_of_Robloxia%E2%84%A2). Is it not fitting that it got a major buff when it came home? |

I remember using the sound of leaves rustling to simulate the sound of treats shuffling inside a bag. I also remember giving the thing a cooldown so that players don't relentlessly spawn a multi-part model into workspace.

It was always going to be a dog, even during the early prototypes. That's how I imagined it, like real life search dogs. Initially I figured that it added roleplay and realism and a little bit of cuteness that the dog would walk up to sleeping NPCs on the field, and crying NPCs in the response scene. That was until [v1.3.0](https://github.com/tristan-bonaobra/hotel-rescue-rbx/releases/tag/v1.3.0) saw a massive overhaul of the dog specifically for [Town of Robloxia](#town-of-robloxia), which was a map far too large to have any time for "roleplay". I'd say, the new roleplay now is a highly energetic dog.

### Power Piston

| Icon | Details |
| :--- | :--- |
| <img src="./icons/PowerPiston.png" width="120" alt="Power Piston"> | **Appearance**: A spring platform with a wide red top and a black base, connected by a thick grey coil. The top surface is studded. While the gear itself is a cardboard box (implying that the piston comes out of the box), the icon is of the piston itself.<br>**Effect**: Summons a piston pushing outwards from the target surface using a `PrismaticConstraint`. The motor is heard only briefly unless the piston's path is blocked or it is otherwise under stress, in which case it whirs loudly and smoke appears.<br>**Niche**: Pushes heavy debris and creates a raised platform to land on or jump from.<br>**Cost**: 20. I consider it less valuable because I personally don't use it often when the [Power Bell](#power-bell) can push debris more flexibly and the [Pull Wrench](#pull-wrench) already safely lowers NPCs for free. |

I think the Power Piston was really the first instance of a perfectly over-engineered feature in Hotel Rescue. Did you know that the whole structure of it is hardcoded? I really wanted there to be some indicator that the piston was under stress, and I thought of how a blender sounds when it doesn't like what it's blending. Turns out that involves a lot of math so I had to get help from AI. I remember the absolute spaghetti of it where that was handled by a script cloned not into the piston but into the sound inside the base specifically. The sounds took a lot of fine-tuning to not drive anyone absolutely mad. I believe the 50-stud `RolloffMaxDistance` standard for gear sounds really started with the Power Piston. It is also the reason the [Power Bell](#power-bell) exists!

I remember that the piston would get stuck a lot, which is why I created the [Power Bell](#power-bell) just to loosen up debris for it to push. Ironically that gear would overshadow it. Initially I made the piston simply unanchor parts that it touched, but then it would be stopped anyway by an anchored part behind the part immediately in front of it. So I made it a large, invisible hitbox instead.

I remember that it used to be a lot longer because I wanted it to be able to push down walls from the opposite side of the room, but then NPCs weren't able to survive a fall from it if it were placed vertically. Right now the pushing-down-walls tech is mostly possible by attaching it to a [Rally Flag](#rally-flag), and it's weird to have to rely on another gear for a basic, expected function.

The Power Piston is really an unfortunate case of a gear being balanced solely for [Disaster Hotel](#disaster-hotel), specifically during the early days where the game was not as matured and tech was yet to be discovered, because even today it's kinda useless even on that map. I remember a single scenario where an unconscious NPC was trapped in the air underneath the hotel and needed a piston to be pushed out, but even then it was inconsistent because the NPC kept slipping off the platform. That resulted in a feature where it would actually teleport unconscious NPCs on top of it, though this has since been removed for reasons I can't remember. If I had to guess, it was probably glitchy physics jank. Nowadays I'd simply change the material of the surface to something with more friction.

As of writing this, I think the Power Piston is due for a rework. I thought about making it adjustable for a while but figured that it would feel better and more "straightforward" if it were simply the perfect length instantly each time. Well, it's starting to look like there isn't a "perfect length". Here's to versatility?

### Power Bell

| Icon | Details |
| :--- | :--- |
| <img src="./icons/PowerBell.png" width="120" alt="Power Bell"> | **Appearance**: A smooth, yellow bell. The normally wooden handle is also smooth and yellow.<br>**Effect**: Knocks back all nearby parts and NPCs, creating a purple shockwave. <br>**Niche**:<br>**Cost**: |

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

## Chapter III: The NPCs

### NPC Designs

### NPC Behaviors

### NPC Personalities

#### Panicked NPCs

#### Clingy NPCs

#### Impatient NPCs

#### Dizzy NPCs

## Chapter IV: Environment and Music

### Locations

#### Disaster Hotel

#### End of Roblox

#### Underground Base

#### Prison Panic

#### Robloxian High School

#### Town of Robloxia

#### The Spawn Island

#### The Win Zone

### Music

#### Urban Descent

#### Groundworks Complex

#### Nikkocity

## Chapter V: Development History and Design Philosophy

### Inspiration and Early Experiments

Hotel Rescue is a game that I wanted to make for a very long time. I would play disaster games on Roblox and think, wouldn't it be interesting if you had to rescue people instead? It would mean actually interacting with the environment instead of simply dodging killbricks. It was a totally unfilled niche, except, somewhat, for games such as [Emergency Response: Liberty County](https://www.roblox.com/games/2534724415/Emergency-Response-Liberty-County) and [Blackhawk Rescue Mission 5](https://www.roblox.com/games/2916899287/Blackhawk-Rescue-Mission-5), which were really about a bunch of other things _besides_ rescue and disaster physics!

During early testing, I fell in love with the sheer grit of it. Most people would rather keep away from the rubble to avoid getting flung unless they had to stay and take shelter. Here we had a treacherous, destroyed environment that was not built for human navigation, and yet we are navigating it and squeezing through its tight spaces anyway, like the caves in [Minecraft](https://www.minecraft.net/en-us), [Terraria](https://store.steampowered.com/app/105600/Terraria/), and [Deep Rock Galactic](https://store.steampowered.com/app/548430/Deep_Rock_Galactic/). I always was interested in cave games.

The vision was there, but a few main problems tended to kill the idea multiple times before it could get started:

Firstly, what was "rescue" supposed to look like? I remember that the rescues were originally going to be other players that needed help escaping the wreckage before becoming rescuers themselves. That would've looked like upwards mobility in the form of trusses and climbable ropes from above. Naturally this gameplay loop meant burying the entirety of [Disaster Hotel](#disaster-hotel) inside a sinkhole to force upwards movement and battles against gravity. That was the state during early prototypes, and I found that large ground and ceiling parts would often tilt in a way that smothered the entire floor, making for awkward gameplay. What ultimately killed this approach, however, was the possibility that griefers could target one level in the building to destroy, permanently cutting off all further upward access.

Secondly, to simulate destruction, you needed a destructible environment. That must've been the biggest obstacle for me as I am not a builder. I remember taking an hour or two just for a basic, multi-story box-building. I was thinking of how the building was gonna break and where NPCs would spawn, as NPC spawn points would've been hardcoded at the time. The idea was that the building would be cloned and arranged in a procedurally generated city map among other prebuilt structures and road sections (think [Anarchy](https://www.roblox.com/games/315118476/Anarchy)). But then, the project would've been about procedurally generated cities, before the original idea could ever come to life. I was also still coming to terms with the new Roblox Studio and was frustrated that what used to be so simple is now hidden underneath layers of a constantly changing interface. That kind of technical friction is my biggest pain point as a creative.

Lastly, how could you make a rubble rescue game not laggy nor glitchy? If a lot of parts were unanchored throughout the course of a long rescue operation, there would be significant lag, glitching, and flinging all over the place. Anyone who has played [Natural Disaster Survival](https://www.roblox.com/games/189707/Natural-Disaster-Survival) would know what I'm talking about. Obviously, the parts had to be anchored, but then they also had to look like proper ruins. While testing destruction with that completed box-building, the first idea was to rotate parts at random to simulate wreckage. But I was eager to make the parts actually fall for the sake of "immersion", so the next idea was to raycast and teleport downwards. That didn't look good, so I tried unanchoring for a few seconds with added impulse. But who's to say it doesn't take more than a few seconds for the parts to reach the ground and settle? I was never happy with the results, and there was always another problem, so I gave up before I could figure it out.

About a year later I was brainstorming with AI about ways I'd go about running my own version of Roblox in a way that doesn't skyrocket server costs while running physics simulations for hundreds of parts. The first solution was to cap it at a dynamic framerate. The other was to actually anchor every part, only temporarily unanchoring when interacted with. Sound familiar? To help refine my theory at the time, I once again joined [Natural Disaster Survival](https://www.roblox.com/games/189707/Natural-Disaster-Survival) to observe the way parts moved around. It was then that the old idea for a disaster rescue game returned to bother me again, and all the pieces finally clicked. Thus was the birth of `tempUnanchor`, a simple yet highly central function that unanchors parts and only reanchors them after a few seconds of not being interacted with by the GM or players. And the test map? [Disaster Hotel](#disaster-hotel). Thus the name, Hotel Rescue. Let's also throw in `breakPart` into the mix, because I wanted the walls and floors to break into interactable pieces, not as one part that made large and ugly slopes. Finally, we had believable rubble! Everything broke through like a dam after that.

### Unlocking Roblox a Different Way

> Roblox characters don't really have hands, and yet, in disaster games, they are often surrounded by parts that are just begging to be grabbed. Tools such as the Pull Wrench unlock that whole new dimension in a physics engine where it should've made sense from the start.

> The popularity of games such as [VR Hands](https://www.roblox.com/games/4832438542/VR-Hands-v3-2), [Surgeon Simulator](https://store.steampowered.com/app/233720/Surgeon_Simulator/), and [GIRP](https://foddy.net/blog/2011/03/girp/) hint at the universal appeal of the near-direct extension of basic, biological human agency and sheer physics.

### On "Retro" Aesthetics

(One of the primitives is that Roblox is a PC game.)

### On Player "Freedom"

### Designing for Speedrunners

### The Cutting Room Floor

| Rejected Feature | Reason |
| :--- | :--- |
| Trusses |  |
| Multi-pull mechanics |  |
| Pathfinding |  |
| Fire and smoke |  |

## Chapter VI: Epilogue

### Mid-2010s Developer's Lament

Remember when scripting meant adding a `.Touched` script inside a part, turning it red, and calling it a lava brick? Good times. I still proudly animate with welds like a real man. In fact, this was about the same approach I brought to this project at the beginning. `tempUnanchor` was originally just a script that was cloned inside parts that I wanted unanchored, which destroyed itself when its job was done. And I was hesitant to entertain this idea one last time because of a previous mental breakdown trying to find the button that makes players R6. Is this a lesson about perseverance and adaptability? Not really. I can't promise that I won't freak out again the next time the Roblox Studio interface shifts around. I think of [MikuMikuClub's](https://www.roblox.com/communities/2729347/MikuMikuClub#!/about) About:

> _Roblox isn't a viable platform for stability nor "non-metaverse" games._

_(Miss you guys. More on the importance of first principles [later](#on-retro-aesthetics).)_

Eventually, though, I had to catch up. It just so happened that I'd be job hunting at the same time I'd work on Hotel Rescue. My stack as marketed is Postgres and Python but, here's the thing that I've been doing for at least 13 years, so I figured that maybe it would be of some value on my portfolio. I figured, however, that it can't be on my portfolio if it isn't on GitHub, and it can't be on GitHub until it was set up with Rojo, which it wasn't. Spending [three days](https://github.com/tristan-bonaobra/hotel-rescue-rbx/tree/refactor/rojo-restructure) turning the whole thing upside down with the help of AI before finally making the connection from VS Code all the way to Roblox Studio was the first step in becoming a modern Roblox developer for me. Hot take, but I thank AI for being that bridge.

### The Future of Hotel Rescue

Hotel Rescue is open-source. I think it is extremely unlikely that it would ever get noticed by the public, and even more unlikely that that would happen _and_ someone's copy of it takes off. But if it ever does happen, then I like to think that I'd be happy just contributing in some way to something, whatever that is. Such is the nature of open-source software. Open-source is the future!

At [AMD's booth](https://www.facebook.com/amdredteamph/posts/amd-is-here-at-the-1st-ai-philippine-expo-2026visit-the-amd-booth-and-experience/122172433244658437/) during the [AI Philippine Expo of 2026](https://www.linkedin.com/search/results/all/?keywords=%23iotconference2026), I witnessed an LLM go through an entire repo to fix one bug. I intend to use some form of that functionality in the future to audit my code, refining anything that looks shaky or prone to—trigger warning—deprecation.

Will this game ever be playable on mobile? No—I don't think so. There's just too much going on. Or, rather, there's a lot going on that just wouldn't work on mobile. Or, it could work on mobile, but I just don't need that kind of additional maintenance work. Sorry, economists, but the mobile market will have to sit this one out. Or, rather, I'll be the one missing out on the mobile market. [Fine by me!](#on-retro-aesthetics)

You might notice that Hotel Rescue uses semantic versioning that starts with a 1 (i.e. `v1.X.X`), implying a `v2.X.X`. You can expect that all versions will be starting with a 1, unless something happens and someone gives the game a complete makeover with a new lobby and a new island with brand-spanking-new [UIs, animations](https://www.youtube.com/watch?v=l3n3_w2mmz8), and... proximity prompts... in which case that 1 shall turn into a 2. I'd welcome any new ideas then.

## Authors

_Tristan Bonaobra (Creator of Hotel Rescue)_