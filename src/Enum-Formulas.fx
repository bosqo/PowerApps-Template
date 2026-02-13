// ============================================================
// ENUM-FORMULAS - Power Fx Enumeration Named Formulas
// Reusable lookup tables for colors, icons, and error kinds
// ============================================================
//
// PURPOSE:
// Centralizes all enumeration data as Named Formulas to keep
// App-Formulas-Template.fx focused on business logic and UDFs.
//
// USAGE:
// Paste this content into App.Formulas BEFORE or AFTER the
// main App-Formulas-Template.fx content. Named Formulas have
// no ordering dependency (they are lazy-evaluated).
//
// SOURCES:
// Based on PowerAppsDarren/PowerFxSnippets (MIT License)
// - color-enum-in-named-formula.md (140 web colors)
// - error-kinds.md (31 error kinds, converted to Named Formula)
// - icons-as-collection.md (178 icons with metadata)
//
// ENUMERATIONS IN THIS FILE:
// - fxWebColors  (140 records) - All standard web colors with RGB, hex, categories
// - fxErrorKinds (31 records)  - Power Apps ErrorKind enum as searchable table
// - fxIcons      (178 records) - All canvas app icons with descriptions and tags
//
// ============================================================


// ============================================================
// SECTION 1: WEB COLORS ENUMERATION (140 colors)
// ============================================================
//
// Usage:
//   LookUp(fxWebColors, Name = "CornflowerBlue").Value    // Get Color value
//   Filter(fxWebColors, Category = "Blues")                // All blue colors
//   LookUp(fxWebColors, Name = "Tomato").HexCode           // Get hex code
//
// Fields: ID, Name, HexCode, Value, Red, Green, Blue,
//         Category, Tags, ComplementaryHex, AccentHex, Alpha
// ============================================================

/* ======================================================================
    fxWebColors - all 140 web colors defined here in a collection
   =================================================================== */
