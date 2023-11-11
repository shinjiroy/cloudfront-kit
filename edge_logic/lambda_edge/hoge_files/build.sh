#!/bin/bash

set -e

for SCRIPT_DIR in ./*; do
    if [ -d "$SCRIPT_DIR" ]; then
        echo "$SCRIPT_DIR をビルド中"

        # ディレクトリ毎にインストールとかをする
    fi
done
