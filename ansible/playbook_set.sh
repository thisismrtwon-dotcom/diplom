# базовая настройка для всех хостов   +++
ansible-playbook playbook_default_settings.yaml -i inventory.yaml

# установка postgresql на все хосты   +++
ansible-playbook playbook_postgresql.yaml -i inventory.yaml

# настройка конфигурации всех кластеров postgresql
ansible-playbook playbook_postgresql_config.yaml -i inventory.yaml --tags="config_master" #  +++
ansible-playbook playbook_postgresql_config.yaml -i inventory.yaml --tags="config_replica"

# установка nginx и настройка балансировщика и MediaWiki  +++
ansible-playbook playbook_nginx.yaml -i inventory.yaml --tags="full"
ansible-playbook playbook_nginx.yaml -i inventory.yaml --tags="nginx_balancer"
ansible-playbook playbook_nginx.yaml -i inventory.yaml --tags="copy_local_settings"



# установка и настройка zabbix_agent для mediawikki и postgresql +++
ansible-playbook playbook_zabbix_agent.yaml -i inventory.yaml

# настройка backup сервера и запуск скрипта на хостах
# скрипт находится в templates/backup_script.sh
ansible-playbook playbook_backup.yaml -i inventory.yaml --tags="install_backup"
ansible-playbook playbook_backup.yaml -i inventory.yaml --tags="config_nginx_server_1"
ansible-playbook playbook_backup.yaml -i inventory.yaml --tags="config_nginx_server_2"
ansible-playbook playbook_backup.yaml -i inventory.yaml --tags="config_backup_postgresql_replica"
ansible-playbook playbook_backup.yaml -i inventory.yaml --tags="config_backup_postgresql_master"




# АВАРИЙНАЯ СМЕНА СЕРВЕРА POSTGRESQL - С MASTER НА REPLICA#

#ansible-playbook playbook_up_replica_to_master.yaml -i inventory.yaml --tags="config_replica"
#ansible-playbook playbook_up_replica_to_master.yaml -i inventory.yaml --tags="config_nginx_server_1"
#ansible-playbook playbook_up_replica_to_master.yaml -i inventory.yaml --tags="config_nginx_server_2"
