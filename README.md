# Push Executors to Hubble

Push the executor to Hubble with the tags `$git_tag` and `latest`

One need to specify the input `git_tag` and set the following secrets in the repo

- `jinahub_token`: token of your Jina AI Cloud account

You need to pass this to the action like so:

```yml
      - name: push to Hubble
        uses: jina-ai/action-hubble-push@v12
        env: 
          jinahub_token: ${{ secrets.jinahub_token }}
```

If you want to release the GPU version, make sure you have `Dockerfile.gpu` in your root folder

Note that the old `exec_secret` is deprecated and removed from this action.