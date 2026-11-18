# TP0 — pipeline complet : build -> démarrage -> contrôles -> chargement HDFS -> job MapReduce -> résultat
# Usage (PowerShell) : .\tps\tp00-environnement-hadoop\scripts\run.ps1
# Si l'exécution de scripts est bloquée : Set-ExecutionPolicy -Scope Process Bypass
$ErrorActionPreference = "Stop"

$TpDir = Resolve-Path (Join-Path $PSScriptRoot "..")
$Root  = Resolve-Path (Join-Path $TpDir "..\..")
$env:COMPOSE_FILE = Join-Path $Root "cluster\compose.yaml"   # cluster partagé par tous les TP

$StreamingJar = "/opt/hadoop/share/hadoop/tools/lib/hadoop-streaming-3.4.1.jar"
$Output = "/data/sales_output_python"

function Step($msg) { Write-Host "`n==> $msg" -ForegroundColor Cyan }
function Run { & $args[0] $args[1..($args.Count-1)]; if ($LASTEXITCODE -ne 0) { throw "Échec : $args" } }

Step "Construction de l'image hadoop-python:3.4.1"
Run docker build -t hadoop-python:3.4.1 (Join-Path $Root "cluster")

Step "Validation et démarrage du cluster"
Run docker compose config -q
Run docker compose up -d
Run docker compose ps

Step "Attente de la sortie du safe mode HDFS"
for ($i = 0; $i -lt 30; $i++) {
    docker compose exec -T namenode hdfs dfsadmin -safemode wait *> $null
    if ($LASTEXITCODE -eq 0) { break }
    Start-Sleep -Seconds 5
}

Step "Contrôles"
docker compose exec -T namenode hdfs dfsadmin -report | Select-String "Live datanodes"
Run docker compose exec -T resourcemanager yarn node -list
Run docker compose exec -T nodemanager python3 --version
Run docker compose exec -T namenode hadoop getconf -confKey mapreduce.framework.name

Step "Chargement de sales.csv dans HDFS"
Run docker compose cp (Join-Path $TpDir "data\sales.csv") namenode:/tmp/sales.csv
Run docker compose exec -T namenode hdfs dfs -mkdir -p /data
Run docker compose exec -T namenode hdfs dfs -put -f /tmp/sales.csv /data/sales.csv

Step "Lancement du job Hadoop Streaming"
Run docker compose cp (Join-Path $TpDir "src\mapper.py")  namenode:/tmp/mapper.py
Run docker compose cp (Join-Path $TpDir "src\reducer.py") namenode:/tmp/reducer.py
Run docker compose exec -T namenode hdfs dfs -rm -r -f $Output
Run docker compose exec -T namenode hadoop jar $StreamingJar `
    -D mapreduce.framework.name=yarn `
    -files /tmp/mapper.py,/tmp/reducer.py `
    -input /data/sales.csv `
    -output $Output `
    -mapper "python3 mapper.py" `
    -reducer "python3 reducer.py"

Step "Résultat"
Run docker compose exec -T namenode bash -c "hdfs dfs -cat '$Output/part-*'"

Write-Host "`nInterfaces : HDFS http://localhost:9870  |  YARN http://localhost:8088"
