# Gitlab

```json
{
  "insecure-registries" : ["registry.local:5050"]
}
```

## administration

If the root account name hasn’t changed, use the username root

### change password from shell

sudo gitlab-rake "gitlab:password:reset"

## How to use (private) gitlab container registry

also see [gitlab container registry administration](https://docs.gitlab.com/ee/administration/packages/container_registry.html)

```bash
# login with your gitlab credentials
docker login gitlab.local:5050
# pull container image from docker hub
docker pull nginx:latest
# tag image
docker tag nginx:latest gitlab.local:5050/root/test/nginx:latest
# create a project test in some namespace gitlab to push into
# push to gitlab
docker push gitlab.local:5050/root/test/nginx:latest
```
