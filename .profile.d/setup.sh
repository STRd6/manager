apt-get install ssh -y

if [ "$PUBLIC_KEY" != "" ]
  then
    mkdir -p ~/.ssh
    chmod 700 ~/.ssh
    echo -e "$PUBLIC_KEY" > ~/.ssh/id_rsa.pub
    echo -e "$PRIVATE_KEY" > ~/.ssh/id_rsa
    chmod 700 ~/.ssh/id_rsa
fi
