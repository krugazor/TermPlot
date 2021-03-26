**ENUM**

# `DisplaySymbol`

**Contents**

- [Cases](#cases)
  - `empty`
  - `point`
  - `vert_left`
  - `vert_right`
  - `horz_top`
  - `horz_bot`
  - `bot_left`
  - `top_right`
  - `top_left`
  - `bot_right`
  - `tick_right`
  - `tick_left`
  - `tick_up`
  - `tick_down`
- [Methods](#methods)
  - `withStyle(_:)`
  - `cWithStyle(_:)`

```swift
public enum DisplaySymbol : String, CaseIterable
```

Possible symbols to use in the graph

## Cases
### `empty`

```swift
case empty
```

### `point`

```swift
case point
```

### `vert_left`

```swift
case vert_left
```

### `vert_right`

```swift
case vert_right
```

### `horz_top`

```swift
case horz_top
```

### `horz_bot`

```swift
case horz_bot
```

### `bot_left`

```swift
case bot_left
```

### `top_right`

```swift
case top_right
```

### `top_left`

```swift
case top_left
```

### `bot_right`

```swift
case bot_right
```

### `tick_right`

```swift
case tick_right
```

### `tick_left`

```swift
case tick_left
```

### `tick_up`

```swift
case tick_up
```

### `tick_down`

```swift
case tick_down
```

## Methods
<details><summary markdown="span"><code>withStyle(_:)</code></summary>

```swift
public func withStyle(_ s: DisplayStyle) -> String
```

Adapts the symbol to a style, and generates a string ready for output
- Parameter s: the style to use
- Returns: the string to output

#### Parameters

| Name | Description |
| ---- | ----------- |
| s | the style to use |

</details>

<details><summary markdown="span"><code>cWithStyle(_:)</code></summary>

```swift
public func cWithStyle(_ s: DisplayStyle) -> Character
```

Adapts the symbol to a style, and generates a character ready for output
- Parameter s: the style to use
- Returns: the character to output

#### Parameters

| Name | Description |
| ---- | ----------- |
| s | the style to use |

</details>