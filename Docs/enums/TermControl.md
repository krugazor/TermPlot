**ENUM**

# `TermControl`

```swift
public enum TermControl : String
```

ANSI control sequences

## Cases
### `CR`

```swift
case CR = "\r"
```

### `NEWLINE`

```swift
case NEWLINE = "\n"
```

### `UP`

```swift
case UP = "\u{001B}[A"
```

### `DOWN`

```swift
case DOWN = "\u{001B}[B"
```

### `FORWARD`

```swift
case FORWARD = "\u{001B}[C"
```

### `BACK`

```swift
case BACK = "\u{001B}[D"
```

### `CLEARSCR`

```swift
case CLEARSCR = "\u{001B}[2J"
```

### `CLEARFROMCSR`

```swift
case CLEARFROMCSR = "\u{001B}[0J"
```

### `CLEARLINE`

```swift
case CLEARLINE = "\u{001B}[2K"
```