fxWebColors = [
    {
        ID:                 1,
        Name:               "AliceBlue",
        HexCode:            "#F0F8FF",
        Value:              ColorValue("#F0F8FF"),
        Red:                240,
        Green:              248,
        Blue:               255,
        Category:           "Whites",
        Tags:               ["neutral", "background", "light"],
        ComplementaryHex:   "#F0F8FF",
        AccentHex:          "#ADD8E6",
        Alpha:              1
    },
    {
        ID:                 2,
        Name:               "AntiqueWhite",
        HexCode:            "#FAEBD7",
        Value:              ColorValue("#FAEBD7"),
        Red:                250,
        Green:              235,
        Blue:               215,
        Category:           "Beiges",
        Tags:               ["warm", "background", "soft"],
        ComplementaryHex:   "#DFF5E6",
        AccentHex:          "#FFB6C1",
        Alpha:              1
    },
    {
        ID:                 3,
        Name:               "Aqua",
        HexCode:            "#00FFFF",
        Value:              ColorValue("#00FFFF"),
        Red:                0,
        Green:              255,
        Blue:               255,
        Category:           "Cyan/Aqua",
        Tags:               ["bright", "water", "vibrant"],
        ComplementaryHex:   "#FF00FF",
        AccentHex:          "#FFD700",
        Alpha:              1
    },
    {
        ID:                 4,
        Name:               "Aquamarine",
        HexCode:            "#7FFFD4",
        Value:              ColorValue("#7FFFD4"),
        Red:                127,
        Green:              255,
        Blue:               212,
        Category:           "Cyan/Aqua",
        Tags:               ["refreshing", "tropical", "bright"],
        ComplementaryHex:   "#7FFFD4",
        AccentHex:          "#FF6347",
        Alpha:              1
    },
    {
        ID:                 5,
        Name:               "Azure",
        HexCode:            "#F0FFFF",
        Value:              ColorValue("#F0FFFF"),
        Red:                240,
        Green:              255,
        Blue:               255,
        Category:           "Whites",
        Tags:               ["soft", "clean", "light"],
        ComplementaryHex:   "#F0FFFF",
        AccentHex:          "#FF69B4",
        Alpha:              1
    },
    {
        ID:                 6,
        Name:               "Beige",
        HexCode:            "#F5F5DC",
        Value:              ColorValue("#F5F5DC"),
        Red:                245,
        Green:              245,
        Blue:               220,
        Category:           "Beiges",
        Tags:               ["neutral", "calm", "warm"],
        ComplementaryHex:   "#000000",
        AccentHex:          "#008080",
        Alpha:              1
    },
    {
        ID:                 7,
        Name:               "Bisque",
        HexCode:            "#FFE4C4",
        Value:              ColorValue("#FFE4C4"),
        Red:                255,
        Green:              228,
        Blue:               196,
        Category:           "Beiges",
        Tags:               ["soft", "warm", "neutral"],
        ComplementaryHex:   "#D2691E",
        AccentHex:          "#FFD700",
        Alpha:              1
    },
    {
        ID:                 8,
        Name:               "Black",
        HexCode:            "#000000",
        Value:              ColorValue("#000000"),
        Red:                0,
        Green:              0,
        Blue:               0,
        Category:           "Blacks",
        Tags:               ["dark", "bold", "classic"],
        ComplementaryHex:   "#FFFFFF",
        AccentHex:          "#FF4500",
        Alpha:              1
    },
    {
        ID:                 9,
        Name:               "BlanchedAlmond",
        HexCode:            "#FFEBCD",
        Value:              ColorValue("#FFEBCD"),
        Red:                255,
        Green:              235,
        Blue:               205,
        Category:           "Beiges",
        Tags:               ["warm", "soft", "neutral"],
        ComplementaryHex:   "#FF6347",
        AccentHex:          "#FF69B4",
        Alpha:              1
    },
    {
        ID:                 10,
        Name:               "Blue",
        HexCode:            "#0000FF",
        Value:              ColorValue("#0000FF"),
        Red:                0,
        Green:              0,
        Blue:               255,
        Category:           "Blues",
        Tags:               ["bold", "primary", "vibrant"],
        ComplementaryHex:   "#FFFF00",
        AccentHex:          "#00FFFF",
        Alpha:              1
    },
    {
        ID:                 11,
        Name:               "BlueViolet",
        HexCode:            "#8A2BE2",
        Value:              ColorValue("#8A2BE2"),
        Red:                138,
        Green:              43,
        Blue:               226,
        Category:           "Purples",
        Tags:               ["vivid", "mysterious", "deep"],
        ComplementaryHex:   "#8A2BE2",
        AccentHex:          "#FF4500",
        Alpha:              1
    },
    {
        ID:                 12,
        Name:               "Brown",
        HexCode:            "#A52A2A",
        Value:              ColorValue("#A52A2A"),
        Red:                165,
        Green:              42,
        Blue:               42,
        Category:           "Browns",
        Tags:               ["earthy", "warm", "classic"],
        ComplementaryHex:   "#40E0D0",
        AccentHex:          "#A52A2A",
        Alpha:              1
    },
    {
        ID:                 13,
        Name:               "BurlyWood",
        HexCode:            "#DEB887",
        Value:              ColorValue("#DEB887"),
        Red:                222,
        Green:              184,
        Blue:               135,
        Category:           "Browns",
        Tags:               ["warm", "earthy", "neutral"],
        ComplementaryHex:   "#8B4513",
        AccentHex:          "#FFD700",
        Alpha:              1
    },
    {
        ID:                 14,
        Name:               "CadetBlue",
        HexCode:            "#5F9EA0",
        Value:              ColorValue("#5F9EA0"),
        Red:                95,
        Green:              158,
        Blue:               160,
        Category:           "Blues",
        Tags:               ["calm", "cool", "muted"],
        ComplementaryHex:   "#5F9EA0",
        AccentHex:          "#7FFF00",
        Alpha:              1
    },
    {
        ID:                 15,
        Name:               "Chartreuse",
        HexCode:            "#7FFF00",
        Value:              ColorValue("#7FFF00"),
        Red:                127,
        Green:              255,
        Blue:               0,
        Category:           "Greens",
        Tags:               ["vibrant", "nature", "bright"],
        ComplementaryHex:   "#FF0000",
        AccentHex:          "#FF4500",
        Alpha:              1
    },
    {
        ID:                 16,
        Name:               "Chocolate",
        HexCode:            "#D2691E",
        Value:              ColorValue("#D2691E"),
        Red:                210,
        Green:              105,
        Blue:               30,
        Category:           "Browns",
        Tags:               ["warm", "rich", "earthy"],
        ComplementaryHex:   "#FFE4B5",
        AccentHex:          "#FFD700",
        Alpha:              1
    },
    {
        ID:                 17,
        Name:               "Coral",
        HexCode:            "#FF7F50",
        Value:              ColorValue("#FF7F50"),
        Red:                255,
        Green:              127,
        Blue:               80,
        Category:           "Oranges",
        Tags:               ["vibrant", "fresh", "tropical"],
        ComplementaryHex:   "#7FFF00",
        AccentHex:          "#FF7F50",
        Alpha:              1
    },
    {
        ID:                 18,
        Name:               "CornflowerBlue",
        HexCode:            "#6495ED",
        Value:              ColorValue("#6495ED"),
        Red:                100,
        Green:              149,
        Blue:               237,
        Category:           "Blues",
        Tags:               ["calm", "cool", "soft"],
        ComplementaryHex:   "#6495ED",
        AccentHex:          "#00BFFF",
        Alpha:              1
    },
    {
        ID:                 19,
        Name:               "Cornsilk",
        HexCode:            "#FFF8DC",
        Value:              ColorValue("#FFF8DC"),
        Red:                255,
        Green:              248,
        Blue:               220,
        Category:           "Beiges",
        Tags:               ["warm", "neutral", "soft"],
        ComplementaryHex:   "#8B0000",
        AccentHex:          "#FF4500",
        Alpha:              1
    },
    {
        ID:                 20,
        Name:               "Crimson",
        HexCode:            "#DC143C",
        Value:              ColorValue("#DC143C"),
        Red:                220,
        Green:              20,
        Blue:               60,
        Category:           "Reds",
        Tags:               ["bold", "deep", "passionate"],
        ComplementaryHex:   "#DC143C",
        AccentHex:          "#B22222",
        Alpha:              1
    },
    {
        ID:                 21,
        Name:               "Cyan",
        HexCode:            "#00FFFF",
        Value:              ColorValue("#00FFFF"),
        Red:                0,
        Green:              255,
        Blue:               255,
        Category:           "Cyan/Aqua",
        Tags:               ["bright", "vibrant", "cool"],
        ComplementaryHex:   "#FF00FF",
        AccentHex:          "#FFD700",
        Alpha:              1
    },
    {
        ID:                 22,
        Name:               "DarkBlue",
        HexCode:            "#00008B",
        Value:              ColorValue("#00008B"),
        Red:                0,
        Green:              0,
        Blue:               139,
        Category:           "Blues",
        Tags:               ["deep", "cool", "bold"],
        ComplementaryHex:   "#8B0000",
        AccentHex:          "#0000FF",
        Alpha:              1
    },
    {
        ID:                 23,
        Name:               "DarkCyan",
        HexCode:            "#008B8B",
        Value:              ColorValue("#008B8B"),
        Red:                0,
        Green:              139,
        Blue:               139,
        Category:           "Cyan/Aqua",
        Tags:               ["deep", "cool", "muted"],
        ComplementaryHex:   "#00FFFF",
        AccentHex:          "#008B8B",
        Alpha:              1
    },
    {
        ID:                 24,
        Name:               "DarkGoldenRod",
        HexCode:            "#B8860B",
        Value:              ColorValue("#B8860B"),
        Red:                184,
        Green:              134,
        Blue:               11,
        Category:           "Browns",
        Tags:               ["warm", "earthy", "rich"],
        ComplementaryHex:   "#B8860B",
        AccentHex:          "#FF8C00",
        Alpha:              1
    },
    {
        ID:                 25,
        Name:               "DarkGray",
        HexCode:            "#A9A9A9",
        Value:              ColorValue("#A9A9A9"),
        Red:                169,
        Green:              169,
        Blue:               169,
        Category:           "Grays",
        Tags:               ["neutral", "cool", "muted"],
        ComplementaryHex:   "#FFFFFF",
        AccentHex:          "#A9A9A9",
        Alpha:              1
    },
    {
        ID:                 26,
        Name:               "DarkGreen",
        HexCode:            "#006400",
        Value:              ColorValue("#006400"),
        Red:                0,
        Green:              100,
        Blue:               0,
        Category:           "Greens",
        Tags:               ["deep", "nature", "rich"],
        ComplementaryHex:   "#FFFF00",
        AccentHex:          "#006400",
        Alpha:              1
    },
    {
        ID:                 27,
        Name:               "DarkKhaki",
        HexCode:            "#BDB76B",
        Value:              ColorValue("#BDB76B"),
        Red:                189,
        Green:              183,
        Blue:               107,
        Category:           "Yellows",
        Tags:               ["muted", "earthy", "soft"],
        ComplementaryHex:   "#FFFF66",
        AccentHex:          "#BDB76B",
        Alpha:              1
    },
    {
        ID:                 28,
        Name:               "DarkMagenta",
        HexCode:            "#8B008B",
        Value:              ColorValue("#8B008B"),
        Red:                139,
        Green:              0,
        Blue:               139,
        Category:           "Purples",
        Tags:               ["deep", "mysterious", "rich"],
        ComplementaryHex:   "#008000",
        AccentHex:          "#8B008B",
        Alpha:              1
    },
    {
        ID:                 29,
        Name:               "DarkOliveGreen",
        HexCode:            "#556B2F",
        Value:              ColorValue("#556B2F"),
        Red:                85,
        Green:              107,
        Blue:               47,
        Category:           "Greens",
        Tags:               ["earthy", "natural", "muted"],
        ComplementaryHex:   "#FF6347",
        AccentHex:          "#556B2F",
        Alpha:              1
    },
    {
        ID:                 30,
        Name:               "DarkOrange",
        HexCode:            "#FF8C00",
        Value:              ColorValue("#FF8C00"),
        Red:                255,
        Green:              140,
        Blue:               0,
        Category:           "Oranges",
        Tags:               ["vibrant", "warm", "bold"],
        ComplementaryHex:   "#FF4500",
        AccentHex:          "#FF8C00",
        Alpha:              1
    },
    {
        ID:                 31,
        Name:               "DarkOrchid",
        HexCode:            "#9932CC",
        Value:              ColorValue("#9932CC"),
        Red:                153,
        Green:              50,
        Blue:               204,
        Category:           "Purples",
        Tags:               ["vivid", "mysterious", "deep"],
        ComplementaryHex:   "#9932CC",
        AccentHex:          "#DA70D6",
        Alpha:              1
    },
    {
        ID:                 32,
        Name:               "DarkRed",
        HexCode:            "#8B0000",
        Value:              ColorValue("#8B0000"),
        Red:                139,
        Green:              0,
        Blue:               0,
        Category:           "Reds",
        Tags:               ["deep", "bold", "passionate"],
        ComplementaryHex:   "#8B0000",
        AccentHex:          "#8B0000",
        Alpha:              1
    },
    {
        ID:                 33,
        Name:               "DarkSalmon",
        HexCode:            "#E9967A",
        Value:              ColorValue("#E9967A"),
        Red:                233,
        Green:              150,
        Blue:               122,
        Category:           "Pinks",
        Tags:               ["soft", "warm", "muted"],
        ComplementaryHex:   "#FA8072",
        AccentHex:          "#FFA07A",
        Alpha:              1
    },
    {
        ID:                 34,
        Name:               "DarkSeaGreen",
        HexCode:            "#8FBC8F",
        Value:              ColorValue("#8FBC8F"),
        Red:                143,
        Green:              188,
        Blue:               143,
        Category:           "Greens",
        Tags:               ["cool", "natural", "calm"],
        ComplementaryHex:   "#8FBC8F",
        AccentHex:          "#8FBC8F",
        Alpha:              1
    },
    {
        ID:                 35,
        Name:               "DarkSlateBlue",
        HexCode:            "#483D8B",
        Value:              ColorValue("#483D8B"),
        Red:                72,
        Green:              61,
        Blue:               139,
        Category:           "Purples",
        Tags:               ["deep", "mysterious", "cool"],
        ComplementaryHex:   "#483D8B",
        AccentHex:          "#483D8B",
        Alpha:              1
    },
    {
        ID:                 36,
        Name:               "DarkSlateGray",
        HexCode:            "#2F4F4F",
        Value:              ColorValue("#2F4F4F"),
        Red:                47,
        Green:              79,
        Blue:               79,
        Category:           "Grays",
        Tags:               ["cool", "muted", "dark"],
        ComplementaryHex:   "#2F4F4F",
        AccentHex:          "#2F4F4F",
        Alpha:              1
    },
    {
        ID:                 37,
        Name:               "DarkTurquoise",
        HexCode:            "#00CED1",
        Value:              ColorValue("#00CED1"),
        Red:                0,
        Green:              206,
        Blue:               209,
        Category:           "Cyan/Aqua",
        Tags:               ["vibrant", "cool", "bright"],
        ComplementaryHex:   "#00CED1",
        AccentHex:          "#40E0D0",
        Alpha:              1
    },
    {
        ID:                 38,
        Name:               "DarkViolet",
        HexCode:            "#9400D3",
        Value:              ColorValue("#9400D3"),
        Red:                148,
        Green:              0,
        Blue:               211,
        Category:           "Purples",
        Tags:               ["vivid", "mysterious", "deep"],
        ComplementaryHex:   "#EE82EE",
        AccentHex:          "#9400D3",
        Alpha:              1
    },
    {
        ID:                 39,
        Name:               "DeepPink",
        HexCode:            "#FF1493",
        Value:              ColorValue("#FF1493"),
        Red:                255,
        Green:              20,
        Blue:               147,
        Category:           "Pinks",
        Tags:               ["vivid", "playful", "bright"],
        ComplementaryHex:   "#FF1493",
        AccentHex:          "#FF1493",
        Alpha:              1
    },
    {
        ID:                 40,
        Name:               "DeepSkyBlue",
        HexCode:            "#00BFFF",
        Value:              ColorValue("#00BFFF"),
        Red:                0,
        Green:              191,
        Blue:               255,
        Category:           "Blues",
        Tags:               ["bright", "cool", "vibrant"],
        ComplementaryHex:   "#00BFFF",
        AccentHex:          "#00BFFF",
        Alpha:              1
    },
    {
        ID:                 41,
        Name:               "DimGray",
        HexCode:            "#696969",
        Value:              ColorValue("#696969"),
        Red:                105,
        Green:              105,
        Blue:               105,
        Category:           "Grays",
        Tags:               ["muted", "cool", "dark"],
        ComplementaryHex:   "#696969",
        AccentHex:          "#696969",
        Alpha:              1
    },
    {
        ID:                 42,
        Name:               "DodgerBlue",
        HexCode:            "#1E90FF",
        Value:              ColorValue("#1E90FF"),
        Red:                30,
        Green:              144,
        Blue:               255,
        Category:           "Blues",
        Tags:               ["vibrant", "cool", "bright"],
        ComplementaryHex:   "#1E90FF",
        AccentHex:          "#1E90FF",
        Alpha:              1
    },
    {
        ID:                 43,
        Name:               "FireBrick",
        HexCode:            "#B22222",
        Value:              ColorValue("#B22222"),
        Red:                178,
        Green:              34,
        Blue:               34,
        Category:           "Reds",
        Tags:               ["warm", "bold", "earthy"],
        ComplementaryHex:   "#B22222",
        AccentHex:          "#FF6347",
        Alpha:              1
    },
    {
        ID:                 44,
        Name:               "FloralWhite",
        HexCode:            "#FFFAF0",
        Value:              ColorValue("#FFFAF0"),
        Red:                255,
        Green:              250,
        Blue:               240,
        Category:           "Whites",
        Tags:               ["soft", "neutral", "light"],
        ComplementaryHex:   "#FFFAF0",
        AccentHex:          "#F5FFFA",
        Alpha:              1
    },
    {
        ID:                 45,
        Name:               "ForestGreen",
        HexCode:            "#228B22",
        Value:              ColorValue("#228B22"),
        Red:                34,
        Green:              139,
        Blue:               34,
        Category:           "Greens",
        Tags:               ["natural", "rich", "deep"],
        ComplementaryHex:   "#228B22",
        AccentHex:          "#228B22",
        Alpha:              1
    },
    {
        ID:                 46,
        Name:               "Fuchsia",
        HexCode:            "#FF00FF",
        Value:              ColorValue("#FF00FF"),
        Red:                255,
        Green:              0,
        Blue:               255,
        Category:           "Magenta",
        Tags:               ["vivid", "bold", "bright"],
        ComplementaryHex:   "#FF00FF",
        AccentHex:          "#FF00FF",
        Alpha:              1
    },
    {
        ID:                 47,
        Name:               "Gainsboro",
        HexCode:            "#DCDCDC",
        Value:              ColorValue("#DCDCDC"),
        Red:                220,
        Green:              220,
        Blue:               220,
        Category:           "Grays",
        Tags:               ["light", "neutral", "soft"],
        ComplementaryHex:   "#DCDCDC",
        AccentHex:          "#DCDCDC",
        Alpha:              1
    },
    {
        ID:                 48,
        Name:               "GhostWhite",
        HexCode:            "#F8F8FF",
        Value:              ColorValue("#F8F8FF"),
        Red:                248,
        Green:              248,
        Blue:               255,
        Category:           "Whites",
        Tags:               ["soft", "neutral", "light"],
        ComplementaryHex:   "#F8F8FF",
        AccentHex:          "#F8F8FF",
        Alpha:              1
    },
    {
        ID:                 49,
        Name:               "Gold",
        HexCode:            "#FFD700",
        Value:              ColorValue("#FFD700"),
        Red:                255,
        Green:              215,
        Blue:               0,
        Category:           "Golds",
        Tags:               ["vibrant", "luxury", "bright"],
        ComplementaryHex:   "#FFD700",
        AccentHex:          "#FFD700",
        Alpha:              1
    },
    {
        ID:                 50,
        Name:               "GoldenRod",
        HexCode:            "#DAA520",
        Value:              ColorValue("#DAA520"),
        Red:                218,
        Green:              165,
        Blue:               32,
        Category:           "Golds",
        Tags:               ["warm", "luxury", "rich"],
        ComplementaryHex:   "#DAA520",
        AccentHex:          "#DAA520",
        Alpha:              1
    },
    {
        ID:                 51,
        Name:               "Gray",
        HexCode:            "#808080",
        Value:              ColorValue("#808080"),
        Red:                128,
        Green:              128,
        Blue:               128,
        Category:           "Grays",
        Tags:               ["neutral", "dark", "muted"],
        ComplementaryHex:   "#A9A9A9",
        AccentHex:          "#A9A9A9",
        Alpha:              1
    },
    {
        ID:                 52,
        Name:               "Green",
        HexCode:            "#008000",
        Value:              ColorValue("#008000"),
        Red:                0,
        Green:              128,
        Blue:               0,
        Category:           "Greens",
        Tags:               ["natural", "fresh", "deep"],
        ComplementaryHex:   "#FF0000",
        AccentHex:          "#008000",
        Alpha:              1
    },
    {
        ID:                 53,
        Name:               "GreenYellow",
        HexCode:            "#ADFF2F",
        Value:              ColorValue("#ADFF2F"),
        Red:                173,
        Green:              255,
        Blue:               47,
        Category:           "Greens",
        Tags:               ["bright", "vibrant", "fresh"],
        ComplementaryHex:   "#ADFF2F",
        AccentHex:          "#ADFF2F",
        Alpha:              1
    },
    {
        ID:                 54,
        Name:               "HoneyDew",
        HexCode:            "#F0FFF0",
        Value:              ColorValue("#F0FFF0"),
        Red:                240,
        Green:              255,
        Blue:               240,
        Category:           "Whites",
        Tags:               ["soft", "neutral", "light"],
        ComplementaryHex:   "#F0FFF0",
        AccentHex:          "#F0FFF0",
        Alpha:              1
    },
    {
        ID:                 55,
        Name:               "HotPink",
        HexCode:            "#FF69B4",
        Value:              ColorValue("#FF69B4"),
        Red:                255,
        Green:              105,
        Blue:               180,
        Category:           "Pinks",
        Tags:               ["playful", "vivid", "bright"],
        ComplementaryHex:   "#FF69B4",
        AccentHex:          "#FF69B4",
        Alpha:              1
    },
    {
        ID:                 56,
        Name:               "IndianRed",
        HexCode:            "#CD5C5C",
        Value:              ColorValue("#CD5C5C"),
        Red:                205,
        Green:              92,
        Blue:               92,
        Category:           "Reds",
        Tags:               ["warm", "earthy", "rich"],
        ComplementaryHex:   "#CD5C5C",
        AccentHex:          "#CD5C5C",
        Alpha:              1
    },
    {
        ID:                 57,
        Name:               "Indigo",
        HexCode:            "#4B0082",
        Value:              ColorValue("#4B0082"),
        Red:                75,
        Green:              0,
        Blue:               130,
        Category:           "Purples",
        Tags:               ["deep", "mysterious", "rich"],
        ComplementaryHex:   "#4B0082",
        AccentHex:          "#4B0082",
        Alpha:              1
    },
    {
        ID:                 58,
        Name:               "Ivory",
        HexCode:            "#FFFFF0",
        Value:              ColorValue("#FFFFF0"),
        Red:                255,
        Green:              255,
        Blue:               240,
        Category:           "Whites",
        Tags:               ["light", "soft", "neutral"],
        ComplementaryHex:   "#000000",
        AccentHex:          "#F5DEB3",
        Alpha:              1
    },
    {
        ID:                 59,
        Name:               "Khaki",
        HexCode:            "#F0E68C",
        Value:              ColorValue("#F0E68C"),
        Red:                240,
        Green:              230,
        Blue:               140,
        Category:           "Yellows",
        Tags:               ["warm", "soft", "light"],
        ComplementaryHex:   "#F5DEB3",
        AccentHex:          "#FFFACD",
        Alpha:              1
    },
    {
        ID:                 60,
        Name:               "Lavender",
        HexCode:            "#E6E6FA",
        Value:              ColorValue("#E6E6FA"),
        Red:                230,
        Green:              230,
        Blue:               250,
        Category:           "Purples",
        Tags:               ["soft", "light", "neutral"],
        ComplementaryHex:   "#800080",
        AccentHex:          "#F5F5DC",
        Alpha:              1
    },
    {
        ID:                 61,
        Name:               "LavenderBlush",
        HexCode:            "#FFF0F5",
        Value:              ColorValue("#FFF0F5"),
        Red:                255,
        Green:              240,
        Blue:               245,
        Category:           "Pinks",
        Tags:               ["vibrant", "fresh", "bright"],
        ComplementaryHex:   "#F0E68C",
        AccentHex:          "#FFF0F5",
        Alpha:              1
    },
    {
        ID:                 62,
        Name:               "LawnGreen",
        HexCode:            "#7CFC00",
        Value:              ColorValue("#7CFC00"),
        Red:                124,
        Green:              252,
        Blue:               0,
        Category:           "Greens",
        Tags:               ["soft", "light", "warm"],
        ComplementaryHex:   "#E6E6FA",
        AccentHex:          "#E6E6FA",
        Alpha:              1
    },
    {
        ID:                 63,
        Name:               "LemonChiffon",
        HexCode:            "#FFFACD",
        Value:              ColorValue("#FFFACD"),
        Red:                255,
        Green:              250,
        Blue:               205,
        Category:           "Yellows",
        Tags:               ["cool", "soft", "light"],
        ComplementaryHex:   "#FFF0F5",
        AccentHex:          "#FFB6C1",
        Alpha:              1
    },
    {
        ID:                 64,
        Name:               "LightBlue",
        HexCode:            "#ADD8E6",
        Value:              ColorValue("#ADD8E6"),
        Red:                173,
        Green:              216,
        Blue:               230,
        Category:           "Blues",
        Tags:               ["soft", "warm", "muted"],
        ComplementaryHex:   "#32CD32",
        AccentHex:          "#FFFACD",
        Alpha:              1
    },
    {
        ID:                 65,
        Name:               "LightCoral",
        HexCode:            "#F08080",
        Value:              ColorValue("#F08080"),
        Red:                240,
        Green:              128,
        Blue:               128,
        Category:           "Pinks",
        Tags:               ["light", "bright", "neutral"],
        ComplementaryHex:   "#FFFACD",
        AccentHex:          "#00FFFF",
        Alpha:              1
    },
    {
        ID:                 66,
        Name:               "LightCyan",
        HexCode:            "#E0FFFF",
        Value:              ColorValue("#E0FFFF"),
        Red:                224,
        Green:              255,
        Blue:               255,
        Category:           "Whites",
        Tags:               ["soft", "calm", "muted"],
        ComplementaryHex:   "#ADD8E6",
        AccentHex:          "#FAFAD2",
        Alpha:              1
    },
    {
        ID:                 67,
        Name:               "LightGoldenRodYellow",
        HexCode:            "#FAFAD2",
        Value:              ColorValue("#FAFAD2"),
        Red:                250,
        Green:              250,
        Blue:               210,
        Category:           "Yellows",
        Tags:               ["light", "soft", "neutral"],
        ComplementaryHex:   "#F08080",
        AccentHex:          "#D3D3D3",
        Alpha:              1
    },
    {
        ID:                 68,
        Name:               "LightGray",
        HexCode:            "#D3D3D3",
        Value:              ColorValue("#D3D3D3"),
        Red:                211,
        Green:              211,
        Blue:               211,
        Category:           "Grays",
        Tags:               ["bright", "fresh", "vibrant"],
        ComplementaryHex:   "#E0FFFF",
        AccentHex:          "#98FB98",
        Alpha:              1
    },
    {
        ID:                 69,
        Name:               "LightGreen",
        HexCode:            "#90EE90",
        Value:              ColorValue("#90EE90"),
        Red:                144,
        Green:              238,
        Blue:               144,
        Category:           "Greens",
        Tags:               ["light", "soft", "neutral"],
        ComplementaryHex:   "#FAFAD2",
        AccentHex:          "#FFB6C1",
        Alpha:              1
    },
    {
        ID:                 70,
        Name:               "LightPink",
        HexCode:            "#FFB6C1",
        Value:              ColorValue("#FFB6C1"),
        Red:                255,
        Green:              182,
        Blue:               193,
        Category:           "Pinks",
        Tags:               ["muted", "soft", "neutral"],
        ComplementaryHex:   "#D3D3D3",
        AccentHex:          "#FFA07A",
        Alpha:              1
    },
    {
        ID:                 71,
        Name:               "LightSalmon",
        HexCode:            "#FFA07A",
        Value:              ColorValue("#FFA07A"),
        Red:                255,
        Green:              160,
        Blue:               122,
        Category:           "Oranges",
        Tags:               ["calm", "natural", "soft"],
        ComplementaryHex:   "#90EE90",
        AccentHex:          "#20B2AA",
        Alpha:              1
    },
    {
        ID:                 72,
        Name:               "LightSeaGreen",
        HexCode:            "#20B2AA",
        Value:              ColorValue("#20B2AA"),
        Red:                32,
        Green:              178,
        Blue:               170,
        Category:           "Greens",
        Tags:               ["soft", "playful", "light"],
        ComplementaryHex:   "#FFB6C1",
        AccentHex:          "#87CEFA",
        Alpha:              1
    },
    {
        ID:                 73,
        Name:               "LightSkyBlue",
        HexCode:            "#87CEFA",
        Value:              ColorValue("#87CEFA"),
        Red:                135,
        Green:              206,
        Blue:               250,
        Category:           "Blues",
        Tags:               ["vibrant", "warm", "bright"],
        ComplementaryHex:   "#FFA07A",
        AccentHex:          "#778899",
        Alpha:              1
    },
    {
        ID:                 74,
        Name:               "LightSlateGray",
        HexCode:            "#778899",
        Value:              ColorValue("#778899"),
        Red:                119,
        Green:              136,
        Blue:               153,
        Category:           "Grays",
        Tags:               ["natural", "cool", "calm"],
        ComplementaryHex:   "#20B2AA",
        AccentHex:          "#B0C4DE",
        Alpha:              1
    },
    {
        ID:                 75,
        Name:               "LightSteelBlue",
        HexCode:            "#B0C4DE",
        Value:              ColorValue("#B0C4DE"),
        Red:                176,
        Green:              196,
        Blue:               222,
        Category:           "Blues",
        Tags:               ["soft", "light", "neutral"],
        ComplementaryHex:   "#87CEFA",
        AccentHex:          "#FFFFE0",
        Alpha:              1
    },
    {
        ID:                 76,
        Name:               "LightYellow",
        HexCode:            "#FFFFE0",
        Value:              ColorValue("#FFFFE0"),
        Red:                255,
        Green:              255,
        Blue:               224,
        Category:           "Yellows",
        Tags:               ["light", "fresh", "natural"],
        ComplementaryHex:   "#778899",
        AccentHex:          "#32CD32",
        Alpha:              1
    },
    {
        ID:                 77,
        Name:               "Lime",
        HexCode:            "#00FF00",
        Value:              ColorValue("#00FF00"),
        Red:                0,
        Green:              255,
        Blue:               0,
        Category:           "Greens",
        Tags:               ["soft", "light", "neutral"],
        ComplementaryHex:   "#B0C4DE",
        AccentHex:          "#00FF00",
        Alpha:              1
    },
    {
        ID:                 78,
        Name:               "LimeGreen",
        HexCode:            "#32CD32",
        Value:              ColorValue("#32CD32"),
        Red:                50,
        Green:              205,
        Blue:               50,
        Category:           "Greens",
        Tags:               ["bright", "vibrant", "fresh"],
        ComplementaryHex:   "#FFFFE0",
        AccentHex:          "#FAF0E6",
        Alpha:              1
    },
    {
        ID:                 79,
        Name:               "Linen",
        HexCode:            "#FAF0E6",
        Value:              ColorValue("#FAF0E6"),
        Red:                250,
        Green:              240,
        Blue:               230,
        Category:           "Beiges",
        Tags:               ["light", "cool", "calm"],
        ComplementaryHex:   "#00FF00",
        AccentHex:          "#FF00FF",
        Alpha:              1
    },
    {
        ID:                 80,
        Name:               "Magenta",
        HexCode:            "#FF00FF",
        Value:              ColorValue("#FF00FF"),
        Red:                255,
        Green:              0,
        Blue:               255,
        Category:           "Magenta",
        Tags:               ["muted", "cool", "neutral"],
        ComplementaryHex:   "#32CD32",
        AccentHex:          "#800000",
        Alpha:              1
    },
    {
        ID:                 81,
        Name:               "Maroon",
        HexCode:            "#800000",
        Value:              ColorValue("#800000"),
        Red:                128,
        Green:              0,
        Blue:               0,
        Category:           "Reds",
        Tags:               ["soft", "cool", "calm"],
        ComplementaryHex:   "#FAF0E6",
        AccentHex:          "#66CDAA",
        Alpha:              1
    },
    {
        ID:                 82,
        Name:               "MediumAquaMarine",
        HexCode:            "#66CDAA",
        Value:              ColorValue("#66CDAA"),
        Red:                102,
        Green:              205,
        Blue:               170,
        Category:           "Greens",
        Tags:               ["light", "neutral", "soft"],
        ComplementaryHex:   "#FF00FF",
        AccentHex:          "#0000CD",
        Alpha:              1
    },
    {
        ID:                 83,
        Name:               "MediumBlue",
        HexCode:            "#0000CD",
        Value:              ColorValue("#0000CD"),
        Red:                0,
        Green:              0,
        Blue:               205,
        Category:           "Blues",
        Tags:               ["bright", "vibrant", "fresh"],
        ComplementaryHex:   "#800000",
        AccentHex:          "#DA55D3",
        Alpha:              1
    },
    {
        ID:                 84,
        Name:               "MediumOrchid",
        HexCode:            "#BA55D3",
        Value:              ColorValue("#BA55D3"),
        Red:                186,
        Green:              85,
        Blue:               211,
        Category:           "Purples",
        Tags:               ["bright", "fresh", "vibrant"],
        ComplementaryHex:   "#66CDAA",
        AccentHex:          "#9370DB",
        Alpha:              1
    },
    {
        ID:                 85,
        Name:               "MediumPurple",
        HexCode:            "#9370DB",
        Value:              ColorValue("#9370DB"),
        Red:                147,
        Green:              112,
        Blue:               219,
        Category:           "Purples",
        Tags:               ["soft", "neutral", "warm"],
        ComplementaryHex:   "#0000CD",
        AccentHex:          "#3CB371",
        Alpha:              1
    },
    {
        ID:                 86,
        Name:               "MediumSeaGreen",
        HexCode:            "#3CB371",
        Value:              ColorValue("#3CB371"),
        Red:                60,
        Green:              179,
        Blue:               113,
        Category:           "Greens",
        Tags:               ["vivid", "playful", "bright"],
        ComplementaryHex:   "#BA55D3",
        AccentHex:          "#7B68EE",
        Alpha:              1
    },
    {
        ID:                 87,
        Name:               "MediumSlateBlue",
        HexCode:            "#7B68EE",
        Value:              ColorValue("#7B68EE"),
        Red:                123,
        Green:              104,
        Blue:               238,
        Category:           "Purples",
        Tags:               ["deep", "bold", "classic"],
        ComplementaryHex:   "#9370DB",
        AccentHex:          "#00FA9A",
        Alpha:              1
    },
    {
        ID:                 88,
        Name:               "MediumSpringGreen",
        HexCode:            "#00FA9A",
        Value:              ColorValue("#00FA9A"),
        Red:                0,
        Green:              250,
        Blue:               154,
        Category:           "Greens",
        Tags:               ["soft", "natural", "calm"],
        ComplementaryHex:   "#3CB371",
        AccentHex:          "#48D1CC",
        Alpha:              1
    },
    {
        ID:                 89,
        Name:               "MediumTurquoise",
        HexCode:            "#48D1CC",
        Value:              ColorValue("#48D1CC"),
        Red:                72,
        Green:              209,
        Blue:               204,
        Category:           "Cyan/Aqua",
        Tags:               ["bold", "deep", "cool"],
        ComplementaryHex:   "#7B68EE",
        AccentHex:          "#C71585",
        Alpha:              1
    },
    {
        ID:                 90,
        Name:               "MediumVioletRed",
        HexCode:            "#C71585",
        Value:              ColorValue("#C71585"),
        Red:                199,
        Green:              21,
        Blue:               133,
        Category:           "Pinks",
        Tags:               ["vivid", "playful", "bright"],
        ComplementaryHex:   "#00FA9A",
        AccentHex:          "#191970",
        Alpha:              1
    },
    {
        ID:                 91,
        Name:               "MidnightBlue",
        HexCode:            "#191970",
        Value:              ColorValue("#191970"),
        Red:                25,
        Green:              25,
        Blue:               112,
        Category:           "Blues",
        Tags:               ["soft", "calm", "muted"],
        ComplementaryHex:   "#48D1CC",
        AccentHex:          "#F5FFFA",
        Alpha:              1
    },
    {
        ID:                 92,
        Name:               "MintCream",
        HexCode:            "#F5FFFA",
        Value:              ColorValue("#F5FFFA"),
        Red:                245,
        Green:              255,
        Blue:               250,
        Category:           "Whites",
        Tags:               ["fresh", "vibrant", "bright"],
        ComplementaryHex:   "#C71585",
        AccentHex:          "#FFE4E1",
        Alpha:              1
    },
    {
        ID:                 93,
        Name:               "MistyRose",
        HexCode:            "#FFE4E1",
        Value:              ColorValue("#FFE4E1"),
        Red:                255,
        Green:              228,
        Blue:               225,
        Category:           "Pinks",
        Tags:               ["cool", "vibrant", "fresh"],
        ComplementaryHex:   "#191970",
        AccentHex:          "#FFE4B5",
        Alpha:              1
    },
    {
        ID:                 94,
        Name:               "Moccasin",
        HexCode:            "#FFE4B5",
        Value:              ColorValue("#FFE4B5"),
        Red:                255,
        Green:              228,
        Blue:               181,
        Category:           "Beiges",
        Tags:               ["bold", "deep", "passionate"],
        ComplementaryHex:   "#F5FFFA",
        AccentHex:          "#FFA07A",
        Alpha:              1
    },
    {
        ID:                 95,
        Name:               "NavajoWhite",
        HexCode:            "#FFDEAD",
        Value:              ColorValue("#FFDEAD"),
        Red:                255,
        Green:              222,
        Blue:               173,
        Category:           "Beiges",
        Tags:               ["soft", "light", "warm"],
        ComplementaryHex:   "#FFE4E1",
        AccentHex:          "#000080",
        Alpha:              1
    },
    {
        ID:                 96,
        Name:               "Navy",
        HexCode:            "#000080",
        Value:              ColorValue("#000080"),
        Red:                0,
        Green:              0,
        Blue:               128,
        Category:           "Blues",
        Tags:               ["soft", "light", "warm"],
        ComplementaryHex:   "#FFE4B5",
        AccentHex:          "#FDF5E6",
        Alpha:              1
    },
    {
        ID:                 97,
        Name:               "OldLace",
        HexCode:            "#FDF5E6",
        Value:              ColorValue("#FDF5E6"),
        Red:                253,
        Green:              245,
        Blue:               230,
        Category:           "Beiges",
        Tags:               ["soft", "light", "neutral"],
        ComplementaryHex:   "#FFDEAD",
        AccentHex:          "#808000",
        Alpha:              1
    },
    {
        ID:                 98,
        Name:               "Olive",
        HexCode:            "#808000",
        Value:              ColorValue("#808000"),
        Red:                128,
        Green:              128,
        Blue:               0,
        Category:           "Greens",
        Tags:               ["bold", "deep", "classic"],
        ComplementaryHex:   "#000080",
        AccentHex:          "#6B8E23",
        Alpha:              1
    },
    {
        ID:                 99,
        Name:               "OliveDrab",
        HexCode:            "#6B8E23",
        Value:              ColorValue("#6B8E23"),
        Red:                107,
        Green:              142,
        Blue:               35,
        Category:           "Greens",
        Tags:               ["soft", "light", "neutral"],
        ComplementaryHex:   "#FDF5E6",
        AccentHex:          "#FF4500",
        Alpha:              1
    },
    {
        ID:                 100,
        Name:               "Orange",
        HexCode:            "#FFA500",
        Value:              ColorValue("#FFA500"),
        Red:                255,
        Green:              165,
        Blue:               0,
        Category:           "Oranges",
        Tags:               ["earthy", "natural", "muted"],
        ComplementaryHex:   "#808000",
        AccentHex:          "#000080",
        Alpha:              1
    },
    {
        ID:                 101,
        Name:               "OrangeRed",
        HexCode:            "#FF4500",
        Value:              ColorValue("#FF4500"),
        Red:                255,
        Green:              69,
        Blue:               0,
        Category:           "Oranges",
        Tags:               ["natural", "muted", "earthy"],
        ComplementaryHex:   "#6B8E23",
        AccentHex:          "#FFA07A",
        Alpha:              1
    },
    {
        ID:                 102,
        Name:               "Orchid",
        HexCode:            "#DA70D6",
        Value:              ColorValue("#DA70D6"),
        Red:                218,
        Green:              112,
        Blue:               214,
        Category:           "Purples",
        Tags:               ["vibrant", "warm", "bright"],
        ComplementaryHex:   "#FF4500",
        AccentHex:          "#EE82EE",
        Alpha:              1
    },
    {
        ID:                 103,
        Name:               "PaleGoldenRod",
        HexCode:            "#EEE8AA",
        Value:              ColorValue("#EEE8AA"),
        Red:                238,
        Green:              232,
        Blue:               170,
        Category:           "Yellows",
        Tags:               ["vivid", "bold", "bright"],
        ComplementaryHex:   "#FF4500",
        AccentHex:          "#98FB98",
        Alpha:              1
    },
    {
        ID:                 104,
        Name:               "PaleGreen",
        HexCode:            "#98FB98",
        Value:              ColorValue("#98FB98"),
        Red:                152,
        Green:              251,
        Blue:               152,
        Category:           "Greens",
        Tags:               ["vivid", "playful", "bright"],
        ComplementaryHex:   "#DA70D6",
        AccentHex:          "#AFEEEE",
        Alpha:              1
    },
    {
        ID:                 105,
        Name:               "PaleTurquoise",
        HexCode:            "#AFEEEE",
        Value:              ColorValue("#AFEEEE"),
        Red:                175,
        Green:              238,
        Blue:               238,
        Category:           "Cyan/Aqua",
        Tags:               ["soft", "muted", "warm"],
        ComplementaryHex:   "#EEE8AA",
        AccentHex:          "#DB7093",
        Alpha:              1
    },
    {
        ID:                 106,
        Name:               "PaleVioletRed",
        HexCode:            "#DB7093",
        Value:              ColorValue("#DB7093"),
        Red:                219,
        Green:              112,
        Blue:               147,
        Category:           "Pinks",
        Tags:               ["fresh", "calm", "light"],
        ComplementaryHex:   "#98FB98",
        AccentHex:          "#FFEFD5",
        Alpha:              1
    },
    {
        ID:                 107,
        Name:               "PapayaWhip",
        HexCode:            "#FFEFD5",
        Value:              ColorValue("#FFEFD5"),
        Red:                255,
        Green:              239,
        Blue:               213,
        Category:           "Beiges",
        Tags:               ["cool", "calm", "soft"],
        ComplementaryHex:   "#AFEEEE",
        AccentHex:          "#FFDAB9",
        Alpha:              1
    },
    {
        ID:                 108,
        Name:               "PeachPuff",
        HexCode:            "#FFDAB9",
        Value:              ColorValue("#FFDAB9"),
        Red:                255,
        Green:              218,
        Blue:               185,
        Category:           "Oranges",
        Tags:               ["soft", "calm", "muted"],
        ComplementaryHex:   "#DB7093",
        AccentHex:          "#CD853F",
        Alpha:              1
    },
    {
        ID:                 109,
        Name:               "Peru",
        HexCode:            "#CD853F",
        Value:              ColorValue("#CD853F"),
        Red:                205,
        Green:              133,
        Blue:               63,
        Category:           "Browns",
        Tags:               ["soft", "light", "warm"],
        ComplementaryHex:   "#FFEFD5",
        AccentHex:          "#FFC0CB",
        Alpha:              1
    },
    {
        ID:                 110,
        Name:               "Pink",
        HexCode:            "#FFC0CB",
        Value:              ColorValue("#FFC0CB"),
        Red:                255,
        Green:              192,
        Blue:               203,
        Category:           "Pinks",
        Tags:               ["warm", "soft", "light"],
        ComplementaryHex:   "#FFDAB9",
        AccentHex:          "#DDA0DD",
        Alpha:              1
    },
    {
        ID:                 111,
        Name:               "Plum",
        HexCode:            "#DDA0DD",
        Value:              ColorValue("#DDA0DD"),
        Red:                221,
        Green:              160,
        Blue:               221,
        Category:           "Purples",
        Tags:               ["earthy", "natural", "rich"],
        ComplementaryHex:   "#CD853F",
        AccentHex:          "#B0E0E6",
        Alpha:              1
    },
    {
        ID:                 112,
        Name:               "PowderBlue",
        HexCode:            "#B0E0E6",
        Value:              ColorValue("#B0E0E6"),
        Red:                176,
        Green:              224,
        Blue:               230,
        Category:           "Blues",
        Tags:               ["playful", "light", "soft"],
        ComplementaryHex:   "#FFC0CB",
        AccentHex:          "#800080",
        Alpha:              1
    },
    {
        ID:                 113,
        Name:               "Purple",
        HexCode:            "#800080",
        Value:              ColorValue("#800080"),
        Red:                128,
        Green:              0,
        Blue:               128,
        Category:           "Purples",
        Tags:               ["soft", "light", "muted"],
        ComplementaryHex:   "#DDA0DD",
        AccentHex:          "#663399",
        Alpha:              1
    },
    {
        ID:                 114,
        Name:               "RebeccaPurple",
        HexCode:            "#663399",
        Value:              ColorValue("#663399"),
        Red:                102,
        Green:              51,
        Blue:               153,
        Category:           "Purples",
        Tags:               ["soft", "cool", "light"],
        ComplementaryHex:   "#B0E0E6",
        AccentHex:          "#FF0000",
        Alpha:              1
    },
    {
        ID:                 115,
        Name:               "Red",
        HexCode:            "#FF0000",
        Value:              ColorValue("#FF0000"),
        Red:                255,
        Green:              0,
        Blue:               0,
        Category:           "Reds",
        Tags:               ["bold", "deep", "classic"],
        ComplementaryHex:   "#800080",
        AccentHex:          "#BC8F8F",
        Alpha:              1
    },
    {
        ID:                 116,
        Name:               "RosyBrown",
        HexCode:            "#BC8F8F",
        Value:              ColorValue("#BC8F8F"),
        Red:                188,
        Green:              143,
        Blue:               143,
        Category:           "Browns",
        Tags:               ["soft", "earthy", "neutral"],
        ComplementaryHex:   "#663399",
        AccentHex:          "#4169E1",
        Alpha:              1
    },
    {
        ID:                 117,
        Name:               "RoyalBlue",
        HexCode:            "#4169E1",
        Value:              ColorValue("#4169E1"),
        Red:                65,
        Green:              105,
        Blue:               225,
        Category:           "Blues",
        Tags:               ["vivid", "cool", "bright"],
        ComplementaryHex:   "#FF0000",
        AccentHex:          "#8B4513",
        Alpha:              1
    },
    {
        ID:                 118,
        Name:               "SaddleBrown",
        HexCode:            "#8B4513",
        Value:              ColorValue("#8B4513"),
        Red:                139,
        Green:              69,
        Blue:               19,
        Category:           "Browns",
        Tags:               ["earthy", "natural", "rich"],
        ComplementaryHex:   "#BC8F8F",
        AccentHex:          "#FA8072",
        Alpha:              1
    },
    {
        ID:                 119,
        Name:               "Salmon",
        HexCode:            "#FA8072",
        Value:              ColorValue("#FA8072"),
        Red:                250,
        Green:              128,
        Blue:               114,
        Category:           "Pinks",
        Tags:               ["soft", "warm", "light"],
        ComplementaryHex:   "#4169E1",
        AccentHex:          "#F4A460",
        Alpha:              1
    },
    {
        ID:                 120,
        Name:               "SandyBrown",
        HexCode:            "#F4A460",
        Value:              ColorValue("#F4A460"),
        Red:                244,
        Green:              164,
        Blue:               96,
        Category:           "Oranges",
        Tags:               ["natural", "fresh", "calm"],
        ComplementaryHex:   "#8B4513",
        AccentHex:          "#2E8B57",
        Alpha:              1
    },
    {
        ID:                 121,
        Name:               "SeaGreen",
        HexCode:            "#2E8B57",
        Value:              ColorValue("#2E8B57"),
        Red:                46,
        Green:              139,
        Blue:               87,
        Category:           "Greens",
        Tags:               ["light", "neutral", "soft"],
        ComplementaryHex:   "#FA8072",
        AccentHex:          "#FFF5EE",
        Alpha:              1
    },
    {
        ID:                 122,
        Name:               "SeaShell",
        HexCode:            "#FFF5EE",
        Value:              ColorValue("#FFF5EE"),
        Red:                255,
        Green:              245,
        Blue:               238,
        Category:           "Whites",
        Tags:               ["cool", "calm", "muted"],
        ComplementaryHex:   "#F4A460",
        AccentHex:          "#A0522D",
        Alpha:              1
    },
    {
        ID:                 123,
        Name:               "Sienna",
        HexCode:            "#A0522D",
        Value:              ColorValue("#A0522D"),
        Red:                160,
        Green:              82,
        Blue:               45,
        Category:           "Browns",
        Tags:               ["light", "soft", "clean"],
        ComplementaryHex:   "#2E8B57",
        AccentHex:          "#C0C0C0",
        Alpha:              1
    },
    {
        ID:                 124,
        Name:               "Silver",
        HexCode:            "#C0C0C0",
        Value:              ColorValue("#C0C0C0"),
        Red:                192,
        Green:              192,
        Blue:               192,
        Category:           "Silvers",
        Tags:               ["vibrant", "fresh", "bright"],
        ComplementaryHex:   "#FFF5EE",
        AccentHex:          "#87CEEB",
        Alpha:              1
    },
    {
        ID:                 125,
        Name:               "SkyBlue",
        HexCode:            "#87CEEB",
        Value:              ColorValue("#87CEEB"),
        Red:                135,
        Green:              206,
        Blue:               235,
        Category:           "Blues",
        Tags:               ["cool", "vibrant", "fresh"],
        ComplementaryHex:   "#A0522D",
        AccentHex:          "#6A5ACD",
        Alpha:              1
    },
    {
        ID:                 126,
        Name:               "SlateBlue",
        HexCode:            "#6A5ACD",
        Value:              ColorValue("#6A5ACD"),
        Red:                106,
        Green:              90,
        Blue:               205,
        Category:           "Purples",
        Tags:               ["soft", "muted", "warm"],
        ComplementaryHex:   "#C0C0C0",
        AccentHex:          "#708090",
        Alpha:              1
    },
    {
        ID:                 127,
        Name:               "SlateGray",
        HexCode:            "#708090",
        Value:              ColorValue("#708090"),
        Red:                112,
        Green:              128,
        Blue:               144,
        Category:           "Grays",
        Tags:               ["deep", "mysterious", "cool"],
        ComplementaryHex:   "#87CEEB",
        AccentHex:          "#FFFAFA",
        Alpha:              1
    },
    {
        ID:                 128,
        Name:               "Snow",
        HexCode:            "#FFFAFA",
        Value:              ColorValue("#FFFAFA"),
        Red:                255,
        Green:              250,
        Blue:               250,
        Category:           "Whites",
        Tags:               ["soft", "vivid", "playful"],
        ComplementaryHex:   "#6A5ACD",
        AccentHex:          "#00FF7F",
        Alpha:              1
    },
    {
        ID:                 129,
        Name:               "SpringGreen",
        HexCode:            "#00FF7F",
        Value:              ColorValue("#00FF7F"),
        Red:                0,
        Green:              255,
        Blue:               127,
        Category:           "Greens",
        Tags:               ["bright", "vibrant", "fresh"],
        ComplementaryHex:   "#708090",
        AccentHex:          "#4682B4",
        Alpha:              1
    },
    {
        ID:                 130,
        Name:               "SteelBlue",
        HexCode:            "#4682B4",
        Value:              ColorValue("#4682B4"),
        Red:                70,
        Green:              130,
        Blue:               180,
        Category:           "Blues",
        Tags:               ["soft", "light", "warm"],
        ComplementaryHex:   "#FFFAFA",
        AccentHex:          "#D2B48C",
        Alpha:              1
    },
    {
        ID:                 131,
        Name:               "Tan",
        HexCode:            "#D2B48C",
        Value:              ColorValue("#D2B48C"),
        Red:                210,
        Green:              180,
        Blue:               140,
        Category:           "Beiges",
        Tags:               ["pure", "clean", "neutral"],
        ComplementaryHex:   "#00FF7F",
        AccentHex:          "#008080",
        Alpha:              1
    },
    {
        ID:                 132,
        Name:               "Teal",
        HexCode:            "#008080",
        Value:              ColorValue("#008080"),
        Red:                0,
        Green:              128,
        Blue:               128,
        Category:           "Cyan/Aqua",
        Tags:               ["light", "neutral", "clean"],
        ComplementaryHex:   "#4682B4",
        AccentHex:          "#D8BFD8",
        Alpha:              1
    },
    {
        ID:                 133,
        Name:               "Thistle",
        HexCode:            "#D8BFD8",
        Value:              ColorValue("#D8BFD8"),
        Red:                216,
        Green:              191,
        Blue:               216,
        Category:           "Purples",
        Tags:               ["bright", "nature", "vibrant"],
        ComplementaryHex:   "#D2B48C",
        AccentHex:          "#FF6347",
        Alpha:              1
    },
    {
        ID:                 134,
        Name:               "Tomato",
        HexCode:            "#FF6347",
        Value:              ColorValue("#FF6347"),
        Red:                255,
        Green:              99,
        Blue:               71,
        Category:           "Reds",
        Tags:               ["warm", "refreshing", "vibrant"],
        ComplementaryHex:   "#008080",
        AccentHex:          "#40E0D0",
        Alpha:              1
    },
    {
        ID:                 135,
        Name:               "Turquoise",
        HexCode:            "#40E0D0",
        Value:              ColorValue("#40E0D0"),
        Red:                64,
        Green:              224,
        Blue:               208,
        Category:           "Cyan/Aqua",
        Tags:               ["cool", "fresh", "vibrant"],
        ComplementaryHex:   "#D8BFD8",
        AccentHex:          "#EE82EE",
        Alpha:              1
    },
    {
        ID:                 136,
        Name:               "Violet",
        HexCode:            "#EE82EE",
        Value:              ColorValue("#EE82EE"),
        Red:                238,
        Green:              130,
        Blue:               238,
        Category:           "Purples",
        Tags:               ["soft", "light", "playful"],
        ComplementaryHex:   "#FF6347",
        AccentHex:          "#F5DEB3",
        Alpha:              1
    },
    {
        ID:                 137,
        Name:               "Wheat",
        HexCode:            "#F5DEB3",
        Value:              ColorValue("#F5DEB3"),
        Red:                245,
        Green:              222,
        Blue:               179,
        Category:           "Beiges",
        Tags:               ["soft", "light", "neutral"],
        ComplementaryHex:   "#40E0D0",
        AccentHex:          "#FFFFFF",
        Alpha:              1
    },
    {
        ID:                 138,
        Name:               "White",
        HexCode:            "#FFFFFF",
        Value:              ColorValue("#FFFFFF"),
        Red:                255,
        Green:              255,
        Blue:               255,
        Category:           "Whites",
        Tags:               ["pure", "clean", "neutral"],
        ComplementaryHex:   "#EE82EE",
        AccentHex:          "#F5F5F5",
        Alpha:              1
    },
    {
        ID:                 139,
        Name:               "WhiteSmoke",
        HexCode:            "#F5F5F5",
        Value:              ColorValue("#F5F5F5"),
        Red:                245,
        Green:              245,
        Blue:               245,
        Category:           "Whites",
        Tags:               ["light", "neutral", "clean"],
        ComplementaryHex:   "#F5DEB3",
        AccentHex:          "#FFFF00",
        Alpha:              1
    },
    {
        ID:                 140,
        Name:               "YellowGreen",
        HexCode:            "#9ACD32",
        Value:              ColorValue("#9ACD32"),
        Red:                154,
        Green:              205,
        Blue:               50,
        Category:           "Greens",
        Tags:               ["bright", "nature", "vibrant"],
        ComplementaryHex:   "#FFFFFF",
        AccentHex:          "#ADFF2F",
        Alpha:              1
    }
];

