**CLASS**

# `LiveSeriesWindow`

```swift
public class LiveSeriesWindow : TimeSeriesWindow
```

Time series based on file handle rather than a source block

## Methods
### `init(tick:total:source:)`

```swift
public override init(tick: TimeInterval, total: TimeInterval, source: @escaping () -> Double)
```

Neutralized public initializer

### `init(tick:total:input:)`

```swift
public init(tick: TimeInterval, total: TimeInterval, input: FileHandle)
```

Public initializer
- Parameters:
  - tick: width of an x-interval (tick time)
  - total: range of the x-axis
  - input: file handle to read from

#### Parameters

| Name | Description |
| ---- | ----------- |
| tick | width of an x-interval (tick time) |
| total | range of the x-axis |
| input | file handle to read from |