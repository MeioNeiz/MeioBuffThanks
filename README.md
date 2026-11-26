# Meio Buff Thanks

A stranger buffs you and is gone before you can type: Meio Buff Thanks whispers one of your
own thank-you lines.

For WoW Forever.

![Three players buff you: before, just the buffs; with Meio Buff Thanks, each gets one
whisper, "Thanks for the Power Word: Fortitude and Divine Spirit, Ancuta.", "Cheers for the
Mark of the Wild, Brom.", "Thanks Cael, that'll come in handy."](docs/before-after.png)

## What it does

When another player casts a long buff on you (Fortitude, Mark of the Wild, Arcane Intellect,
Kings...), it whispers them a thank you. Write your own lines; `{name}` and `{spell}` are
filled in.

![The messages window: your thank you lines, one per line, such as "Thanks for the {spell},
{name}.", with Defaults, Test and Save](docs/messages.png)

- Several buffs from one player: one whisper naming them all
- Once per player every 15 minutes, so a rebuff doesn't spam them
- A random wait of 2 to 6 seconds before each thanks, so it reads like a person
- Skips short buffs, heals and your own group (each can be changed)
- Your own lines for each of your characters, or one shared list
- The /thank emote as well, or instead
- Only players the game can name: in your group, targeted, under the mouse or with a
  nameplate showing

Settings: Esc > Options > AddOns > MeioBuffThanks, or `/buffthanks`.

- `/buffthanks on|off`: switch it all on or off
- `/buffthanks whisper on|off`, `emote on|off`, `group on|off`
- `/buffthanks messages`: edit your thank you lines (tick "Own lines" for this character only)
- `/buffthanks test`: show a random line, filled in, in your chat (sends nothing)
- `/buffthanks help`: list the commands

## Install

Use your addon manager (CurseForge, Wago), or unzip a GitHub release into
`World of Warcraft\_forever_\Interface\AddOns` and restart WoW fully.

## Feedback

Bugs, ideas or just a thumbs up: leave a comment on the CurseForge or Wago page you got it from. [GitHub issues](https://github.com/MeioNeiz/MeioBuffThanks/issues) are welcome too.

## More Meio addons

[Meio Trainer Compare](https://www.curseforge.com/wow/addons/trainercompare) | [Meio Next Stop](https://www.curseforge.com/wow/addons/leavebutton) | [Meio Auto Rank](https://www.curseforge.com/wow/addons/meio-autorank) | [Meio Meter Hover](https://www.curseforge.com/wow/addons/meterhover) | [Meio Map](https://addons.wago.io/addons/meiomap) | [Meio Alts](https://addons.wago.io/addons/meioalts) | [Meio DPS](https://addons.wago.io/addons/meiodps) | [Meio Nameplates](https://addons.wago.io/addons/meioplates) | [Meio Hub](https://addons.wago.io/addons/meiohub) | [Meio Pets](https://addons.wago.io/addons/meiopets) | [Meio XP Meter](https://addons.wago.io/addons/meiostats) | [Meio Bags](https://addons.wago.io/addons/meiobags) | [Meio Fixes](https://addons.wago.io/addons/meiofixes) | [Meio Flight Times](https://addons.wago.io/addons/meioflighttimes) | [Meio Tooltips](https://addons.wago.io/addons/meiotooltipfold) | [Meio Autorun](https://addons.wago.io/addons/meioautorunturn) | [Meio Mail](https://addons.wago.io/addons/meiomail) | [Meio QoL](https://addons.wago.io/addons/meioqol) | [Meio TSM Browse](https://addons.wago.io/addons/tsmbrowse) | [Meio Shards](https://addons.wago.io/addons/meioshards) | [Meionomics](https://www.curseforge.com/wow/addons/meionomics) | [Meio Spike Check](https://addons.wago.io/addons/meiospikecheck) | [Meio BiS Extras](https://addons.wago.io/addons/meiobisextras) | [Meio Flare Fixes](https://addons.wago.io/addons/meioflarefixes) | [Meio Flare Questie](https://addons.wago.io/addons/meioflarequestie)

## Licence

[MIT](LICENSE)
