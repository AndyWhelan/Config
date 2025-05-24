#!/usr/bin/env python3

import json
import os
import plistlib
import sys
import uuid

def color_dict_to_list(color_dict):
   if not color_dict:
      return None
   return [
      color_dict.get('Red Component', 0.0),
      color_dict.get('Green Component', 0.0),
      color_dict.get('Blue Component', 0.0),
      color_dict.get('Alpha Component', 1.0),
   ]

loaded_dynamic_path = os.path.expanduser('~/Library/Application Support/iTerm2/DynamicProfiles/myprofiles.json')
output_path = '../term/iterm2/DynamicProfiles/myprofiles.json'
plist_path = os.path.expanduser('~/Library/Preferences/com.googlecode.iterm2.plist')

if not os.path.exists(plist_path):
   print(f"Error: iTerm2 plist not found at {plist_path}", file=sys.stderr)
   sys.exit(1)

try:
   with open(plist_path, 'rb') as f:
      plist = plistlib.load(f)
except Exception as e:
   print(f"Failed to read plist: {e}", file=sys.stderr)
   sys.exit(1)

profiles = plist.get('New Bookmarks', [])

dynamic_profiles = []
def generate_unique_guid():
   existing_guids = set()
   for p in profiles:
      guid = p.get("Guid")
      if guid:
          existing_guids.add(guid.upper())
   new_guid = str(uuid.uuid4()).upper()
   while new_guid in existing_guids:
      new_guid = str(uuid.uuid4()).upper()
   return new_guid

for p in profiles:
   dp = {}
   dp['Name'] = p.get('Name', 'Unnamed Profile')
   dp["Guid"] = generate_unique_guid()

   #dp['Guid'] = p.get('Guid') or None

   # Font parsing
   font_str = p.get('Normal Font', '')
   if font_str:
      parts = font_str.rsplit(' ', 1)
      if len(parts) == 2:
         dp['FontName'] = parts[0]
         try:
            dp['FontSize'] = float(parts[1])
         except ValueError:
            dp['FontSize'] = 12
      else:
         dp['FontName'] = font_str
         dp['FontSize'] = 12

   # Colors (safe to export)
   for key in ['Background Color', 'Foreground Color', 'Cursor Color', 'Cursor Text Color', 'Selection Color', 'Tab Color']:
      if key in p:
         val = color_dict_to_list(p[key])
         if val is not None:
            dp[key.replace(' ', '')] = val

   # ANSI palette colors
   for i in range(16):
      key = f'Ansi {i} Color'
      if key in p:
         val = color_dict_to_list(p[key])
         if val is not None:
            dp[f'Ansi{i}Color'] = val

   # Font style booleans (safe)
   for key in ['Use Bold Font', 'Use Italic Font', 'Use Non-ASCII Font']:
      if key in p:
         dp[key.replace(' ', '')] = p[key]

   dynamic_profiles.append(dp)

output = {"Profiles": dynamic_profiles}

with open(loaded_dynamic_path, 'w') as f:
   json.dump(output, f, indent=2)
with open(output_path, 'w') as f:
   json.dump(output, f, indent=2)

print(f"Dynamic Profiles JSON saved to {output_path} and {loaded_dynamic_path}")
