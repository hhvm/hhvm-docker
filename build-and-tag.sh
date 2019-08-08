#!/bin/bash
#
# Copyright (c) 2017-present, Facebook, Inc.
# All rights reserved.
#
# This source code is licensed under the MIT license found in the
# LICENSE file in the root directory of this source tree.

set -ex

VERSION="${1:-"$(date +%Y.%m.%d)"}"
cd "$(dirname "$0")"

if [ $(uname -s) == "Darwin" ]; then
  GREP=egrep
else
  GREP="grep -P"
fi

if echo "$VERSION" | $GREP -q '^\d{4}\.\d{2}\.\d{2}$'; then
  HHVM_PACKAGE="hhvm-nightly=${VERSION}-*"
  HHVM_REPO_DISTRO=bionic
else
  HHVM_PACKAGE="hhvm=${VERSION}-*"
  MAJ_MIN=$(echo "$VERSION" | cut -f1,2 -d.)
  HHVM_REPO_DISTRO="bionic-${MAJ_MIN}"
  (git checkout "${MAJ_MIN}-lts" || git checkout "$MAJ_MIN" || true) 2>/dev/null
fi

docker build \
  --build-arg "HHVM_PACKAGE=$HHVM_PACKAGE" \
  --build-arg "HHVM_REPO_DISTRO=$HHVM_REPO_DISTRO" \
  -t "hhvm/hhvm:$VERSION" \
  hhvm-latest/

docker build \
  --build-arg "HHVM_BASE_IMAGE=hhvm/hhvm:$VERSION" \
  -t "hhvm/hhvm-proxygen:$VERSION" \
  hhvm-latest-proxygen/

docker push hhvm/hhvm:$VERSION
docker push hhvm/hhvm-proxygen:$VERSION

for TAG in $(<EXTRA_TAGS); do
  docker tag "hhvm/hhvm:$VERSION" "hhvm/hhvm:$TAG"
  docker tag "hhvm/hhvm-proxygen:$VERSION" "hhvm/hhvm-proxygen:$TAG"
  docker push "hhvm/hhvm:$TAG"
  docker push "hhvm/hhvm-proxygen:$TAG"
done
