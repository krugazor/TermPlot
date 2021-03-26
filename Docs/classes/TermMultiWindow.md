**CLASS**

# `TermMultiWindow`

**Contents**

- [Properties](#properties)
  - `subwindows`
  - `stackType`
  - `ratios`
  - `offsets`
  - `rectangleCache`
- [Methods](#methods)
  - `offsetsFromRatios(length:ratios:)`
  - `init(stack:ratios:_:)`
  - `init(stack:ratios:_:)`
  - `setup(stack:ratios:_:)`
  - `start()`
  - `stop()`
  - `sizeDidChange()`
  - `rowsDidChange()`
  - `colsDidChange()`
  - `rectangle(for:)`
  - `boxWindow(id:_:)`
  - `requestBuffer(for:box:_:)`
  - `requestStyledBuffer(for:box:_:)`

```swift
public class TermMultiWindow : TermWindow
```

Class that allows sub window compositions in stacks, either horizontal or vertical

## Properties
<details><summary markdown="span"><code>subwindows</code></summary>

```swift
let subwindows : [TermWindow]
```

</details>

<details><summary markdown="span"><code>stackType</code></summary>

```swift
let stackType: StackType
```

subwindows for this window

</details>

<details><summary markdown="span"><code>ratios</code></summary>

```swift
let ratios : [Float]
```

split type

</details>

<details><summary markdown="span"><code>offsets</code></summary>

```swift
var offsets : [Int]
```

original ratios asked by the caller

</details>

<details><summary markdown="span"><code>rectangleCache</code></summary>

```swift
var rectangleCache : [UUID:(x: Int, y: Int, width: Int, height: Int)] = [:]
```

rectangle cache to avoid computing it every time
invalidated on screen size change

</details>

## Methods
<details><summary markdown="span"><code>offsetsFromRatios(length:ratios:)</code></summary>

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

</details>

<details><summary markdown="span"><code>init(stack:ratios:_:)</code></summary>

```swift
convenience init(stack: StackType, ratios lrat: [Float], _ subs: TermWindow...) throws
```

Convenience initializer to switch from variadic parameters to arrays
- See init for details on the parameters

</details>

<details><summary markdown="span"><code>init(stack:ratios:_:)</code></summary>

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

</details>

<details><summary markdown="span"><code>setup(stack:ratios:_:)</code></summary>

```swift
public static func setup(stack: StackType, ratios lrat: [Float], _ subs: TermWindow...) throws -> TermMultiWindow
```

Publicly exposed initializer
  - stack: vertical or horizontal
  - ratios: the ratios to apply
  - subs: the terminal windows that will compose this stack
- Throws: if there is a mismatch in windows and ratios, of if a ratio is 0, or any other configuration error
- Returns: a fully initialized stack of subwindows

</details>

<details><summary markdown="span"><code>start()</code></summary>

```swift
public func start()
```

function to start displaying the graph

</details>

<details><summary markdown="span"><code>stop()</code></summary>

```swift
public func stop()
```

function to stop displaying the graph

</details>

<details><summary markdown="span"><code>sizeDidChange()</code></summary>

```swift
func sizeDidChange()
```

</details>

<details><summary markdown="span"><code>rowsDidChange()</code></summary>

```swift
override func rowsDidChange()
```

</details>

<details><summary markdown="span"><code>colsDidChange()</code></summary>

```swift
override func colsDidChange()
```

</details>

<details><summary markdown="span"><code>rectangle(for:)</code></summary>

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

</details>

<details><summary markdown="span"><code>boxWindow(id:_:)</code></summary>

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

</details>

<details><summary markdown="span"><code>requestBuffer(for:box:_:)</code></summary>

```swift
public override func requestBuffer(for sub: TermWindow, box: TermWindow.BoxType = .simple, _ handler: (inout [[Character]]) -> Void)
```

#### Parameters

| Name | Description |
| ---- | ----------- |
| for | the window requesting a buffer |
| box | should we box the screen? |
| handler | the block that will fill the buffer |

</details>

<details><summary markdown="span"><code>requestStyledBuffer(for:box:_:)</code></summary>

```swift
public override func requestStyledBuffer(for sub: TermWindow, box: TermWindow.BoxType = .simple, _ handler: (inout [[TermCharacter]]) -> Void)
```

#### Parameters

| Name | Description |
| ---- | ----------- |
| for | the window requesting a buffer |
| box | should we box the screen? |
| handler | the block that will fill the buffer |

</details>