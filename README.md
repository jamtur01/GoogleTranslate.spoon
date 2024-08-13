# GoogleTranslate Spoon

## Overview

GoogleTranslate is a Spoon for [Hammerspoon](http://www.hammerspoon.org/) that provides quick and easy access to Google's translation service. It includes a menu bar integration, translation history, language selection UI, and more.

## Features

- Translate text using Google Translate API
- Menu bar integration for quick access to translation features
- Translation history accessible from the menu bar
- UI for selecting source and target languages
- Clipboard integration for easy copy-paste of translations
- Configurable hotkeys for translation
- Supports multiple language pairs

## Requirements

- Hammerspoon
- Google Cloud API Key (for accessing Google Translate API)

## Installation

1. Download the GoogleTranslate.spoon and place it in your Hammerspoon Spoons directory (`~/.hammerspoon/Spoons/`).
2. Load the Spoon in your Hammerspoon configuration:

```lua
hs.loadSpoon("GoogleTranslate")
```

## Configuration

Configure the Spoon with your Google Cloud API Key and default language settings:

```lua
spoon.GoogleTranslate:configure("YOUR_API_KEY", "en", "es")
```

Replace `"YOUR_API_KEY"` with your actual Google Cloud API Key. The second and third parameters set the default source and target languages respectively (optional).

## Usage

### Basic Usage

After configuration, you can use the Spoon's translate function:

```lua
spoon.GoogleTranslate:translate()
```

This will open a chooser interface where you can enter text to translate.

### Binding Hotkeys

You can bind a hotkey to trigger the translation function:

```lua
spoon.GoogleTranslate:bindHotkeys({
    translate = {{"cmd", "alt"}, "T"}
})
```

This binds Cmd+Alt+T to open the translation interface.

### Menu Bar Usage

The Spoon adds a menu bar item (🌐) that provides quick access to:

- Translation interface
- Language selection for source and target languages
- Recent translation history

### Keyboard Shortcuts in Translation Interface

- `Tab`: Switch between original text and translation
- `Cmd+T`: Swap source and target languages
- `Cmd+C`: Copy the selected translation to clipboard

## Advanced Configuration

You can modify the following settings in the Spoon:

- `maxHistorySize`: Maximum number of translations to keep in history (default: 50)
- `APIKEY`: Your Google Cloud API Key
- `source`: Default source language
- `target`: Default target language

Example:

```lua
spoon.GoogleTranslate.maxHistorySize = 100
spoon.GoogleTranslate.source = "fr"
spoon.GoogleTranslate.target = "de"
```

## Troubleshooting

- If translations fail, ensure your API key is correct and has the necessary permissions.
- For any other issues, please check the Hammerspoon console for error messages.

## License

MIT License

## Acknowledgements

- Owns heritage to [Translate-for-Hammerspoon](https://github.com/pasiaj/Translate-for-Hammerspoon), which in turn owns some heritage to [Anycomplete codebase](https://github.com/nathancahill/Anycomplete) by [Nathan Cahill](https://nathancahill.com/).
- This Spoon uses the Google Cloud Translation API.

## Links

- [Hammerspoon](http://www.hammerspoon.org/)
- [Google Cloud Translation API](https://cloud.google.com/translate)
