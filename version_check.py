import pkg_resources as pkg
from distutils.version import LooseVersion as version
import requests as req
import os
import subprocess

def check_installed_vs_pypi(package):
    dist = pkg.get_distribution(package)
    installed_version = dist.version
    try:
        latest_version = req.get(f'https://pypi.org/pypi/{package}/json').json()['info']['version']
        if version(installed_version) < version(latest_version):
            print(f'{package} {installed_version} is out of date. Consider rebuilding your container to update to version {latest_version}.')
        else:
            print(f'{package} {installed_version} is up to date.')
    except req.exceptions.RequestException:
        print(f'{package} {installed_version} may not be up to date; PufferTank failed to connect to the pip registry to check.')
        
def check_dev_version(package):
    dist = pkg.get_distribution(package)
    os.chdir(dist.location)
    print(f'{package} {dist.version} (development)')
    result = subprocess.run('git status | head -n 2', shell=True, capture_output=True, text=True)
    print(result.stdout)

if __name__ == "__main__":
    dist = pkg.get_distribution('pufferlib')
    if '/puffertank/' in dist.location:
        check_dev_version('pufferlib')
    else:
        check_installed_vs_pypi('pufferlib')