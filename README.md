# Hotel Rescue

**README version**: Last updated v1.2.1 on November 9, 2026.

[hotel-rescue-rbx on GitHub](https://github.com/tristan-bonaobra/hotel-rescue-rbx)

## About

A heroic twist on disaster survival.

# Usage guide

This section explains how to play the game and mod its code.

## How to play

1. Install Roblox Studio via [Roblox Creator Hub](https://create.roblox.com/docs/tutorials/curriculums/studio/install-studio).
2. Download and open the latest `.rbxl` on the [Releases](https://github.com/tristan-bonaobra/hotel-rescue-rbx/releases) page.
3. In the **Home** tab, set the dropdown menu to **Test** and click the play button.

### Custom audio

This part is optional. Roblox hosts all audio on their servers and do not let other users use audio from non-verified publishers.

To play with music and dialog:

1. Upload the sound files in `assets` through the [Roblox Creator Dashboard](https://create.roblox.com/dashboard/creations?activeTab=Audio&inventoryAssetTypes=All) and take note of the **Asset ID** in the sound's URL.
2. Set the `SoundId` of the Sound instances accordingly using the **Explorer** and **Properties** windows. [see paths](#sound-instance-paths)

#### Sound instance paths

```text
ServerStorage/
└── Sounds/
    ├── Gear/
    │   ├── BearFollow1
    │   ├── BearFollow2
    │   ├── BearFollow3
    │   └── BearFollow4
    └── Music/
        ├── GroundworksComplex
        └── UrbanDescent
```

## Local development

1. Clone the repo and open the latest `.rbxl`. [see guide](#how-to-play)
1. Install **Rojo** in your [environment](https://rojo.space/docs/v7/getting-started/installation/) and in [Roblox Studio](https://create.roblox.com/store/asset/13916111004/Rojo).
2. Connect your environment to Roblox Studio by executing `rojo serve` in-terminal and clicking **Connect** (and **Accept**, if changes are made) in the Rojo plugin window.