import requests
import json
from requests.exceptions import RequestException, Timeout
import git

if __name__ == '__main__':

    repo = git.Repo("git@github.com:hamza333-tech/python_application.git")
    tree = repo.tree()