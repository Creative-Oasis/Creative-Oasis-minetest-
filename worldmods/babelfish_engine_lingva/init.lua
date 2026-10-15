-- babelfish_redo/babelfish_engine_lingva/init.lua
-- Google Translate backend
-- Compatible with Luanti 5.14
-- SPDX-License-Identifier: LGPL-3.0-or-later

local http = assert(
    core.request_http_api(),
    "Could not get HTTP API table. Add babelfish_engine_lingva to secure.http_mods"
)

local S = core.get_translator("babelfish_engine_lingva")

local engine_status = "init"

local language_codes = {}
local language_alias = {}


-- =========================================================
-- GOOGLE TRANSLATE
-- =========================================================

local serviceurl =
    core.settings:get("babelfish_engine_lingva.serviceurl")

if not serviceurl or serviceurl == "" then
    serviceurl = "https://translate.googleapis.com"

    core.log(
        "warning",
        "[babelfish_engine_lingva] serviceurl not specified, using " ..
        serviceurl
    )
end

serviceurl = string.gsub(serviceurl, "/+$", "")


-- =========================================================
-- LANGUAGE LIST
-- =========================================================

local languages = {
    ["af"] = "Afrikaans",
    ["ar"] = "Arabic",
    ["bg"] = "Bulgarian",
    ["bn"] = "Bengali",
    ["ca"] = "Catalan",
    ["cs"] = "Czech",
    ["da"] = "Danish",
    ["de"] = "German",
    ["el"] = "Greek",
    ["en"] = "English",
    ["es"] = "Spanish",
    ["et"] = "Estonian",
    ["fa"] = "Persian",
    ["fi"] = "Finnish",
    ["fr"] = "French",
    ["he"] = "Hebrew",
    ["hi"] = "Hindi",
    ["hr"] = "Croatian",
    ["hu"] = "Hungarian",
    ["id"] = "Indonesian",
    ["is"] = "Icelandic",
    ["it"] = "Italian",
    ["ja"] = "Japanese",
    ["ko"] = "Korean",
    ["lt"] = "Lithuanian",
    ["lv"] = "Latvian",
    ["ms"] = "Malay",
    ["nl"] = "Dutch",
    ["no"] = "Norwegian",
    ["pl"] = "Polish",
    ["pt"] = "Portuguese",
    ["ro"] = "Romanian",
    ["ru"] = "Russian",
    ["sk"] = "Slovak",
    ["sl"] = "Slovenian",
    ["sr"] = "Serbian",
    ["sv"] = "Swedish",
    ["th"] = "Thai",
    ["tr"] = "Turkish",
    ["uk"] = "Ukrainian",
    ["ur"] = "Urdu",
    ["vi"] = "Vietnamese",
    ["zh-CN"] = "Chinese Simplified",
    ["zh-TW"] = "Chinese Traditional",
}


for code, name in pairs(languages) do
    language_codes[code] = name
end


-- =========================================================
-- LANGUAGE ALIASES
-- =========================================================

language_alias["zh"] = "zh-CN"
language_alias["zhs"] = "zh-CN"
language_alias["zh-cn"] = "zh-CN"
language_alias["zh-hans"] = "zh-CN"
language_alias["zh_cn"] = "zh-CN"

language_alias["zht"] = "zh-TW"
language_alias["zh-tw"] = "zh-TW"
language_alias["zh-hant"] = "zh-TW"
language_alias["zh_tw"] = "zh-TW"

language_alias["es_US"] = "es"
language_alias["en_US"] = "en"
language_alias["en_GB"] = "en"
language_alias["fr_FR"] = "fr"
language_alias["de_DE"] = "de"
language_alias["it_IT"] = "it"
language_alias["pt_BR"] = "pt"
language_alias["pt_PT"] = "pt"

language_alias["sr_Cyrl"] = "sr"
language_alias["sr_Latn"] = "sr"


-- =========================================================
-- HTTP GET
-- =========================================================

local function http_get(url, callback)

    http.fetch({
        url = url,
        method = "GET",
        timeout = 10,

        extra_headers = {
            "accept: application/json",
            "user-agent: Creative-Oasis-Luanti-BabelFish",
        },

    }, function(response)

        if not response then

            core.log(
                "error",
                "[babelfish_engine_lingva] No HTTP response"
            )

            callback(nil)
            return
        end


        if not response.succeeded then

            core.log(
                "error",
                "[babelfish_engine_lingva] HTTP request failed: " ..
                dump(response)
            )

            callback(nil)
            return
        end


        if not response.data
            or response.data == "" then

            core.log(
                "error",
                "[babelfish_engine_lingva] Empty HTTP response"
            )

            callback(nil)
            return
        end


        local data, err =
            core.parse_json(
                response.data,
                nil,
                true
            )


        if not data then

            core.log(
                "error",
                "[babelfish_engine_lingva] Invalid JSON response: " ..
                tostring(err)
            )

            core.log(
                "error",
                "[babelfish_engine_lingva] Raw response: " ..
                tostring(response.data)
            )

            callback(nil)
            return
        end


        callback(data)
    end)
