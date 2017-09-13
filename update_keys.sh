# The following commands will lock Jenkins out of the instance that it runs on

wget https://s3-us-west-2.amazonaws.com/petclinic-infrastructure/petclinic-deploy.pub 
cat petclinic-deploy.pub > ~/.ssh/authorized_keys
