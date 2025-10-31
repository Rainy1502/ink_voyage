# Dark Mode Color Reference - Quick Guide
**InkVoyage App - Figma Design Node: 50:18875**

## 🎨 Quick Color Reference

### Copy-Paste Ready Colors

#### Backgrounds
```dart
const backgroundDark = Color(0xFF1A1625);      // Main background
const surfaceDark = Color(0xFF231832);         // Cards, surfaces
const veryDark = Color(0xFF1A0F2E);           // Bottom nav, buttons
```

#### Primary Colors
```dart
const cyan = Color(0xFF00D9FF);               // Primary accent
const purple = Color(0xFF7B3FF2);             // Secondary (Sedang Dibaca)
const lightPurple = Color(0xFFB967FF);        // Tertiary (Selesai)
```

#### Borders (with opacity)
```dart
const cyanBorder20 = Color(0x3300D9FF);       // 20% opacity
const cyanBorder30 = Color(0x4D00D9FF);       // 30% opacity
const cyanBorder40 = Color(0x6600D9FF);       // 40% opacity

const purpleBorder20 = Color(0x33B967FF);     // Light purple 20%
const purpleBorder30 = Color(0x4DB967FF);     // Light purple 30%
```

#### Text Colors
```dart
const textPrimary = Colors.white;             // Main text
const textCyan60 = Color(0x9900D9FF);         // Cyan 60% - labels
const textPurple70 = Color(0xB3B967FF);       // Light purple 70%
```

#### Icon Backgrounds
```dart
const iconBgCyan10 = Color(0x1A00D9FF);       // Cyan 10%
const iconBgPurple10 = Color(0x1AB967FF);     // Light purple 10%
```

#### Shadows
```dart
BoxShadow(
  color: Color(0x9900D9FF),                   // Cyan 60%
  blurRadius: 16,
  offset: Offset(0, 2),
)

BoxShadow(
  color: Color(0x6600D9FF),                   // Cyan 40%
  blurRadius: 8,
  offset: Offset(0, 1),
)
```

#### Special Colors
```dart
const errorRed = Color(0xFFE7000B);           // Light mode error
const errorRedDark = Color(0xFFFB2C36);       // Dark mode error
const logoutRedDark = Color(0xFFFF6467);      // Dark mode logout
const grayUnselected = Color(0xFF99A1AF);     // Bottom nav gray
const logoutGray30 = Color(0x4D262626);       // Logout button bg
```

#### Gradients
```dart
// Cyan gradient for avatar
LinearGradient(
  begin: Alignment.topCenter,
  end: Alignment.bottomCenter,
  colors: [Color(0xFF00D9FF), Color(0xFF00B8D4)],
)

// Purple gradient for light mode header
LinearGradient(
  begin: Alignment.topCenter,
  end: Alignment.bottomCenter,
  colors: [Color(0xFFAD46FF), Color(0xFF9810FA), Color(0xFF8200DB)],
)
```

## 📋 Component Color Mapping

### Profile Screen Dark Mode

| Component | Background | Border | Text | Icon |
|-----------|------------|--------|------|------|
| **Header** | `#1A1625` (solid) | Cyan 20% | Cyan | - |
| **Avatar** | Cyan gradient | Cyan | Dark `#0D0711` | - |
| **Dark Mode Card** | `#231832` | Cyan 20% | Cyan/White | Cyan |
| **Total Buku Card** | `#231832` | Cyan 20% | Cyan | Cyan |
| **Sedang Dibaca Card** | `#231832` | Purple 20% | Purple | Purple |
| **Selesai Card** | `#231832` | Light Purple 20% | Light Purple | Light Purple |
| **Halaman Dibaca Card** | `#231832` | Cyan 20% | Cyan | Cyan |
| **Account Info Card** | `#231832` | Cyan 20% | Cyan/White | Cyan |
| **Achievement Card** | `#231832` | Light Purple 20% | Light Purple/White | - |
| **Logout Button** | Gray 30% | Red | Light Red | Light Red |

## 🔍 Alpha Opacity Values

| Opacity % | Hex Value | Usage |
|-----------|-----------|-------|
| 10% | `0x1A` | Icon backgrounds |
| 20% | `0x33` | Card borders |
| 30% | `0x4D` | Icon borders, achievement box |
| 40% | `0x66` | Button borders, shadows |
| 60% | `0x99` | Label text, shadows |
| 70% | `0xB3` | Achievement text |

## 💡 Usage Examples

### Card with Cyan Border
```dart
Container(
  decoration: BoxDecoration(
    color: const Color(0xFF231832),
    border: Border.all(
      color: const Color(0x3300D9FF),
      width: 1.162,
    ),
    borderRadius: BorderRadius.circular(14),
  ),
)
```

### Icon Container
```dart
Container(
  decoration: BoxDecoration(
    color: const Color(0x1A00D9FF),      // 10% bg
    border: Border.all(
      color: const Color(0x4D00D9FF),    // 30% border
      width: 1.162,
    ),
    borderRadius: BorderRadius.circular(10),
  ),
  child: Icon(
    icon,
    color: const Color(0xFF00D9FF),      // Full opacity
  ),
)
```

### Text with Opacity
```dart
Text(
  'Label',
  style: TextStyle(
    color: const Color(0x9900D9FF),      // Cyan 60%
    fontSize: 14,
  ),
)
```

### Theme Detection
```dart
final isDark = Theme.of(context).brightness == Brightness.dark;

// Use in widget
color: isDark ? const Color(0xFF00D9FF) : Colors.white
```

---

**Quick Tip**: Use `const` for color definitions to optimize performance!

**Reference**: See `DARK_MODE_BACKUP_README.md` for complete documentation.
