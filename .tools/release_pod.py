import subprocess
import argparse
import itertools
import re

def get_next_version(version):
    major, minor = version.rsplit('.', 1)
    new_minor = int(minor) + 1
    return "%s.%d" % (major, new_minor)


# os helpers
def run_command(cmd=None, parts=None, show_output=True):
    if show_output:
        if parts:
            print('runnning: "%s"' % " ".join(parts))
        else:
            print('running: "%s"' % cmd)

    if not parts:
        parts = cmd.split(' ')

    process = subprocess.Popen(parts, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    stdout, _ = process.communicate()

    ret = stdout.decode('ascii')
    if show_output and ret:
        print(ret)

    return ret

# git helpers

def get_latest_git_tag():
    response = run_command('git tag --sort=-creatordate', False)
    tags = response.rstrip('\n').split('\n')
    if len(tags) > 0:
        return tags[0]
    return 'v0.1.0'


def get_next_git_version():
    current_version = get_latest_git_tag()
    return get_next_version(current_version)

# pod file helpers

def find_podspec_files(containing=None):
    response = run_command('ls', False)
    files = response.rstrip('\n').split('\n')
    podspec_files = [f for f in files if '.podspec' in f]

    if containing:
        return [p for p in podspec_files if containing.lower() in p.lower()]

    return podspec_files

def get_current_pod_version(file):
    with open(file) as f:
        return re.findall("[.]version\s*?=\s*?['\"]([^'\"]+)['\"]", f.read())[0]


def get_current_pod_source_tag(file):
    # :tag => "v0.1.1"
    with open(file) as f:
        return re.findall(":tag\s*?=>\s*?['\"]([^'\"]+)['\"]", f.read())[0]


def change_pod_version(file, next_version=None):
    version = get_current_pod_version(file)
    if not next_version:
        next_version = get_next_version(version)

    with open(file) as f:
        content = f.read()

    with open(file, 'w') as f:
        f.write(content.replace(version, next_version))

    return version, next_version

def change_repo_tag(file, next_tag):
    curr_tag = get_current_pod_source_tag(file)
    
    with open(file) as f:
        content = f.read()

    with open(file, 'w') as f:
        f.write(content.replace(curr_tag, next_tag))


def parse_args():
    parser = argparse.ArgumentParser(description='Create Cocoapod Releases for the Ethos Project')
    parser.add_argument('--pods', nargs='+', default="all", help='Pod that should be updated, defaults to all')
    parser.add_argument('--version', help='Target verision')
    parser.add_argument('--message', help='Commit Message')

    args = parser.parse_args()
    target_pods = args.pods
    if target_pods == 'all': # default
        target_pods = find_podspec_files()
    else:
        target_pods = list(itertools.chain(*[find_podspec_files(p) for p in target_pods]))

    target_version = args.version
    if not target_version:
        target_version = get_next_git_version()

    release_message = args.message
    if not release_message:
        release_message = "new pod release version %s" % target_version

    return target_pods, target_version, release_message


current_version = get_latest_git_tag() 
pods, version, message = parse_args()

print(pods)
print('%-30s %s -> %s' % ('Ethos:', current_version, version))

for pod in pods:
    change_repo_tag(pod, version)
    pod_version, pod_next_version = change_pod_version(pod)
    print('%-30s %s -> %s' % (pod + ":", pod_version, pod_next_version))

# 415  git commit -m "testing a version change" .
#   416  git tag v0.1.1
#   417  git status
#   418  git push --tags
#   419  git status
#   420  git push
#   421  pod repo push EthosUtilSpec EthosUtil.podspec 

run_command('git add .')
run_command(parts=['git', 'commit', '-m', '"%s"' % message, '.'])
run_command('git tag %s' % version)
run_command('git push')
run_command('git push --tags')

for pod in pods:
    output = run_command('pod repo push --allow-warnings %sSpec %s' % (pod.split('.')[0], pod))


