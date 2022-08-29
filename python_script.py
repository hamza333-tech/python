import requests
import json
from requests.exceptions import RequestException, Timeout
import git


class AuthErr(Exception):
    pass

class AuthToken:
    PATH = '/security/authenticate'

    def __init__(self, url):
        self.url = url

    def get_token(self, username, password):
        payload = {'username': username, 'password': password}
        try:
            url = self.url + AuthToken.PATH
            resp = requests.post(url, data=payload)
            if resp.status_code != 200:
                raise AuthErr('Likely: wrong username / password.')
            tokenjson = json.loads(resp.text)
            return tokenjson["token"]
        except RequestException as ex:
            raise ex

def application_creation(url, payload, auth_token):
    headers = {
        'Content-Type': "application/json",
        'Authorization': "Bearer " + auth_token
    }

    response = requests.request("POST", url, json= payload, headers=headers)
    print(response.text)

def application_edit (url, payload, auth_token):
    headers = {
    'Content-Type': "text/plain",
    'Authorization': "Bearer " + auth_token
    }
    response = requests.request("POST", url, data = payload, headers=headers)
    print(response.text)
    
if __name__ == '__main__':
    repo = git.Repo("./")
    diff = repo.git.diff('HEAD~1..HEAD', name_only=True)
    print(diff)
    authToken = AuthToken('http://35.194.76.168:9080')
    auth_token = authToken.get_token('admin', 'Yn7Ccgrx2_4XDijc')
    
    f = open(diff)
    file_data = f.read()
    application_edit("http://35.194.76.168:9080/api/v2/tungsten", f"{file_data}", auth_token) 