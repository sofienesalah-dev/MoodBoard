#!/usr/bin/env python3
"""
A11y Check - Heuristic accessibility checker for SwiftUI views
Scans SwiftUI code for common accessibility issues.
"""

import sys
import re
import argparse


def check_accessibility(content):
    """Run heuristic accessibility checks on SwiftUI code."""
    issues = []
    warnings = []
    
    # Check 1: Images without accessibility labels
    image_pattern = r'Image\s*\('
    images = re.findall(image_pattern, content)
    
    if images:
        # Check if .accessibilityLabel or .accessibility(label:) is present
        has_image_labels = bool(re.search(r'\.accessibilityLabel\s*\(', content) or 
                                re.search(r'\.accessibility\s*\(\s*label:', content))
        
        if not has_image_labels:
            issues.append(
                "🚨 Images detected without .accessibilityLabel()\n"
                "   → Add descriptive labels for screen readers"
            )
    
    # Check 2: Buttons without accessibility context
    button_pattern = r'Button\s*\('
    buttons = re.findall(button_pattern, content)
    
    if buttons:
        has_accessibility = 'accessibility' in content.lower()
        if not has_accessibility:
            warnings.append(
                "⚠️  Buttons detected without accessibility modifiers\n"
                "   → Consider adding .accessibilityLabel() or .accessibilityHint()"
            )
    
    # Check 3: No Text elements (potential silence for screen readers)
    has_text = bool(re.search(r'\bText\s*\(', content))
    has_label = bool(re.search(r'\bLabel\s*\(', content))
    
    if not has_text and not has_label and len(content) > 100:
        issues.append(
            "🚨 No Text() elements found in view\n"
            "   → Screen readers may have no content to announce"
        )
    
    # Check 4: Custom tap gestures without accessibility actions
    has_gesture = bool(re.search(r'\.onTapGesture|\.gesture\(', content))
    has_accessibility_action = bool(re.search(r'\.accessibilityAction\(', content))
    
    if has_gesture and not has_accessibility_action:
        warnings.append(
            "⚠️  Custom gestures detected without .accessibilityAction()\n"
            "   → Make gestures accessible via VoiceOver"
        )
    
    # Check 5: Low contrast or color-only information
    color_only_indicators = ['color:', 'foregroundColor', 'background(Color']
    if any(indicator in content for indicator in color_only_indicators):
        has_shapes_or_icons = bool(re.search(r'\b(Image|SF|Symbol|Circle|Rectangle|shape)\b', content))
        if not has_shapes_or_icons:
            warnings.append(
                "⚠️  Color usage detected\n"
                "   → Ensure information is not conveyed by color alone"
            )
    
    return issues, warnings


def main():
    parser = argparse.ArgumentParser(description='A11y Checker for SwiftUI')
    parser.add_argument('--file', help='SwiftUI file to analyze (optional, uses stdin if not provided)')
    
    args = parser.parse_args()
    
    # Read content to analyze
    if args.file:
        try:
            with open(args.file, 'r', encoding='utf-8') as f:
                content = f.read()
        except Exception as e:
            print(f"❌ Error reading file {args.file}: {e}", file=sys.stderr)
            sys.exit(1)
    else:
        content = sys.stdin.read()
    
    # Run accessibility checks
    print("♿ A11y Quick Scan")
    print("=" * 50)
    
    issues, warnings = check_accessibility(content)
    
    if not issues and not warnings:
        print("✅ No obvious accessibility issues detected!")
        print("\n💡 Manual checks still recommended:")
        print("   • Test with VoiceOver")
        print("   • Verify Dynamic Type support")
        print("   • Check color contrast ratios")
    else:
        if issues:
            print("\n🔴 ISSUES (high priority):")
            for issue in issues:
                print(f"\n{issue}")
        
        if warnings:
            print("\n🟡 WARNINGS (should review):")
            for warning in warnings:
                print(f"\n{warning}")
        
        print("\n" + "=" * 50)
        print("📖 Learn more: https://developer.apple.com/accessibility/")


if __name__ == "__main__":
    main()

