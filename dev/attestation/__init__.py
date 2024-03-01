from argparse import ArgumentParser, Namespace
from zokrates import write_zokrates_input

parser = ArgumentParser()

parser.add_argument('-i', '--input', type=int, nargs='+')


def main():
    print(" ".join(write_zokrates_input([0, 4294967295, 0])))

# example
#
# python3 cli.py -i 0 4294967295 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 4294967295 0 0 0 0 0 0 0 0 0 0 0 0 0 4294967295
