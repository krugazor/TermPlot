**CLASS**

# `TermWindow`

```swift
public class TermWindow
```

"Screen" or "buffer" analog for output. Will be used by all descendants to draw things in the terminal

## Properties
### `rows`

```swift
public private(set) var rows: Int
```

number of rows in the buffer

### `cols`

```swift
public private(set) var cols: Int
```

number of columns in the buffer

## Methods
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