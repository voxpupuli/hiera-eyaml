# New release instructions for developers

1. `export VERSION=N.N.N`
2. `sed -i -e "/VERSION =/s,[0-9.]+,${VERSION}," lib/hiera/backend/eyaml.rb`
3. `CHANGELOG_GITHUB_TOKEN=... bundle exec rake changelog`
4. `git add lib/hiera/backend/eyaml.rb CHANGELOG.md`
5. `git commit -s -S -m "Release ${VERSION}" lib/hiera/backend/eyaml.rb CHANGELOG.md`
6. `git tag -a -s -m "Release ${VERSION}" v${VERSION} HEAD`
