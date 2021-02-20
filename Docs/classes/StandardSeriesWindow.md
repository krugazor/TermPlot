**CLASS**

# `StandardSeriesWindow`

```swift
public class StandardSeriesWindow : TermWindow
```

Standard series display: x number of y values

## Properties
### `totalTime`

```swift
var totalTime : TimeInterval
```

x-axis range size

### `timeTick`

```swift
var timeTick : TimeInterval
```

x-axis tick mark

### `timeCount`

```swift
var timeCount : Int
```

x-axis tick count

### `maxValue`

```swift
public var maxValue : Double?
```

ceiling of the graph, if necessary
will be computed if nil

### `seriesColor`

```swift
public var seriesColor : StandardSeriesColorScheme = .monochrome(.red)
```

Current series color scheme

### `seriesStyle`

```swift
public var seriesStyle : StandardSeriesStyle = .block
```

Current series style

### `boxStyle`

```swift
public var boxStyle : StandardSeriesBoxType = .simple
```

Current box style

### `values`

```swift
var values : [Double]
```

The actual y values

### `rowStyles`

```swift
var rowStyles : [(color: TermColor, styles:[TermStyle])]
```

Pre-computed color/style by row (needed for quartiles most of all)

## Methods
### `rowsDidChange()`

```swift
override func rowsDidChange()
```

Recompute row styles (needed for quartiles most of all) when the number of rows changes

### `computeRowStyles()`

```swift
func computeRowStyles()
```

Recompute row styles

### `init(tick:total:)`

```swift
public init(tick: TimeInterval, total: TimeInterval)
```

Public initializer
- Parameters:
  - tick: width of an x-interval
  - total: range of the x-axis

#### Parameters

| Name | Description |
| ---- | ----------- |
| tick | width of an x-interval |
| total | range of the x-axis |

### `addValue(_:)`

```swift
public func addValue(_ val: Double)
```

Adds a value to the end of the buffer
- Parameter val: the value

#### Parameters

| Name | Description |
| ---- | ----------- |
| val | the value |

### `addValues(_:)`

```swift
public func addValues(_ vals: [Double])
```

Adds values to the end of the buffer
- Parameter vals: the values

#### Parameters

| Name | Description |
| ---- | ----------- |
| vals | the values |

### `replaceValues(with:)`

```swift
public func replaceValues(with: [Double])
```

Replaces all the values in the buffer
- Parameter with: the new values

#### Parameters

| Name | Description |
| ---- | ----------- |
| with | the new values |

### `modifyValues(_:)`

```swift
public func modifyValues(_ apply: @escaping ([Double])->[Double])
```

Reserve-and-modify mechanism to replace the values in the buffer selectively
- Parameter apply: the block to call for new values

#### Parameters

| Name | Description |
| ---- | ----------- |
| apply | the block to call for new values |

### `start()`

```swift
public func start()
```

Overrided function to start displaying the graph

### `stop()`

```swift
public func stop()
```

Overrided function to stop displaying the graph

### `display()`

```swift
func display()
```

Display the buffer, based on current style and colors

### `getLineParameters(point1:point2:)`

```swift
static func getLineParameters(point1: (x: Double, y:Double), point2: (x: Double, y:Double)) -> (a: Double, b: Double, c: Double)
```

Used for interpolation, gets the function that defines the line between two points
- Parameters:
  - point1: first point
  - point2: second point
- Returns: `a*x+b*y+c=0` equation parameters (a,b, and c)

#### Parameters

| Name | Description |
| ---- | ----------- |
| point1 | first point |
| point2 | second point |

### `mapDomains(_:to:)`

```swift
static func mapDomains(_ points: [(x: Double, y:Double)], to: [Double]) -> [(x: Double, y:Double)]
```

Interpolation function
- Parameters:
  - points: the discreet points to start from
  - to: the discreet domain (x) to map onto
- Returns: the discreet mapped points

#### Parameters

| Name | Description |
| ---- | ----------- |
| points | the discreet points to start from |
| to | the discreet domain (x) to map onto |