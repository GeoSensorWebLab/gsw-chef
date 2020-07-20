# Terraform: Arctic Sensor Web on Amazon Web Services

Will set up on AINA's AWS account:

* `relational-database-service.tf`
    - DB Instance for SensorThings
* `elastic-compute-cloud.tf`
* `virtual-private-cloud.tf`
    - VPC for SensorThings-related servers

## Usage Instructions

Start by setting up Terraform:

```
$ terraform init
```

The run Terraform to check what changes will be made:

```
$ terraform plan
```

When satisfied with the listed changes, apply and Terraform will update AWS to match.

## Import Guide

This guide is only necessary when importing an existing AWS setup into Terraform. The guide is only for future reference/notes.

As the resources were manually created in the AWS web console, here are the steps taken to import them into Terraform configuration. Each resource must be manually imported one-by-one as there is no mass Terraform import [yet](https://github.com/hashicorp/terraform/issues/22219).

### Step 1: Create an empty resource in the TF file

Using the [Terraform AWS resources list](https://www.terraform.io/docs/providers/aws/index.html) as a reference, create one empty resource in the TF file for the one being imported.

```
resource "aws_db_instance" "frost-database-1" {}
```

In this case, we are going to import an RDS `aws_db_instance` with a custom ID of `frost-database-1`. The ID is local to Terraform only and is used when referred to by other resources in the TF file.

### Step 2: Import onto that resource an existing resource from AWS

Log into the AWS Web Console, and find the resource to be imported. It should have a definitive unique ID, which is sometimes a readable string, or a random set of characters. In this case, the database instance is also called `frost-database-1`.

Run the import command to get the existing AWS state and write it to the local Terraform state file.

```
$ terraform import aws_db_instance.frost-database-1 frost-database-1
```

### Step 3: Copy the AWS state arguments into the TF file

The resource we declared in the TF file earlier is missing the arguments and configuration to create that specific type of resource. We would not be able to run Terraform on an empty AWS account right now, as there are not enough required arguments defined.

We will copy the arguments from the AWS state that we just imported. Run the `show` command to display the AWS state, and copy out the arguments for the resource `aws_db_instance.frost-database-1`. It should look like a fully-formed Terraform resource code block. Put these arguments in the resource we added earlier in the TF file.

```
$ terraform show
```

### Step 4: Use `plan` to adjust TF file resource

Some of the information that came from the state is read-only, and we cannot actually use in the TF file. Run the `plan` command to list all the errors. If there are no errors, then **do not** apply the plan unless you want to synchronize your local TF file resource **onto** AWS in production. (We will do that later.)

```
$ terraform plan
```

When reviewing errors, the error message will refer to the **resource block** and not the actual argument that is causing the error.

If you have successfully matched the Terraform resource to the state in AWS, you should see:

```
No changes. Infrastructure is up-to-date.

This means that Terraform did not detect any differences between your
configuration and real physical resources that exist. As a result, no
actions need to be performed.
```

This is perfect. Now that this resource is configured using Terraform, we can move on to the next resource and repeat the steps. This may seem tedious, but it does provide the safest way to review the state and prevent mis-configurations.
