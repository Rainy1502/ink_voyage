# InkVoyage Assets

This folder contains all image assets for the InkVoyage application, downloaded directly from the Figma design.

## Status
✅ **All assets successfully downloaded from Figma design**

## Available Assets

### Main Images (`/`)
- `app_logo.png` - Application logo (1024x1024)
- `book_cover_crime_and_punishment.png` - Sample book cover (1024x1024)
- `book_cover_crime_and_punishment_cropped.png` - Cropped version (1024x814)
- `book_cover_sample_1.png` - Sample book cover 1 (1118x1600)
- `book_cover_sample_2.png` - Sample book cover 2 (1024x1024)

### Icons (`icons/`)
#### Navigation Icons
- `icon_books_nav.svg` - Books tab icon (24x24)
- `icon_progress_nav.svg` - Progress tab icon (24x24)
- `icon_profile_nav.svg` - Profile tab icon (24x24)

#### Feature Icons
- `icon_book.svg` - Book icon (20x20)
- `icon_chart.svg` - Statistics/Chart icon (32x32)
- `icon_check.svg` - Complete/Check icon (32x32)
- `icon_pages.svg` - Pages icon (32x32)
- `icon_pages_read.svg` - Pages read icon (32x32)
- `icon_trophy.svg` - Achievement/Trophy icon (32x32)

#### User Profile Icons
- `icon_user.svg` - User/Profile icon (39x39)
- `icon_email.svg` - Email icon (39x39)
- `icon_calendar.svg` - Calendar/Date icon (39x39)

#### Action Icons
- `icon_search.svg` - Search icon (24x24)
- `icon_add.svg` - Add/Plus icon (16x16)
- `icon_logout.svg` - Logout icon (16x16)

## Usage in Code
```dart
// App Logo
Image.asset('assets/images/app_logo.png', width: 100, height: 100)

// Book Covers
Image.asset('assets/images/book_cover_sample_1.png')

// SVG Icons (using flutter_svg package)
SvgPicture.asset('assets/images/icons/icon_book.svg', width: 24, height: 24)
```

## Notes
- All PNG images are exported at 2x scale for high-DPI displays
- SVG icons maintain vector quality and can scale to any size
- Icons use original Figma design colors and can be themed in code
- For SVG support, ensure `flutter_svg` package is added to `pubspec.yaml`
