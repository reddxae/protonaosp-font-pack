# ProtonAOSP Font Pack

Inter was chosen as the UI font for its cleanliness and legibility; it is neutral and looks similar to Apple's San Francisco UI font. Because it was specifically designed for use in GUIs, it is a great replacement for Roboto on Android.

Source Serif was chosen as the serif font because it is one of the best open-source fonts that complement Inter's style.

All fonts included in this repo are open-source and licensed under the [SIL Open Font License.](https://openfontlicense.org)

- [Inter](https://github.com/rsms/inter) for most text [(4.1).](https://github.com/rsms/inter/releases/tag/v4.1)
- [Fira Code](https://github.com/tonsky/FiraCode) for monospace text [(6.2).](https://github.com/tonsky/FiraCode/releases/tag/6.2)
- [Source Serif](https://github.com/adobe-fonts/source-serif) for serif text [(4.005).](https://github.com/adobe-fonts/source-serif/releases/tag/4.005R)

## Modules

Here's an explanation of what prefixes mean.

* `lineage` — simply replaces system fonts. Suitable for AOSP or LineageOS based ROMs without GMS.
* `lineage-killgmsfont` — replaces system fonts and kills internal GMS Font API Service to ensure Google Apps rely on custom installed fonts. Suitable for AOSP or LineageOS based ROMs with GMS.
* `pixel` — replaces system fonts. Suitable for stock Pixel OS or ROMs based on it, but some Google apps will still use Google Sans.
* `pixel-killgmsfont` — replaces system fonts and kills internal GMS Font API Service to ensure that all Google Apps rely on custom installed fonts. Suitable for stock Pixel OS or ROMs based on it.

## Compatibility

To maximize compatibility, all font names have been patched to match the original fonts. This fixes some issues in third-party apps, such as Firefox.

Additionally, Roboto will be used as a fallback for characters not supported by Inter. This way, unsupported characters are still displayed with the correct metrics and hints.

Since the Pixel stock uses Google Sans for UI and Google apps, and this implementation is a bit hard-coded and doesn't use auto-adjustment in some cases, I had to manually set the most eye-pleasing font metrics for certain styles (see [font_fallback.xml](/modules/pixel/system/etc/font_fallback.xml)). You can change them to your liking by changing the values where they're set.
____

Compatible and tested with pure clean Android 15 (LineageOS 22.1) and stock Pixel OS (AP4A.250205.002). Most likely won't work with vendor ROMs like HyperOS, ColorOS etc. 

## Credits

* [kdrag0n/inter-font-pack](https://github.com/kdrag0n/inter-font-pack) & [ihfandicahyo/proton-aosp-stuff](https://github.com/ihfandicahyo/proton-aosp-stuff) for an idea and all basis of this repo.
* [MrCarb0n/killgmsfont](https://github.com/MrCarb0n/killgmsfont) for logic of disabling GMS Font API Service.