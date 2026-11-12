import os
import re

lib_dir = 'lib'

for root, dirs, files in os.walk(lib_dir):
    for f in files:
        if f.endswith('.dart'):
            path = os.path.join(root, f)
            with open(path, 'r', encoding='utf-8') as file:
                content = file.read()
            
            new_content = content.replace('.withOpacity(', '.withValues(alpha: ')
            
            # Also remove print statements to fix avoid_print
            # A simple regex for print(...)
            new_content = re.sub(r'print\([^)]*\);', '', new_content)
            
            if new_content != content:
                with open(path, 'w', encoding='utf-8') as file:
                    file.write(new_content)
                print(f"Fixed {path}")

print("Done fixing withOpacity and prints.")
