import sys, re

def strip_comments(text):
    """State machine: blank out comment bodies, keep newlines and code."""
    out = []
    i, n = 0, len(text)
    state = 'code'   # code | line | block | str | chr
    while i < n:
        c = text[i]
        nxt = text[i+1] if i+1 < n else ''
        if state == 'code':
            if c == '/' and nxt == '/':
                state = 'line'; out.append('  '); i += 2; continue
            if c == '/' and nxt == '*':
                state = 'block'; out.append('  '); i += 2; continue
            if c == '"':
                state = 'str'; out.append(c); i += 1; continue
            if c == "'":
                state = 'chr'; out.append(c); i += 1; continue
            out.append(c); i += 1
        elif state == 'line':
            if c == '\n':
                state = 'code'; out.append('\n')
            i += 1
        elif state == 'block':
            if c == '*' and nxt == '/':
                state = 'code'; out.append('  '); i += 2; continue
            if c == '\n':
                out.append('\n')
            i += 1
        elif state == 'str':
            if c == '\\' and i+1 < n:
                out.append(c); out.append(text[i+1]); i += 2; continue
            if c == '"':
                state = 'code'
            out.append(c); i += 1
        elif state == 'chr':
            if c == '\\' and i+1 < n:
                out.append(c); out.append(text[i+1]); i += 2; continue
            if c == "'":
                state = 'code'
            out.append(c); i += 1
    return ''.join(out)

def norm_lines(code):
    res = []
    for ln in code.split('\n'):
        s = ln.strip()
        if s == '':
            continue
        res.append(s)
    return res

def main():
    enc_map = {0:'ascii'}
    pathA, pathB = sys.argv[1], sys.argv[2]
    a = open(pathA,'rb').read()
    b = open(pathB,'rb').read()
    A = strip_comments(a.decode('utf-8', 'replace'))
    B = strip_comments(b.decode('gbk', 'replace'))
    la, lb = norm_lines(A), norm_lines(B)
    print('A lines(code,non-empty) =', len(la), ' B lines =', len(lb))
    import difflib
    diff = list(difflib.unified_diff(lb, la, fromfile='BACKUP-17:45', tofile='CURRENT', lineterm='', n=2))
    print('\n'.join(diff) if diff else '(code identical)')

main()
