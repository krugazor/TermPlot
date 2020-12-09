**CLASS**

# `StandardSeriesWindow`

```swift
public class StandardSeriesWindow : TermWindow
```

Standard series display: x number of y values

## Properties
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

## Methods
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
