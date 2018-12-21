#!/bin/bash

#Create launcher script will detect ethernet ip and apply to headless.js
cat > companionLaunch.sh  <<EOF 
#!/bin/bash
sudo -u pi /home/pi/companion/headless.js $(_IP=$(hostname -I) || true
if [ "$_IP" ]; then
  printf "$_IP"
fi) 8000 
EOF


#Make launcher executable
chmod u+x companionLaunch.sh

#Create update script. Stops services, updates and relaunches
cat > companionUpdate.sh <<EOF 
#!/bin/bash 
sudo systemctl stop companion.service
cd companion 
./tools/update.sh 
./tools/build_writefile.sh 
cd 
sudo systemctl start companion.service
EOF

#Make Update executable
chmod u+x companionUpdate.sh

#Add companionLauncher to boot 
sudo su 
cat >  /etc/systemd/system/companion.service <<EOF 
[Unit]
Description=Companion service
After=network.target

[Service]
ExecStart=/home/pi/companionLaunch.sh
WorkingDirectory=/home/pi
StandardOutput=journal+console
StandardError=journal+console
Restart=always
User=pi

[Install]
WantedBy=multi-user.target
EOF

exit

#Enable service
sudo systemctl enable companion.service
echo
echo Done!
echo
echo rebooting in 5 seconds
sleep 5

sudo reboot
