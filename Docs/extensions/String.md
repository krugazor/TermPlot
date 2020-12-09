**EXTENSION**

# `String`
```swift
public extension String
```

## Methods
### `apply(_:style:)`

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

### `apply(_:styles:)`

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