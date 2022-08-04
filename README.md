## Setup

1. Go to the `remote_state directory` in project.
```bash
cd infra/remote_state; terraform init; terraform apply
```


2. Go to the `infra directory` in project.
```bash
cd infra; terraform init; terraform apply
```
This will output
* URL to access the web server.
* ECR repo url where docker images should be pushed.

## Development
1. Make desired code changes to `src` directory.
2. Run docker build
```bash
cd src; docker build -t <docker_ecr_repo_url>:<version> . 
```
For Apple M1 run below command to build image
```bash
cd src; docker buildx build -t <docker_ecr_repo_url>:<version> . --platform linux/amd64 
```
3. Docker login into the ECR repo
```bash
aws ecr get-login-password --region <region> | docker login --username AWS --password-stdin <ecr_repo_url>
```
4. Publish docker image 
```bash
docker push <docker_ecr_repo_url>:<version>
```
5. Apply the `infra` terraform project with the version provided in above step
```bash
cd infra; terraform apply -var="release_version=<release_version>"
```
