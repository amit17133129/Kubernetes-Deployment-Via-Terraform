## Kubernetes Deployment Via Terraform

Kubernetes, also known as K8s, is an open-source system for automating deployment, scaling, and management of containerized applications.

It groups containers that make up an application into logical units for easy management and discovery. Kubernetes builds upon 15 years of experience of running production workloads at Google, combined with best-of-breed ideas and practices from the community.

- **Terraform** is an open-source infrastructure as code software tool that enables you to safely and predictably create, change, and improve infrastructure.

- **Terraform** is a tool for building, changing, and versioning infrastructure safely and efficiently. Terraform can manage existing and popular service providers as well as custom in-house solutions.

### The key features of Terraform are:

- **Infrastructure as Code:** Infrastructure is described using a high-level configuration syntax. This allows a blueprint of your datacenter to be versioned and treated as you would any other code. Additionally, infrastructure can be shared and re-used.

- **Execution Plans:** Terraform has a “planning” step where it generates an execution plan. The execution plan shows what Terraform will do when you call apply. This lets you avoid any surprises when Terraform manipulates infrastructure.

- **Resource Graph:** Terraform builds a graph of all your resources, and parallelizes the creation and modification of any non-dependent resources. Because of this, Terraform builds infrastructure as efficiently as possible, and operators get insight into dependencies in their infrastructure.

- **Change Automation:** Complex change sets can be applied to your infrastructure with minimal human interaction. With the previously mentioned execution plan and resource graph, you know exactly what Terraform will change and in what order, avoiding many possible human errors.

## Kubernetes Deployment Using Terraform:

In this article you will find an integration of kubernetes and terraform. The only pre-requisite for this integration is to have a k8s-cluster ready. You have to save the config file which is located at ./kube/config folder. Paste the configuration og kubernetes cluster in a file.

### Configuring k8s provider:
For integrating kubernetes with terraform you have to tell which provider you have to use. Here we are using kubernetes so we will be using kubernetes provider.

```
provider "kubernetes" {
  config_path    = "~/.kube/config"
}
```

The above provider of kubernetes requires config path of your kubernetes config file.

<p align="center">
  <img width="800" height="225" src="https://miro.medium.com/max/1400/1*fCB1eQ3hbXW38cq395sO3Q.png">
</p>

### Creating Namespace:
Now lets create a terraform file for namespaces. The below code will help you to create namespaces.

```

resource "kubernetes_namespace" "k8s_terraform" {
  metadata {
    name = "k8s-terraform-demo"
  }
}
```

The metadata block will take the name of the namespace which you wanted to create.
<p align="center">
  <img width="800" height="225" src="https://miro.medium.com/max/1400/1*RUcuLWrYGTJJxKSb6GZGSA.png">
</p>

### Creating Deployment:
Now lets create terraform code for deployment. The metadata block from the below code of deployment takes name, namespaces and respective labels.

```
resource "kubernetes_deployment" "terraform_k8s_demo" {
  metadata {
    name = "my-deploy"
    namespace = kubernetes_namespace.k8s_terraform.id
    labels = {
      test = "terraform-k8s-demo"
    }
  }

  spec {
    replicas = 3

    selector {
      match_labels = {
        test = "terraform-k8s-demo"
      }
    }

    template {
      metadata {
        labels = {
          test = "terraform-k8s-demo"
        }
      }

      spec {
        container {
          image = "nginx:1.21.6"
          name  = "con1"

          resources {
            limits = {
              cpu    = "0.5"
              memory = "512Mi"
            }
            requests = {
              cpu    = "250m"
              memory = "50Mi"
            }
          }

          liveness_probe {
            http_get {
              path = "/"
              port = 80

              http_header {
                name  = "X-Custom-Header"
                value = "Awesome"
              }
            }

            initial_delay_seconds = 3
            period_seconds        = 3
          }
        }
      }
    }
  }
}
```

The specifications needs how many replica you wanted in one deployment. The selector will matches the respective labels. Finally the template block needs the labels and its respective specifications.

The specs inside the template needs resources requirements such as memory limits, cpu limits, container name and from which you will deploy the image and finally the liveness and readiness probe.

<p align="center">
  <img width="900" height="700" src="https://miro.medium.com/max/1400/1*0rl-ldSIOTaPPA7IHmDw4g.png">
</p>

### Creating HPA (Horizontal Pod Auto Scaler):
- In Kubernetes, a HorizontalPodAutoscaler automatically updates a workload resource (such as a Deployment or StatefulSet), with the aim of automatically scaling the workload to match demand.

- Horizontal scaling means that the response to increased load is to deploy more Pods. This is different from vertical scaling, which for Kubernetes would mean assigning more resources (for example: memory or CPU) to the Pods that are already running for the workload.

- If the load decreases, and the number of Pods is above the configured minimum, the HorizontalPodAutoscaler instructs the workload resource (the Deployment, StatefulSet, or other similar resource) to scale back down.

- Horizontal pod autoscaling does not apply to objects that can’t be scaled (for example: a DaemonSet.) The below terraform code of HPA will help you to create a HPA.

```
resource "kubernetes_horizontal_pod_autoscaler" "my_hpa" {
  metadata {
    name      = "k8s-terraform-hpa"
    namespace = kubernetes_namespace.k8s_terraform.id
  }

  spec {
    max_replicas = 16
    min_replicas = 5

    target_cpu_utilization_percentage = 80

    scale_target_ref {
      api_version = "apps/v1"
      kind        = "Deployment"
      name        = "my-deploy"
    }
  }
}
```

The HPA’s metadata block requires the name and respective namespace in which you wanted to deploy the HPA.

The specifications of HPA needs maximum replicas and minimum replicas. These replicas defines that what will be the minimum and maximum pods you will need when the target utilization of cpu reached to 80 %.

Finally HPA will refer which deployment. So you have to mention the name of the deployment in scale_target_ref block.

<p align="center">
  <img width="800" height="350" src="https://miro.medium.com/max/1400/1*89Ml1yBg__GqoVxZ3_H_rA.png">
</p>

All set !! Finally we have to deploy code. First we will run terraform init.

## Terraform init:

<p align="center">
  <img width="800" height="350" src="https://miro.medium.com/max/1400/1*0D1wlJD_J2UrWxceUxsdBw.png">
</p>

<p align="center">
  <img width="800" height="360" src="https://miro.medium.com/max/1400/1*3K-nP0uhRpLm1wxfCP_03A.gif">
</p>

## Terraform Plan:

<p align="center">
  <img width="800" height="350" src="https://miro.medium.com/max/1400/1*QLJOOdtyJebV1GdafHkqyw.png">
</p>

<p align="center">
  <img width="800" height="360" src="https://miro.medium.com/max/1400/1*l8UnzSunWfaqdsTNbklgsw.gif">
</p>

## Terraform Apply:
<p align="center">
  <img width="800" height="360" src="https://miro.medium.com/max/1400/1*5ps5vjfrMz2VorXFPS32HQ.gif">
</p>

Now all the resources is deployed. In the below image you can see that the namespaces, deployments and HPA has been successfully deployed.
<p align="center">
  <img width="800" height="275" src="https://miro.medium.com/max/1400/1*l-cGmaICqWgaRcqikspIdw.png">
</p>

I hope you had liked this way of representing the article. Please like and comment for future interesting integrations 😊😊.

