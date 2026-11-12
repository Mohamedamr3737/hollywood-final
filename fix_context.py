import re

log_content = """
   info - lib/app/home/view/Appointments/appointment_details_page.dart:84:13 -
          use_build_context_synchronously
   info - lib/app/home/view/Appointments/appointment_details_page.dart:85:22 -
          use_build_context_synchronously
   info - lib/app/home/view/Appointments/appointment_details_page.dart:90:28 -
          use_build_context_synchronously
   info - lib/app/home/view/Appointments/appointment_details_page.dart:93:26 -
          use_build_context_synchronously
   info - lib/app/home/view/Appointments/appointments_preview_page.dart:143:44 -
          use_build_context_synchronously
   info - lib/app/home/view/MyRequests/add_comment_page_request.dart:83:20 -
          use_build_context_synchronously
   info - lib/app/home/view/MyRequests/add_ticket_page_request.dart:88:20 -
          use_build_context_synchronously
   info - lib/app/home/view/MyRequests/ticket_details_page_request.dart:73:20 -
          use_build_context_synchronously
   info - lib/app/home/view/Notifications/notifications_page.dart:46:26 -
          use_build_context_synchronously
   info - lib/app/home/view/Notifications/notifications_page.dart:58:41 -
          use_build_context_synchronously
   info - lib/app/home/view/Notifications/notifications_page.dart:61:11 -
          use_build_context_synchronously
   info - lib/app/home/view/Prescription/medication_detail_page.dart:40:28 -
          use_build_context_synchronously
   info - lib/app/home/view/Prescription/medication_detail_page.dart:40:68 -
          use_build_context_synchronously
   info - lib/app/home/view/Prescription/my_meals_page.dart:75:11 -
          use_build_context_synchronously
   info - lib/app/home/view/Prescription/my_meals_page.dart:75:57 -
          use_build_context_synchronously
   info - lib/app/home/view/Profile/profile_page.dart:39:40 -
          use_build_context_synchronously
   info - lib/app/home/view/Profile/profile_page.dart:92:30 -
          use_build_context_synchronously
   info - lib/app/home/view/Profile/profile_page.dart:95:28 -
          use_build_context_synchronously
   info - lib/app/home/view/Profile/profile_page.dart:166:26 -
          use_build_context_synchronously
   info - lib/app/home/view/Profile/profile_page.dart:244:33 -
          use_build_context_synchronously
   info - lib/app/home/view/Profile/profile_page.dart:470:66 -
          use_build_context_synchronously
   info - lib/app/home/view/Profile/profile_page.dart:472:48 -
          use_build_context_synchronously
   info - lib/app/home/view/Sessions/session_detail_page.dart:145:45 -
          use_build_context_synchronously
   info - lib/app/home/view/Sessions/session_detail_page.dart:152:45 -
          use_build_context_synchronously
   info - lib/app/home/view/Shop/cart_page.dart:549:26 -
          use_build_context_synchronously
   info - lib/app/home/view/Shop/cart_page.dart:551:28 -
          use_build_context_synchronously
   info - lib/app/home/view/Shop/shop_view.dart:798:11 -
          use_build_context_synchronously
"""

import collections

issues = collections.defaultdict(list)
for line in log_content.split('\n'):
    m = re.search(r'info - (lib/[^:]+):(\d+):', line)
    if m:
        issues[m.group(1)].append(int(m.group(2)))

for file_path, lines in issues.items():
    with open(file_path, 'r', encoding='utf-8') as f:
        content_lines = f.readlines()
    
    lines = sorted(list(set(lines)), reverse=True)
    
    for l in lines:
        line_idx = l - 1
        original_line = content_lines[line_idx]
        indent = len(original_line) - len(original_line.lstrip())
        # Insert check
        content_lines.insert(line_idx, " " * indent + "if (!context.mounted) return;\n")

    with open(file_path, 'w', encoding='utf-8') as f:
        f.writelines(content_lines)
    print(f"Fixed {file_path}")

print("Done context fixes.")
