**CLASS**

# `TermMultiWindow`

```swift
public class TermMultiWindow : TermWindow
```

Class that allows sub window compositions in stacks, either horizontal or vertical

## Properties
### `subwindows`

```swift
let subwindows : [TermWindow]
```

### `stackType`

```swift
let stackType: StackType
```

subwindows for this window

### `ratios`

```swift
let ratios : [Float]
```

split type

### `offsets`

```swift
var offsets : [Int]
```

original ratios asked by the caller

### `rectangleCache`

```swift
var rectangleCache : [UUID:(x: Int, y: Int, width: Int, height: Int)] = [:]
```

rectangle cache to avoid computing it every time
invalidated on screen size change

## Methods
### `offsetsFromRatios(length:ratios:)`

```swift
static func offsetsFromRatios(length: Int, ratios: [Float]) -> [Int]
```

translation into character offsets
function that translates and rounds ratios to offsets (to avoid code duplication)
- Parameters:
  - length: total width or height to split
  - ratios: ratios to apply
- Returns: the offsets

#### Parameters

| Name | Description |
| ---- | ----------- |
| length | total width or height to split |
| ratios | ratios to apply |

### `init(stack:ratios:_:)`

```swift
convenience init(stack: StackType, ratios lrat: [Float], _ subs: TermWindow...) throws
```

Convenience initializer to switch from variadic parameters to arrays
- See init for details on the parameters

### `init(stack:ratios:_:)`

```swift
init(stack: StackType, ratios lrat: [Float], _ subs: [TermWindow]) throws
```

Standard initializer
- Parameters:
  - stack: vertical or horizontal
  - ratios: the ratios to apply
  - subs: the terminal windows that will compose this stack
- Throws: if there is a mismatch in windows and ratios, of if a ratio is 0, or any other configuration error

#### Parameters

| Name | Description |
| ---- | ----------- |
| stack | vertical or horizontal |
| ratios | the ratios to apply |
| subs | the terminal windows that will compose this stack |

### `setup(stack:ratios:_:)`

```swift
public static func setup(stack: StackType, ratios lrat: [Float], _ subs: TermWindow...) throws -> TermMultiWindow
```

Publicly exposed initializer
  - stack: vertical or horizontal
  - ratios: the ratios to apply
  - subs: the terminal windows that will compose this stack
- Throws: if there is a mismatch in windows and ratios, of if a ratio is 0, or any other configuration error
- Returns: a fully initialized stack of subwindows

### `start()`

```swift
public func start()
```

function to start displaying the graph

### `stop()`

```swift
public func stop()
```

function to stop displaying the graph

### `sizeDidChange()`

```swift
func sizeDidChange()
```

### `rowsDidChange()`

```swift
override func rowsDidChange()
```

### `colsDidChange()`

```swift
override func colsDidChange()
```

### `rectangle(for:)`

```swift
func rectangle(for id: UUID) -> (x: Int, y: Int, width: Int, height: Int)
```

Gets the coordinates for the subwindow
- Parameter id: the id of the window to get coords for
- Returns: the offsets, width, and height

#### Parameters

| Name | Description |
| ---- | ----------- |
| id | the id of the window to get coords for |

### `boxWindow(id:_:)`

```swift
public func boxWindow(id: UUID, _ style: BoxType = .simple)
```

Draws a box around the screen
- Parameters:
   - id: the id of the subwindow to box
   - style: the box style (default `.simple`)

#### Parameters

| Name | Description |
| ---- | ----------- |
| id | the id of the subwindow to box |
| style | the box style (default `.simple`) |

### `requestBuffer(for:box:_:)`

```swift
public override func requestBuffer(for sub: TermWindow, box: TermWindow.BoxType = .simple, _ handler: (inout [[Character]]) -> Void)
```

#### Parameters

| Name | Description |
| ---- | ----------- |
| for | the window requesting a buffer |
| box | should we box the screen? |
| handler | the block that will fill the buffer |

### `requestStyledBuffer(for:box:_:)`

```swift
public override func requestStyledBuffer(for sub: TermWindow, box: TermWindow.BoxType = .simple, _ handler: (inout [[TermCharacter]]) -> Void)
```

#### Parameters

| Name | Description |
| ---- | ----------- |
| for | the window requesting a buffer |
| box | should we box the screen? |
| handler | the block that will fill the buffer |