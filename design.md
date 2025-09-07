# Design Documentation - Farmlytics

## Typography

### Primary Font: Funnel Display
- **Usage**: Main headings, titles, body text, and primary UI elements
- **Weights Available**: 
  - Regular (400)
  - Bold (700)
- **License**: SIL Open Font License
- **Source**: Google Fonts
- **Characteristics**: Modern, clean, highly readable neo-grotesque typeface
- **Best For**: 
  - App titles and headings
  - Main content text
  - Navigation elements
  - Primary buttons and CTAs

### Secondary Font: Helvetica
- **Usage**: Labels, captions, secondary information, and fine details
- **Weights Available**: Regular, Bold (system dependent)
- **License**: System font (varies by platform)
- **Characteristics**: Classic, neutral, highly legible sans-serif
- **Best For**:
  - Form labels
  - Captions and metadata
  - Secondary navigation
  - Fine print and disclaimers

## Font Hierarchy

### Headlines (Funnel Display Bold)
- **Headline Large**: Main page titles, hero text
- **Headline Medium**: Section headers, card titles
- **Headline Small**: Subsection headers, widget titles

### Titles (Funnel Display)
- **Title Large**: Important labels, primary navigation
- **Title Medium**: Secondary labels, form field labels
- **Title Small**: Tertiary labels, minor headings

### Body Text (Funnel Display)
- **Body Large**: Main content paragraphs, descriptions
- **Body Medium**: Standard content text, list items
- **Body Small**: Secondary content, footnotes (Helvetica)

### Labels (Helvetica)
- **Label Large**: Primary form labels, important metadata
- **Label Medium**: Standard labels, secondary information
- **Label Small**: Fine print, disclaimers, timestamps

## Design Principles

### Typography Guidelines
1. **Consistency**: Use Funnel Display for all primary content to maintain brand consistency
2. **Hierarchy**: Clear visual hierarchy through font weights and sizes
3. **Readability**: Ensure sufficient contrast and appropriate sizing for mobile devices
4. **Accessibility**: Maintain minimum 16px font size for body text on mobile
5. **Platform Compatibility**: Helvetica as fallback ensures cross-platform consistency

### Color Scheme
- **Primary**: Green (Colors.green) - Represents nature, growth, and agriculture
- **Status Bar**: Dark content on light backgrounds for optimal visibility

### Spacing and Layout
- **Consistent Margins**: Use 8px grid system for spacing
- **Touch Targets**: Minimum 44px for interactive elements
- **Content Width**: Maximum 600px for optimal reading experience

## Implementation Notes

### Flutter Theme Configuration
```dart
ThemeData(
  fontFamily: 'FunnelDisplay',
  textTheme: TextTheme(
    // Headlines use Funnel Display Bold
    headlineLarge: TextStyle(fontFamily: 'FunnelDisplay', fontWeight: FontWeight.bold),
    // Body text uses Funnel Display Regular
    bodyLarge: TextStyle(fontFamily: 'FunnelDisplay'),
    // Labels use Helvetica for secondary information
    labelSmall: TextStyle(fontFamily: 'Helvetica'),
  ),
)
```

### Font Loading
- Funnel Display fonts are bundled with the app for consistent rendering
- Helvetica relies on system fonts for optimal performance
- Font files are located in `assets/fonts/`

## Brand Identity

### Visual Personality
- **Modern**: Clean, contemporary design with Funnel Display
- **Professional**: Reliable and trustworthy through consistent typography
- **Agricultural**: Green color scheme reflects farming and nature
- **Accessible**: Clear hierarchy and readable fonts for all users

### Target Audience
- Farmers and agricultural professionals
- Tech-savvy users who appreciate clean, modern interfaces
- Users who need clear, readable information in various lighting conditions

## Future Considerations

### Scalability
- Font system supports easy addition of new weights
- Color scheme can be extended with additional shades
- Typography hierarchy can accommodate new content types

### Accessibility
- Consider adding support for larger text sizes
- Ensure sufficient color contrast ratios
- Test with screen readers and accessibility tools

### Platform Optimization
- Monitor font rendering across different devices
- Consider platform-specific font optimizations
- Test on various screen sizes and resolutions

---

*Last Updated: September 2025*
*Version: 1.0*
