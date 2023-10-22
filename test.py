import subprocess

sin = [
    'one',
    'two',
    'tree',
    'suiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiii',
    ''
        ]

sout = [
    'one explanation',
    'two explanation',
    '',
    '',
    ''
        ]

serr = [
    '',
    '',
    '<ERROR>: Key not found !',
    '<ERROR>: Too many characters for key!',
    '<ERROR>: Key not found !'
        ]

passed_tests = 0

for i in range(len(sin)):
    test_data = [sin[i], sout[i], serr[i]]

    pr = subprocess.Popen(['./main'], stdin = subprocess.PIPE, stdout = subprocess.PIPE, stderr = subprocess.PIPE, text=True)
    stdout, stderr = pr.communicate(input=test_data[0])
    stdout, stderr = stdout.strip(), stderr.strip()

    print(f'Test {i + 1}:')

    if stdout == test_data[1] and stderr == test_data[2]:
        print('Test passed: ')
        print(f'\tSTDIN:  {test_data[0]}')
        print(f'\tSTDOUT: {test_data[1]}')
        print(f'\tSTDERR: {test_data[2]}')
        passed_tests += 1
    else:
        if stdout != test_data[1]:
            print(f'Incorrect DATA output "{stdout}" != "{test_data[1]}" for "{test_data[0]}"\n')
        if stderr != test_data[2]:
            print(f'Incorrect ERROR output "{stderr}" != "{test_data[2]}" for "{test_data[0]}"\n')

print('\nRESULTS')
print(f'\tPASSED: {passed_tests} | {len(sin)}')
print(f'\tFAILED: {len(sin) - passed_tests} | {len(sin)}')

