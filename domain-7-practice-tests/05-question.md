# Question 5: Service Account and RBAC

Create a new Service Account named new-sa in the default namespace.
The SA should have permission to list secrets
Associate the SA with a pod named nginx-pod
Verify if the LIST operation works by using the curl command that uses the SA token within the POD