end


-- =========================================================
-- LANGUAGE NORMALIZATION
-- =========================================================

local function normalize_language(code)

    if not code or code == "" then
        return nil
    end


    if language_alias[code] then
        return language_alias[code]
    end


    if language_codes[code] then
        return code
    end


    local lower = string.lower(code)


    if language_alias[lower] then
        return language_alias[lower]
    end


    if language_codes[lower] then
        return lower
    end


    return code
end


-- =========================================================
-- TRANSLATION
-- =========================================================

local function translate(
    source,
    target,
    query,
    callback
)

    if engine_status == "error" then

        callback(
            false,
            S("Engine error while initializing.")
        )

        return
    end


    if not query or query == "" then

        callback(
            false,
            S("Nothing to translate.")
        )

        return
    end


    source = normalize_language(source) or "auto"
    target = normalize_language(target) or "en"


    -- Google uses zh-CN / zh-TW.
    if source == "zh" then
        source = "zh-CN"
    end

    if target == "zh" then
        target = "zh-CN"
    end


    -- -----------------------------------------------------
    -- Build Google Translate URL
    -- -----------------------------------------------------

    local url =
        serviceurl ..
        "/translate_a/single" ..
        "?client=gtx" ..
        "&sl=" ..
        core.urlencode(source) ..
        "&tl=" ..
        core.urlencode(target) ..
        "&dt=t" ..
        "&q=" ..
        core.urlencode(query)


    core.log(
        "action",
        "[babelfish_engine_lingva] Translating " ..
        source ..
        " -> " ..
        target ..
        ": " ..
        query
    )


    core.log(
        "action",
        "[babelfish_engine_lingva] URL: " ..
        url
    )


    http_get(url, function(data)

        core.log(
            "action",
            "[babelfish_engine_lingva] Response: " ..
            dump(data)
        )


        if not data then

            callback(
                false,
                S("Error getting translation")
            )

            return
        end


        -- -------------------------------------------------
        -- Google response format:
        --
        -- [
        --   [
        --     ["Bonjour", "Hello", ...]
        --   ],
        --   ...
        --   "en"
        -- ]
        -- -------------------------------------------------

        if type(data) ~= "table" then

            callback(
                false,
                S(
                    "Translation service returned invalid data"
                )
            )

            return
        end


        if type(data[1]) ~= "table" then

            callback(
                false,
                S(
                    "Translation service returned no translation"
                )
            )

            return
        end


        local translated_parts = {}


        for _, part in ipairs(data[1]) do

            if type(part) == "table"
                and type(part[1]) == "string" then

                translated_parts[
                    #translated_parts + 1
                ] = part[1]
            end
        end


        local translated =
            table.concat(
                translated_parts,
                ""
            )


        if translated == "" then

            callback(
                false,
                S(
                    "Translation service returned empty text"
                )
            )

            return
        end


        -- -------------------------------------------------
        -- Google normally returns detected source language
        -- at index 3.
        -- -------------------------------------------------

        local detected_source = source


        if type(data[3]) == "string"
            and data[3] ~= "" then

            detected_source =
                normalize_language(data[3])
                or data[3]
        end


        if detected_source == "zh-CN" then
            detected_source = "zh"
        elseif detected_source == "zh-TW" then
            detected_source = "zh_HANT"
        end


        core.log(
            "action",
            "[babelfish_engine_lingva] Translation result: " ..
            translated
        )


        core.log(
            "action",
            "[babelfish_engine_lingva] Detected source: " ..
            tostring(detected_source)
        )


        callback(
            true,
            translated,
            detected_source
        )
    end)
end


-- =========================================================
-- MINETEST LANGUAGE MAP
-- =========================================================

local mt_language_map = {

    ["es_US"] = "es",

    ["en_US"] = "en",
    ["en_GB"] = "en",

    ["fr_FR"] = "fr",

    ["de_DE"] = "de",

    ["it_IT"] = "it",

    ["pt_BR"] = "pt",
    ["pt_PT"] = "pt",

    ["lzh"] = "zh_HANT",

    ["zh_CN"] = "zh",
    ["zh_TW"] = "zh_HANT",

    ["sr_Cyrl"] = "sr",
    ["sr_Latn"] = "sr",
}


-- =========================================================
-- ENGINE READY
-- =========================================================

engine_status = "ready"


core.log(
    "action",
    "[babelfish_engine_lingva] Google Translate backend ready"
)


-- =========================================================
-- REGISTER ENGINE
-- =========================================================

babelfish.register_engine({

    translate = translate,

    language_codes = language_codes,

    language_alias = language_alias,

    mt_language_map = mt_language_map,

    compliance = nil,

    engine_label = "Google Translate",
})