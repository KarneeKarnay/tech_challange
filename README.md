# Tech Challenge 
## Introduction
This document will detail the solution provided for this challenge, options I considered, decisions made and how to embellish the solution further. 

## The solution:
My solution is to use an instance to host a web server that allows users via the requests to change the sentence in the html returned. I have implemented this solution using Python, AWS EC2 and Terraform, the code for Python & Terraform available at this github repo. 

- Terraform completes setup the infrastructure on AWS
    - Create a Security Group that enables 
        - ssh access to my IP Address
        - http access to everyone.
    - Create the Instance and assign
        - Security Group.
        - SSH Key
        - User Data 
- Python covers the webserver and it’s behavior
    - Create an Asynchronous Web Server
        - Setup handling of requests
        - Change dynamic string.
- AWS to host the solution.
    - Store SSH Key. 

To apply this solution you need only do the following:

Prerequisites:
- AWS CLI Installed locally
- Terraform Installed locally
- AWS EC2 KeyPair of name tech_challange. 

Steps:
1. export AWS_ACCESS_KEY_ID=<insert your key id>
2. export AWS_SECRET_ACCESS_KEY=<insert your key>
3. terraform init
4. terraform plan 
5. terraform apply 


## Options Considered & Reasoning
For this solution I considered three options for how to go about this. These options and my reasoning behind why I choose or didn’t choose one are listed below. 

The reason I have chosen AWS for my solutions is one of comfort and time. I know AWS and while there might be better solutions on GCP or Azure, AWS would allow for my quickest solution.

I like to approach solutions by breaking them down into small chunks.There are two immediate aspects to this problem: 
- Web Server that can support dynamic content. 
- IaC process that can ensure this is repeatable. 
And two environmental aspect to it:
- This must be done quickly.
- Cost

If a solution could not comply with these three aspects then it was not suitable for the folution.  
### AWS API Gateway + Lambda + S3 and Terraform.
This solution would be that Lambda would handle the web server functionality and S3 would host a html file. The API Gateway would direct traffic to the Lambda. I would use the python runtime to handle requests to either display the page, a document hosted in S3, and/or edit the string within it.

S3 is a very light weight solution to storage which makes it a good fist to the document location. Lambda couldn’t be tasked with storage of the document or provide it each time as Lambda functions are Stateless by design.

Lambda could quite easily provide the functionality needed. Combined with the API Gateway we could set up an  ingestion point for requests, then pass that to Lambda to determine the functionality. 

Terraform lastly could be used to present this all as IaC.

The issue with this approach to me was concerns around time to set up. I have not attempted myself to write a script that could do what I would need to do with this lambda and past experience has taught me that debugging Lambdas can be painful. Considering time as a factor I choose not to use this solution.   

### AWS ALB + Fargate + Terraform
This solution would be to host the web server in a container that itself is hosted on AWS Fargate. The container image would be stored on AWS ECR, then we’d use an AWS Fargate cluster to host the service. An Application Load Balancer would be created to allow easy mapping from an external point to the internal service. 

This solution is very light weight in terms of maintenance. We don’t have to worry about EC2 instances hosting the web server, Fargate combined with ALB would enable scaling and robustness. Lastly the ECR Service would ensure our container image was protected and available to Fargate for any updates. 

The biggest problem with this solution to me was cost. Fargate is not included in AWS Free Tier and while there are cheaper options available that in turn would make more work for documenting this as IaC via Terraform. 

### AWS EC2 & Terraform
Sometimes the best solution is the simplest one. I was asked to do something I haven’t done before and do it as quickly as possible. I know EC2 and I know how to debug issues that occur on it. Terraform offers a great deal of control in provisioning EC2 Instances and User Data would allow me to setup and start the service without ever having to login to the instance. The only manual step would be the creation of the key-pair used for ssh connections to the instance. In my opinion to avoid the security risks that can come from leaked credentials, this is a safe option.

The downsides to this solution are scalability. This solution works fine right now, because only a handful of people are using it. In the future if this was a service that we would seek to up-scale we’d run into issues. There is no Load Balancer, there is no Auto-Scaling Group, there are no Health Checks and there is no multi-az.   There is also no elastic-ip either so the ip address will be lost.  

This is quick, it does provide what was requested and better yet it does it at a minimum cost to myself or anyone else that seeks to use it. 

## The better solution
Let's assume that the requirements change and you want a service that does what it currently does, but also is Highly Available, Robust and Observable.  In that case I would probably go with the first option. (AWS API Gateway + Lambda + S3 and Terraform). 

EC2 can support scalability, but that’s still extra work that needs to be handled by Terraform and there are costs associated with scaling EC2. They can be mitigated, we could look at spot or reserved instance types, but the biggest savings would be in adopting a serverless model. 

This service is lightweight, it responds within seconds, it can run within a containerised environment. Lambda seems to be a good choice. Lambda can support scaling of requests into the thousands. All the services provided are region wide, ensuring the loss of one data center wouldn’t lead to an impact to the service. 

All these services support logging, API Gateway and Lambda to CloudWatch and S3 supports its own logging. Enabling all these would give you a high degree of observability in your solution. 

All of this solution could be stored as IaC via Terraform. The main issues to watch out with this solution are the costs from increased throughout. All of these services will have charges around throughput, but should be less than the alternatives. Alternatively if the service becomes more complex it might make lambdas more difficult to manage.Instead at a certain point EKS becomes a potential option. It would have costs, but it would reduce the complexity of the service from multiple lambdas to a single container. 

 
