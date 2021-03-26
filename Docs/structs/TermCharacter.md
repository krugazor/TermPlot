**STRUCT**

# `TermCharacter`

**Contents**

- [Properties](#properties)
  - `char`
  - `color`
  - `styles`
- [Methods](#methods)
  - `init(_:color:styles:)`

```swift
public struct TermCharacter
```

Basic "pixel" like structure

## Properties
<details><summary markdown="span"><code>char</code></summary>

```swift
var char : Character
```

the character

</details>

<details><summary markdown="span"><code>color</code></summary>

```swift
var color : TermColor
```

the color

</details>

<details><summary markdown="span"><code>styles</code></summary>

```swift
var styles : [TermStyle]
```

the styles

</details>

## Methods
<details><summary markdown="span"><code>init(_:color:styles:)</code></summary>

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

</details>