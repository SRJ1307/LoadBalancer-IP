
# Deploying a Load Balancer and Managing Scalesets(NIC)

 Hello Everyone, here we will learn, how to deploy a load balancer and manage the behind scale sets using the IP of scale sets.

First thing first, we need a Scalset.
Let's create it.
1. Open the Azure Portal and search for "Virtual Machine Scale Set".
2. Click on the Create option. 
3. In the resource group click Create New and name it "vmss".
4. Choose the region as "EastUS".
5. Leave the Availability zone as it is.
6. "In Orchestration mode" choose uniform. (Since we will be creating VMs with the same config and image, if you want VMs with different images and config you can choose Flexible).
7. Choose the image as "Ubuntu Server 20.4 LTS- X64 Gen 2".
8. Choose size as "Standard_B1s -1 vcpu".
9. Choose authentication type as password and set your user name and password.
10. Skip the next two sections spot and disks and move to Networking.
11. Here if you want to use your own v-net if you have any, you can choose that, otherwise you can create a new one. I am creating a new one. Also, make sure the load balancing option is disabled.
12. Move to the next section i.e. scaling. Make the initial instance count as 1.
13. Choose the scaling policy as custom, as soon you choose it, an option related to it will get enabled.
14. Set the following options: Please refer attached screenshot: Scale out means increase the no of VMS and scale in means decrease the no of VMs.
15. Next is the management section, here choose Upgrade Mode as "Automatic".
16. In the Health section check "Enable application health monitoring".
17. In the advanced section under custom data paste this script:
   #!/bin/bash
      sudo apt-get update
      sudo apt-get install -y nginx
      echo "Hello World from $(hostname -f)" > /var/www/html/index.html
18.  Now review + create it.
    
<img width="340" alt="image" src="https://github.com/SRJ1307/LoadBalancer-IP/assets/157812379/df15493b-6036-42b8-bc75-6a967a0f2abf">
<img width="617" alt="image" src="https://github.com/SRJ1307/LoadBalancer-IP/assets/157812379/ff147af1-d874-4e09-8bab-e6d8f5316462">
<img width="785" alt="image" src="https://github.com/SRJ1307/LoadBalancer-IP/assets/157812379/2ddddacf-e489-4c7c-81a9-0d8b5fbaafa1">
<img width="739" alt="image" src="https://github.com/SRJ1307/LoadBalancer-IP/assets/157812379/1ab3f95d-8e85-4280-994e-579849ffef0c">

Now, Since our scale set is created, we need a load balancer to handle all the traffic coming to it.
Let's create one.
  1. Search for Load Balancer in Azure and click on create.
  2. Choose you resource group.
  3. Give load balancer a name, I have given lb3, since I have already other 2 presents.
  4. Set type as "Public" and tier as "Regional".
  5. Next is the frontendip configuration, create a new frontend ip(see attached image).
  6. Next is backend pool, since we have created an ip to access now we need to attach our scaleset to load-balancer, for this we use the backendpool property of load balancer. Click on "+ Add a backendpool".
  7. Give a name to backendpool and choose the  Virtual network associated with your scaleset.
  8. Now for inbound rules, refer to the attached image and follow to create a load balancing rule and health probe.
  9. Now review + create it.
  10. Now we need to add the approval for coming requests, in Azure by default it is off.
  11. Search for network security group in azure. Open the related nsg to load-balancer.
  12. Inside the nsg on the left pane select "inbound security rules".
  13. Now click on + Add, and a new pane will pop up, inside under services choose Http, by default it is custom. Click on save/Add after choosing Http.
  14. Now go to the load-balancer that you created, Inside that on the left pane choose "Frontend IP configuration", now copy the IP and search for this in a new tab.
  15. You will get your results. The custom data which we added while creating the scale set, will tell you the host name.


