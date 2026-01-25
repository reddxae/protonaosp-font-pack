# ProtonAOSP Font Pack

Inter was chosen as the UI font for its cleanliness and legibility; it is neutral and looks similar to Apple's San Francisco UI font. Because it was specifically designed for use in GUIs, it is a great replacement for Roboto on Android.

Source Serif was chosen as the serif font because it is one of the best open-source fonts that complement Inter's style.

All fonts included in this repo are open-source and licensed under the [SIL Open Font License](https://openfontlicense.org):

- [Inter](https://github.com/rsms/inter) for most text [(4.1)](https://github.com/rsms/inter/releases/tag/v4.1);
- [Fira Code](https://github.com/tonsky/FiraCode) for monospace text [(6.2)](https://github.com/tonsky/FiraCode/releases/tag/6.2);
- [Source Serif](https://github.com/adobe-fonts/source-serif) for serif text [(4.005)](https://github.com/adobe-fonts/source-serif/releases/tag/4.005R).

> [!NOTE]
> It is known that in some cases, after installing the module, the Play Store starts crashing on its Search page. Currently, the only solution is to remove the fallback to the Roboto. I have no idea how to fix this, since the problem is on the side of Google's closed library.

## Modules

Here's an explanation of what prefixes mean:

* [**`lineage`**](/modules/lineage) — suitable for AOSP or LineageOS based ROMs.
* [**`pixel`**](/modules/pixel) — suitable only for stock Pixel OS or Pixel-like ROMs (EvolutionX, crDroid and others forcing Google Sans in config).
* [**`oneui`**](/modules/oneui) — replaces system fonts to the pack above, and forces the use of AOSP fonts for all other languages instead of Samsung's own fonts.

Some Google apps will still use Google Sans. 

Module version indicates which OS version the module is designed for (e.g. v16.1 is for Android 16 QPR1). However, it should usually be compatible with the latest Android versions.

## Compatibility

To maximize compatibility, all font names have been patched to match the original fonts. This fixes some issues in third-party apps, such as Firefox. You can do the same using the attached script in the repository files.

Additionally, Roboto [will be used as a fallback](/modules/lineage/15.1/system/etc/font_fallback.xml#L89-L96) for characters not supported by Inter. This way, unsupported characters are still displayed with the correct metrics and hints.

Since the stock Pixel OS uses Google Sans for the UI and Google apps, and its implementation is a bit hard-coded and lacks auto-adjustment in some cases, I had to manually set the most eye-pleasing font metrics for certain styles (see [font_fallback.xml](/modules/pixel/15.1/system/etc/font_fallback.xml#L87-L138)) in Pixel modules lineup. You can change them to your liking by increasing or decreasing the values.

____

Compatible with and tested on:
* stock Android 15 (LineageOS 22.1), Android 16 (LineageOS 23.1, 23.2);
* Google Pixel OS (AP4A.250205.002);
* Samsung One UI 6.1.1.

It is unlikely to work with vendor ROMs, such as HyperOS or ColorOS. Contributions for those are always welcome!

## Credits

* [kdrag0n/inter-font-pack](https://github.com/kdrag0n/inter-font-pack) & [ihfandicahyo/proton-aosp-stuff](https://github.com/ihfandicahyo/proton-aosp-stuff) for an idea and all basis of this repo.
