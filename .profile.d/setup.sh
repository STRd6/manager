HOME=/root
# TODO: Get from other ENV variables
DOMAIN="cloudpeninsula.com"

mkdir -p $HOME

if [ "$PUBLIC_KEY" != "" ]
  then
    SSH_DIR=$HOME/.ssh
    mkdir -p $SSH_DIR
    chmod 700 $SSH_DIR
    echo -e "$PUBLIC_KEY" > $SSH_DIR/id_rsa.pub
    echo -e "$PRIVATE_KEY" > $SSH_DIR/id_rsa
    chmod 700 $SSH_DIR/id_rsa
fi

apt-get install ssh -y

cat > $SSH_DIR/config <<EOF
Host root
  HostName $DOMAIN
  IdentityFile ~/.ssh/id_rsa
EOF
