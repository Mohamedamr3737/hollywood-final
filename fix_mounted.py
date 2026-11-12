import os

files = [
    "lib/app/home/view/Appointments/appointment_details_page.dart",
    "lib/app/home/view/MyRequests/add_comment_page_request.dart",
    "lib/app/home/view/MyRequests/add_ticket_page_request.dart",
    "lib/app/home/view/MyRequests/ticket_details_page_request.dart",
    "lib/app/home/view/Notifications/notifications_page.dart",
    "lib/app/home/view/Prescription/medication_detail_page.dart",
    "lib/app/home/view/Profile/profile_page.dart",
    "lib/app/home/view/Shop/cart_page.dart",
]

for file_path in files:
    if os.path.exists(file_path):
        with open(file_path, 'r', encoding='utf-8') as f:
            content = f.read()
        
        new_content = content.replace("if (!context.mounted) return;", "if (!mounted) return;")
        
        if new_content != content:
            with open(file_path, 'w', encoding='utf-8') as f:
                f.write(new_content)
            print(f"Fixed {file_path}")

print("Done fixing mounted checks.")
