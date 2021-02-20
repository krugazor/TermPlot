**CLASS**

# `TermWindow`

```swift
public class TermWindow
```

"Screen" or "buffer" analog for output. Will be used by all descendants to draw things in the terminal

## Properties
### `_window`

```swift
static fileprivate var _window : TermWindow?
```

Singleton variable

### `default`

```swift
static public var `default` : TermWindow
```

Singleton shared variable

### `screenLock`

```swift
fileprivate var screenLock : NSLock = NSLock()
```

clear screen lock

### `originalSettings`

```swift
fileprivate var originalSettings : termios?
```

settings grabbed from the terminal when the instance started

### `setup`

```swift
fileprivate var setup = false
```

have we setup the TTY?

### `rows`

```swift
public internal(set) var rows: Int
```

number of rows in the buffer

### `cols`

```swift
public internal(set) var cols: Int
```

number of columns in the buffer

### `currentBox`

```swift
fileprivate var currentBox : (cols: Int, rows: Int) = (0,0)
```

remnants from earlier experiments about lessening the number of redraws

### `cursorPosition`

```swift
fileprivate var cursorPosition : (x: Int, y: Int) = (0,0)
```

remnants from earlier experiments about lessening the number of redraws

### `wid`

```swift
let wid = UUID()
```

unique ID to make sure we're talking about the same windows

### `embeddedIn`

```swift
var embeddedIn: TermWindow?
```

if a window is embedded in another

## Methods
### `rowsDidChange()`

```swift
func rowsDidChange()
```

Function called when screen size changes

### `colsDidChange()`

```swift
func colsDidChange()
```

Function called when screen size changes

### `size(for:)`

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

### `size(for:)`

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

### `init(embedIn:)`

```swift
init(embedIn: TermWindow? = nil)
```

Default initializer

### `setupTTY()`

```swift
func setupTTY()
```

Sets the ANSI terminal up (hides the cursor, clears the screen, etc)

### `restoreTTY(then:)`

```swift
func restoreTTY(then: @escaping ()->())
```

Restores the TTY to previous settings (before the program grabbed it)
- Parameter then: the block to call once the settings are restored

#### Parameters

| Name | Description |
| ---- | ----------- |
| then | the block to call once the settings are restored |

### `moveCursorRight(_:)`

```swift
public func moveCursorRight(_ amount: Int)
```

Publicly exposed function to move the cursor right
- Parameter amount: number of steps

#### Parameters

| Name | Description |
| ---- | ----------- |
| amount | number of steps |

### `moveCursorLeft(_:)`

```swift
public func moveCursorLeft(_ amount: Int)
```

Publicly exposed function to move the cursor left
- Parameter amount: number of steps

#### Parameters

| Name | Description |
| ---- | ----------- |
| amount | number of steps |

### `moveCursorUp(_:)`

```swift
public func moveCursorUp(_ amount: Int)
```

Publicly exposed function to move the cursor up
- Parameter amount: number of steps

#### Parameters

| Name | Description |
| ---- | ----------- |
| amount | number of steps |

### `moveCursorDown(_:)`

```swift
public func moveCursorDown(_ amount: Int)
```

Publicly exposed function to move the cursor down
- Parameter amount: number of steps

#### Parameters

| Name | Description |
| ---- | ----------- |
| amount | number of steps |

### `clearScreen()`

```swift
public func clearScreen()
```

Clears the screen and sets the TTY up if necessary

### `boxScreen(_:)`

```swift
public func boxScreen(_ style: BoxType = .simple)
```

Draws a box around the screen
- Parameter style: the box style (default `.simple`)

#### Parameters

| Name | Description |
| ---- | ----------- |
| style | the box style (default `.simple`) |

### `draw(_:offset:clearSkip:)`

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

### `draw(_:offset:clearSkip:)`

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

### `requestBuffer(for:box:_:)`

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

### `requestStyledBuffer(for:box:_:)`

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

### `requestBuffer(box:_:)`

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

### `requestStyledBuffer(box:_:)`

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