// ============================================================
// SECTION 2: ERROR KINDS ENUMERATION (31 error kinds)
// ============================================================
//
// Usage:
//   LookUp(fxErrorKinds, KindName = "Timeout")            // Find by name
//   Filter(fxErrorKinds, Category = "Data")                // Data-related errors
//   LookUp(fxErrorKinds, KindNumber = 4).KindName          // Find by number
//
// NOTE: Converted from ClearCollect to Named Formula for
//       declarative consistency. KindNumbers are sequential
//       (not matching original ErrorKind enum values, which
//       have duplicates in the source). Use KindName for lookups.
//
// Fields: KindNumber, KindName, Category
// ============================================================

// Error Kinds - Named Formula (converted from ClearCollect pattern)
// Source: PowerAppsDarren/PowerFxSnippets (MIT License)
fxErrorKinds = [
    {KindNumber: 0, KindName: "None", Category: "General"},
    {KindNumber: 1, KindName: "Unknown", Category: "General"},
    {KindNumber: 2, KindName: "InvalidArgument", Category: "General"},
    {KindNumber: 3, KindName: "NotFound", Category: "General"},
    {KindNumber: 4, KindName: "PermissionDenied", Category: "General"},
    {KindNumber: 5, KindName: "Timeout", Category: "General"},
    {KindNumber: 6, KindName: "ConcurrencyConflict", Category: "General"},
    {KindNumber: 7, KindName: "RateLimitExceeded", Category: "General"},
    {KindNumber: 8, KindName: "OperationCancelled", Category: "General"},
    {KindNumber: 9, KindName: "QuotaExceeded", Category: "General"},
    {KindNumber: 10, KindName: "Sync", Category: "Data"},
    {KindNumber: 11, KindName: "MissingRequired", Category: "Data"},
    {KindNumber: 12, KindName: "CreatePermission", Category: "Data"},
    {KindNumber: 13, KindName: "EditPermissions", Category: "Data"},
    {KindNumber: 14, KindName: "DeletePermissions", Category: "Data"},
    {KindNumber: 15, KindName: "Conflict", Category: "Data"},
    {KindNumber: 16, KindName: "ConstraintViolated", Category: "Data"},
    {KindNumber: 17, KindName: "GeneratedValue", Category: "Data"},
    {KindNumber: 18, KindName: "ReadOnlyValue", Category: "Data"},
    {KindNumber: 19, KindName: "Validation", Category: "Data"},
    {KindNumber: 20, KindName: "Div0", Category: "Calculation"},
    {KindNumber: 21, KindName: "BadLanguageCode", Category: "Calculation"},
    {KindNumber: 22, KindName: "BadRegex", Category: "Calculation"},
    {KindNumber: 23, KindName: "InvalidFunctionUsage", Category: "Calculation"},
    {KindNumber: 24, KindName: "FileNotFound", Category: "System"},
    {KindNumber: 25, KindName: "AnalysisError", Category: "System"},
    {KindNumber: 26, KindName: "ReadPermission", Category: "System"},
    {KindNumber: 27, KindName: "NotSupported", Category: "System"},
    {KindNumber: 28, KindName: "InsufficientMemory", Category: "System"},
    {KindNumber: 29, KindName: "Network", Category: "System"},
    {KindNumber: 30, KindName: "Numeric", Category: "Calculation"}
];

