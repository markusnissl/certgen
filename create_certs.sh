DOMAIN_NAME=$1
echo ""
echo ""


ROOTCADIR="./certs/root"
if [ -d "$DIR" ]; then
  echo "Root CA found. Generting root CA skipped."
else
  echo "Root CA not found, creating Root CA"
  mkdir $ROOTCADIR
  
  openssl genrsa -out $ROOTCADIR/rootCA.key 4096
  openssl req -x509 -new -nodes -key $ROOTCADIR/rootCA.key -sha256 -days 1024 -out $ROOTCADIR/rootCA.crt -subj "/C=AT/ST=Vienna/L=Vienna/O=Acme/CN=AcmeAuthority (self-signed)"
  
  echo "Requesting to updating keystore with created rootCA, you can also add the rootCA later"
  if [[ $OSTYPE == 'darwin'* ]]; then
    echo "sudo security add-trusted-cert -d -r trustRoot -k /Library/Keychains/System.keychain $ROOTCADIR/rootCA.crt"
    sudo security add-trusted-cert -d -r trustRoot -k /Library/Keychains/System.keychain $ROOTCADIR/rootCA.crt
  elif [[ $OSTYPE == 'linux'* ]]; then
    echo "cp $ROOTCADIR/cert.crt /usr/local/share/ca-certificates/rootCA.crt && update-ca-certificates"
  fi
  echo ""
  echo ""
fi

echo ""
echo "Creating certifiacte for $DOMAIN_NAME and *.$DOMAIN_NAME"
echo ""
DIR="./certs/$DOMAIN_NAME"

if [ -d "$DIR" ]; then
  echo "Directory for domain already found."
  read -p "Do you want to continue? " -n 1 -r
  echo ""
  
  if [[ ! $REPLY =~ ^[Yy]$ ]]
  then
    [[ "$0" = "$BASH_SOURCE" ]] && exit 1 || return 1 # handle exits from shell or function but don't exit interactive shell
  fi

  rm -R $DIR
fi

mkdir $DIR

envsubst < cert.conf.template > cert.conf

openssl genrsa -out $DIR/cert.key 2048
openssl req -new -key $DIR/cert.key -subj "/C=AT/ST=Vienna/L=Vienna/O=Acme/CN=${DOMAIN_NAME}/" -config cert.conf -out $DIR/cert.csr
openssl x509 -req -extensions v3_req -in $DIR/cert.csr -CA $ROOTCADIR/rootCA.crt -CAkey $ROOTCADIR/rootCA.key -CAcreateserial -CAserial $ROOTCADIR/serial.srl -out $DIR/cert.crt -days 500 -sha256 -extfile cert.conf

