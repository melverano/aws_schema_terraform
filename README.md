# aws_schema_terraform
Epam aws homework.

This script brings up the infrastructure in AWS for a web application, as Wordpress took as an example. This scheme provides load balancing and high fault tolerance due to the autoscalling group and different availability zones of launch configuration, as well as data synchronization of the application itself using efs and datasync. It is assumed that the release of the application, after the CI / CD, goes to the s3 bucket, which is synchronized with the efs volume via the data sync task and the application goes to ec2.
![Untitled Workspace](https://user-images.githubusercontent.com/77063239/129718751-819757ed-fe53-483f-b020-a637415b546f.png)

Important!
auto_scaling_group.tf needs to be modified before running the script. You need to specify your ami image in which the efs mount package will be installed and configured. Otherwise, the script will not work correctly!
