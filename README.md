# Push Executors to Hubble

Push the executor to Hubble with the tags `$git_tag` and `latest`

One need to specify the input `git_tag` and set the following secrets in the repo

- `SECRET`: secret of the executor

Example `cd.yml`:

```yaml
...
      - name: push to Hubble
        id: push_exec_action
        uses: jina-ai/action-hubble-push@v4
        env:
          git_tag: ${{ steps.previous_tag_action.outputs.tag }}    
```

If you want to release the GPU version, make sure you have `Dockerfile.gpu` in your root folder
