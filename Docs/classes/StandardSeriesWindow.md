**CLASS**

# `StandardSeriesWindow`

**Contents**

- [Properties](#properties)
  - `totalTime`
  - `timeTick`
  - `timeCount`
  - `maxValue`
  - `seriesColor`
  - `seriesStyle`
  - `boxStyle`
  - `values`
  - `rowStyles`
- [Methods](#methods)
  - `rowsDidChange()`
  - `computeRowStyles()`
  - `init(tick:total:)`
  - `addValue(_:)`
  - `addValues(_:)`
  - `replaceValues(with:)`
  - `modifyValues(_:)`
  - `start()`
  - `stop()`
  - `display()`
  - `getLineParameters(point1:point2:)`
  - `mapDomains(_:to:)`

```swift
public class StandardSeriesWindow : TermWindow
```

Standard series display: x number of y values

## Properties
<details><summary markdown="span"><code>totalTime</code></summary>

```swift
var totalTime : TimeInterval
```

x-axis range size

</details>

<details><summary markdown="span"><code>timeTick</code></summary>

```swift
var timeTick : TimeInterval
```

x-axis tick mark

</details>

<details><summary markdown="span"><code>timeCount</code></summary>

```swift
var timeCount : Int
```

x-axis tick count

</details>

<details><summary markdown="span"><code>maxValue</code></summary>

```swift
public var maxValue : Double?
```

ceiling of the graph, if necessary
will be computed if nil

</details>

<details><summary markdown="span"><code>seriesColor</code></summary>

```swift
public var seriesColor : StandardSeriesColorScheme = .monochrome(.red)
```

Current series color scheme

</details>

<details><summary markdown="span"><code>seriesStyle</code></summary>

```swift
public var seriesStyle : StandardSeriesStyle = .block
```

Current series style

</details>

<details><summary markdown="span"><code>boxStyle</code></summary>

```swift
public var boxStyle : TermBoxType = .simple
```

Current box style

</details>

<details><summary markdown="span"><code>values</code></summary>

```swift
var values : [Double]
```

The actual y values

</details>

<details><summary markdown="span"><code>rowStyles</code></summary>

```swift
var rowStyles : [(color: TermColor, styles:[TermStyle])]
```

Pre-computed color/style by row (needed for quartiles most of all)

</details>

## Methods
<details><summary markdown="span"><code>rowsDidChange()</code></summary>

```swift
override func rowsDidChange()
```

Recompute row styles (needed for quartiles most of all) when the number of rows changes

</details>

<details><summary markdown="span"><code>computeRowStyles()</code></summary>

```swift
func computeRowStyles()
```

Recompute row styles

</details>

<details><summary markdown="span"><code>init(tick:total:)</code></summary>

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

</details>

<details><summary markdown="span"><code>addValue(_:)</code></summary>

```swift
public func addValue(_ val: Double)
```

Adds a value to the end of the buffer
- Parameter val: the value

#### Parameters

| Name | Description |
| ---- | ----------- |
| val | the value |

</details>

<details><summary markdown="span"><code>addValues(_:)</code></summary>

```swift
public func addValues(_ vals: [Double])
```

Adds values to the end of the buffer
- Parameter vals: the values

#### Parameters

| Name | Description |
| ---- | ----------- |
| vals | the values |

</details>

<details><summary markdown="span"><code>replaceValues(with:)</code></summary>

```swift
public func replaceValues(with: [Double])
```

Replaces all the values in the buffer
- Parameter with: the new values

#### Parameters

| Name | Description |
| ---- | ----------- |
| with | the new values |

</details>

<details><summary markdown="span"><code>modifyValues(_:)</code></summary>

```swift
public func modifyValues(_ apply: @escaping ([Double])->[Double])
```

Reserve-and-modify mechanism to replace the values in the buffer selectively
- Parameter apply: the block to call for new values

#### Parameters

| Name | Description |
| ---- | ----------- |
| apply | the block to call for new values |

</details>

<details><summary markdown="span"><code>start()</code></summary>

```swift
public func start()
```

Overrided function to start displaying the graph

</details>

<details><summary markdown="span"><code>stop()</code></summary>

```swift
public func stop()
```

Overrided function to stop displaying the graph

</details>

<details><summary markdown="span"><code>display()</code></summary>

```swift
func display()
```

Display the buffer, based on current style and colors

</details>

<details><summary markdown="span"><code>getLineParameters(point1:point2:)</code></summary>

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

</details>

<details><summary markdown="span"><code>mapDomains(_:to:)</code></summary>

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

</details>