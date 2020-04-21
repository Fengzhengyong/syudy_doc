import sys, pyperclip

PASSWD={'root':'kingdee',
        'kduser':'kingdee2',
        'other':'kingdee3'}

if len(sys.argv) < 2:
    print('Usage: python pw.py [account] - copy account password')
    sys.exit()

account=sys.argv[1]

if account in PASSWD:
    pyperclip.copy(PASSWD[account])
    print('Password for ' + account + 'copied to clipboard')
else:
    print('There is no account named ' + account)
