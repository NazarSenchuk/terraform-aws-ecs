name: Deploy to ECS

on:
  push:
    branches:
      - main
permissions:
  id-token: write   
  contents: read 
jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout repository
        uses: actions/checkout@v4

      - name: Configure AWS credentials
        uses: aws-actions/configure-aws-credentials@v4
        with:
          role-to-assume: ${role}
          role-session-name: ${session}
          aws-region: ${region}

      - name: Login to ECR (eu-central-1)
        run: |
          aws ecr get-login-password --region ${registry_region} \
          | docker login --username AWS --password-stdin ${registry}

      - name: Build, tag, and push image to Amazon ECR
        env:
          ECR_REGISTRY: $${{ steps.login-ecr.outputs.registry }}
          ECR_REPOSITORY: ${service_name}
          IMAGE_TAG: $${{ github.sha }}
        run: |
          docker build -t $ECR_REGISTRY/$ECR_REPOSITORY:$IMAGE_TAG .
          docker push $ECR_REGISTRY/$ECR_REPOSITORY:$IMAGE_TAG

      - name: Download existing task definition
        run: |
          aws ecs describe-task-definition \
            --task-definition ${task_defenition} \
            --query taskDefinition > task-definition.json

      - name: Update Amazon ECS task definition
        id: render-container
        uses: aws-actions/amazon-ecs-render-task-definition@v1
        with:
          task-definition: task-definition.json
          container-name: ${container_name}
          image: $${{ steps.login-ecr.outputs.registry }}/${service_name}:$${{ github.sha }}

      - name: Deploy Amazon ECS task definition
        uses: aws-actions/amazon-ecs-deploy-task-definition@v1
        with:
          task-definition: $${{ steps.render-container.outputs.task-definition }}
          service: ${service_name}
          cluster: ${cluster_name}
          wait-for-service-stability: true
