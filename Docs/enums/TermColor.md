**ENUM**

# `TermColor`

**Contents**

- [Cases](#cases)
  - `black`
  - `light_black`
  - `red`
  - `light_red`
  - `green`
  - `light_green`
  - `yellow`
  - `light_yellow`
  - `blue`
  - `light_blue`
  - `magenta`
  - `light_magenta`
  - `cyan`
  - `light_cyan`
  - `white`
  - `light_white`
  - `default`
- [Properties](#properties)
  - `asRGB`

```swift
public enum TermColor : Int, CaseIterable
```

The ANSI colors (self explanatory)

## Cases
### `black`

```swift
case black = 0
```

### `light_black`

```swift
case light_black = 60
```

### `red`

```swift
case red = 1
```

### `light_red`

```swift
case light_red = 61
```

### `green`

```swift
case green = 2
```

### `light_green`

```swift
case light_green = 62
```

### `yellow`

```swift
case yellow = 3
```

### `light_yellow`

```swift
case light_yellow = 63
```

### `blue`

```swift
case blue = 4
```

### `light_blue`

```swift
case light_blue = 64
```

### `magenta`

```swift
case magenta = 5
```

### `light_magenta`

```swift
case light_magenta = 65
```

### `cyan`

```swift
case cyan = 6
```

### `light_cyan`

```swift
case light_cyan = 66
```

### `white`

```swift
case white = 7
```

### `light_white`

```swift
case light_white = 67
```

### `default`

```swift
case `default` = 9
```

## Properties
<details><summary markdown="span"><code>asRGB</code></summary>

```swift
var asRGB : (r: Float, g: Float, b: Float)?
```

</details>