// ============================================================
// SECTION 3: ICONS ENUMERATION (178 icons)
// ============================================================
//
// Usage:
//   LookUp(fxIcons, Name = "Home").Icon                    // Get Icon value
//   Filter(fxIcons, Category = "Navigation")               // Navigation icons
//   Search(fxIcons, "edit", "Name", "Description")         // Search icons
//   Filter(fxIcons, "search" in Tags)                      // Filter by tag
//
// Fields: Sequence, Name, Icon, Description, Tags, Category
// ============================================================

fxIcons = Sort(
    [
        {
            Sequence:       1,
            Name:           "Add",
            Icon:           Icon.Add,
            Description:    "A plus sign icon indicating addition or creation of new items",
            Tags:           ["plus", "new", "create"],
            Category:       "Actions"
        },
        {
            Sequence:       2,
            Name:           "Cancel",
            Icon:           Icon.Cancel,
            Description:    "An 'X' icon typically used to cancel actions or close dialogs",
            Tags:           ["close", "delete", "remove"],
            Category:       "Actions"
        },
        {
            Sequence:       3,
            Name:           "CancelBadge",
            Icon:           Icon.CancelBadge,
            Description:    "An 'X' icon within a circular badge, often used to indicate cancellation or removal in a more prominent way",
            Tags:           ["close", "delete", "remove", "badge"],
            Category:       "Notifications"
        },
        {
            Sequence:       4,
            Name:           "Edit",
            Icon:           Icon.Edit,
            Description:    "A pencil icon typically used to represent editing or modifying content",
            Tags:           ["modify", "change", "update", "pencil"],
            Category:       "Actions"
        },
        {
            Sequence:       5,
            Name:           "Check",
            Icon:           Icon.Check,
            Description:    "A checkmark icon often used to indicate completion, confirmation, or selection",
            Tags:           ["complete", "confirm", "select", "approve"],
            Category:       "Actions"
        },
        {
            Sequence:       6,
            Name:           "CheckBadge",
            Icon:           Icon.CheckBadge,
            Description:    "A checkmark icon within a circular badge, typically used to indicate successful completion or approval in a more prominent way",
            Tags:           ["complete", "confirm", "approve", "badge", "success"],
            Category:       "Notifications"
        },
        {
            Sequence:       7,
            Name:           "Search",
            Icon:           Icon.Search,
            Description:    "A magnifying glass icon typically used for search functionality or to indicate a search action",
            Tags:           ["find", "lookup", "explore", "magnifying glass"],
            Category:       "Actions"
        },
        {
            Sequence:       8,
            Name:           "Filter",
            Icon:           Icon.Filter,
            Description:    "A funnel-like icon typically used to represent filtering or sorting options",
            Tags:           ["sort", "funnel", "refine", "narrow"],
            Category:       "Data"
        },
        {
            Sequence:       9,
            Name:           "FilterFlat",
            Icon:           Icon.FilterFlat,
            Description:    "A simplified filter icon, typically used to represent filtering or sorting options in a flat design style",
            Tags:           ["sort", "funnel", "refine", "narrow", "flat"],
            Category:       "Data"
        },
        {
            Sequence:       10,
            Name:           "FilterFlatFilled",
            Icon:           Icon.FilterFlatFilled,
            Description:    "A filled version of the simplified filter icon, representing filtering or sorting options in a flat, solid design style",
            Tags:           ["sort", "funnel", "refine", "narrow", "flat", "filled"],
            Category:       "Data"
        },
        {
            Sequence:       11,
            Name:           "Sort",
            Icon:           Icon.Sort,
            Description:    "An icon representing sorting functionality, typically shown as stacked horizontal lines of decreasing length",
            Tags:           ["order", "arrange", "organize", "sequence"],
            Category:       "Data"
        },
        {
            Sequence:       12,
            Name:           "Reload",
            Icon:           Icon.Reload,
            Description:    "A circular arrow icon typically used to represent reloading, refreshing, or syncing content",
            Tags:           ["refresh", "update", "sync", "circular"],
            Category:       "Actions"
        },
        {
            Sequence:       13,
            Name:           "Trash",
            Icon:           Icon.Trash,
            Description:    "A trash can icon typically used to represent deletion or removal of items",
            Tags:           ["delete", "remove", "discard", "bin"],
            Category:       "Actions"
        },
        {
            Sequence:       14,
            Name:           "Save",
            Icon:           Icon.Save,
            Description:    "A floppy disk icon typically used to represent saving or storing data",
            Tags:           ["store", "preserve", "record", "floppy"],
            Category:       "Actions"
        },
        {
            Sequence:       15,
            Name:           "Download",
            Icon:           Icon.Download,
            Description:    "An arrow pointing downward into a tray, typically used to represent downloading or saving files",
            Tags:           ["save", "retrieve", "get", "arrow"],
            Category:       "Actions"
        },
        {
            Sequence:       16,
            Name:           "Copy",
            Icon:           Icon.Copy,
            Description:    "Two overlapping rectangles, typically used to represent copying or duplicating content",
            Tags:           ["duplicate", "clone", "replicate", "paste"],
            Category:       "Actions"
        },
        {
            Sequence:       17,
            Name:           "LikeDislike",
            Icon:           Icon.LikeDislike,
            Description:    "A combination of thumbs up and thumbs down icons, typically used for rating or feedback",
            Tags:           ["feedback", "rating", "thumbs", "vote"],
            Category:       "Social"
        },
        {
            Sequence:       18,
            Name:           "Crop",
            Icon:           Icon.Crop,
            Description:    "An icon representing the crop tool, typically used in image editing to trim or resize images",
            Tags:           ["trim", "resize", "edit", "image"],
            Category:       "Design"
        },
        {
            Sequence:       19,
            Name:           "Pin",
            Icon:           Icon.Pin,
            Description:    "An icon representing a pushpin, typically used to indicate location or to 'pin' items for quick access",
            Tags:           ["location", "mark", "save", "bookmark"],
            Category:       "Navigation"
        },
        {
            Sequence:       20,
            Name:           "ClearDrawing",
            Icon:           Icon.ClearDrawing,
            Description:    "An icon representing clearing or erasing a drawing, typically shown as an eraser or clear canvas",
            Tags:           ["erase", "clear", "delete", "reset"],
            Category:       "Design"
        },
        {
            Sequence:       21,
            Name:           "ExpandView",
            Icon:           Icon.ExpandView,
            Description:    "An icon representing expanding or enlarging a view, typically shown as outward-pointing arrows",
            Tags:           ["enlarge", "maximize", "fullscreen", "zoom"],
            Category:       "View"
        },
        {
            Sequence:       22,
            Name:           "CollapseAll",
            Icon:           Icon.CollapseView,
            Description:    "An icon representing the action to collapse all expanded items or sections, typically shown as inward-pointing arrows",
            Tags:           ["collapse", "minimize", "shrink", "fold"],
            Category:       "View"
        },
        {
            Sequence:       23,
            Name:           "Draw",
            Icon:           Icon.Draw,
            Description:    "An icon representing a drawing tool, typically shown as a pencil or brush for creating or editing graphics",
            Tags:           ["pencil", "sketch", "create", "design"],
            Category:       "Design"
        },
        {
            Sequence:       24,
            Name:           "Compose",
            Icon:           Icon.Compose,
            Description:    "An icon representing the action of composing or writing, typically shown as a pen or pencil with paper",
            Tags:           ["write", "create", "edit", "document"],
            Category:       "Communication"
        },
        {
            Sequence:       25,
            Name:           "Erase",
            Icon:           Icon.Erase,
            Description:    "An icon representing an eraser tool, typically used for removing or deleting content in drawing or editing applications",
            Tags:           ["delete", "remove", "clear", "clean"],
            Category:       "Design"
        },
        {
            Sequence:       26,
            Name:           "Message",
            Icon:           Icon.Message,
            Description:    "An icon representing a message or chat bubble, typically used for communication or messaging features",
            Tags:           ["chat", "communication", "text", "speech"],
            Category:       "Communication"
        },
        {
            Sequence:       27,
            Name:           "Post",
            Icon:           Icon.Post,
            Description:    "An icon representing a post or publication, typically shown as a document or note being sent or published",
            Tags:           ["publish", "send", "share", "submit"],
            Category:       "Communication"
        },
        {
            Sequence:       28,
            Name:           "AddDocument",
            Icon:           Icon.AddDocument,
            Description:    "An icon representing the action of adding a new document, typically shown as a document with a plus sign",
            Tags:           ["new", "create", "file", "add"],
            Category:       "Files"
        },
        {
            Sequence:       29,
            Name:           "AddLibrary",
            Icon:           Icon.AddLibrary,
            Description:    "An icon representing the action of adding a new library or collection, typically shown as multiple documents or books with a plus sign",
            Tags:           ["collection", "books", "add", "create"],
            Category:       "Files"
        },
        {
            Sequence:       30,
            Name:           "Import",
            Icon:           Icon.Import,
            Description:    "An icon representing the action of importing data or files, typically shown as an arrow pointing into a box or document",
            Tags:           ["upload", "transfer", "input", "inbound"],
            Category:       "Data"
        },
        {
            Sequence:       31,
            Name:           "Export",
            Icon:           Icon.Export,
            Description:    "An icon representing the action of exporting data or files, typically shown as an arrow pointing out of a box or document",
            Tags:           ["download", "transfer", "output", "outbound"],
            Category:       "Data"
        },
        {
            Sequence:       32,
            Name:           "QuestionMark",
            Icon:           Icon.QuestionMark,
            Description:    "An icon representing a question or help, typically shown as a question mark symbol",
            Tags:           ["help", "inquiry", "support", "information"],
            Category:       "Information"
        },
        {
            Sequence:       33,
            Name:           "Help",
            Icon:           Icon.Help,
            Description:    "An icon representing assistance or support, typically shown as a question mark or a lifebuoy",
            Tags:           ["support", "assistance", "guidance", "information"],
            Category:       "Information"
        },
        {
            Sequence:       34,
            Name:           "ThumbsDown",
            Icon:           Icon.ThumbsDown,
            Description:    "An icon representing disapproval or dislike, typically shown as a hand with the thumb pointing downward",
            Tags:           ["dislike", "negative", "feedback", "rating"],
            Category:       "Social"
        },
        {
            Sequence:       35,
            Name:           "ThumbsDownFilled",
            Icon:           Icon.ThumbsDownFilled,
            Description:    "A filled icon representing strong disapproval or dislike, typically shown as a solid hand with the thumb pointing downward",
            Tags:           ["dislike", "negative", "feedback", "rating", "filled"],
            Category:       "Social"
        },
        {
            Sequence:       36,
            Name:           "ThumbsUpFilled",
            Icon:           Icon.ThumbsUpFilled,
            Description:    "A filled icon representing strong approval or like, typically shown as a solid hand with the thumb pointing upward",
            Tags:           ["like", "positive", "feedback", "rating", "filled"],
            Category:       "Social"
        },
        {
            Sequence:       37,
            Name:           "Undo",
            Icon:           Icon.Undo,
            Description:    "An icon representing the action of undoing or reverting a previous action, typically shown as a curved arrow pointing left or counterclockwise",
            Tags:           ["revert", "reverse", "back", "previous"],
            Category:       "Actions"
        },
        {
            Sequence:       38,
            Name:           "Redo",
            Icon:           Icon.Redo,
            Description:    "An icon representing the action of redoing or reapplying a previously undone action, typically shown as a curved arrow pointing right or clockwise",
            Tags:           ["reapply", "forward", "repeat", "next"],
            Category:       "Actions"
        },
        {
            Sequence:       39,
            Name:           "ZoomIn",
            Icon:           Icon.ZoomIn,
            Description:    "An icon representing the action of zooming in or enlarging a view, typically shown as a magnifying glass with a plus sign",
            Tags:           ["magnify", "enlarge", "increase", "expand"],
            Category:       "View"
        },
        {
            Sequence:       40,
            Name:           "ZoomOut",
            Icon:           Icon.ZoomOut,
            Description:    "An icon representing the action of zooming out or reducing a view, typically shown as a magnifying glass with a minus sign",
            Tags:           ["reduce", "decrease", "shrink", "minimize"],
            Category:       "View"
        },
        {
            Sequence:       41,
            Name:           "OpenInNewWindow",
            Icon:           Icon.OpenInNewWindow,
            Description:    "An icon representing the action of opening a link or content in a new window or tab, typically shown as a square with an arrow pointing outward",
            Tags:           ["external", "link", "new tab", "launch"],
            Category:       "Navigation"
        },
        {
            Sequence:       42,
            Name:           "Share",
            Icon:           Icon.Share,
            Description:    "An icon representing the action of sharing content or information, typically shown as interconnected nodes or an arrow pointing outward from a circle",
            Tags:           ["distribute", "send", "social", "connect"],
            Category:       "Communication"
        },
        {
            Sequence:       43,
            Name:           "Publish",
            Icon:           Icon.Publish,
            Description:    "An icon representing the action of publishing or making content publicly available, typically shown as an upward arrow or a document with an upward arrow",
            Tags:           ["release", "upload", "distribute", "make public"],
            Category:       "Content"
        },
        {
            Sequence:       44,
            Name:           "Link",
            Icon:           Icon.Link,
            Description:    "An icon representing a hyperlink or connection between elements, typically shown as a chain link or interlocking rings",
            Tags:           ["hyperlink", "url", "connect", "attach"],
            Category:       "Web"
        },
        {
            Sequence:       45,
            Name:           "Sync",
            Icon:           Icon.Sync,
            Description:    "An icon representing synchronization or data refresh, typically shown as two circular arrows forming a loop",
            Tags:           ["refresh", "update", "reload", "synchronize"],
            Category:       "Data"
        },
        {
            Sequence:       46,
            Name:           "View",
            Icon:           Icon.View,
            Description:    "An icon representing the action of viewing or previewing content, typically shown as an eye",
            Tags:           ["preview", "see", "visibility", "show"],
            Category:       "Actions"
        },
        {
            Sequence:       47,
            Name:           "Hide",
            Icon:           Icon.Hide,
            Description:    "An icon representing the action of hiding or concealing content, typically shown as an eye with a slash through it",
            Tags:           ["invisible", "conceal", "hidden", "private"],
            Category:       "Actions"
        },
        {
            Sequence:       48,
            Name:           "Bookmark",
            Icon:           Icon.Bookmark,
            Description:    "An icon representing a bookmark or saved item, typically shown as a ribbon or tag",
            Tags:           ["save", "favorite", "mark", "flag"],
            Category:       "Actions"
        },
        {
            Sequence:       49,
            Name:           "BookmarkFilled",
            Icon:           Icon.BookmarkFilled,
            Description:    "A filled icon representing a bookmark or saved item, typically shown as a solid ribbon or tag",
            Tags:           ["save", "favorite", "mark", "flag", "filled"],
            Category:       "Actions"
        },
        {
            Sequence:       50,
            Name:           "Reset",
            Icon:           Icon.Reset,
            Description:    "An icon representing the action of resetting or returning to an initial state, typically shown as a circular arrow",
            Tags:           ["restart", "refresh", "revert", "circular arrow"],
            Category:       "Actions"
        },
        {
            Sequence:       51,
            Name:           "Blocked",
            Icon:           Icon.Blocked,
            Description:    "An icon representing a blocked or prohibited state, typically shown as a circle with a diagonal line through it",
            Tags:           ["prohibited", "forbidden", "stop", "no"],
            Category:       "Status"
        },
        {
            Sequence:       52,
            Name:           "DockLeft",
            Icon:           Icon.DockLeft,
            Description:    "An icon representing docking or aligning content to the left side, typically shown as a rectangle with a smaller rectangle aligned to its left edge",
            Tags:           ["align", "left", "layout", "position"],
            Category:       "Layout"
        },
        {
            Sequence:       53,
            Name:           "AddUser",
            Icon:           Icon.AddUser,
            Description:    "An icon representing the action of adding a new user, typically shown as a user silhouette with a plus sign",
            Tags:           ["new user", "create account", "sign up", "register"],
            Category:       "Users"
        },
        {
            Sequence:       54,
            Name:           "Cut",
            Icon:           Icon.Cut,
            Description:    "An icon representing a cutting action, typically shown as a pair of scissors",
            Tags:           ["scissors", "trim", "clip", "snip"],
            Category:       "Actions"
        },
        {
            Sequence:       55,
            Name:           "Paste",
            Icon:           Icon.Paste,
            Description:    "An icon representing the action of pasting content, typically shown as a clipboard or document with a downward arrow",
            Tags:           ["insert", "paste", "clipboard", "add"],
            Category:       "Actions"
        },
        {
            Sequence:       56,
            Name:           "Leave",
            Icon:           Icon.Leave,
            Description:    "An icon representing the action of leaving or exiting, typically shown as a door with an arrow pointing outward",
            Tags:           ["exit", "logout", "depart", "sign out"],
            Category:       "Actions"
        },
        {
            Sequence:       57,
            Name:           "Home",
            Icon:           Icon.Home,
            Description:    "An icon representing a home or main page, typically shown as a simple house shape",
            Tags:           ["house", "main", "start", "homepage"],
            Category:       "Navigation"
        },
        {
            Sequence:       58,
            Name:           "Hamburger",
            Icon:           Icon.Hamburger,
            Description:    "An icon representing a menu, typically shown as three horizontal lines stacked vertically",
            Tags:           ["menu", "navigation", "options", "sidebar"],
            Category:       "Navigation"
        },
        {
            Sequence:       59,
            Name:           "Settings",
            Icon:           Icon.Settings,
            Description:    "An icon representing settings or configuration options, typically shown as a gear or cog wheel",
            Tags:           ["configuration", "options", "preferences", "gear"],
            Category:       "System"
        },
        {
            Sequence:       60,
            Name:           "More",
            Icon:           Icon.More,
            Description:    "An icon representing additional options or actions, typically shown as three dots (ellipsis) either horizontally or vertically aligned",
            Tags:           ["ellipsis", "options", "additional", "menu"],
            Category:       "Navigation"
        },
        {
            Sequence:       61,
            Name:           "Waffle",
            Icon:           Icon.Waffle,
            Description:    "An icon representing a menu of multiple options, typically shown as a 3x3 grid of small squares",
            Tags:           ["menu", "grid", "options", "navigation"],
            Category:       "Navigation"
        },
        {
            Sequence:       62,
            Name:           "ChevronLeft",
            Icon:           Icon.ChevronLeft,
            Description:    "An icon representing a left-pointing chevron, typically used for navigation or to indicate a collapsible menu",
            Tags:           ["left", "arrow", "back", "previous"],
            Category:       "Navigation"
        },
        {
            Sequence:       63,
            Name:           "ChevronRight",
            Icon:           Icon.ChevronRight,
            Description:    "An icon representing a right-pointing chevron, typically used for navigation or to indicate an expandable menu",
            Tags:           ["right", "arrow", "next", "forward"],
            Category:       "Navigation"
        },
        {
            Sequence:       64,
            Name:           "ChevronUp",
            Icon:           Icon.ChevronUp,
            Description:    "An icon representing an upward-pointing chevron, typically used for navigation or to indicate an expandable menu",
            Tags:           ["up", "arrow", "expand", "collapse"],
            Category:       "Navigation"
        },
        {
            Sequence:       65,
            Name:           "ChevronDown",
            Icon:           Icon.ChevronDown,
            Description:    "An icon representing a downward-pointing chevron, typically used for navigation or to indicate a collapsible menu",
            Tags:           ["down", "arrow", "expand", "collapse"],
            Category:       "Navigation"
        },
        {
            Sequence:       66,
            Name:           "NextArrow",
            Icon:           Icon.NextArrow,
            Description:    "An icon representing a forward or next action, typically shown as an arrow pointing to the right",
            Tags:           ["forward", "next", "advance", "right"],
            Category:       "Navigation"
        },
        {
            Sequence:       67,
            Name:           "BackArrow",
            Icon:           Icon.BackArrow,
            Description:    "An icon representing a backward or previous action, typically shown as an arrow pointing to the left",
            Tags:           ["back", "previous", "return", "left"],
            Category:       "Navigation"
        },
        {
            Sequence:       68,
            Name:           "ArrowDown",
            Icon:           Icon.ArrowDown,
            Description:    "An icon representing a downward direction or action, typically shown as an arrow pointing downward",
            Tags:           ["down", "descend", "dropdown", "expand"],
            Category:       "Navigation"
        },
        {
            Sequence:       69,
            Name:           "ArrowUp",
            Icon:           Icon.ArrowUp,
            Description:    "An icon representing an upward direction or action, typically shown as an arrow pointing upward",
            Tags:           ["up", "ascend", "upward", "rise"],
            Category:       "Navigation"
        },
        {
            Sequence:       70,
            Name:           "ArrowLeft",
            Icon:           Icon.ArrowLeft,
            Description:    "An icon representing a leftward direction or action, typically shown as an arrow pointing to the left",
            Tags:           ["left", "back", "previous", "backward"],
            Category:       "Navigation"
        },
        {
            Sequence:       71,
            Name:           "ArrowRight",
            Icon:           Icon.ArrowRight,
            Description:    "An icon representing a rightward direction or action, typically shown as an arrow pointing to the right",
            Tags:           ["right", "forward", "next", "advance"],
            Category:       "Navigation"
        },
        {
            Sequence:       72,
            Name:           "Camera",
            Icon:           Icon.Camera,
            Description:    "An icon representing a camera or photo-taking action, typically shown as a simplified camera shape",
            Tags:           ["photo", "picture", "capture", "image"],
            Category:       "Media"
        },
        {
            Sequence:       73,
            Name:           "Document",
            Icon:           Icon.Document,
            Description:    "An icon representing a document or file, typically shown as a rectangular shape with a folded corner",
            Tags:           ["file", "paper", "page", "document"],
            Category:       "Files"
        },
        {
            Sequence:       74,
            Name:           "DockCheckProperties",
            Icon:           Icon.DockCheckProperties,
            Description:    "An icon representing a document with a checkmark, typically used to indicate verified or approved document properties",
            Tags:           ["document", "checkmark", "verify", "approve", "properties"],
            Category:       "Files"
        },
        {
            Sequence:       75,
            Name:           "Folder",
            Icon:           Icon.Folder,
            Description:    "An icon representing a folder or directory, typically shown as a simplified folder shape",
            Tags:           ["directory", "file system", "storage", "organize"],
            Category:       "Files"
        },
        {
            Sequence:       76,
            Name:           "Journal",
            Icon:           Icon.Journal,
            Description:    "An icon representing a journal or log, typically shown as a book or notebook",
            Tags:           ["log", "notebook", "diary", "record"],
            Category:       "Files"
        },
        {
            Sequence:       77,
            Name:           "ForkKnife",
            Icon:           Icon.ForkKnife,
            Description:    "An icon representing food or dining, typically shown as a fork and knife crossed or side by side",
            Tags:           ["food", "dining", "restaurant", "meal"],
            Category:       "Miscellaneous"
        },
        {
            Sequence:       78,
            Name:           "Transportation",
            Icon:           Icon.Transportation,
            Description:    "An icon representing transportation or travel, typically shown as a vehicle or mode of transport",
            Tags:           ["travel", "vehicle", "transport", "journey"],
            Category:       "Travel"
        },
        {
            Sequence:       79,
            Name:           "Airplane",
            Icon:           Icon.Airplane,
            Description:    "An icon representing an airplane or air travel, typically shown as a simplified side view of an aircraft",
            Tags:           ["flight", "travel", "aviation", "transport"],
            Category:       "Travel"
        },
        {
            Sequence:       80,
            Name:           "Bus",
            Icon:           Icon.Bus,
            Description:    "An icon representing a bus or public transportation, typically shown as a simplified side view of a bus",
            Tags:           ["public transport", "travel", "vehicle", "commute"],
            Category:       "Travel"
        },
        {
            Sequence:       81,
            Name:           "Cars",
            Icon:           Icon.Cars,
            Description:    "An icon representing multiple cars or vehicles, typically shown as simplified car silhouettes",
            Tags:           ["vehicles", "automobiles", "transport", "traffic"],
            Category:       "Transportation"
        },
        {
            Sequence:       82,
            Name:           "Money",
            Icon:           Icon.Money,
            Description:    "An icon representing money or currency, typically shown as banknotes or coins",
            Tags:           ["currency", "cash", "finance", "payment"],
            Category:       "Finance"
        },
        {
            Sequence:       83,
            Name:           "Currency",
            Icon:           Icon.Currency,
            Description:    "An icon representing currency or exchange, typically shown as a dollar sign or multiple currency symbols",
            Tags:           ["money", "exchange", "finance", "forex"],
            Category:       "Finance"
        },
        {
            Sequence:       84,
            Name:           "AddToCalendar",
            Icon:           Icon.AddToCalendar,
            Description:    "An icon representing the action of adding an event to a calendar, typically shown as a calendar with a plus sign",
            Tags:           ["event", "schedule", "appointment", "date"],
            Category:       "Calendar"
        },
        {
            Sequence:       85,
            Name:           "CalendarBlank",
            Icon:           Icon.CalendarBlank,
            Description:    "An icon representing a blank calendar or date selection, typically shown as an empty calendar grid",
            Tags:           ["date", "schedule", "month", "empty"],
            Category:       "Calendar"
        },
        {
            Sequence:       86,
            Name:           "OfficeBuilding",
            Icon:           Icon.OfficeBuilding,
            Description:    "An icon representing an office building or corporate structure, typically shown as a multi-story building",
            Tags:           ["building", "corporate", "company", "workplace"],
            Category:       "Business"
        },
        {
            Sequence:       87,
            Name:           "PaperClip",
            Icon:           Icon.PaperClip,
            Description:    "An icon representing an attachment or linked file, typically shown as a paper clip",
            Tags:           ["attachment", "file", "link", "document"],
            Category:       "Files"
        },
        {
            Sequence:       88,
            Name:           "Newspaper",
            Icon:           Icon.Newspaper,
            Description:    "An icon representing a newspaper or news article, typically shown as a folded newspaper",
            Tags:           ["news", "article", "press", "media"],
            Category:       "Media"
        },
        {
            Sequence:       89,
            Name:           "Lock",
            Icon:           Icon.Lock,
            Description:    "An icon representing security or a locked state, typically shown as a padlock",
            Tags:           ["security", "locked", "private", "protected"],
            Category:       "Security"
        },
        {
            Sequence:       90,
            Name:           "Waypoint",
            Icon:           Icon.Waypoint,
            Description:    "An icon representing a location or destination point, typically shown as a map pin or marker",
            Tags:           ["location", "pin", "marker", "destination"],
            Category:       "Maps"
        },
        {
            Sequence:       91,
            Name:           "Location",
            Icon:           Icon.Location,
            Description:    "An icon representing a geographical location or position, typically shown as a crosshair or target",
            Tags:           ["position", "coordinates", "gps", "pinpoint"],
            Category:       "Maps"
        },
        {
            Sequence:       92,
            Name:           "DocumentPDF",
            Icon:           Icon.DocumentPDF,
            Description:    "An icon representing a PDF document, typically shown as a file with PDF text",
            Tags:           ["pdf", "file", "document", "adobe"],
            Category:       "Files"
        },
        {
            Sequence:       93,
            Name:           "Bell",
            Icon:           Icon.Bell,
            Description:    "An icon representing a notification or alert, typically shown as a bell shape",
            Tags:           ["notification", "alert", "reminder", "alarm"],
            Category:       "Notifications"
        },
        {
            Sequence:       94,
            Name:           "ShoppingCart",
            Icon:           Icon.ShoppingCart,
            Description:    "An icon representing a shopping cart or basket, typically used for e-commerce",
            Tags:           ["cart", "basket", "shopping", "ecommerce"],
            Category:       "Commerce"
        },
        {
            Sequence:       95,
            Name:           "Phone",
            Icon:           Icon.Phone,
            Description:    "An icon representing a telephone or mobile device, typically shown as a handset or smartphone shape",
            Tags:           ["telephone", "call", "mobile", "contact"],
            Category:       "Communication"
        },
        {
            Sequence:       96,
            Name:           "PhoneHangUp",
            Icon:           Icon.PhoneHangUp,
            Description:    "An icon representing ending a phone call, typically shown as a phone handset facing down",
            Tags:           ["end call", "hang up", "telephone", "disconnect"],
            Category:       "Communication"
        },
        {
            Sequence:       97,
            Name:           "Mobile",
            Icon:           Icon.Mobile,
            Description:    "An icon representing a mobile phone or smartphone, typically shown as a rectangular device with a screen",
            Tags:           ["smartphone", "cellphone", "device", "handheld"],
            Category:       "Devices"
        },
        {
            Sequence:       98,
            Name:           "Laptop",
            Icon:           Icon.Laptop,
            Description:    "An icon representing a laptop computer, typically shown as a portable computer with a screen and keyboard",
            Tags:           ["computer", "notebook", "portable", "device"],
            Category:       "Devices"
        },
        {
            Sequence:       99,
            Name:           "ComputerDesktop",
            Icon:           Icon.ComputerDesktop,
            Description:    "An icon representing a desktop computer, typically shown as a monitor with a keyboard",
            Tags:           ["computer", "PC", "workstation", "desktop"],
            Category:       "Devices"
        },
        {
            Sequence:       100,
            Name:           "Devices",
            Icon:           Icon.Devices,
            Description:    "An icon representing multiple electronic devices, typically shown as a combination of smartphone, tablet, and laptop or desktop computer",
            Tags:           ["electronics", "gadgets", "technology", "multi-device"],
            Category:       "Devices"
        },
        {
            Sequence:       101,
            Name:           "Controller",
            Icon:           Icon.Controller,
            Description:    "An icon representing a game controller or gamepad, typically shown as a simplified gaming device with buttons",
            Tags:           ["gamepad", "gaming", "joystick", "console"],
            Category:       "Entertainment"
        },
        {
            Sequence:       102,
            Name:           "Tools",
            Icon:           Icon.Tools,
            Description:    "An icon representing tools or settings, typically shown as a wrench and screwdriver crossed",
            Tags:           ["settings", "repair", "maintenance", "configure"],
            Category:       "Utilities"
        },
        {
            Sequence:       103,
            Name:           "ToolsWrench",
            Icon:           Icon.ToolsWrench,
            Description:    "An icon representing a wrench tool, typically shown as a single adjustable wrench",
            Tags:           ["wrench", "repair", "maintenance", "adjust"],
            Category:       "Utilities"
        },
        {
            Sequence:       104,
            Name:           "Mail",
            Icon:           Icon.Mail,
            Description:    "An icon representing an envelope or email, typically shown as a simplified envelope shape",
            Tags:           ["email", "message", "envelope", "communication"],
            Category:       "Communication"
        },
        {
            Sequence:       105,
            Name:           "Send",
            Icon:           Icon.Send,
            Description:    "An icon representing the action of sending a message, typically shown as a paper airplane",
            Tags:           ["send", "message", "paper airplane", "submit"],
            Category:       "Communication"
        },
        {
            Sequence:       106,
            Name:           "Clock",
            Icon:           Icon.Clock,
            Description:    "An icon representing a clock or time, typically shown as a circular clock face with hands",
            Tags:           ["time", "watch", "schedule", "hour"],
            Category:       "Time"
        },
        {
            Sequence:       107,
            Name:           "ListWatchlistRemind",
            Icon:           Icon.ListWatchlistRemind,
            Description:    "An icon representing a watchlist or reminder list, typically shown as a checklist with a clock or bell",
            Tags:           ["watchlist", "reminder", "checklist", "alert"],
            Category:       "Productivity"
        },
        {
            Sequence:       108,
            Name:           "LogJournal",
            Icon:           Icon.LogJournal,
            Description:    "An icon representing a log or journal, typically shown as a book or notepad with writing",
            Tags:           ["log", "journal", "record", "diary"],
            Category:       "Productivity"
        },
        {
            Sequence:       109,
            Name:           "Note",
            Icon:           Icon.Note,
            Description:    "An icon representing a note or memo, typically shown as a piece of paper with writing or a folded corner",
            Tags:           ["memo", "paper", "write", "document"],
            Category:       "Productivity"
        },
        {
            Sequence:       110,
            Name:           "PhotosPictures",
            Icon:           Icon.PhotosPictures,
            Description:    "An icon representing photos or pictures, typically shown as multiple overlapping image frames",
            Tags:           ["photos", "pictures", "images", "gallery"],
            Category:       "Media"
        },
        {
            Sequence:       111,
            Name:           "RadarActivityMonitor",
            Icon:           Icon.RadarActivityMonitor,
            Description:    "An icon representing a radar or activity monitor, typically shown as a circular display with scanning lines or activity indicators",
            Tags:           ["radar", "monitor", "activity", "scan"],
            Category:       "Analytics"
        },
        {
            Sequence:       112,
            Name:           "Tablet",
            Icon:           Icon.Tablet,
            Description:    "An icon representing a tablet device, typically shown as a rectangular device with a large screen",
            Tags:           ["device", "iPad", "touchscreen", "portable"],
            Category:       "Devices"
        },
        {
            Sequence:       113,
            Name:           "Tag",
            Icon:           Icon.Tag,
            Description:    "An icon representing a tag or label, typically shown as a simplified tag shape with a hole for attachment",
            Tags:           ["label", "category", "price", "identifier"],
            Category:       "Commerce"
        },
        {
            Sequence:       114,
            Name:           "CameraAperture",
            Icon:           Icon.CameraAperture,
            Description:    "An icon representing a camera aperture, typically shown as a circular shape with blades forming an opening",
            Tags:           ["camera", "lens", "photography", "focus"],
            Category:       "Media"
        },
        {
            Sequence:       115,
            Name:           "ColorPicker",
            Icon:           Icon.ColorPicker,
            Description:    "An icon representing a color picker tool, typically shown as an eyedropper or color selection tool",
            Tags:           ["eyedropper", "color", "palette", "design"],
            Category:       "Design"
        },
        {
            Sequence:       116,
            Name:           "DetailList",
            Icon:           Icon.DetailList,
            Description:    "An icon representing a detailed list view, typically shown as multiple horizontal lines representing list items with additional details",
            Tags:           ["list", "details", "view", "items"],
            Category:       "Interface"
        },
        {
            Sequence:       117,
            Name:           "DocumentWithContent",
            Icon:           Icon.DocumentWithContent,
            Description:    "An icon representing a document with content, typically shown as a paper sheet with lines or text",
            Tags:           ["file", "content", "text", "paper"],
            Category:       "Files"
        },
        {
            Sequence:       118,
            Name:           "ListScrollEmpty",
            Icon:           Icon.ListScrollEmpty,
            Description:    "An icon representing an empty scrollable list, typically shown as a rectangle with horizontal lines and a scroll bar",
            Tags:           ["list", "empty", "scroll", "view"],
            Category:       "Interface"
        },
        {
            Sequence:       119,
            Name:           "ListScrollWatchlist",
            Icon:           Icon.ListScrollWatchlist,
            Description:    "An icon representing a scrollable watchlist, typically shown as a list with a scroll bar and a star or eye symbol",
            Tags:           ["watchlist", "scroll", "favorites", "monitor"],
            Category:       "Interface"
        },
        {
            Sequence:       120,
            Name:           "OptionsList",
            Icon:           Icon.OptionsList,
            Description:    "An icon representing a list of options or settings, typically shown as a series of horizontal lines with toggles or checkboxes",
            Tags:           ["options", "settings", "menu", "preferences"],
            Category:       "Interface"
        },
        {
            Sequence:       121,
            Name:           "LightningBolt",
            Icon:           Icon.LightningBolt,
            Description:    "An icon representing a lightning bolt, typically shown as a jagged line symbolizing electricity or fast action",
            Tags:           ["electricity", "power", "energy", "fast"],
            Category:       "Weather"
        },
        {
            Sequence:       122,
            Name:           "HorizontalLine",
            Icon:           Icon.HorizontalLine,
            Description:    "An icon representing a horizontal line, typically shown as a straight horizontal line used for separation or division",
            Tags:           ["line", "separator", "divider", "horizontal"],
            Category:       "Interface"
        },
        {
            Sequence:       123,
            Name:           "VerticalLine",
            Icon:           Icon.VerticalLine,
            Description:    "An icon representing a vertical line, typically shown as a straight vertical line used for separation or division",
            Tags:           ["line", "separator", "divider", "vertical"],
            Category:       "Interface"
        },
        {
            Sequence:       124,
            Name:           "Ribbon",
            Icon:           Icon.Ribbon,
            Description:    "An icon representing a ribbon, typically shown as a decorative ribbon shape often used for awards or special designations",
            Tags:           ["award", "prize", "recognition", "decoration"],
            Category:       "Miscellaneous"
        },
        {
            Sequence:       125,
            Name:           "Diamond",
            Icon:           Icon.Diamond,
            Description:    "An icon representing a diamond, typically shown as a stylized diamond shape often used to symbolize luxury or value",
            Tags:           ["gem", "jewel", "luxury", "value"],
            Category:       "Miscellaneous"
        },
        {
            Sequence:       126,
            Name:           "Alarm",
            Icon:           Icon.Alarm,
            Description:    "An icon representing an alarm, typically shown as a ringing bell or clock face with alarm indicators",
            Tags:           ["alert", "notification", "reminder", "clock"],
            Category:       "Time"
        },
        {
            Sequence:       127,
            Name:           "History",
            Icon:           Icon.History,
            Description:    "An icon representing history or past events, typically shown as a clock face with an arrow pointing counterclockwise",
            Tags:           ["past", "time", "record", "chronology"],
            Category:       "Time"
        },
        {
            Sequence:       128,
            Name:           "Heart",
            Icon:           Icon.Heart,
            Description:    "An icon representing a heart, typically shown as a stylized heart shape often used to symbolize love, affection, or favorites",
            Tags:           ["love", "like", "favorite", "affection"],
            Category:       "Miscellaneous"
        },
        {
            Sequence:       129,
            Name:           "Print",
            Icon:           Icon.Print,
            Description:    "An icon representing a printer or the action of printing, typically shown as a simplified printer device",
            Tags:           ["printer", "document", "paper", "output"],
            Category:       "Office"
        },
        {
            Sequence:       130,
            Name:           "Error",
            Icon:           Icon.Error,
            Description:    "An icon representing an error or warning, typically shown as an exclamation mark in a triangle or circle",
            Tags:           ["warning", "alert", "danger", "caution"],
            Category:       "Interface"
        },
        {
            Sequence:       131,
            Name:           "Flag",
            Icon:           Icon.Flag,
            Description:    "An icon representing a flag, typically shown as a rectangular or triangular shape on a pole",
            Tags:           ["banner", "marker", "signal", "country"],
            Category:       "Miscellaneous"
        },
        {
            Sequence:       132,
            Name:           "Notebook",
            Icon:           Icon.Notebook,
            Description:    "An icon representing a notebook or journal, typically shown as a bound book with lines or a spiral binding",
            Tags:           ["journal", "diary", "notes", "writing"],
            Category:       "Office"
        },
        {
            Sequence:       133,
            Name:           "Bug",
            Icon:           Icon.Bug,
            Description:    "An icon representing a bug or software error, typically shown as a stylized insect or a symbol indicating a programming issue",
            Tags:           ["error", "glitch", "insect", "debugging"],
            Category:       "Development"
        },
        {
            Sequence:       134,
            Name:           "Microphone",
            Icon:           Icon.Microphone,
            Description:    "An icon representing a microphone, typically shown as a simplified handheld or stand microphone used for audio input",
            Tags:           ["audio", "voice", "record", "sound"],
            Category:       "Media"
        },
        {
            Sequence:       135,
            Name:           "Video",
            Icon:           Icon.Video,
            Description:    "An icon representing video or a video camera, typically shown as a simplified camera or a play button within a frame",
            Tags:           ["movie", "film", "camera", "recording"],
            Category:       "Media"
        },
        {
            Sequence:       136,
            Name:           "Shop",
            Icon:           Icon.Shop,
            Description:    "An icon representing a shop or store, typically shown as a simplified storefront or shopping bag",
            Tags:           ["store", "retail", "market", "commerce"],
            Category:       "Commerce"
        },
        {
            Sequence:       137,
            Name:           "Phonebook",
            Icon:           Icon.Phonebook,
            Description:    "An icon representing a phonebook or contact list, typically shown as a book with a telephone symbol or a list of contacts",
            Tags:           ["contacts", "directory", "address book", "phone list"],
            Category:       "Communication"
        },
        {
            Sequence:       138,
            Name:           "Enhance",
            Icon:           Icon.Enhance,
            Description:    "An icon representing enhancement or improvement, typically shown as a magic wand or a sparkle symbol",
            Tags:           ["improve", "upgrade", "optimize", "magic"],
            Category:       "Editing"
        },
        {
            Sequence:       139,
            Name:           "Unlock",
            Icon:           Icon.Unlock,
            Description:    "An icon representing an unlocked state, typically shown as an open padlock or a lock with an open shackle",
            Tags:           ["open", "access", "security", "permission"],
            Category:       "Security"
        },
        {
            Sequence:       140,
            Name:           "Calculator",
            Icon:           Icon.Calculator,
            Description:    "An icon representing a calculator, typically shown as a simplified device with number buttons and a display screen",
            Tags:           ["math", "computation", "arithmetic", "calculate"],
            Category:       "Office"
        },
        {
            Sequence:       141,
            Name:           "Support",
            Icon:           Icon.Support,
            Description:    "An icon representing support or customer service, typically shown as a headset, speech bubble, or a person offering assistance",
            Tags:           ["help", "customer service", "assistance", "technical support"],
            Category:       "Communication"
        },
        {
            Sequence:       142,
            Name:           "Lightbulb",
            Icon:           Icon.Lightbulb,
            Description:    "An icon representing a lightbulb, typically shown as a simplified incandescent bulb shape, often used to symbolize ideas or inspiration",
            Tags:           ["idea", "inspiration", "innovation", "creativity"],
            Category:       "Miscellaneous"
        },
        {
            Sequence:       143,
            Name:           "Key",
            Icon:           Icon.Key,
            Description:    "An icon representing a key, typically shown as a simplified key shape with a distinctive head and shaft, often used to symbolize access or security",
            Tags:           ["access", "security", "unlock", "password"],
            Category:       "Security"
        },
        {
            Sequence:       144,
            Name:           "Scan",
            Icon:           Icon.Scan,
            Description:    "An icon representing scanning or barcode reading, typically shown as a simplified scanner or barcode with scanning lines",
            Tags:           ["barcode", "QR code", "reader", "scanning"],
            Category:       "Technology"
        },
        {
            Sequence:       145,
            Name:           "Hospital",
            Icon:           Icon.Hospital,
            Description:    "An icon representing a hospital or medical facility, typically shown as a building with a cross symbol or a simplified medical emblem",
            Tags:           ["medical", "healthcare", "emergency", "clinic"],
            Category:       "Health"
        },
        {
            Sequence:       146,
            Name:           "Health",
            Icon:           Icon.Health,
            Description:    "An icon representing health or wellness, typically shown as a heart symbol, medical cross, or a simplified human figure",
            Tags:           ["wellness", "medical", "healthcare", "healthy"],
            Category:       "Health"
        },
        {
            Sequence:       147,
            Name:           "Medical",
            Icon:           Icon.Medical,
            Description:    "An icon representing medical or healthcare services, typically shown as a medical cross, caduceus symbol, or a simplified medical instrument",
            Tags:           ["healthcare", "doctor", "medicine", "hospital"],
            Category:       "Health"
        },
        {
            Sequence:       148,
            Name:           "Manufacture",
            Icon:           Icon.Manufacture,
            Description:    "An icon representing manufacturing or industrial production, typically shown as a factory building, assembly line, or gear symbols",
            Tags:           ["factory", "industry", "production", "assembly"],
            Category:       "Industry"
        },
        {
            Sequence:       149,
            Name:           "Train",
            Icon:           Icon.Train,
            Description:    "An icon representing a train or railway transportation, typically shown as a simplified side view of a train or locomotive",
            Tags:           ["railway", "transportation", "locomotive", "subway"],
            Category:       "Transportation"
        },
        {
            Sequence:       150,
            Name:           "Globe",
            Icon:           Icon.Globe,
            Description:    "An icon representing a globe or world map, typically shown as a circular shape with simplified continents or latitude and longitude lines",
            Tags:           ["world", "earth", "international", "global"],
            Category:       "Geography"
        },
        {
            Sequence:       151,
            Name:           "GlobeNotConnected",
            Icon:           Icon.GlobeNotConnected,
            Description:    "An icon representing a globe with no internet connection, typically shown as a globe symbol with a disconnection indicator",
            Tags:           ["no internet", "offline", "disconnected", "network error"],
            Category:       "Network"
        },
        {
            Sequence:       152,
            Name:           "GlobeRefresh",
            Icon:           Icon.GlobeRefresh,
            Description:    "An icon representing a globe with a refresh or reload action, typically shown as a globe symbol with circular arrows indicating refresh",
            Tags:           ["reload", "update", "sync", "global refresh"],
            Category:       "Network"
        },
        {
            Sequence:       153,
            Name:           "GlobeChangesPending",
            Icon:           Icon.GlobeChangesPending,
            Description:    "An icon representing a globe with pending changes, typically shown as a globe symbol with a clock or hourglass indicator",
            Tags:           ["global updates", "pending changes", "world sync", "update in progress"],
            Category:       "Network"
        },
        {
            Sequence:       154,
            Name:           "GlobeWarning",
            Icon:           Icon.GlobeWarning,
            Description:    "An icon representing a globe with a warning or alert, typically shown as a globe symbol with an exclamation mark or warning triangle",
            Tags:           ["global alert", "world warning", "international caution", "earth hazard"],
            Category:       "Network"
        },
        {
            Sequence:       155,
            Name:           "GlobeError",
            Icon:           Icon.GlobeError,
            Description:    "An icon representing a globe with an error or critical issue, typically shown as a globe symbol with an 'X' mark or error symbol",
            Tags:           ["global error", "world problem", "international issue", "earth malfunction"],
            Category:       "Network"
        },
        {
            Sequence:       156,
            Name:           "HalfFilledCircle",
            Icon:           Icon.HalfFilledCircle,
            Description:    "An icon representing a circle that is half filled, typically shown as a circular shape with one half solid and the other half empty or outlined",
            Tags:           ["half", "semicircle", "partial", "50 percent"],
            Category:       "Shapes"
        },
        {
            Sequence:       157,
            Name:           "Tray",
            Icon:           Icon.Tray,
            Description:    "An icon representing a tray or platform, typically shown as a flat, rectangular shape with raised edges, often used to symbolize a container or serving surface",
            Tags:           ["container", "platform", "serving", "inbox"],
            Category:       "Office"
        },
        {
            Sequence:       158,
            Name:           "Text",
            Icon:           Icon.Text,
            Description:    "An icon representing text or typography, typically shown as a letter 'T' or a few lines symbolizing written content",
            Tags:           ["typography", "font", "writing", "content"],
            Category:       "Editing"
        },
        {
            Sequence:       159,
            Name:           "Shirt",
            Icon:           Icon.Shirt,
            Description:    "An icon representing a shirt or clothing item, typically shown as a simplified outline of a collared shirt or t-shirt",
            Tags:           ["clothing", "apparel", "fashion", "garment"],
            Category:       "Fashion"
        },
        {
            Sequence:       160,
            Name:           "Signal",
            Icon:           Icon.Signal,
            Description:    "An icon representing the Signal messaging app, typically shown as a speech bubble with a padlock inside",
            Tags:           ["messaging", "secure communication", "privacy", "encryption"],
            Category:       "Communication"
        },
        {
            Sequence:       161,
            Name:           "People",
            Icon:           Icon.People,
            Description:    "An icon representing a group of people or users, typically shown as multiple simplified human figures",
            Tags:           ["users", "group", "community", "team"],
            Category:       "Social"
        },
        {
            Sequence:       162,
            Name:           "Person",
            Icon:           Icon.Person,
            Description:    "An icon representing a single person or user, typically shown as a simplified human figure or head and shoulders silhouette",
            Tags:           ["user", "individual", "profile", "avatar"],
            Category:       "Social"
        },
        {
            Sequence:       163,
            Name:           "EmojiFrown",
            Icon:           Icon.EmojiFrown,
            Description:    "An icon representing a frowning face emoji, typically shown as a circular face with downturned eyes and mouth",
            Tags:           ["sad", "unhappy", "disappointed", "negative"],
            Category:       "Emoji"
        },
        {
            Sequence:       164,
            Name:           "EmojiSmile",
            Icon:           Icon.EmojiSmile,
            Description:    "An icon representing a smiling face emoji, typically shown as a circular face with upturned eyes and mouth",
            Tags:           ["happy", "joy", "positive", "cheerful"],
            Category:       "Emoji"
        },
        {
            Sequence:       165,
            Name:           "EmojiSad",
            Icon:           Icon.EmojiSad,
            Description:    "An icon representing a sad face emoji, typically shown as a circular face with downturned eyes and mouth, often with a tear",
            Tags:           ["unhappy", "crying", "upset", "depressed"],
            Category:       "Emoji"
        },
        {
            Sequence:       166,
            Name:           "EmojiNeutral",
            Icon:           Icon.EmojiNeutral,
            Description:    "An icon representing a neutral face emoji, typically shown as a circular face with straight line for a mouth and neutral eyes",
            Tags:           ["indifferent", "expressionless", "poker face", "impartial"],
            Category:       "Emoji"
        },
        {
            Sequence:       167,
            Name:           "EmojiHappy",
            Icon:           Icon.EmojiHappy,
            Description:    "An icon representing a happy face emoji, typically shown as a circular face with wide smile and upturned eyes",
            Tags:           ["joyful", "ecstatic", "grinning", "elated"],
            Category:       "Emoji"
        },
        {
            Sequence:       168,
            Name:           "Warning",
            Icon:           Icon.Warning,
            Description:    "An icon representing a warning or caution, typically shown as a triangle with an exclamation mark inside",
            Tags:           ["alert", "caution", "danger", "attention"],
            Category:       "Interface"
        },
        {
            Sequence:       169,
            Name:           "Information",
            Icon:           Icon.Information,
            Description:    "An icon representing information or details, typically shown as a lowercase 'i' in a circle",
            Tags:           ["info", "details", "help", "about"],
            Category:       "Interface"
        },
        {
            Sequence:       170,
            Name:           "Database",
            Icon:           Icon.Database,
            Description:    "An icon representing a database or data storage, typically shown as a cylindrical shape or stacked disks",
            Tags:           ["storage", "data", "server", "repository"],
            Category:       "Technology"
        },
        {
            Sequence:       171,
            Name:           "Weather",
            Icon:           Icon.Weather,
            Description:    "An icon representing weather conditions, typically shown as a sun, cloud, or combination of weather symbols",
            Tags:           ["forecast", "climate", "meteorology", "temperature"],
            Category:       "Nature"
        },
        {
            Sequence:       172,
            Name:           "TrendingHashtag",
            Icon:           Icon.TrendingHashtag,
            Description:    "An icon representing a trending hashtag, typically shown as a hashtag symbol (#) with an upward arrow or graph",
            Tags:           ["popular", "viral", "social media", "trend"],
            Category:       "Social Media"
        },
        {
            Sequence:       173,
            Name:           "TrendingUpwards",
            Icon:           Icon.TrendingUpwards,
            Description:    "An icon representing an upward trend, typically shown as a line graph or arrow pointing upwards",
            Tags:           ["increase", "growth", "rising", "improvement"],
            Category:       "Business"
        },
        {
            Sequence:       174,
            Name:           "Items",
            Icon:           Icon.Items,
            Description:    "An icon representing multiple items or a list, typically shown as stacked rectangles or a bulleted list",
            Tags:           ["list", "inventory", "collection", "elements"],
            Category:       "Interface"
        },
        {
            Sequence:       175,
            Name:           "LevelsLayersItems",
            Icon:           Icon.LevelsLayersItems,
            Description:    "An icon representing multiple levels, layers, or stacked items, typically shown as overlapping shapes or stacked planes",
            Tags:           ["layers", "stack", "hierarchy", "organization"],
            Category:       "Interface"
        },
        {
            Sequence:       176,
            Name:           "Trending",
            Icon:           Icon.Trending,
            Description:    "An icon representing trending or popular topics, typically shown as a graph with an upward trend or a flame symbol",
            Tags:           ["popular", "viral", "hot topic", "trending now"],
            Category:       "Social Media"
        },
        {
            Sequence:       177,
            Name:           "LineWeight",
            Icon:           Icon.LineWeight,
            Description:    "An icon representing line weight or thickness, typically shown as multiple horizontal lines of varying thicknesses",
            Tags:           ["thickness", "stroke", "width", "border"],
            Category:       "Design"
        },
        {
            Sequence:       178,
            Name:           "Printing3D",
            Icon:           Icon.Printing3D,
            Description:    "An icon representing 3D printing, typically shown as a simplified 3D printer or a cube being constructed layer by layer",
            Tags:           ["additive manufacturing", "rapid prototyping", "3D modeling", "fabrication"],
            Category:       "Technology"
        }
    ],
    Sequence,
    SortOrder.Ascending
);
