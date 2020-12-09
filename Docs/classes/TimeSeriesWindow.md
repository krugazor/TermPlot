**CLASS**

# `TimeSeriesWindow`

```swift
public class TimeSeriesWindow : StandardSeriesWindow
```

Series variant based ton timer ticks

## Methods
### `init(tick:total:)`

```swift
public override init(tick: TimeInterval, total: TimeInterval)
```

Neutralized public initializer
- Parameters:
  - tick: useless
  - total: useless

#### Parameters

| Name | Description |
| ---- | ----------- |
| tick | useless |
| total | useless |

### `init(tick:total:source:)`

```swift
public init(tick: TimeInterval, total: TimeInterval, source: @escaping ()->Double)
```

Public initializer
- Parameters:
  - tick: width of an x-interval, time between ticks
  - total: range of the x-axis
  - source: the block to call every tick for new values

#### Parameters

| Name | Description |
| ---- | ----------- |
| tick | width of an x-interval, time between ticks |
| total | range of the x-axis |
| source | the block to call every tick for new values |

### `start()`

```swift
public override func start()
```

Starts the display and tick

### `stop()`

```swift
public override func stop()
```

Stops the tick
