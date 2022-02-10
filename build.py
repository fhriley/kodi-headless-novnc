#!/usr/bin/env python3
import argparse
import subprocess
import shlex

BASE_IMAGE = 'ubuntu:22.04'
EASY_NOVNC_BRANCH = 'v1.3.0'
IMAGE_NAME = 'fhriley/kodi-headless-novnc'
PLATFORMS = ['linux/amd64', 'linux/arm64', 'linux/arm/v7']
CACHE = f'type=registry,ref={IMAGE_NAME}:'
BUILDX = 'docker buildx build {build_args} --platform {platforms} {tags} --cache-from {cache} --cache-to type=inline,mode=max {push} --pull .'

if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=f'Build {IMAGE_NAME}')
    parser.add_argument('-x', '--execute', action='store_true',
                        help='execute the build after printing the command')
    parser.add_argument('--push', action='store_true',
                        help='push the image')
    parser.add_argument('-b', '--base', default=BASE_IMAGE,
                        help=f'the base image (default: "{BASE_IMAGE}" )')
    parser.add_argument('-e', '--easy-novnc', default=EASY_NOVNC_BRANCH,
                        help=f'the easy-novnc branch (default: "{EASY_NOVNC_BRANCH}" )')
    parser.add_argument('-c', '--cache',
                        help='the tag to cache from (default: first tag argument)')
    parser.add_argument('-p', '--platform', nargs='+', default=PLATFORMS,
                        help=f'the platform to build for (default: {PLATFORMS})')
    parser.add_argument('branch', help='the branch/tag to build')
    parser.add_argument('tag', nargs='+', help='a tag to add to the image')
    args = parser.parse_args()

    build_args = [
        f'BASE_IMAGE={args.base}',
        f'KODI_BRANCH={args.branch}',
        f'EASY_NOVNC_BRANCH={args.easy_novnc}',
    ]

    buildx = BUILDX.format(
        build_args=' '.join([f'--build-arg {arg}' for arg in build_args]),
        platforms=','.join(args.platform),
        tags=' '.join([f'--tag {IMAGE_NAME}:{tag}' for tag in args.tag]),
        cache=CACHE + (args.cache or args.tag[0]),
        push='--push' if args.push else ''
    )

    print(buildx)

    if args.execute:
        subprocess.run(shlex.split(buildx), check=True)
