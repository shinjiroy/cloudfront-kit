#!/bin/bash

set -e

# 引数の数をチェック
if [ $# -ne 1 ]; then
    echo "引数が必要です。staging または production を指定してください。"
    exit 1
fi

ENVIRONMENT_ARG=$1
# 引数が staging または production であるかをチェック
if [ "$ENVIRONMENT_ARG" != "staging" ] && [ "$ENVIRONMENT_ARG" != "production" ]; then
    echo "引数は development または production のいずれかを指定してください。"
    exit 1
fi

# productionに限り、mainブランチでのみのデプロイを許可する
if [ "$ENVIRONMENT_ARG" = "production" ]; then
    CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD)
    if [ "$CURRENT_BRANCH" != "main" ]; then
        echo "productionをデプロイするならmainブランチでデプロイしてください。現在のブランチ:$CURRENT_BRANCH"
        exit 1
    fi
fi

# functionsのコードをminifyして環境毎のディレクトリに配置
docker-compose run --rm minifier -r -o $ENVIRONMENT_ARG/cloudfront/minified/functions/ edge_function/functions/

# Lambda@edgeのコードをビルドして環境毎のディレクトリに配置
for DIR in ./edge_function/lambda_edge/*/; do
    (cd $DIR && ./build.sh)
    # 気になる場合は毎回消す
    # rm -rf $ENVIRONMENT_ARG/cloudfront/lambda_src/*
    cp -r -- $DIR/*/ $ENVIRONMENT_ARG/cloudfront/lambda_src/
done

docker-compose run --rm terraform bash -c "cd ./$ENVIRONMENT_ARG && terragrunt run-all plan"

docker-compose run --rm terraform bash -c "cd ./$ENVIRONMENT_ARG && terragrunt run-all apply"
