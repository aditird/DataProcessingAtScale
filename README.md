
This file details the steps performed to install Zookeeper, Kafka and Neo4j.

1. Start docker desktop

2. Start minikube by running command
minikube start

3. Apply the yaml file properties for Zookeeper and Kafka
kubectl apply -f zookeeper-setup.yaml
kubectl apply -f kafka-setup.yaml

3a. Expose a port for Kafka to be accessible from localhost
kubectl port-forward <kafka pod name> 9092

3b. minikube tunnel  # Port conflict with 3a if done before 3a

4. To monitor deployments via dashboard
minikube dashboard

5. Verifications
5a. To get the pods that are running
kubectl get pods

5b. To get the services that are running
kubectl get services
or
kubectl get svc

5c. To see log of errored pod (if there are any errors)
kubectl logs <podname> -p
example below
kubectl logs kafka-service-84bf74d956-xv299 -p

6. To stop minikube (do this at the end after all testing)
minikube stop



