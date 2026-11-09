# PGR301 Eksamen 2026 - Besvarelse Kandidatnummer 4

## Oppgave 1

Bygg imaget fra repo-root:

```
docker build -t wishifai .
```

Kopier `.env.example` til `.env`, og fyll inn egne verdier for `AWS_ACCESS_KEY_ID` og `AWS_SECRET_ACCESS_KEY`:

```
cp .env.example .env
```

Start en container på localhost:9999:

```
docker run --rm -p 9999:8080 --env-file .env -e S3_BUCKET=wishifai-4-images wishifai
```

Test fra en annen terminal:

```
curl -F "image=@samples/sample_image.png" http://localhost:9999/api/analyze
```

Brukte github.sha som image_tag fordi det er en lett måte å gjøre taggen unik.

Grønn kjøring: https://github.com/LeanderChristensen/pgr301-exam-2026/actions/runs/41878986512

## Oppgave 2

Public service URL: https://wi-15835376c25847ba8ee36012093e0c1d.ecs.eu-west-1.on.aws

Terraform-state lagres i den delte S3-bucketen `pgr301-terraform-state` med nøkkelen `wishifai/4/terraform.tfstate`.

Kandidatnummeret i nøkkelen gjør at state-filen ikke kolliderer med andre kandidater.

Terraform må kjøre etter container-build fordi den deployer image-taggen som bygges i forrige jobb. Med `needs:` deployes heller ingenting hvis bygget feiler, så tjenesten fortsetter å kjøre den forrige fungerende versjonen.

Grønn kjøring: https://github.com/LeanderChristensen/pgr301-exam-2026/actions/runs/42223855036