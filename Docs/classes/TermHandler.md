**CLASS**

# `TermHandler`

**Contents**

- [Properties](#properties)
  - `cols`
  - `rows`
  - `windowResizedAction`
  - `screenLock`
  - `_instance`
  - `shared`
- [Methods](#methods)
  - `init()`
  - `trap(signal:action:)`
  - `moveCursorNewline()`
  - `moveCursorRight(_:)`
  - `moveCursorLeft(_:)`
  - `moveCursorDown(_:)`
  - `moveCursorUp(_:)`
  - `moveCursor(toX:y:)`
  - `put(s:)`
  - `put(s:color:style:)`
  - `put(s:color:styles:)`
  - `set(_:style:)`
  - `set(_:styles:)`
  - `lock()`
  - `unlock()`

```swift
public class TermHandler
```

Low level class used to handle everything ANSI

## Properties
<details><summary markdown="span"><code>cols</code></summary>

```swift
public fileprivate(set) var cols  = 80
```

columns in the current instance

</details>

<details><summary markdown="span"><code>rows</code></summary>

```swift
public fileprivate(set) var rows = 43
```

lines in the current instance

</details>

<details><summary markdown="span"><code>windowResizedAction</code></summary>

```swift
var windowResizedAction : ((TermHandler)->Void)?
```

block to call in the event of window resizing
not the most elegant, but I cannot have labels on the arguments

</details>

<details><summary markdown="span"><code>screenLock</code></summary>

```swift
var screenLock = NSLock()
```

the "v-sync" lock

</details>

<details><summary markdown="span"><code>_instance</code></summary>

```swift
static var _instance : TermHandler?
```

private singleton instance

</details>

<details><summary markdown="span"><code>shared</code></summary>

```swift
static public var shared : TermHandler
```

public shared singleton

</details>

## Methods
<details><summary markdown="span"><code>init()</code></summary>

```swift
init()
```

private-ish initializer for the singleton

</details>

<details><summary markdown="span"><code>trap(signal:action:)</code></summary>

```swift
public class func trap(signal: Int32, action: @escaping SigActionHandler)
```

Trap an operating system signal.

- Parameters:
       - signal:    The signal to catch.
       - action:    The action handler.

</details>

<details><summary markdown="span"><code>moveCursorNewline()</code></summary>

```swift
public func moveCursorNewline()
```

Moves the cursor down and to the beginning of the line (may not be supported)
- Parameter amount: the delta

#### Parameters

| Name | Description |
| ---- | ----------- |
| amount | the delta |

</details>

<details><summary markdown="span"><code>moveCursorRight(_:)</code></summary>

```swift
public func moveCursorRight(_ amount: Int)
```

Moves the cursor right by a certain amount
- Parameter amount: the delta

#### Parameters

| Name | Description |
| ---- | ----------- |
| amount | the delta |

</details>

<details><summary markdown="span"><code>moveCursorLeft(_:)</code></summary>

```swift
public func moveCursorLeft(_ amount: Int)
```

Moves the cursor left by a certain amount
- Parameter amount: the delta

#### Parameters

| Name | Description |
| ---- | ----------- |
| amount | the delta |

</details>

<details><summary markdown="span"><code>moveCursorDown(_:)</code></summary>

```swift
public func moveCursorDown(_ amount: Int)
```

Moves the cursor down by a certain amount
- Parameter amount: the delta

#### Parameters

| Name | Description |
| ---- | ----------- |
| amount | the delta |

</details>

<details><summary markdown="span"><code>moveCursorUp(_:)</code></summary>

```swift
public func moveCursorUp(_ amount: Int)
```

Moves the cursor up by a certain amount
- Parameter amount: the delta

#### Parameters

| Name | Description |
| ---- | ----------- |
| amount | the delta |

</details>

<details><summary markdown="span"><code>moveCursor(toX:y:)</code></summary>

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

</details>

<details><summary markdown="span"><code>put(s:)</code></summary>

```swift
public func put(s: String)
```

variant of (out)put with an agnostic string
- Parameter s: the text to output

#### Parameters

| Name | Description |
| ---- | ----------- |
| s | the text to output |

</details>

<details><summary markdown="span"><code>put(s:color:style:)</code></summary>

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

</details>

<details><summary markdown="span"><code>put(s:color:styles:)</code></summary>

```swift
public func put(s: String, color: TermColor, styles: [TermStyle])
```

variant of (out)put with an specific style
- Parameter s: the text to output
- Parameter color: the color to use
- Parameter styles: the styles to use

#### Parameters

| Name | Description |
| ---- | ----------- |
| s | the text to output |
| color | the color to use |
| styles | the styles to use |

</details>

<details><summary markdown="span"><code>set(_:style:)</code></summary>

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

</details>

<details><summary markdown="span"><code>set(_:styles:)</code></summary>

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

</details>

<details><summary markdown="span"><code>lock()</code></summary>

```swift
public func lock()
```

Locks the v-blank

</details>

<details><summary markdown="span"><code>unlock()</code></summary>

```swift
public func unlock()
```

Unlocks the v-blank

</details>