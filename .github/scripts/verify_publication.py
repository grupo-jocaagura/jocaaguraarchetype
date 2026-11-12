"""Read back the exact hosted release. Never uploads or retries an upload."""
import argparse
from pathlib import Path
import time

from publication_policy import PACKAGE, REPOSITORY_URL, metadata, read_json


def verify_response(response, version):
    if not isinstance(response, dict) or response.get('version') != version:
        raise ValueError('pub.dev version does not match the prepared source')
    spec = response.get('pubspec', {})
    if spec.get('name') != PACKAGE or spec.get('version') != version or spec.get('repository') != REPOSITORY_URL:
        raise ValueError('Published identity/provenance differs from the prepared package')
    if spec.get('dependencies', {}).get('jocaagura_domain') != '^2.0.0':
        raise ValueError('Published core constraint differs from the certified release')


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('tag')
    args = parser.parse_args()
    version = metadata(Path('pubspec.yaml').read_text(encoding='utf-8'))
    if args.tag != f'v{version}':
        parser.exit(1, 'Publication evidence requires the exact release tag.\n')
    for attempt in range(6):
        response = read_json(f'https://pub.dev/api/packages/{PACKAGE}/versions/{version}', missing_ok=True)
        if response is not None:
            verify_response(response, version)
            print(f'Verified hosted publication: {PACKAGE} {version}')
            return
        if attempt < 5:
            time.sleep(5)
    parser.exit(1, 'Publication not visible; inspect the upload before any retry.\n')


if __name__ == '__main__':
    main()
