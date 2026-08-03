#!/bin/sh
# SPDX-FileCopyrightText: Copyright (c) 2026 NVIDIA CORPORATION & AFFILIATES. All rights reserved.
# SPDX-License-Identifier: Apache-2.0
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     https://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

set -eu

script_dir=$(CDPATH= cd -- "$(dirname "$0")" && pwd)
chart_dir=$(CDPATH= cd -- "$script_dir/.." && pwd)

assert_line() {
  printf '%s\n' "$rendered" | grep -Fqx "$1" || {
    echo "expected rendered config to contain: $1" >&2
    return 1
  }
}

rendered=$(helm template reval "$chart_dir" \
  --set reval.serviceConfig.auth.jwt.enabled=true \
  --set-string reval.serviceConfig.auth.jwt.jwkSetUrl=https://identity.example.test/jwks \
  --set-string reval.serviceConfig.auth.jwt.validateRequiredScopes=helmreval:validate \
  --set-string reval.serviceConfig.auth.jwt.renderRequiredScopes=helmreval:render)

assert_line "      jwt:"
assert_line "        enabled: true"
assert_line '        jwk-set-url: "https://identity.example.test/jwks"'
assert_line '        validate-required-scopes: "helmreval:validate"'
assert_line '        render-required-scopes: "helmreval:render"'

echo "helm-reval auth render checks passed"
