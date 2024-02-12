alias dbp := dockerbuildandpush

dockerbuild: sqlxprepare test
    docker build -t daicanglong/hsr-dictionary-backend:latest . --platform linux/arm64

dockerpush:
    docker push daicanglong/hsr-dictionary-backend:latest

dockerbuildandpush: dockerbuild dockerpush

test:
    cargo test --workspace

format:
    cargo clippy --fix --allow-dirty

lint:
    cargo clippy --workspace

sqlxprepare:
    cargo sqlx prepare --workspace