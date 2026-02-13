
# SERVEUR D’IMPRESSION AVEC QUOTAS UTILISATEURS
# Ubuntu Server / Debian
############################################################


# 1 INSTALLATION
############################

sudo apt update -y
sudo apt install -y cups cups-client cups-bsd


# 2 ACTIVER CUPS
############################

sudo systemctl enable cups
sudo systemctl start cups


# 3 AUTORISER ACCÈS RÉSEAU (VLAN ADMIN + STAFF)
############################

sudo sed -i 's/Listen localhost:631/Port 631/' /etc/cups/cupsd.conf

sudo tee -a /etc/cups/cupsd.conf <<EOF

<Location />
  Order allow,deny
  Allow 192.168.10.0/24
  Allow 192.168.20.0/24
</Location>

<Location /admin>
  AuthType Basic
  Require user @SYSTEM
  Order allow,deny
  Allow 192.168.10.0/24
</Location>
EOF

sudo systemctl restart cups


# 4 AJOUT IMPRIMANTE RÉSEAU
############################
# Exemple IP imprimante : 192.168.40.10

sudo lpadmin -p IMPRIMANTE_HP \
-E \
-v socket://192.168.40.10:9100 \
-m everywhere

sudo cupsenable IMPRIMANTE_HP
sudo cupsaccept IMPRIMANTE_HP


# 5 CRÉATION UTILISATEURS (exemple)
############################

sudo adduser user1
sudo adduser user2


# 6 ACTIVER QUOTAS
############################

# Limite : 100 pages par mois
sudo lpadmin -p IMPRIMANTE_HP \
-o job-page-limit=100 \
-o job-quota-period=2592000


# 7 ACTIVER LOGS
############################

sudo sed -i 's/LogLevel warn/LogLevel info/' /etc/cups/cupsd.conf
sudo systemctl restart cups


# 8 FIREWALL (OUVERTURE PORT 631)
############################

sudo iptables -A INPUT -p tcp --dport 631 -s 192.168.10.0/24 -j ACCEPT
sudo iptables -A INPUT -p tcp --dport 631 -s 192.168.20.0/24 -j ACCEPT
sudo netfilter-persistent save


# FIN CONFIGURATION
###################
