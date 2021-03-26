**CLASS**

# `TermWindow`

**Contents**

- [Properties](#properties)
  - `_window`
  - `default`
  - `screenLock`
  - `originalSettings`
  - `setup`
  - `rows`
  - `cols`
  - `currentBox`
  - `cursorPosition`
  - `wid`
  - `embeddedIn`
- [Methods](#methods)
  - `rowsDidChange()`
  - `colsDidChange()`
  - `size(for:)`
  - `size(for:)`
  - `init(embedIn:)`
  - `setupTTY()`
  - `restoreTTY(then:)`
  - `moveCursorRight(_:)`
  - `moveCursorLeft(_:)`
  - `moveCursorUp(_:)`
  - `moveCursorDown(_:)`
  - `clearScreen()`
  - `boxScreen(_:)`
  - `draw(_:offset:clearSkip:)`
  - `draw(_:offset:clearSkip:)`
  - `requestBuffer(for:box:_:)`
  - `requestStyledBuffer(for:box:_:)`
  - `requestBuffer(box:_:)`
  - `requestStyledBuffer(box:_:)`

```swift
public class TermWindow
```

"Screen" or "buffer" analog for output. Will be used by all descendants to draw things in the terminal

## Properties
<details><summary markdown="span"><code>_window</code></summary>

```swift
static fileprivate var _window : TermWindow?
```

Singleton variable

</details>

<details><summary markdown="span"><code>default</code></summary>

```swift
static public var `default` : TermWindow
```

Singleton shared variable

</details>

<details><summary markdown="span"><code>screenLock</code></summary>

```swift
fileprivate var screenLock : NSLock = NSLock()
```

clear screen lock

</details>

<details><summary markdown="span"><code>originalSettings</code></summary>

```swift
fileprivate var originalSettings : termios?
```

settings grabbed from the terminal when the instance started

</details>

<details><summary markdown="span"><code>setup</code></summary>

```swift
fileprivate var setup = false
```

have we setup the TTY?

</details>

<details><summary markdown="span"><code>rows</code></summary>

```swift
public internal(set) var rows: Int
```

number of rows in the buffer

</details>

<details><summary markdown="span"><code>cols</code></summary>

```swift
public internal(set) var cols: Int
```

number of columns in the buffer

</details>

<details><summary markdown="span"><code>currentBox</code></summary>

```swift
fileprivate var currentBox : (cols: Int, rows: Int) = (0,0)
```

remnants from earlier experiments about lessening the number of redraws

</details>

<details><summary markdown="span"><code>cursorPosition</code></summary>

```swift
fileprivate var cursorPosition : (x: Int, y: Int) = (0,0)
```

remnants from earlier experiments about lessening the number of redraws

</details>

<details><summary markdown="span"><code>wid</code></summary>

```swift
let wid = UUID()
```

unique ID to make sure we're talking about the same windows

</details>

<details><summary markdown="span"><code>embeddedIn</code></summary>

```swift
var embeddedIn: TermWindow?
```

if a window is embedded in another

</details>

## Methods
<details><summary markdown="span"><code>rowsDidChange()</code></summary>

```swift
func rowsDidChange()
```

Function called when screen size changes

</details>

<details><summary markdown="span"><code>colsDidChange()</code></summary>

```swift
func colsDidChange()
```

Function called when screen size changes

</details>

<details><summary markdown="span"><code>size(for:)</code></summary>

```swift
func size(for: TermWindow) -> (width: Int, height: Int)
```

function used to determine the width/height we should give our children windows
as it mostly is for multiterms, this will likely return the size of the terminal
will need to be overridden

- Parameter for : the term to look for in children

- Returns: the expected size this window will occupy

#### Parameters

| Name | Description |
| ---- | ----------- |
| for | the term to look for in children |

</details>

<details><summary markdown="span"><code>size(for:)</code></summary>

```swift
func size(for: UUID) -> (width: Int, height: Int)
```

function used to determine the width/height we should give our children windows
as it mostly is for multiterms, this will likely return the size of the terminal
will need to be overridden

- Parameter for : the term uuid to look for in children

- Returns: the expected size this window will occupy

#### Parameters

| Name | Description |
| ---- | ----------- |
| for | the term uuid to look for in children |

</details>

<details><summary markdown="span"><code>init(embedIn:)</code></summary>

```swift
init(embedIn: TermWindow? = nil)
```

Default initializer

</details>

<details><summary markdown="span"><code>setupTTY()</code></summary>

```swift
func setupTTY()
```

Sets the ANSI terminal up (hides the cursor, clears the screen, etc)

</details>

<details><summary markdown="span"><code>restoreTTY(then:)</code></summary>

```swift
func restoreTTY(then: @escaping ()->())
```

Restores the TTY to previous settings (before the program grabbed it)
- Parameter then: the block to call once the settings are restored

#### Parameters

| Name | Description |
| ---- | ----------- |
| then | the block to call once the settings are restored |

</details>

<details><summary markdown="span"><code>moveCursorRight(_:)</code></summary>

```swift
public func moveCursorRight(_ amount: Int)
```

Publicly exposed function to move the cursor right
- Parameter amount: number of steps

#### Parameters

| Name | Description |
| ---- | ----------- |
| amount | number of steps |

</details>

<details><summary markdown="span"><code>moveCursorLeft(_:)</code></summary>

```swift
public func moveCursorLeft(_ amount: Int)
```

Publicly exposed function to move the cursor left
- Parameter amount: number of steps

#### Parameters

| Name | Description |
| ---- | ----------- |
| amount | number of steps |

</details>

<details><summary markdown="span"><code>moveCursorUp(_:)</code></summary>

```swift
public func moveCursorUp(_ amount: Int)
```

Publicly exposed function to move the cursor up
- Parameter amount: number of steps

#### Parameters

| Name | Description |
| ---- | ----------- |
| amount | number of steps |

</details>

<details><summary markdown="span"><code>moveCursorDown(_:)</code></summary>

```swift
public func moveCursorDown(_ amount: Int)
```

Publicly exposed function to move the cursor down
- Parameter amount: number of steps

#### Parameters

| Name | Description |
| ---- | ----------- |
| amount | number of steps |

</details>

<details><summary markdown="span"><code>clearScreen()</code></summary>

```swift
public func clearScreen()
```

Clears the screen and sets the TTY up if necessary

</details>

<details><summary markdown="span"><code>boxScreen(_:)</code></summary>

```swift
public func boxScreen(_ style: BoxType = .simple)
```

Draws a box around the screen
- Parameter style: the box style (default `.simple`)

#### Parameters

| Name | Description |
| ---- | ----------- |
| style | the box style (default `.simple`) |

</details>

<details><summary markdown="span"><code>draw(_:offset:clearSkip:)</code></summary>

```swift
func draw(_ buffer: [[Character]], offset: (Int,Int) = (0,0), clearSkip: Bool = true)
```

Draws the contents of a buffer to screen (blit function)
- Parameters:
  - buffer: the buffer to output
  - offset: the offset at which to start on screen

#### Parameters

| Name | Description |
| ---- | ----------- |
| buffer | the buffer to output |
| offset | the offset at which to start on screen |

</details>

<details><summary markdown="span"><code>draw(_:offset:clearSkip:)</code></summary>

```swift
func draw(_ buffer: [[TermCharacter]], offset: (Int,Int) = (0,0), clearSkip: Bool = true)
```

Draws the contents of a buffer to screen (blit function)
- Parameters:
  - buffer: the buffer to output
  - offset: the offset at which to start on screen

#### Parameters

| Name | Description |
| ---- | ----------- |
| buffer | the buffer to output |
| offset | the offset at which to start on screen |

</details>

<details><summary markdown="span"><code>requestBuffer(for:box:_:)</code></summary>

```swift
public func requestBuffer(for sub: TermWindow, box: BoxType = .simple, _ handler: (inout [[Character]])->Void)
```

Reserve and callback mechanic to draw on screen: a buffer is generated according to the current size, then filled by the block, then blit
In this particular case, does nothing, as regular windows don't have subwindows
- Parameters:
  - for: the window requesting a buffer
  - box: should we box the screen?
  - handler: the block that will fill the buffer

#### Parameters

| Name | Description |
| ---- | ----------- |
| for | the window requesting a buffer |
| box | should we box the screen? |
| handler | the block that will fill the buffer |

</details>

<details><summary markdown="span"><code>requestStyledBuffer(for:box:_:)</code></summary>

```swift
public func requestStyledBuffer(for sub: TermWindow, box: BoxType = .simple, _ handler: (inout [[TermCharacter]])->Void)
```

Reserve and callback mechanic to draw on screen: a buffer is generated according to the current size, then filled by the block, then blit
In this particular case, does nothing, as regular windows don't have subwindows
- Parameters:
  - for: the window requesting a buffer
  - box: should we box the screen?
  - handler: the block that will fill the buffer

#### Parameters

| Name | Description |
| ---- | ----------- |
| for | the window requesting a buffer |
| box | should we box the screen? |
| handler | the block that will fill the buffer |

</details>

<details><summary markdown="span"><code>requestBuffer(box:_:)</code></summary>

```swift
public func requestBuffer(box: BoxType = .simple, _ handler: (inout [[Character]])->Void)
```

Reserve and callback mechanic to draw on screen: a buffer is generated according to the current size, then filled by the block, then blit
- Parameters:
  - box: should we box the screen?
  - handler: the block that will fill the buffer

#### Parameters

| Name | Description |
| ---- | ----------- |
| box | should we box the screen? |
| handler | the block that will fill the buffer |

</details>

<details><summary markdown="span"><code>requestStyledBuffer(box:_:)</code></summary>

```swift
public func requestStyledBuffer(box: BoxType = .simple, _ handler: (inout [[TermCharacter]])->Void)
```

Reserve and callback mechanic to draw on screen: a buffer is generated according to the current size, then filled by the block, then blit
- Parameters:
  - box: should we box the screen?
  - handler: the block that will fill the buffer

#### Parameters

| Name | Description |
| ---- | ----------- |
| box | should we box the screen? |
| handler | the block that will fill the buffer |

</details>