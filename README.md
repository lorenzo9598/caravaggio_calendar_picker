# caravaggio_calendar_picker

Flutter calendar date picker with **single**, **multiple**, and **range** selection modes.

Used by [caravaggio_ui](https://github.com/lorenzo9598/caravaggio_ui) and publishable standalone on pub.dev.

## Install

```yaml
dependencies:
  caravaggio_calendar_picker: ^1.0.0
```

## Usage

```dart
import 'package:caravaggio_calendar_picker/caravaggio_calendar_picker.dart';

CDatePicker(
  mode: CustomDatePickerMode.range,
  firstDate: DateTime.now(),
  lastDate: DateTime.now().add(const Duration(days: 60)),
  onChanged: (dates) {
    final start = dates.first;
    final end = dates.last;
  },
)
```

## Modes

| Mode | Behavior |
|------|----------|
| `single` | One date |
| `multiple` | Toggle individual days |
| `range` | Start + end tap, inclusive range highlight |

## License

See the parent project license.
