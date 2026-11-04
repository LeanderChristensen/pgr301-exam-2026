# PGR301 Eksamen 2026 - Besvarelse Kandidatnummer 4

## Oppgave 1A - Container

Bygg imaget fra repo-root:

```
docker build -t wishifai .
```

Start en container på localhost:9999 (Bytt `AWS_ACCESS_KEY_ID` og `AWS_SECRET_ACCESS_KEY` med egne verdier):

```
docker run --rm -p 9999:8080 -e AWS_ACCESS_KEY_ID -e AWS_SECRET_ACCESS_KEY wishifai
```

Test fra en annen terminal:

```
curl -F "image=@samples/sample_image.png" http://localhost:9999/api/analyze
```

Brukte github.sha som image_tag fordi det er en lett måte å gjøre taggen unik.
