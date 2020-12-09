**CLASS**

# `TermHandler`

```swift
public class TermHandler
```

Low level class used to handle everything ANSI

## Properties
### `cols`

```swift
public fileprivate(set) var cols  = 80
```

columns in the current instance

### `rows`

```swift
public fileprivate(set) var rows = 43
```

lines in the current instance

## Methods
### `trap(signal:action:)`

```swift
public class func trap(signal: Int32, action: @escaping SigActionHandler)
```

Trap an operating system signal.

- Parameters:
       - signal:    The signal to catch.
       - action:    The action handler.

### `moveCursorRight(_:)`

```swift
public func moveCursorRight(_ amount: Int)
```

Moves the cursor right by a certain amount
- Parameter amount: the delta

#### Parameters

| Name | Description |
| ---- | ----------- |
| amount | the delta |

### `moveCursorLeft(_:)`

```swift
public func moveCursorLeft(_ amount: Int)
```

Moves the cursor left by a certain amount
- Parameter amount: the delta

#### Parameters

| Name | Description |
| ---- | ----------- |
| amount | the delta |

### `moveCursorDown(_:)`

```swift
public func moveCursorDown(_ amount: Int)
```

Moves the cursor down by a certain amount
- Parameter amount: the delta

#### Parameters

| Name | Description |
| ---- | ----------- |
| amount | the delta |

### `moveCursorUp(_:)`

```swift
public func moveCursorUp(_ amount: Int)
```

Moves the cursor up by a certain amount
- Parameter amount: the delta

#### Parameters

| Name | Description |
| ---- | ----------- |
| amount | the delta |

### `moveCursor(toX:y:)`

```swift
public func moveCursor(toX: Int, y: Int)
```

Moves the cursor to specific coordinates. Warning! 1-based
- Parameters:
  - toX: x position
  - y: y position

#### Parameters

| Name | Description |
| ---- | ----------- |
| toX | x position |
| y | y position |

### `put(s:)`

```swift
public func put(s: String)
```

variant of (out)put with an agnostic string
- Parameter s: the text to output

#### Parameters

| Name | Description |
| ---- | ----------- |
| s | the text to output |

### `put(s:color:style:)`

```swift
public func put(s: String, color: TermColor, style: TermStyle)
```

variant of (out)put with an specific style
- Parameter s: the text to output
- Parameter color: the color to use
- Parameter style: the style to use

#### Parameters

| Name | Description |
| ---- | ----------- |
| s | the text to output |
| color | the color to use |
| style | the style to use |

### `set(_:style:)`

```swift
public func set(_ color: TermColor, style: TermStyle)
```

changes the style for the next output
- Parameter color: the color to use
- Parameter style: the style to use

#### Parameters

| Name | Description |
| ---- | ----------- |
| color | the color to use |
| style | the style to use |

### `set(_:styles:)`

```swift
public func set(_ color: TermColor, styles: [TermStyle])
```

changes the style for the next output
- Parameter color: the color to use
- Parameter style: the set of styles to use

#### Parameters

| Name | Description |
| ---- | ----------- |
| color | the color to use |
| style | the set of styles to use |

### `lock()`

```swift
public func lock()
```

Locks the v-blank

### `unlock()`

```swift
public func unlock()
```

Unlocks the v-blank
