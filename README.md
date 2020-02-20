# Домашнее задание 12
## PAM 
* Запретить всем пользователям, кроме группы admin логин в выходные (суббота и воскресенье), без учета праздников
## Выполнение
Проверку группы буду выполнять с помощью скрипта для модуля pam_exec.so  
Условием проверяю номер дня недели, меньше 6 - код выхода 0  
(для проверки работы скрипта ставил 4, чтобы срабатывало начиная с четверга)  
в другом случае дополнительно проверяю группу  
В выводе команды "id $PAM_USER" ищу имя группы admin  
```bash
#!/bin/bash
if [[ $(date +%u) -lt 6 ]] ; then
 exit 0
elif [ "$(id $PAM_USER | grep -Eo '\badmin\b')" = "admin" ]; then
 exit 0
else
 exit 1
fi
```
В секции provision Vagrantfile разрешу вход по паролю  
Добавляю пользователей user1,2,3 и группу admin,туда добавляю vagrant, root и user1,2  
копирую скрипт и добавляю модуль pam_exec в настройки PAM  
```bash
sed -i '65s/PasswordAuthentication no/PasswordAuthentication yes/g' /etc/ssh/sshd_config
systemctl restart sshd
groupadd admin
useradd -m -s /bin/bash user1 && useradd -m -s /bin/bash user2 && useradd -m -s /bin/bash user3
gpasswd -a user1 admin && gpasswd -a user2 admin && gpasswd -a root admin && gpasswd -a vagrant admin
echo "Otus2020"| passwd --stdin user1 && echo "Otus2020" | passwd --stdin user2 && echo "Otus2020" | passwd --stdin user3
chmod +x /vagrant/login.sh
cp /vagrant/login.sh /usr/local/bin/login.sh
sed -i '/pam_nologin.so/ a\ account    required     pam_exec.so \/usr\/local\/bin\/login.sh' /etc/pam.d/sshd
```
после старта машины проверяю вход под пользователем user3, которого в группу admin не добавлял  
```bash
[root@centos7 .ssh]# ssh 192.168.12.5 -l user3
user3@192.168.12.5's password:
/usr/local/bin/login.sh failed: exit code 1
Authentication failed.
[root@centos7 .ssh]# ssh 192.168.12.5 -l vagrant
vagrant@192.168.12.5's password:
[vagrant@pam ~]$
```
```bash
Feb 20 09:42:09 localhost sshd[5596]: pam_exec(sshd:account): /usr/local/bin/login.sh failed: exit code 1
Feb 20 09:42:09 localhost sshd[5596]: Failed password for user3 from 192.168.12.1 port 36302 ssh2
Feb 20 09:42:09 localhost sshd[5596]: fatal: Access denied for user user3 by PAM account configuration [preauth]
Feb 20 09:42:14 localhost sshd[5605]: Accepted password for vagrant from 192.168.12.1 port 36304 ssh2
Feb 20 09:42:14 localhost sshd[5605]: pam_unix(sshd:session): session opened for user vagrant by (uid=0)
```
В выводе консоли и логах secure видно что скрипт отрабатывает и дает код выхода 1 для пользователя не из admin  

