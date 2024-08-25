local obj = {}
obj.__index = obj

-- Metadata
obj.name = "Translate"
obj.version = "1.0"
obj.author = "James Turnbull <james@lovedthanlost.net>"
obj.license = "MIT"
obj.homepage = "https://github.com/jamtur01/Translate.spoon"

-- Default settings
obj.APIKEY = ""
obj.apiProvider = "google"  -- Options: "google" or "deepl"
obj.source = "en"
obj.target = "es"
obj.history = {}
obj.maxHistorySize = 50

-- Constructor
function obj.new(apiKey, sourceLang, targetLang, provider)
    local self = setmetatable({}, obj)
    self:configure(apiKey, sourceLang, targetLang, provider)
    return self
end

-- Initialize the Spoon
function obj:init()
    self.source = hs.settings.get("Translate_source") or self.source
    self.target = hs.settings.get("Translate_target") or self.target
    self.apiProvider = hs.settings.get("Translate_apiProvider") or self.apiProvider
    self.menuBar = hs.menubar.new()
    self:setupMenuBar()
    return self
end

-- Configure the Spoon
function obj:configure(APIKEY, source, target, provider)
    self.APIKEY = APIKEY or self.APIKEY
    self.source = source or self.source
    self.target = target or self.target
    self.apiProvider = provider or self.apiProvider
    hs.settings.set("Translate_apiProvider", self.apiProvider)
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
        {title = "Switch API Provider", fn = function() self:switchProvider() end},
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

-- Switch between Google and DeepL API providers
function obj:switchProvider()
    self.apiProvider = self.apiProvider == "google" and "deepl" or "google"
    hs.alert.show("API Provider switched to " .. self.apiProvider)
    hs.settings.set("Translate_apiProvider", self.apiProvider)
end

-- Main translate function
function obj:translate()
    if self.APIKEY == "" then
        hs.alert('You must enter your API KEY')
        return
    end

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
        self.source = so
        self.target = ta
    
        hs.alert.closeSpecific(alerts["langPrimary"], 0)
        hs.alert.closeSpecific(alerts["langSecondary"], 0)
    
        alerts["langPrimary"] = hs.alert.show(string.format('%s ⇢ %s', string.upper(self.source), string.upper(self.target)), { ["textSize"] = 50 }, 2)
        alerts["langSecondary"] = hs.alert.show('⌘⌥T to switch.', 2)
    
        -- Trigger re-translation with the updated languages
        local currentQuery = chooser:query()
        reset()
        self:updateChooser(chooser, choices, reset)
    end

    t = hs.hotkey.bind({'cmd', 'alt'}, 't', function()
        setLang(self.target, self.source)
        local currentQuery = chooser:query()
        reset()
        chooser:query(currentQuery)  -- Force re-query with the updated languages
        self:updateChooser(chooser, choices, reset)
    end)
    
    t = hs.hotkey.bind('cmd', 't', function()
        setLang(self.target, self.source)
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

    chooser:queryChangedCallback(function()
        self:updateChooser(chooser, choices, reset)
    end)
    chooser:searchSubText(false)
    chooser:show()
    setLang(self.source, self.target)
end

-- Update chooser based on the current query
function obj:updateChooser(chooser, choices, reset)
    local query = chooser:query()
    if query:len() == 0 then 
        reset()
        return 
    end

    self:performTranslation(query, function(translation)
        if query == translation then return end

        local choice = {
            ["text"] = translation,
            ["subText"] = query,
        }

        local found = hs.fnutils.find(choices, function(element)
            return element["text"] == translation
        end)

        if found == nil then 
            table.insert(choices, 1, choice)
        end

        chooser:choices(choices)
    end)
end

-- Perform translation for both Google and DeepL
function obj:performTranslation(text, callback)
    if self.apiProvider == "google" then
        self:performGoogleTranslation(text, callback)
    else
        self:performDeepLTranslation(text, callback)
    end
end

-- Perform Google translation
function obj:performGoogleTranslation(text, callback)
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
            hs.alert.show("Google Translation failed: " .. (status or "unknown error"))
        end
    end)
end

-- Perform DeepL translation
function obj:performDeepLTranslation(text, callback)
    -- Determine the correct DeepL API endpoint based on plan
    local DEEPL_ENDPOINT = self.apiPlan == "pro" 
        and 'https://api.deepl.com/v2/translate' 
        or 'https://api-free.deepl.com/v2/translate'

    local url = DEEPL_ENDPOINT

    local headers = {
        ["Authorization"] = "DeepL-Auth-Key " .. self.APIKEY,
        ["Content-Type"] = "application/json"
    }

    local body = hs.json.encode({
        text = { text },
        source_lang = self.source,
        target_lang = self.target
    })

    hs.http.asyncPost(url, body, headers, function(status, responseBody, responseHeaders)
        if status == 200 then
            local response = hs.json.decode(responseBody)
            local translatedText = response.translations[1].text
            self:addToHistory(text, translatedText)
            hs.pasteboard.setContents(translatedText)
            if callback then callback(translatedText) end
        else
            hs.alert.show("DeepL Translation failed: " .. (status or "unknown error"))
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
                hs.settings.set("Translate_source", selection.code)
            else
                self.target = selection.code
                hs.settings.set("Translate_target", selection.code)
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
