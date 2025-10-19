#!/usr/bin/env python3
"""
HIG Advisor - Offline SwiftUI Human Interface Guidelines advisor
Reads local markdown guides and provides recommendations.
"""

import sys
import os
import argparse
import glob
from pathlib import Path


def load_guides(guides_dir):
    """Load all .md files from the guides directory."""
    guides = {}
    pattern = os.path.join(guides_dir, "*.md")
    
    for filepath in glob.glob(pattern):
        filename = os.path.basename(filepath)
        guide_name = filename.replace(".md", "")
        
        try:
            with open(filepath, 'r', encoding='utf-8') as f:
                guides[guide_name] = f.read()
        except Exception as e:
            print(f"Warning: Could not load {filepath}: {e}", file=sys.stderr)
    
    return guides


def analyze_content(content, guides):
    """Analyze content and provide HIG recommendations."""
    content_lower = content.lower()
    recommendations = []
    
    # Check for specific keywords and provide relevant advice
    keywords_map = {
        'navigation': ['navigation', 'navigationlink', 'navigationstack', 'tabview'],
        'actions': ['button', 'action', 'tap', 'gesture', 'onclick']
    }
    
    matched_guides = set()
    
    for guide_name, keywords in keywords_map.items():
        if any(keyword in content_lower for keyword in keywords):
            matched_guides.add(guide_name)
    
    # If no specific matches, provide a general pack
    if not matched_guides:
        matched_guides = {'navigation', 'actions'}
        recommendations.append("🔍 No specific keywords detected. Providing general HIG recommendations:")
    
    # Extract recommendations from matched guides
    for guide_name in matched_guides:
        if guide_name in guides:
            guide_content = guides[guide_name]
            recommendations.append(f"\n📘 From {guide_name}.md:")
            
            # Extract key points (lines starting with -, *, or numbered lists)
            lines = guide_content.split('\n')
            points = []
            for line in lines:
                stripped = line.strip()
                if stripped.startswith(('-', '*', '•')) or (len(stripped) > 2 and stripped[0].isdigit() and stripped[1] in '.):'):
                    points.append(stripped)
            
            # Limit to 3 points per guide
            for point in points[:3]:
                recommendations.append(f"  {point}")
    
    return recommendations


def main():
    parser = argparse.ArgumentParser(description='HIG Advisor for SwiftUI')
    parser.add_argument('--root', default='Guides/HIG', help='Root directory for HIG guides')
    parser.add_argument('--file', help='File to analyze (optional, uses stdin if not provided)')
    
    args = parser.parse_args()
    
    # Load guides
    guides_dir = args.root
    if not os.path.isabs(guides_dir):
        # Make relative to workspace root (parent of tools/)
        script_dir = os.path.dirname(os.path.abspath(__file__))
        workspace_root = os.path.dirname(os.path.dirname(script_dir))
        guides_dir = os.path.join(workspace_root, guides_dir)
    
    if not os.path.exists(guides_dir):
        print(f"❌ Error: Guides directory not found: {guides_dir}", file=sys.stderr)
        sys.exit(1)
    
    guides = load_guides(guides_dir)
    
    if not guides:
        print(f"⚠️  Warning: No guides found in {guides_dir}", file=sys.stderr)
        sys.exit(1)
    
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
    
    # Analyze and provide recommendations
    print("🎨 HIG Advisor Analysis")
    print("=" * 50)
    
    recommendations = analyze_content(content, guides)
    
    if recommendations:
        for rec in recommendations[:5]:  # Limit to 5 recommendations
            print(rec)
    else:
        print("✅ No specific recommendations. Code looks good!")
    
    print("\n" + "=" * 50)
    print(f"📚 Loaded guides: {', '.join(guides.keys())}")


if __name__ == "__main__":
    main()

