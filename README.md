# Multi-Server Deployment of a Flask Banking App Using Jenkins Agents

## Overview
This document provides steps and details for deploying a Banking Flask application to AWS using Jenkins for CI/CD workflow automation. The application is deployed across multiple EC2 instances in separate availability zones to achieve high availability.

**Key components covered include:**
- Creating infrastructure as code with Terraform
- Setting up a Jenkins controller and configuring a Jenkins agent
- Building a Jenkins pipeline to automate deployments
- Deploying the application across multiple EC2 instances
- Documenting the process and architecture

The goal is to create an automated, repeatable Jenkins pipeline for deploying the Banking application to AWS. This provides hands-on experience with core DevOps practices.

## Infrastructure
The infrastructure was created using Terraform and follows the naming convention D5.1_<resource>.

**The following resources were created:**
- D5.1_VPC - VPC with 2 public subnets across 2 AZs
- D5.1_WebSG - Security group for web servers
- D5.1_AppSG - Security group for app servers
- D5.1_Jenkins - EC2 instance for Jenkins server
- D5.1_Agent - EC2 instance for Jenkins agent and first Banking app server
- D5.1_App - EC2 instance for second Banking app server

The components were deployed across two public subnets in separate AZs for high availability.

**Security groups restricted access to only necessary ports:**
- SSH on port 22
- Jenkins on port 8080
- App on port 8000

A route table was configured to allow internet access from the public subnets.

![dep5 1_img2](https://github.com/belindadunu/Deployment-5.1/assets/139175163/8cdbd19d-a5da-4fb3-a52b-c4c9ba1af2cb)

This architecture provides loose coupling between the layers, with the agents and app servers separated from the Jenkins controller. The public subnets allow inbound internet access which is required for this use case.

## Jenkins/Jenkins Agent Architecture
The Jenkins server and Jenkins agent utilize a controller-agent architecture to enable distributed builds.

**Jenkins Server**:
- Hosting the Jenkins web UI and displaying build statuses/logs
- Storing job configurations and build histories
- Scheduling jobs and assigning work to agents
- Dispatching build steps to agents
- Managing plugins, credentials, and global configurations

**Jenkins Agent**:
- Registering itself with the main Jenkins server
- Accepting and executing build jobs assigned by the controller
- Performing actual build, test, package, and deploy steps
- Communicating job results and artifacts back to the Jenkins controller
- Managing tools, dependencies, and resources required by jobs

This separation of concerns provides scalability, availability, speed, and security benefits.

## Steps
1. Created AWS infrastructure with Terraform
2. Launched EC2 instance for Jenkins and installed:
    - Jenkins
    - Python 3.7
    - Jenkins Pipeline Keep Running Step plugin
3. Launched EC2 instance for Jenkins agent and installed:
    - Python 3.7
    - Configured Jenkins agent using these [steps](https://www.jenkins.io/doc/book/using/using-agents/)
    - Configured Jenkins agent to connect to main Jenkins server
4. Created Jenkins multibranch pipeline job
5. Pushed app code to GitHub repository
6. Configured Jenkins job to pull code from GitHub
7. Jenkins job builds and deploys app to agent EC2
8. Tested app was accessible on agent
9. Created another EC2 instance for app server
10. Configured Jenkins job to deploy to app servers
11. Tested app deployed and accessible from both servers

<img width="1109" alt="Screen Shot 2023-10-21 at 8 24 28 AM" src="https://github.com/belindadunu/Deployment-5.1/assets/139175163/e153dadd-193a-4506-baf3-e61c39443b3d">

## Issues
- Instances were shutting down automatically at 9 pm daily, causing loss of unsaved work on the README.md documentation. This highlighted the need to commit changes more frequently.
- Was initially unable to SSH into the agents due to not using the correct key pair. Verified the key pair being used matched the one specified in the Terraform build.

## Optimization
Some ways to improve efficiency, resilience, and portability:
- Use autoscaling groups for Jenkins, agents, and app servers to allow dynamic scaling
- Add a load balancer to distribute traffic across multiple app servers
- Dockerize key components like the app, database, and Jenkins for simplified portability
- Place the database servers and Jenkins controller in private subnets, restricting direct external access
- Leverage Ansible for automating deployments across multiple servers and configurations

By placing backend components like the database and Jenkins into private subnets, we can limit exposure while maintaining internet access to the application. Combined with automation tools like Terraform, Ansible, and Docker, this architecture can provide a scalable, secure, and robust deployment.

## Conclusion
This project demonstrated core DevOps practices by implementing a full CI/CD pipeline for a multi-server architecture. Key takeaways include learning how to automate deployments with Jenkins, create repeatable infrastructure as code, and deploy applications across availability zones for high availability. The result is an automated, robust process for continuously building, testing, and deploying this Banking application.

![Dep5 1](https://github.com/belindadunu/Deployment-5.1/assets/139175163/8867e408-4a25-47ae-83a2-cf911f07a936)
