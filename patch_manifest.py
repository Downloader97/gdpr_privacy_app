p = 'android/app/src/main/AndroidManifest.xml'
s = open(p, encoding='utf-8').read()
items = (
    '<intent><action android:name="android.intent.action.SENDTO"/>'
    '<data android:scheme="mailto"/></intent>\n'
    '        <intent><action android:name="android.intent.action.VIEW"/>'
    '<data android:scheme="https"/></intent>\n'
)
if 'android:scheme="mailto"' in s:
    print('queries gia presenti')
elif '</queries>' in s:
    s = s.replace('</queries>', '    ' + items + '    </queries>', 1)
else:
    s = s.replace('<application', '<queries>\n        ' + items + '    </queries>\n    <application', 1)
open(p, 'w', encoding='utf-8').write(s)
print('manifest aggiornato')
