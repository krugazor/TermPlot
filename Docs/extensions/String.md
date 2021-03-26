**EXTENSION**

# `String`
```swift
public extension String
```

## Methods
<details><summary markdown="span"><code>apply(_:style:)</code></summary>

```swift
func apply(_ color: TermColor, style: TermStyle = .default) -> String
```

Creates a string with specified color and style
- Parameters:
  - color: the color to use
  - style: the style to use
- Returns: a string ready to be output in an ANSI terminal

#### Parameters

| Name | Description |
| ---- | ----------- |
| color | the color to use |
| style | the style to use |

</details>

<details><summary markdown="span"><code>apply(_:styles:)</code></summary>

```swift
func apply(_ color: TermColor, styles: [TermStyle] = [.default]) -> String
```

Creates a string with specified color and style
- Parameters:
  - color: the color to use
  - styles: the styles to use
- Returns: a string ready to be output in an ANSI terminal

#### Parameters

| Name | Description |
| ---- | ----------- |
| color | the color to use |
| styles | the styles to use |

</details>

<details><summary markdown="span"><code>split(every:backwards:)</code></summary>

```swift
public func split(every: Int, backwards: Bool = false) -> [String]
```

Splits a string into groups of `every` n characters, grouping from left-to-right by default. If `backwards` is true, right-to-left.

</details>