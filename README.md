# Push Executors to Hubble

Push the executor to Hubble with the tags `$git_tag` and `latest`

One need to specify the input `git_tag` and set the following secrets in the repo

- `NAME`: name of the executor
- `SECRECT`: secret of the executor

If you want to release the GPU version, make sure you have `Dockerfile.gpu` in your root folder