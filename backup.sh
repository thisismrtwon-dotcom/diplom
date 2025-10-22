BACKUP_IP="10.10.1.128"
BACKUP_USER="backup_user"
BACKUP_PASSWORD="qwerty"
DIRECTORY_FOR_BACKUP="/var/lib/postgresql/14/main"
PREFIX_BACKUP_FILE=$(cat /etc/hostname)
CURRENT_TIME=$(date +"%d_%m_%Y__%H-%M-%S") #текущее время в формате  день_месяц_год__час-минута-секунда
RESULT_FILENAME="$PREFIX_BACKUP_FILE"-"$CURRENT_TIME".tar.gz
DIRECTORY_FOR_SAVE_TAR=$HOME
FULL_PATH="$HOME"/"$RESULT_FILENAME"

#echo $FULL_PATH
#exit

function ping_check_backup_host { #проверка доступности хоста
   if ping -c 1 -W 2 "$BACKUP_IP" &> /dev/null; then
      echo "backup сервер $BACKUP_IP доступен"
   else
      echo "backup сервер $BACKUP_IP не доступен"
      exit
   fi
}

function create_backup_file {
   result_save_file="$HOME/$RESULT_FILENAME"
   if tar -czf $result_save_file /var/lib/postgresql/14/main/; then
      echo "архив $result_save_file" успешно создан
   else
      echo "не удалось создать архив, возможно директория не существует."
      exit
   fi
}

function send_file_to_backup_server {
   if sshpass -p "$BACKUP_PASSWORD" scp $FULL_PATH "$BACKUP_USER@$BACKUP_IP:~"; then
      echo "файл успешно сохранен на backup сервере."
   else
      echo "ошибка при передаче архива на сервер."
   fi
}

function delete_old_file {
   if rm $FULL_PATH; then
      echo "не нужный архив успешно удален"
   else
      echo "ошибка при удалении архива с данной машины"
   fi
}

function main {
  ping_check_backup_host
  create_backup_file
  send_file_to_backup_server
  delete_old_file
}

main
