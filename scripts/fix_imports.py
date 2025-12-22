#!/usr/bin/env python3
"""Fix duplicate imports and const issues in Dart files"""

import os
import re

FILES = [
    "lib/ui/setting/settings_screen.dart",
    "lib/ui/history/history_screen.dart",
    "lib/ui/home/home_screen.dart",
    "lib/ui/setting/page/language_settings_page.dart",
    "lib/ui/setting/page/theme_settings_page.dart",
    "lib/ui/setting/page/profile_settings_page.dart",
    "lib/ui/setting/page/about_page.dart",
    "lib/ui/setting/page/bluetooth_settings_page.dart",
    "lib/ui/setting/page/watch_management_page.dart",
    "lib/ui/setting/page/contact_support_page.dart",
    "lib/ui/setting/page/chart_preferences_page.dart",
    "lib/ui/home/widget/firmware_selection_dialog.dart",
    "lib/ui/home/widget/firmware_update_dialog.dart",
    "lib/ui/home/widget/watch_button_card.dart",
    "lib/ui/onboarding/onboarding_screen.dart",
]

def fix_file(filepath):
    """Fix a single file by removing duplicate imports and const issues"""
    if not os.path.exists(filepath):
        print(f"  ⚠️ File not found: {filepath}")
        return

    with open(filepath, 'r', encoding='utf-8') as f:
        lines = f.readlines()

    # Remove duplicate l10n imports
    seen_l10n = False
    new_lines = []
    l10n_import = "import 'package:flutter_bloc_app_template/generated/l10n.dart';\n"

    for line in lines:
        if "generated/l10n.dart" in line:
            if not seen_l10n:
                seen_l10n = True
                new_lines.append(l10n_import)
        else:
            new_lines.append(line)

    # Fix const issues - remove const keyword before Text(S.of(context)...)
    content = ''.join(new_lines)
    content = re.sub(r'const Text\(S\.of\(context\)', 'Text(S.of(context)', content)

    with open(filepath, 'w', encoding='utf-8') as f:
        f.write(content)

    print(f"  ✅ Fixed {os.path.basename(filepath)}")

def main():
    print("🔧 Fixing duplicate imports and const issues...")
    for filepath in FILES:
        fix_file(filepath)
    print("\n✅ All files fixed!")

if __name__ == "__main__":
    main()
