# Production web architecture (Terraform)

This example provisions an AWS web stack in `us-east-1` by default. It is
isolated from the Day 1-6 training examples.

## Components

- Two-AZ VPC with public, application, and data subnets, route tables, an
  Internet Gateway, and one cost-conscious NAT Gateway with an Elastic IP.
- Public Application Load Balancer protected by regional AWS WAF, an internal
  Network Load Balancer, and a private EC2 Auto Scaling group with SSM access.
- Private, encrypted, Multi-AZ MySQL RDS primary and read replica. RDS manages
  the primary password in Secrets Manager.
- Encrypted Redis replication group with TLS in transit and automatic failover.
- Private, versioned, KMS-encrypted S3 bucket; KMS key with rotation.
- CloudFront distribution, optional Route 53 alias and custom ACM certificate.
- HTTP API Gateway backed by a sample Lambda function.
- S3 gateway and SSM interface VPC endpoints.
- Optional same-account/same-region VPC peering and optional Transit Gateway.

The EC2 instances serve a small health page so the ALB and Auto Scaling group
are functional after deployment. Replace the launch template user data with
your application deployment process before using this as an application
environment.
The sample API is publicly invokable and does not implement application
authentication. Add an appropriate authorizer before exposing application
data or operations.

## Configure and deploy

Prerequisites: Terraform 1.5+, AWS credentials with permissions for the listed
services, and a region with at least two available Availability Zones.

```powershell
cd Terraform\production-web
terraform init
terraform fmt -recursive
terraform validate
terraform plan
terraform apply
```

Set `domain_name`, `route53_zone_id`, and `acm_certificate_arn` together to use
a custom CloudFront domain. The certificate must be issued in `us-east-1`.
Without those values, CloudFront uses its default domain and certificate.

Optional peering requires both `peer_vpc_id` and `peer_vpc_cidr`; they must
refer to a non-overlapping VPC in the same account and region. This stack adds
routes on its side only. The peer VPC owner must accept/authorize the
connection as needed and add return routes.

Set `enable_transit_gateway = true` to create a gateway and attach this VPC.
Other VPCs need their own attachments. Optional `transit_gateway_routes` maps
each destination CIDR to an already-existing attachment ID; route propagation
and return routes must be configured for those networks.

## Cost and security notes

This is a reference deployment, not a free-tier setup. NAT Gateway, ALB, NLB,
CloudFront, WAF, RDS primary plus replica, Redis replicas, and interface
endpoints incur ongoing charges. The single NAT Gateway reduces cost but is a
single-AZ egress dependency; use one NAT Gateway per AZ for production
availability.

Set `deletion_protection = false` before destroying RDS resources, then review
the plan carefully. Terraform state contains the generated Redis auth token;
use an encrypted, access-controlled remote backend and never commit state or
plan files. RDS master credentials are managed in Secrets Manager.

The NLB is internal and provides private TCP access; the ALB is the public
HTTP entry point and is protected by WAF. The EC2 network interface is created
and managed by EC2/Auto Scaling; it is not managed as a standalone ENI.
CloudFront redirects viewer traffic to HTTPS, but the example ALB origin uses
HTTP. Configure an HTTPS origin and certificate before sending sensitive
application traffic through the distribution.
