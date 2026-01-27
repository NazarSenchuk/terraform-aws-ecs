# Known Issues & Troubleshooting

This document tracks known bugs, common errors, and their workarounds.

## Known Issues

### 1. Terraform doesn't finish deployment
**Error:** `ResourceInitializationError: Unable to launch instance(s) for capacity provider ...-managed.`
- **Cause:** Due to AWS initialization of capacity providers cooldowns , terraform return error of timeout.
- **Solution:** 
  - Execute terraform provisioning again with the same configurations.
  
### 2. Deployments in progress status
**Error:** `Sometimes  , deployments  can stop on "in progress" status , there a lot of  reasons. Commonly it doesn't take more than 5 minutes.Anyway , check events inside service `


### 3. Blue/Green Deployment Target Group Conflict
**Error:** `DuplicateTargetGroupName: A target group with the same name already exists.`
- **Cause:** Terraform might try to create a new target group before the old one is deleted during a rename or migration of service type.
- **Solution:** Wrap the Target Group creation with unique suffixes or ensure `lifecycle { create_before_destroy = true }` is used (which is handled internally in most cases).

### 4. Service Connect Namespace Latency
**Potential Issue:** After deploying a new service, it might take 1-2 minutes for the Service Connect DNS name to become resolvable.
- **Cause:** Propagation delay in Service Discovery / Cloud Map.
- **Monitoring:** Check the "Service Connect" tab in the ECS Console to verify the status of the endpoints.

## Common Terraform Fixes

| Issue | fix |
|-------|-----|
| `Undeclared resource reference` | Ensure all module outputs are correctly mapped in the root `modules.tf`. |
| `Dynamic block argument error` | In `aws_lb_listener_rule`, the `condition` block structure changed in recent provider versions. Use lists for path patterns. |
| `Task stopped: Essential container in task exited` | Check CloudWatch Logs. This is usually an application-level crash or missing environment variable. |

## Troubleshooting Steps

1. **Logs**: Always check `aws_cloudwatch_log_group` logs for the specific ECS service.
2. **Task State**: Look at the "Stopped Tasks" in the ECS console for failure reasons (e.g., "OutOfMemoryError", "ImagePullBackOff").
3. **Plan Sync**: Run `terraform refresh` if your state seems out of sync with actual AWS resources.
