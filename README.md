# GoogleTranslate Spoon for Hammerspoon

## Overview

GoogleTranslate is a Spoon for Hammerspoon that provides quick and easy access to Google's translation service directly from your macOS desktop. With a simple hotkey, you can translate text between languages, making it an invaluable tool for multilingual work and study.

## Features

- Translate text between multiple languages
- Quick language switching
- Accumulates translation results for easy reference
- Copy translations to clipboard
- Customizable hotkeys

## Requirements

- [Hammerspoon](http://www.hammerspoon.org/) (Make sure you have the latest version installed)
- A Google Cloud API Key with the Cloud Translation API enabled

## Installation

1. Download the `GoogleTranslate.spoon` directory.
2. Place it in your Hammerspoon Spoons directory (`~/.hammerspoon/Spoons/`).
3. Add the following to your `~/.hammerspoon/init.lua`:

   ```lua
   hs.loadSpoon("GoogleTranslate")
   ```

## Configuration

Before using the Spoon, you need to configure it with your Google Cloud API Key and set your preferred languages. Add the following to your `init.lua`:

```lua
spoon.GoogleTranslate:configure("YOUR_API_KEY", "en", "es")
```

Replace `"YOUR_API_KEY"` with your actual Google Cloud API Key, and adjust the language codes as needed (e.g., "en" for English, "es" for Spanish).

## Usage

1. Bind a hotkey to activate the translation function:

   ```lua
   spoon.GoogleTranslate:bindHotkeys({
       translate = { {"cmd", "alt"}, "t" }
   })
   ```

   This binds Command+Option+T to activate the translator.

2. Press the hotkey to open the translation interface.
3. Type the text you want to translate.
4. Use the following commands within the interface:
   - `Tab`: Switch between original text and translation
   - `Cmd+T`: Switch source and target languages
   - `Cmd+C`: Copy the selected translation to clipboard

## Customization

You can customize the source and target languages by modifying the `configure` function call in your `init.lua`:

```lua
spoon.GoogleTranslate:configure("YOUR_API_KEY", "fr", "de")
```

This example sets French as the source language and German as the target language.

## Contributing

Contributions to improve GoogleTranslate are welcome! Please feel free to submit pull requests or create issues for bugs and feature requests.

## License

This project is licensed under the MIT License. See the LICENSE file for details.

## Acknowledgements

- Owns heritage to [Translate-for-Hammerspoon](https://github.com/pasiaj/Translate-for-Hammerspoon), which in turn owns some heritage to [Anycomplete codebase](https://github.com/nathancahill/Anycomplete) by [Nathan Cahill](https://nathancahill.com/).
- This Spoon uses the Google Cloud Translation API.

## Support

If you encounter any issues or have questions, please file an issue on the GitHub repository.
