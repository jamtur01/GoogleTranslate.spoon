local obj = {}
obj.__index = obj

-- Metadata
obj.name = "GoogleTranslate"
obj.version = "2.0"
obj.author = "James Turnbull <james@lovedthanlost.net>"
obj.license = "MIT"
obj.homepage = "https://github.com/jamtur01/GoogleTranslateSpoon"

-- Default settings
obj.APIKEY = ""
obj.source = "en"
obj.target = "es"
obj.history = {}
obj.maxHistorySize = 50

-- Constructor
function obj.new(apiKey, sourceLang, targetLang)
    local self = setmetatable({}, obj)
    self:configure(apiKey, sourceLang, targetLang)
    return self
end

-- Initialize the Spoon
function obj:init()
    self.source = hs.settings.get("GoogleTranslate_source") or self.source
    self.target = hs.settings.get("GoogleTranslate_target") or self.target
    self.menuBar = hs.menubar.new()
    self:setupMenuBar()
    return self
end


-- Configure the Spoon
function obj:configure(APIKEY, source, target)
    self.APIKEY = APIKEY or self.APIKEY
    self.source = source or self.source
    self.target = target or self.target
end

-- Setup menu bar
function obj:setupMenuBar()
    if self.menuBar then
        self.menuBar:setTitle("🌐")
        self.menuBar:setMenu(function()
            return self:generateMenu()
        end)
    end
end

-- Generate dynamic menu
function obj:generateMenu()
    local menu = {
        {title = "Translate", fn = function() self:translate() end},
        {title = "Set Source Language", fn = function() self:setLanguage("source") end},
        {title = "Set Target Language", fn = function() self:setLanguage("target") end},
        {title = "-"},
        {title = "Translation History", disabled = true},
    }
    
    -- Add history items
    for i = 1, math.min(5, #self.history) do
        table.insert(menu, {
            title = string.format("%s -> %s", self.history[i].original, self.history[i].translated),
            fn = function() hs.pasteboard.setContents(self.history[i].translated) end
        })
    end
    
    return menu
end

-- Main translate function
function obj:translate()
    if self.APIKEY == "" then
        hs.alert('You must enter your Google Cloud API KEY')
        return
    end

    local GOOGLE_ENDPOINT = 'https://translation.googleapis.com/language/translate/v2?key=%s'
    local API_KEY = self.APIKEY
    local target = self.target
    local source = self.source

    local alerts = {}
    local current = hs.application.frontmostApplication()
    local tab, copy, t
    local choices = {}

    local chooser = hs.chooser.new(function(chosen)
        if copy then copy:delete() end
        if tab then tab:delete() end
        if t then t:delete() end
        current:activate()
        if chosen then
            self:performTranslation(chosen.text)
        end
    end)

    -- Removes all items in list
    local function reset()
        chooser:choices({})
    end

    local function setLang(so, ta)
        source = so
        target = ta

        hs.alert.closeSpecific(alerts["langPrimary"], 0)
        hs.alert.closeSpecific(alerts["langSecondary"], 0)

        alerts["langPrimary"] = hs.alert.show(string.format('%s ⇢ %s', string.upper(source), string.upper(target)), { ["textSize"] = 50 }, 2)
        alerts["langSecondary"] = hs.alert.show('⌘T to switch.', 2)
    end

    tab = hs.hotkey.bind('', 'tab', function()
        local id = chooser:selectedRow()
        local item = choices[id]
        if not item then return end
        chooser:query(item.subText)
        reset()
        updateChooser()
    end)

    t = hs.hotkey.bind('cmd', 't', function()
        setLang(target, source)
        reset()
    end)

    copy = hs.hotkey.bind('cmd', 'c', function()
        local id = chooser:selectedRow()
        local item = choices[id]
        if item then
            chooser:hide()
            hs.pasteboard.setContents(item.text)
            hs.alert.show("Copied to clipboard", 1)
        else
            hs.alert.show("No search result to copy", 1)
        end
    end)

    local function updateChooser()
        local string = chooser:query()
        if string:len() == 0 then return reset() end

        self:performTranslation(string, function(translation)
            if string == translation then return end

            local choice = {
                ["text"] = translation,
                ["subText"] = string,
            }

            local found = hs.fnutils.find(choices, function(element)
                return element["text"] == translation
            end)

            if found == nil then table.insert(choices, 1, choice) end
            chooser:choices(choices)
        end)
    end

    chooser:queryChangedCallback(updateChooser)
    chooser:searchSubText(false)
    chooser:show()
    setLang(source, target)
end

-- Perform translation
function obj:performTranslation(text, callback)
    local url = string.format(
        "https://translation.googleapis.com/language/translate/v2?key=%s",
        self.APIKEY
    )
    
    local headers = {
        ["Content-Type"] = "application/json"
    }
    
    local body = hs.json.encode({
        q = text,
        source = self.source,
        target = self.target,
        format = "text"
    })
    
    hs.http.asyncPost(url, body, headers, function(status, responseBody, responseHeaders)
        if status == 200 then
            local response = hs.json.decode(responseBody)
            local translatedText = response.data.translations[1].translatedText
            self:addToHistory(text, translatedText)
            hs.pasteboard.setContents(translatedText)
            if callback then callback(translatedText) end
        else
            hs.alert.show("Translation failed: " .. (status or "unknown error"))
        end
    end)
end

-- Add to translation history
function obj:addToHistory(original, translated)
    table.insert(self.history, 1, {original = original, translated = translated})
    if #self.history > self.maxHistorySize then
        table.remove(self.history)
    end
end

-- Set language
function obj:setLanguage(which)
local chooser = hs.chooser.new(function(selection)
    if selection then
        if which == "source" then
            self.source = selection.code
            hs.settings.set("GoogleTranslate_source", selection.code)
        else
            self.target = selection.code
            hs.settings.set("GoogleTranslate_target", selection.code)
        end
        hs.alert.show(string.format("%s language set to %s", which:gsub("^%l", string.upper), selection.text))
    end
end)
    
    local languages = {
        {text = "English", code = "en"},
        {text = "Spanish", code = "es"},
        {text = "French", code = "fr"},
        {text = "German", code = "de"},
        {text = "Italian", code = "it"},
        {text = "Japanese", code = "ja"},
        {text = "Korean", code = "ko"},
        {text = "Chinese (Simplified)", code = "zh-CN"},
        {text = "Russian", code = "ru"},
        {text = "Arabic", code = "ar"}
    }
    
    if which == "source" then
        table.insert(languages, 1, {text = "Auto Detect", code = "auto"})
    end
    
    chooser:choices(languages)
    chooser:show()
end

-- Binds the hotkey
function obj:bindHotkeys(mapping)
    hs.spoons.bindHotkeysToSpec({
        translate = hs.fnutils.partial(self.translate, self)
    }, mapping)
end

return obj