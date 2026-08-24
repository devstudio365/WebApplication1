az acr login --name devstudio35
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

docker compose build
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

docker compose push
