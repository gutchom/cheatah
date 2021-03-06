#!/usr/bin/env bash

set -e
set -x
set -ex
set -u
set -o pipefail

# more bash-friendly output for jq
JQ="jq --raw-output --exit-status"

#SUMMARY: This is the intended name of the new image tag.
newImageName="date-$(date +%F)_build-${CIRCLE_BUILD_NUM}_branch-${CIRCLE_BRANCH}"

#SUMMARY: This is the name of the temp image that has already been built within the dependencies of the circle.yml file:
# EXAMPLE: circle.yml snippet
#...
#  override:
#    - docker info
#    - docker build -t some-image-name .
#...
builtImageName="cheatah-slack"

#SUMMARY: This is the host where your repository lives. For ECR, it's typically of the form: {UniqueId}.dkr.ecr.{location}.amazonaws.com
repositoryHost="787647415306.dkr.ecr.ap-northeast-1.amazonaws.com/cheatah/cheatah-slack"

#SUMMARY: This is the name of the repository you wish to push to.
repositoryName="cheatah/cheatah-slack"

#SUMMARY: This is the intended full path of the new image.
tagPath="$repositoryHost/$repositoryName:$newImageName"

#SUMMARY: The region your ECR registry is in.
ecrRegion="ap-northeast-1"

#SUMMARY: The base name of the task you want running the image.
#NOTE: This does not include the revision number that is typically added on.
taskName="cheatah-slack"

#SUMMARY: memory for the task (Not 100% about the specifics for this)
taskMemory=200

#SUMMARY: cpu for the task (Not 100% about the specifics for this)
taskCpu=10

#SUMMARY: This is the port relative to the container. I.e., within your code, this is what port your service is registered on.
containerPort=8124

#SUMMARY: The port on the host that the container port is mapped to. This will be the port you use to access the service publicly.
hostPort=49160

#SUMMARY: The name of the cluster the service is running on.
clusterName="cheatah-slack"

#SUMMARY: The name of the service running the task.
serviceName="cheatah-slack"

#SUMMARY: the definition of the task to run the image.
task_def="[{
      \"name\": \"$taskName\",
      \"image\": \"$tagPath\",
      \"essential\": true,
      \"memory\": $taskMemory,
      \"cpu\": $taskCpu,
      \"portMappings\": [
        {
            \"containerPort\": $containerPort,
            \"hostPort\": $hostPort
        }
      ]
  }]"

#SUMMARY: Tags and pushes the image to ECR
push_image_to_ecr() {
  echo "Logging into ECR"
  eval $(aws ecr get-login --region $ecrRegion)

  echo "Pushing image $tagPath"
  docker tag $builtImageName $tagPath
  docker push $tagPath
}

#SUMMARY: Registers the task with ECS.
register_task_definition() {

    if revision=$(aws ecs register-task-definition --container-definitions "$task_def" --family $taskName | $JQ '.taskDefinition.taskDefinitionArn'); then
        echo "Revision: $revision"
    else
        echo "Failed to register task definition"
        return 1
    fi
}

#SUMMARY: updates the service to use the new image revision.
update_service() {
    if [[ $(aws ecs update-service --cluster $clusterName --service $serviceName --task-definition $revision | \
                   $JQ '.service.taskDefinition') != $revision ]]; then
        echo "Error updating service."
        return 1
    fi

    echo "Deployed!"
    return 0
}

push_image_to_ecr
register_task_definition
update_service