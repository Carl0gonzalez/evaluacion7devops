resource "aws_codedeploy_app" "porttrack" {
  name = "PortTrackCodeDeployApp"
  compute_platform = "ECS"
}

resource "aws_codedeploy_deployment_group" "porttrack" {
  app_name               = aws_codedeploy_app.porttrack.name
  deployment_group_name  = "porttrack-bluegreen-group"
  service_role_arn       = aws_iam_role.eks_cluster_role.arn
  deployment_config_name = "CodeDeployDefault.ECSAllAtOnce"

  auto_rollback_configuration {
    enabled = true
    events  = ["DEPLOYMENT_FAILURE"]
  }

  blue_green_deployment_config {
    deployment_ready_option {
      action_on_timeout = "STOP_DEPLOYMENT"
      wait_time_in_minutes = 30
    }
    terminate_blue_instances_on_deployment_success {
      action = "TERMINATE"
      wait_time_in_minutes = 5
    }
  }
}