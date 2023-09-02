# Question 3: Auditing

Create an Audit Policy with the following configuration

1. Log all namespace events at RequestResponse
2. Log all PODS events at Request.
3. No configmaps related events should be logged.
4. All other events should be stored at metadata level.
5. There should be maximum log files of 3.
6. Policy configuration should be available at /etc/kubernetes/audit-policy.yaml
7. Logs should be stored in a /var/log/audit.log