# Push Executors to Hubble

Push the executor to Hubble with the tags `$git_tag` and `latest`

One need to specify the input `git_tag` and set the following secrets in the repo

- `SECRET`: secret of the executor

You need to pass this to the action like so:

```yml
      - name: push to Hubble
        uses: jina-ai/action-hubble-push@v3
        env:
          exec_secret: ${{ secrets.SECRET }}
```

If you want to release the GPU version, make sure you have `Dockerfile.gpu` in your root folder