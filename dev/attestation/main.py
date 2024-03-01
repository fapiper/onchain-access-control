from argparse import ArgumentParser, Namespace
from zokrates import write_zokrates_input, createMerkleRoot

parser = ArgumentParser()

parser.add_argument('-i', '--input', type=int, nargs='+')
parser.add_argument('-m', '--merkle', action='store_true')

args: Namespace = parser.parse_args()

def cli(input):
    """
    Example usage: bazel run //book_sorting:main -- --input 0 4294967295 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 4294967295 0 0 0 0 0 0 0 0 0 0 0 0 0 4294967295
    """
    print(" ".join(write_zokrates_input(input)))


if __name__ == "__main__":
    cli()
# example
#
# python3 cli.py -i 0 4294967295 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 4294967295 0 0 0 0 0 0 0 0 0 0 0 0 0 4294967295
