"""Validate GitHub's signed OIDC claims without uploading or logging the JWT."""
import argparse
import json
import os
from pathlib import Path
from urllib.parse import urlencode
from urllib.request import Request, urlopen

REPOSITORY = 'grupo-jocaagura/jocaaguraarchetype'
ISSUER = 'https://token.actions.githubusercontent.com'
AUDIENCE = 'https://pub.dev'
ENVIRONMENT = 'pub.dev'


def validate_claims(claims, env, mode):
    expected = {
        'iss': ISSUER, 'aud': AUDIENCE, 'repository': REPOSITORY,
        'repository_id': '769937954', 'repository_owner_id': '193098028',
        'sub': f'repo:{REPOSITORY}:environment:{ENVIRONMENT}',
        'environment': ENVIRONMENT, 'sha': env['GITHUB_SHA'],
        'ref': env['GITHUB_REF'], 'ref_type': env['GITHUB_REF_TYPE'],
        'event_name': env['GITHUB_EVENT_NAME'], 'run_id': env['GITHUB_RUN_ID'],
        'runner_environment': 'github-hosted',
    }
    if env.get('GITHUB_REPOSITORY') != REPOSITORY:
        raise ValueError('OIDC must originate in the official repository')
    for name, value in expected.items():
        if claims.get(name) != value:
            raise ValueError(f'OIDC claim mismatch: {name}')
    workflow = 'publish.yaml' if mode == 'publish' else 'oidc_probe.yaml'
    if claims.get('workflow_ref') != f'{REPOSITORY}/.github/workflows/{workflow}@{env["GITHUB_REF"]}':
        raise ValueError('OIDC workflow identity mismatch')
    if mode == 'publish':
        if env['GITHUB_REF_TYPE'] != 'tag' or env['GITHUB_EVENT_NAME'] not in ('push', 'workflow_dispatch'):
            raise ValueError('Publication requires a tag push or tag dispatch')
        if str(claims.get('ref_protected')).lower() != 'true':
            raise ValueError('Publication requires a protected immutable release tag')
    elif env['GITHUB_EVENT_NAME'] not in ('pull_request', 'workflow_dispatch'):
        raise ValueError('Probe requires a PR or manual dispatch')
    # Keep only non-secret identity evidence, never the bearer token/signature.
    return {key: claims[key] for key in expected} | {
        'workflow_ref': claims['workflow_ref'], 'mode': mode,
        'result': 'signed_claims_verified', 'pub_dev_upload': 'not_executed',
    }


def signed_claims(token):
    import jwt
    key = jwt.PyJWKClient(ISSUER + '/.well-known/jwks').get_signing_key_from_jwt(token)
    return jwt.decode(token, key.key, algorithms=['RS256'], audience=AUDIENCE,
                      issuer=ISSUER, options={'require': ['exp', 'iat', 'iss', 'aud', 'sub']})


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--mode', choices=['probe', 'publish'], required=True)
    parser.add_argument('--output', type=Path, required=True)
    args = parser.parse_args()
    try:
        url = os.environ['ACTIONS_ID_TOKEN_REQUEST_URL'] + '&' + urlencode({'audience': AUDIENCE})
        request = Request(url, headers={'Authorization': 'Bearer ' + os.environ['ACTIONS_ID_TOKEN_REQUEST_TOKEN']})
        with urlopen(request, timeout=30) as response:
            token = json.load(response)['value']
        evidence = validate_claims(signed_claims(token), dict(os.environ), args.mode)
        args.output.write_text(json.dumps(evidence, indent=2) + '\n', encoding='utf-8')
        print('Signed GitHub OIDC identity verified for pub.dev; no upload performed by this check.')
    except Exception as error:
        # Do not include token-bearing exceptions, request headers or response bodies.
        parser.exit(1, f'OIDC validation failed closed ({type(error).__name__}).\n')


if __name__ == '__main__':
    main()
