**CLASS**

# `TimeSeriesWindow`

**Contents**

- [Properties](#properties)
  - `sourceTimer`
  - `sourceBlock`
- [Methods](#methods)
  - `init(tick:total:)`
  - `init(tick:total:source:)`
  - `start()`
  - `stop()`

```swift
public class TimeSeriesWindow : StandardSeriesWindow
```

Series variant based ton timer ticks

## Properties
<details><summary markdown="span"><code>sourceTimer</code></summary>

```swift
var sourceTimer : Timer?
```

the timer that will repeatedly call the input block

</details>

<details><summary markdown="span"><code>sourceBlock</code></summary>

```swift
var sourceBlock : ()->Double
```

the block in charge of getting new values

</details>

## Methods
<details><summary markdown="span"><code>init(tick:total:)</code></summary>

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

</details>

<details><summary markdown="span"><code>init(tick:total:source:)</code></summary>

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

</details>

<details><summary markdown="span"><code>start()</code></summary>

```swift
public override func start()
```

Starts the display and tick

</details>

<details><summary markdown="span"><code>stop()</code></summary>

```swift
public override func stop()
```

Stops the tick

</details>