<img width="755" alt="image" src="https://github.com/SRJ1307/LoadBalancer-IP/assets/157812379/b3dd852a-2a3c-403a-a976-151c2c702a13">
<img width="1259" alt="image" src="https://github.com/SRJ1307/LoadBalancer-IP/assets/157812379/1157aee2-7f11-4a45-b39a-4b8766a4f2ea">
<img width="1253" alt="image" src="https://github.com/SRJ1307/LoadBalancer-IP/assets/157812379/824213e4-6cfa-4f09-aa05-f1544e071dcd">
<img width="1255" alt="image" src="https://github.com/SRJ1307/LoadBalancer-IP/assets/157812379/504af63d-a765-4534-86f0-ed3a7799b7aa">
<img width="1249" alt="image" src="https://github.com/SRJ1307/LoadBalancer-IP/assets/157812379/0f35104c-f4cd-44a2-a750-deccac5695f3">
<img width="1240" alt="image" src="https://github.com/SRJ1307/LoadBalancer-IP/assets/157812379/5d3a78f2-8d30-44e9-abd2-0228f4eeb4bc">
<img width="1199" alt="image" src="https://github.com/SRJ1307/LoadBalancer-IP/assets/157812379/c594b4da-0594-4353-898a-800ba88fb8b8">

Congratulations, you have successfully deployed a scaleset. Now to test that it successfully works we will ahve to deploy a bastion and put some stress through it.
Let's do this. Let's check if our instances really increases or not if we put some stress on it.

1. Go to scale set which you created for this.
2. In the left hand side search for instances. If you select instances, you will see that only one instance is available currently which is supposed to increase on load.
3. Open the instance which you see currently.
4. You wil see connect option, click on that, a drop-down will come up, choose bastion from there. A new window will come, from there click Deploy Bastion.
5. Be patient, it will take some time to deploy.
6. Once it gets deployed, it will ask for username and password, use the creds that you used while creating the scaleset.

One important thing here, we have created scaleset vms, and deployed load balancer also to connect to it, but to put some stress on it and make it really useful we need to provide internet to it.
First let's check if it has internet on it or not?
To-Do this use command "sudo apt-get update" This command updates the current repository through internet.
When you will run this command you will see that, it will stuck at 0 % and it will give some error. That is currently our VM/Scalset has no internet connection.
So Let's provide internet connection to it.
  1. Search for NAT Gateways in Azure and create one.
  2. Choose resource group and give a name to nat gateway. Make sure to keep the same resource group as VN and Load balancer(In my case i have deployed everything to EastUS).
  3. In Outbound IP section under Public IP create  a new IP.
  4. Under subnet section choose the vnet relate to you scaleset and loadbalancer.
  5. Now review + create it.
  6. Once the deployment is complete, got to bastion and run the same " sudo apt-get update " command this time repository will get updated.
  7. Now we need to give some stress to our VMs, for this we will use stress module of linux.
  8. Run command " sudo apt-get install stress ". This will install the module.
  9. To give stress to CPU use command " stress --cpu 4 ".
  10. Wait for 5 minutes or it may take more depending on the time which you set while setting the scaling rule in scaleset while ceating it.
  11. Go to scaleset which you created and search for instances, now you will see more than 2 or 3 instances as per load instead of one.
  12. You can verify this from the browser also where you had opened the IP from load balancer.



<img width="1251" alt="image" src="https://github.com/SRJ1307/LoadBalancer-IP/assets/157812379/ec309e50-d9ed-4f48-9ce8-5e447ecb1a12">
<img width="1050" alt="image" src="https://github.com/SRJ1307/LoadBalancer-IP/assets/157812379/24dd5815-a8d5-4b97-889b-0580c66c5167">
<img width="1232" alt="image" src="https://github.com/SRJ1307/LoadBalancer-IP/assets/157812379/9a7ba9ac-a1d0-4d19-a0e4-2139cfd0d748">
<img width="557" alt="image" src="https://github.com/SRJ1307/LoadBalancer-IP/assets/157812379/6edd3c1f-d464-4487-96b2-ceef40e23865">
<img width="562" alt="image" src="https://github.com/SRJ1307/LoadBalancer-IP/assets/157812379/6ea19da8-dde0-4d73-9397-57db23abdf8c">
<img width="638" alt="image" src="https://github.com/SRJ1307/LoadBalancer-IP/assets/157812379/4027f0c3-4034-4099-b5ca-44a08ad36687">
More than one instance, it will keep increasing as the load increases.
<img width="1252" alt="image" src="https://github.com/SRJ1307/LoadBalancer-IP/assets/157812379/1c55d135-a226-4624-9906-e6fa70686642">

Happy learning.















