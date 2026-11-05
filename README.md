# dotfiles

A bunch of `dotfiles` and scripts for installing them with GNU Stow, as well as
installing all the actual packages.

<!-- toc GFM -->

- [**Pi**xie's **K**DE **D**esktop (`pikd`)](#pixies-kde-desktop-pikd)
- [**c**hrissx **M**edia **m**acOS **S**etup **S**cripts (`cmmss`)](#chrissx-media-macos-setup-scripts-cmmss)
  - [Other software (esp. audio plugins)](#other-software-esp-audio-plugins)
- [`base`](#base)
- [Updating](#updating)

<!-- toc -->

## **Pi**xie's **K**DE **D**esktop (`pikd`)

Installs desktop apps and configures KDE Plasma on Fedora-based systems, mainly
[pibi](pibi/README.md):

```sh
curl -L https://github.com/pixelcmtd/dotfiles/raw/daddy/install | sh -s pikd
```

## **c**hrissx **M**edia **m**acOS **S**etup **S**cripts (`cmmss`)

A set of scripts for easily installing a lot of packages and configuration,
primarily on "Apple silicon" (ARM), currently macOS 15 Sequoia and macOS 27
Golden Gate.

> [!WARNING]
> Older macOS versions, as well as Intel-based versions are unsupported. Expect
> to run into issues, patching them should be pretty easy though.

> [!NOTE]
> I am currently testing CMMSS on macOS 27.

- Grant Terminal Full Disk Access (in the System Settings)
- Install [XCode](https://apps.apple.com/de/app/xcode/id497799835) from the App
  Store (`open -a "App Store" https://apps.apple.com/de/app/xcode/id497799835`)
  or [Apple Developer page](https://developer.apple.com/download/all/?q=Xcode)
- Run `sudo xcodebuild -license` and agree to the license
- Run
  `curl -L https://github.com/pixelcmtd/dotfiles/raw/daddy/install | sh -s cmmss`
- Open iTerm, go to the Preferences (⌘,): General → Preferences →
  `Load preferences from a custom folder or URL` →
  `/Users/your_name/src/pixelcmtd/dotfiles/cmmss`

### Other software (esp. audio plugins)

A lot of software, especially audio plugins, isn't in Homebrew, or otherwise
easily automatable. This may be seen as a long to-do list.

- [TinkerTool](https://www.bresink.com/osx/0TinkerTool/download.php)
- [XLN](https://www.xlnaudio.com/install)
- [destroyfx](http://destroyfx.org)
- [Ample](https://www.amplesound.net/en/download.asp)
- [Plugin Alliance](https://www.plugin-alliance.com/en/installation-manager.html#downloads)
- Antares (installed through my Homebrew)
- Native Access (installed through Homebrew)
- Softube Central (installed through Homebrew)
- [GVST](https://www.gvst.co.uk/downloads.htm)
- [Melodyne](https://services.celemony.com/cgi-bin/WebObjects/LicenseApp.woa/wa/LoginDA)

## `base`

> [!NOTE]
> `base` is not intended for individual install, but for installation through
> one of the config systems listed above.

Finishes up the install, specifically the following steps:

- disable brew analytics
- install [many homebrew formulae, and cargo and go packages](base/Brewfile)
- disable dart analytics
- install flutter stable from `fvm`

### `kilobase`

The part of `base` that you wouldn't want for a minimal/devcontainer/… install:

- install [a few more packages](kilobase/Brewfile)
- clone a big list of repos into `~/src`

## Updating

Using `topgrade` to update all installed packages is recommended. To keep
configurations in sync, `git pull && ./run base` (maybe `./run cmmss`,
`./run pikd`, etc) should usually do the trick. In some cases, manual patches
might be required after major changes.
