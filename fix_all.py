import re
import collections
import os

log_content = """
   info - lib/app/auth/reset_password/new_password_page.dart:56:38 -
   info - lib/app/auth/reset_password/new_password_page.dart:70:36 -
   info - lib/app/auth/reset_password/new_password_page.dart:73:26 -
   info - lib/app/auth/reset_password/reset_password.dart:33:29 -
   info - lib/app/auth/reset_password/reset_password.dart:39:15 -
   info - lib/app/auth/reset_password/reset_password.dart:43:13 -
   info - lib/app/auth/reset_password/reset_password.dart:46:26 -
   info - lib/app/home/controller/appointments_controller.dart:184:20 -
   info - lib/app/home/controller/appointments_controller.dart:190:26 -
   info - lib/app/home/controller/profile_controller.dart:88:32 -
   info - lib/app/home/controller/profile_controller.dart:96:30 -
   info - lib/app/home/controller/profile_controller.dart:131:32 -
   info - lib/app/home/controller/profile_controller.dart:139:30 -
   info - lib/app/home/controller/profile_controller.dart:144:26 -
   info - lib/app/home/controller/profile_controller.dart:155:28 -
   info - lib/app/home/controller/profile_controller.dart:176:30 -
   info - lib/app/home/controller/profile_controller.dart:180:28 -
   info - lib/app/home/controller/profile_controller.dart:183:26 -
   info - lib/app/home/controller/profile_controller.dart:194:13 -
   info - lib/app/home/controller/profile_controller.dart:216:30 -
   info - lib/app/home/controller/profile_controller.dart:222:28 -
   info - lib/app/home/controller/profile_controller.dart:225:26 -
"""

issues = collections.defaultdict(list)
for line in log_content.split('\n'):
    m = re.search(r'info - (lib/[^:]+):(\d+):', line)
    if m:
        issues[m.group(1)].append(int(m.group(2)))

for file_path, lines in issues.items():
    if not os.path.exists(file_path):
        continue
    with open(file_path, 'r', encoding='utf-8') as f:
        content_lines = f.readlines()
    
    lines = sorted(list(set(lines)), reverse=True)
    
    for l in lines:
        line_idx = l - 1
        original_line = content_lines[line_idx]
        indent = len(original_line) - len(original_line.lstrip())
        content_lines.insert(line_idx, " " * indent + "if (!context.mounted) return;\n")

    with open(file_path, 'w', encoding='utf-8') as f:
        f.writelines(content_lines)
    print(f"Fixed {file_path}")

print("Done context fixes.")
