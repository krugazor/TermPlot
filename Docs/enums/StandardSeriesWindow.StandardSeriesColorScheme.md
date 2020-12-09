**ENUM**

# `StandardSeriesWindow.StandardSeriesColorScheme`

```swift
public enum StandardSeriesColorScheme
```

Color schemes
- monochrome
- quarters (1/4 of the screen is the same color)
- quartiles (1/4 of the *values* is the same color)

## Cases
### `monochrome(_:)`

```swift
case monochrome(TermColor)
```

### `quarters(_:_:_:_:)`

```swift
case quarters(TermColor,TermColor,TermColor,TermColor)
```

### `quartiles(_:_:_:_:)`

```swift
case quartiles(TermColor,TermColor,TermColor,TermColor)
```
