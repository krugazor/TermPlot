**STRUCT**

# `TermCharacter`

```swift
public struct TermCharacter
```

Basic "pixel" like structure

## Properties
### `char`

```swift
var char : Character
```

the character

### `color`

```swift
var color : TermColor
```

the color

### `styles`

```swift
var styles : [TermStyle]
```

the styles

## Methods
### `init(_:color:styles:)`

```swift
public init(_ c: Character = " ", color col : TermColor = .default, styles s: [TermStyle] = [.default])
```

Initializer with defaults built-in
- Parameters:
  - c: a character
  - col: a color
  - s: styles to use

#### Parameters

| Name | Description |
| ---- | ----------- |
| c | a character |
| col | a color |
| s | styles to use |