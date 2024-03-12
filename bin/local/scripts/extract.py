import argparse
from shlex import join
import warnings
from subprocess import run
from os.path import splitext
from os import remove as rm_file

def extract(path: str, one_top_level: bool, allow_remote: bool, keep: bool = False):
    m = lambda ext: path.endswith(ext)

    extracted_name = splitext(path)[0]

    _tar_args = []
    _bunzip2_args = []
    _zip_args = []
    if one_top_level:
        _tar_args.append('--one-top-level')
        _zip_args.extend(['-d', extracted_name])
    if not allow_remote:
        _tar_args.append('--force-local')
    if keep:
        _bunzip2_args.append('--keep')


    if m('.tar.bz2'):
        return ('tar', '-xjf', path, *_tar_args)
    elif m('.tar.gz'):
        return ('tar', '-xzf', path, *_tar_args)
    elif m('.bz2'):
        return ('bunzip2', path, *_bunzip2_args)
    elif m('.gz'):
        return ('gunzip', path)
    elif m('.tar'):
        return ('tar', '-xf', path, *_tar_args)
    elif m('.tbz2'):
        return ('tar', '-xjf', path, *_tar_args)
    elif m('.tgz'):
        return ('tar', '-xzf', path, *_tar_args)
    elif m('.zip'):
        return ('unzip', path)
    elif m('.rar'):
        return ('unrar', 'x', path)
    elif m('.Z'):
        return ('uncompress', path)
    elif m('.7z'):
        return ('7z', 'x', path)
    elif m('.snz'):
        return ('snunzip', path)
    else:
        raise ValueError('Unsupported file type')


if __name__ == '__main__':
    parser = argparse.ArgumentParser(prog='extract', description='Extract supported archive types')
    parser.add_argument('filename', nargs='+')
    parser.add_argument('-d', '--one-top-level', action='store_true', help='Extract to a new directory')
    parser.add_argument('-p', '--preview', action='store_true', help='Print the command that would be executed then exit')
    parser.add_argument('-R', '--remote', action='store_true', help='Prevent default behaviour of force local for filenames that look like remote files')
    args = parser.parse_args()
    for f in args.filename:
        cmd = join(extract(f, one_top_level=args.one_top_level, allow_remote=args.remote))
        print(cmd)
        if not args.preview:
            completed_process = run(cmd, shell=True)
            if completed_process.returncode != 0:
                print(f'Process exited with non-success return code {completed_process.returncode}')

