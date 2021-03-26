**CLASS**

# `LiveSeriesWindow`

**Contents**

- [Methods](#methods)
  - `init(tick:total:source:)`
  - `init(tick:total:input:)`

```swift
public class LiveSeriesWindow : TimeSeriesWindow
```

Time series based on file handle rather than a source block

## Methods
<details><summary markdown="span"><code>init(tick:total:source:)</code></summary>

```swift
public override init(tick: TimeInterval, total: TimeInterval, source: @escaping () -> Double)
```

Neutralized public initializer

</details>

<details><summary markdown="span"><code>init(tick:total:input:)</code></summary>

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

</details>