import os
import re

def to_snake_case(name):
    s1 = re.sub('(.)([A-Z][a-z]+)', r'\1_\2', name)
    return re.sub('([a-z0-9])([A-Z])', r'\1_\2', s1).lower()

lib_dir = 'lib'

# 1. Collect all dart files
all_dart_files = []
for root, dirs, files in os.walk(lib_dir):
    for f in files:
        if f.endswith('.dart'):
            all_dart_files.append(os.path.join(root, f))

# 2. Identify renames
renames = {}
for path in all_dart_files:
    dir_name = os.path.dirname(path)
    base_name = os.path.basename(path)
    if base_name != to_snake_case(base_name):
        new_base = to_snake_case(base_name)
        new_path = os.path.join(dir_name, new_base)
        renames[path] = new_path

# 3. Apply renames
for old_path, new_path in renames.items():
    os.rename(old_path, new_path)
    print(f"Renamed: {old_path} -> {new_path}")

# 4. Update imports
# Since imports can be relative or absolute (package:hollywoodapp/...), 
# we need to replace the old filename with the new filename in all files.
# For simplicity, we can just replace old_base with new_base if it appears in an import string.

# We will read all files, and for each line, if it contains import and the old filename, replace it.
# To be safe, we just replace `old_base` with `new_base` if they are in the same directory.
for path in all_dart_files:
    # use the new path if it was renamed
    current_path = renames.get(path, path)
    with open(current_path, 'r', encoding='utf-8') as f:
        content = f.read()
    
    new_content = content
    for old_p, new_p in renames.items():
        old_base = os.path.basename(old_p)
        new_base = os.path.basename(new_p)
        
        # We look for the old_base in the content. Usually it's like '.../old_base' or 'old_base'
        # We can just replace the string. But we must be careful not to replace parts of other strings.
        # It's usually within quotes.
        new_content = new_content.replace(f"/{old_base}'", f"/{new_base}'")
        new_content = new_content.replace(f"/{old_base}\"", f"/{new_base}\"")
        new_content = new_content.replace(f"'{old_base}'", f"'{new_base}'")
        new_content = new_content.replace(f"\"{old_base}\"", f"\"{new_base}\"")

    if content != new_content:
        with open(current_path, 'w', encoding='utf-8') as f:
            f.write(new_content)

print("Done renaming and updating imports.")
