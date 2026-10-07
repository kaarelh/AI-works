# run a script with a large recursion limit / stack:  python3 run.py script.py [args]
import sys, threading, runpy
sys.setrecursionlimit(1000000)
threading.stack_size(512 * 1024 * 1024)
script = sys.argv[1]
sys.argv = sys.argv[1:]
def go():
    runpy.run_path(script, run_name='__main__')
t = threading.Thread(target=go); t.start(); t.join()
